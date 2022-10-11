#include <stdio.h>
#include <stdlib.h>
#include <proto/exec.h>
#include <proto/poseidon.h>
#include <exec/alerts.h>

#include "sidblast.h"

#define SysBase (*(struct ExecBase **) (4L))

struct Buffer
{
    uint16_t    pending;
    uint8_t     data[8192];
};

struct SIDBlasterUSB
{
    struct PsdDevice*   device;

    struct Task*        ctrlTask;
    struct Task*        mainTask;

    struct Library*     psdLibrary;
    struct MsgPort*     msgPort;
    struct PsdPipe*     inPipe;
    struct PsdPipe*     outPipe;

    uint16_t            inBufferNum;
    uint16_t            outBufferNum;

    struct Buffer       inBuffers[2];
    struct Buffer       outBuffers[2];

    uint32_t            deviceLost;
};

static struct SIDBlasterUSB* usb = NULL;

static void SIDTask();
static void writePacket(uint8_t* packet, uint16_t length);
static uint8_t readResult();
static uint32_t deviceUnplugged(register struct Hook *hook __asm("a0"), register APTR object __asm("a2"), register APTR message __asm("a1"));
static const struct Hook hook = { .h_Entry = (HOOKFUNC)deviceUnplugged };

uint8_t sid_init()
{
    if (usb)
        return usb != NULL;

    struct Library* PsdBase;
    if(!(PsdBase = OpenLibrary("poseidon.library", 1)))
        return FALSE;

    usb = psdAllocVec(sizeof(struct SIDBlasterUSB));

    if (!usb)
    {
        CloseLibrary(PsdBase);
        return FALSE;
    }

    usb->ctrlTask = FindTask(NULL);
    if (psdSpawnSubTask("SIDTask", SIDTask, usb))
    {
        Wait(SIGF_SINGLE);
    }
    usb->ctrlTask = NULL;

    if (usb->mainTask)
    {
        psdAddErrorMsg(RETURN_OK, "SIDBlasterUSB", "Time to rock some 8-bit!");
    }
    else
    {
        psdAddErrorMsg(RETURN_ERROR, "SIDBlasterUSB", "Failed to acquire ancient hardware!");
        sid_exit();
    }

    CloseLibrary(PsdBase);
    PsdBase = NULL;

    return usb != NULL;
}

void sid_exit()
{
    if (!usb)
        return;

    if(usb->mainTask)
    {
        // reset SID output
        sid_write_reg(0x00, 0x00);  // freq voice 1
        sid_write_reg(0x01, 0x00);
        sid_write_reg(0x07, 0x00);  // freq voice 2
        sid_write_reg(0x08, 0x00);
        sid_write_reg(0x0e, 0x00);  // freq voice 3
        sid_write_reg(0x0f, 0x00);
    }

    struct Library* PsdBase;
    if((PsdBase = OpenLibrary("poseidon.library", 1)))
    {
        usb->ctrlTask = FindTask(NULL);

        Forbid();
        if(usb->mainTask)
        {
            Signal(usb->mainTask, SIGBREAKF_CTRL_C);
        }
        Permit();

        while(usb->mainTask)
        {
            Wait(SIGF_SINGLE);
        }
        usb->ctrlTask = NULL;

        psdFreeVec(usb);
        usb = NULL;

        CloseLibrary(PsdBase);
        PsdBase = NULL;
    }
}

uint8_t sid_read_reg(register uint8_t reg __asm("d0"))
{
    if (!(usb && !usb->deviceLost))
        return 0x00;

    usb->ctrlTask = FindTask(NULL);

    uint8_t buf[] = { 0xa0 + reg };
    writePacket(buf, sizeof(buf));
    Signal(usb->mainTask, SIGBREAKF_CTRL_D);

    Wait(SIGBREAKF_CTRL_D);
    usb->ctrlTask = NULL;

    return readResult();
}

void sid_write_reg(register uint8_t reg __asm("d0"), register uint8_t value __asm("d1"))
{
    if (!(usb && !usb->deviceLost))
        return;

    uint8_t buf[] = { 0xe0 + reg, value };
    writePacket(buf, sizeof(buf));
    Signal(usb->mainTask, SIGBREAKF_CTRL_D);
}


/*-------------------------------------------------------*/


#define PsdBase usb->psdLibrary

static uint8_t AllocSID(struct SIDBlasterUSB* usb);
static void FreeSID(struct SIDBlasterUSB* usb);

static void SIDTask()
{
    struct Task* currentTask = FindTask(NULL);
    struct SIDBlasterUSB* usb = currentTask->tc_UserData;

    if(!(PsdBase = OpenLibrary("poseidon.library", 1)))
    {
        Alert(AG_OpenLib);
    }
    else if (AllocSID(usb))
    {
        usb->mainTask = currentTask;

        Forbid();
        if(usb->ctrlTask)
        {
            Signal(usb->ctrlTask, SIGF_SINGLE);
        }
        Permit();

        uint32_t signals;
        uint32_t sigMask = (1L << usb->msgPort->mp_SigBit) | SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_D;

        uint8_t result[3];
        psdSendPipe(usb->inPipe, result, sizeof(result));
        do
        {
            signals = Wait(sigMask);

            struct PsdPipe* pipe;
            while((pipe = (struct PsdPipe *) GetMsg(usb->msgPort)))
            {  
                if (pipe != usb->inPipe)
                    continue;

                uint32_t ioerr;
                if((ioerr = psdGetPipeError(pipe)))
                {
                    if (usb->deviceLost)
                        break;
                    psdDelayMS(20);
                }
                else
                {
                    uint32_t actual = psdGetPipeActual(pipe);
                    if (actual > 2)
                    {
                        uint8_t res = result[2];

                        Disable();
                        struct Buffer* buffer = &usb->inBuffers[usb->inBufferNum];
                        if (sizeof(buffer->data) - 1 > buffer->pending)
                        {
                            buffer->data[buffer->pending] = res;
                            buffer->pending += 1;
                            if (usb->ctrlTask)
                            {
                                Signal(usb->ctrlTask, SIGBREAKF_CTRL_D);
                            }
                        }
                        Enable();
                    }
                }

                psdSendPipe(usb->inPipe, result, sizeof(result));
            }

            if (signals & SIGBREAKF_CTRL_D)
            {
                Disable();
                struct Buffer* buffer = &usb->outBuffers[usb->outBufferNum];
                usb->outBufferNum ^= 1;
                usb->outBuffers[usb->outBufferNum].pending = 0;
                Enable();

                if (buffer->pending)
                    psdDoPipe(usb->outPipe, buffer->data, buffer->pending);
            }

        } while(!(signals & SIGBREAKF_CTRL_C));
    }

    FreeSID(usb);

    Forbid();
    usb->mainTask = NULL;
    if(usb->ctrlTask)
    {
        Signal(usb->ctrlTask, SIGF_SINGLE);
    }
}

static uint8_t AllocSID(struct SIDBlasterUSB* usb)
{
    // Find SIDBlasterUSB
    {
        psdLockReadPBase();

        APTR pab = NULL;

        APTR pd = NULL;
        while(pd = psdFindDevice(pd, 
                                DA_VendorID, 0x0403,
                                DA_ProductID, 0x6001,
                                DA_Manufacturer, (ULONG)"Devsound",
                                DA_Binding, (ULONG)NULL,
                                TAG_END))
        {
            psdLockReadDevice(pd);

            const char* product;
            psdGetAttrs(PGA_DEVICE, pd,
                        DA_ProductName, (ULONG)&product,
                        TAG_END);

            pab = psdClaimAppBinding(ABA_Device, (ULONG)pd,
                                ABA_ReleaseHook, (ULONG)&hook,
                                ABA_UserData, (ULONG)usb);

            psdUnlockDevice(pd);

            if (pab)
                break;
        }

        psdUnlockPBase();

        if (!pd)
            return FALSE;

        usb->device = pd;
    }

    if (!(usb->msgPort = CreateMsgPort()))
        return FALSE;

    // Init SIDBlasterUSB (based on wireshark'd USB sniffing)
    {
        enum FTDI_Request
        {
            FTDI_Reset          = 0x00,
            FTDI_ModemCtrl      = 0x01,
            FTDI_SetFlowCtrl    = 0x02,
            FTDI_SetBaudRate    = 0x03,
            FTDI_SetData        = 0x04,
            FTDI_GetModemStat   = 0x05,
            FTDI_SetLatTimer    = 0x09,
            FTDI_GetLatTimer    = 0x0A,
            FTDI_ReadEEPROM     = 0x90,
        };

        enum FTDI_ResetType
        {
            FTDI_Reset_PurgeRXTX = 0,
            FTDI_Reset_PurgeRX,
            FTDI_Reset_PurgeTX
        };

        uint8_t recvBuffer[64];
        struct PsdPipe* ep0pipe = psdAllocPipe(usb->device, usb->msgPort, NULL);
        if (!ep0pipe)
            return FALSE;

        psdPipeSetup(ep0pipe, URTF_IN|URTF_VENDOR, FTDI_GetLatTimer, 0x00, 0x00);
        psdDoPipe(ep0pipe, recvBuffer, 1);

        psdPipeSetup(ep0pipe, URTF_VENDOR, FTDI_SetLatTimer, 0x10, 0x00);
        psdDoPipe(ep0pipe, NULL, 0);

        psdPipeSetup(ep0pipe, URTF_IN|URTF_VENDOR, FTDI_GetLatTimer, 0x00, 0x00);
        psdDoPipe(ep0pipe, recvBuffer, 1);

        psdPipeSetup(ep0pipe, URTF_IN|URTF_VENDOR, FTDI_ReadEEPROM, 0x00, 0x0a);
        psdDoPipe(ep0pipe, recvBuffer, 2);

        psdPipeSetup(ep0pipe, URTF_VENDOR, FTDI_Reset, FTDI_Reset_PurgeRXTX, 0x00);
        psdDoPipe(ep0pipe, NULL, 0);
        for (int i = 0; i < 6; ++i) {
            psdPipeSetup(ep0pipe, URTF_VENDOR, FTDI_Reset, FTDI_Reset_PurgeRX, 0x00);
            psdDoPipe(ep0pipe, NULL, 0);
        }
        psdPipeSetup(ep0pipe, URTF_VENDOR, FTDI_Reset, FTDI_Reset_PurgeTX, 0x00);
        psdDoPipe(ep0pipe, NULL, 0);

        psdPipeSetup(ep0pipe, URTF_IN|URTF_VENDOR, FTDI_GetModemStat, 0x00, 0x00);
        psdDoPipe(ep0pipe, recvBuffer, 2);

        psdPipeSetup(ep0pipe, URTF_IN|URTF_VENDOR, FTDI_GetLatTimer, 0x00, 0x00);
        psdDoPipe(ep0pipe, recvBuffer, 1);

        psdPipeSetup(ep0pipe, URTF_VENDOR, FTDI_SetBaudRate, 0x06, 0x00);
        psdDoPipe(ep0pipe, NULL, 0);

        psdPipeSetup(ep0pipe, URTF_VENDOR, FTDI_SetData, 0x08, 0x00);
        psdDoPipe(ep0pipe, NULL, 0);

        psdFreePipe(ep0pipe);
    }

    // Allocate in/out pipes
    {
        struct PsdInterface* interface = psdFindInterface(usb->device, NULL, TAG_END);
        if (!interface)
            return FALSE;

        struct PsdEndpoint* epIn = psdFindEndpoint(interface, NULL,
                                                   EA_IsIn, TRUE,
                                                   EA_TransferType, USEAF_BULK,
                                                   TAG_END);
        if (!epIn)
            return FALSE;

        struct PsdEndpoint* epOut = psdFindEndpoint(interface, NULL,
                                                   EA_IsIn, FALSE,
                                                   EA_TransferType, USEAF_BULK,
                                                   TAG_END);
        if (!epOut)
            return FALSE;

        if (!(usb->inPipe = psdAllocPipe(usb->device, usb->msgPort, epIn)))
            return FALSE;
        if (!(usb->outPipe = psdAllocPipe(usb->device, usb->msgPort, epOut)))
            return FALSE;
    }

    return TRUE;
}

static void FreeSID(struct SIDBlasterUSB* usb)
{
    if (usb->inPipe)
    {
        psdAbortPipe(usb->inPipe);
        psdWaitPipe(usb->inPipe);
        psdFreePipe(usb->inPipe);
        usb->inPipe = NULL;
    }

    if (usb->outPipe)
    {
        psdAbortPipe(usb->outPipe);
        psdWaitPipe(usb->outPipe);
        psdFreePipe(usb->outPipe);
        usb->outPipe = NULL;
    }

    if (usb->msgPort)
    {
        DeleteMsgPort(usb->msgPort);
        usb->msgPort = NULL;
    }

    if (usb->device)
    {
        struct PsdAppBinding* appBinding = NULL;
        psdGetAttrs(PGA_DEVICE, usb->device,
                    DA_Binding, (ULONG)&appBinding,
                    TAG_END);
        psdReleaseAppBinding(appBinding);
        usb->device = NULL;
    }

    if (usb->psdLibrary)
    {
        CloseLibrary(usb->psdLibrary);
        usb->psdLibrary = NULL;
    }
}

static uint32_t deviceUnplugged(register struct Hook *hook __asm("a0"), register APTR object __asm("a2"), register APTR message __asm("a1"))
{
    struct SIDBlasterUSB* usb = (struct SIDBlasterUSB*)message;

    usb->deviceLost = TRUE;

    if (usb->outPipe)
        psdAbortPipe(usb->outPipe);

    Forbid();
    if(usb->mainTask)
    {
        Signal(usb->mainTask, SIGBREAKF_CTRL_C);

        psdAddErrorMsg(RETURN_OK, "SIDBlasterUSB", "End of an era");
    }
    Permit();

    return 0;
}

static void writePacket(uint8_t* packet, uint16_t length)
{
    while(TRUE)
    {
        Disable();

        struct Buffer* buffer = &usb->outBuffers[usb->outBufferNum];
        if ((sizeof(buffer->data) - length) < buffer->pending)
        {
            // not enough space, retry
            Enable();
            continue;
        }

        uint8_t* dest = &buffer->data[buffer->pending];
        CopyMem(packet, dest, length);
        buffer->pending += length;

        Enable();
        break;
    }
}

static uint8_t readResult()
{
    while(TRUE)
    {
        Disable();

        struct Buffer* buffer = &usb->inBuffers[usb->inBufferNum];
        if (buffer->pending < 1)
        {
            // not enough data, retry
            Enable();
            continue;
        }

        uint8_t result = buffer->data[0];
        buffer->pending = 0;
        usb->inBufferNum ^= 1;
        usb->inBuffers[usb->inBufferNum].pending = 0;

        Enable();

        return result;
    }
}
