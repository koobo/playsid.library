;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
 ifnd __VASM
TEST = 1
 endif

 ifd TEST
 	incdir	include:
 	include	exec/types.i
 	include	exec/libraries.i
 	

	STRUCTURE PlaySidBase,0
	STRUCT	psb_LibNode,LIB_SIZE
	UBYTE	psb_Flags
	UBYTE	psb_Pad
	APTR	psb_SysLib
	APTR	psb_SegList

	UWORD	psb_PlayMode
	UWORD	psb_TimeSeconds
	UWORD	psb_TimeMinutes
	APTR	psb_DisplayData

	APTR	psb_SongLocation
	UWORD	psb_SongLength
	UWORD	psb_SongStart
	UWORD	psb_SongInit
	UWORD	psb_SongMain
	UWORD	psb_SongNumber
	UWORD	psb_SongDefault
	ULONG	psb_SongSpeedMask
	UWORD	psb_SongFlags

	UWORD	psb_SongTune
	UWORD	psb_SongSpeed
	UWORD	psb_SongLoop

	UWORD	psb_VertFreq
	UWORD	psb_TimeEnable
	APTR	psb_TimeSignalTask
	ULONG	psb_TimeSignalMask
	UWORD	psb_DisplayEnable
	APTR	psb_DisplaySignalTask
	ULONG	psb_DisplaySignalMask
	UWORD	psb_ReverseEnable
	UWORD	psb_EmulResourceFlag
	UWORD	psb_SongSetFlag
	STRUCT	psb_ChannelEnable,8

	APTR	psb_VolumePointer
	STRUCT	psb_VolumePointers,64
	UWORD	psb_IntVecAudFlag
	APTR	psb_OldIntVecAud0
	APTR	psb_OldIntVecAud1
	APTR	psb_OldIntVecAud2
	APTR	psb_OldIntVecAud3
	UWORD	psb_TimerAFlag
	UWORD	psb_TimerBFlag
	APTR	psb_CalcFTable
	APTR	psb_SIDSampleNoise
	APTR	psb_SIDSampleTri
	APTR	psb_SIDSampleSaw
	APTR	psb_SIDSamplePulse
	APTR	psb_SIDSampleTPul
	APTR	psb_SIDSampleTSaw
	APTR	psb_SIDSampleFree
	APTR	psb_SIDSampleFour
	APTR	psb_SIDSampleFConv
	APTR	psb_FourMemList
	APTR	psb_SoundRemPars
	APTR	psb_PlayBackPars
	UWORD	psb_TimerConstA
	UWORD	psb_TimerConstB
	UWORD	psb_TimerConst50Hz
	UWORD	psb_ConvClockConst
	UWORD	psb_ConvFourConst
	UWORD	psb_CPUVersion
	UWORD	psb_OldC64TimerA
	UWORD	psb_NewFreq
	UWORD	psb_LastNoise
	UWORD	psb_PulseOffset
	UWORD	psb_UpdateFreq
	UWORD	psb_UpdateCounter
	UWORD	psb_RememberMode
	APTR	psb_Enve1
	APTR	psb_Enve2
	APTR	psb_Enve3
	APTR	psb_Chan1
	APTR	psb_Chan2
	APTR	psb_Chan3
	APTR	psb_Chan4
	APTR	psb_AttDecRelStep
	APTR	psb_VolumeTable
	APTR	psb_AttackDecay
	APTR	psb_SustainRelease
	APTR	psb_SustainTable
	APTR	psb_AttackTable
	APTR	psb_PrgMem
	APTR	psb_MMUMem
	APTR	psb_C64Mem
	APTR	psb_EnvelopeMem
	APTR	psb_SampleMem
	UWORD	psb_AudioDevice
	APTR	psb_AudioIO
	APTR	psb_AudioMP
	UBYTE	psb_FilterType ; SID filter type
	UBYTE	psb_FilterFreq ; SID filter frequency (upper 8 bits)
	UBYTE	psb_FilterResonance ; SID Filter resonance (0..15)
	UBYTE   psd_pad1
	ULONG	psb_FilterAmpl ; IIR filter input attenuation
	ULONG	psb_FilterD1 ; IIR filter coefficients
	ULONG	psb_FilterD2 ; IIR filter coefficients
	ULONG	psb_FilterG1 ; IIR filter coefficients
	ULONG	psb_FilterG2 ; IIR filter coefficients
	LABEL	psb_SIZEOF

; ========================================================================;
; === Channel ============================================================;
; ========================================================================;

	STRUCTURE	Channel,0
	APTR	ch_ProgPointer
	APTR	ch_SamAdrOld
	APTR	ch_SamAdrNew
	ULONG	ch_SamLenDec
	ULONG	ch_SamLenHDec
	ULONG	ch_SamIndStart
	ULONG	ch_SamIndStop
	ULONG	ch_SyncLenOld
	ULONG	ch_SyncLenNew
	UWORD	ch_Freq64Old
	UWORD	ch_Freq64New
	UWORD	ch_SamPer
	UWORD	ch_SamLen
	UWORD	ch_SamPerOld
	UWORD	ch_SamPerNew
	UWORD	ch_SamLenOld
	UWORD	ch_SamLenNew
	UBYTE	ch_SyncIndOld
	UBYTE	ch_SyncIndNew
	UBYTE	ch_WaveOld
	UBYTE	ch_WaveNew
	UBYTE	ch_AudIRQType		;See Type list below
	UBYTE	ch_RSyncToggle
	; True if filter is enabled for this channel
	UBYTE   ch_FilterEnabled
	UBYTE   ch_pad
	; IIR filter previous input/output signal for this channel
	ULONG	ch_Xn1
	ULONG	ch_Xn2
	ULONG	ch_Yn1
	ULONG	ch_Yn2
	; Filtered output will be written here
	APTR	ch_FilterOutputBufferA
	APTR	ch_FilterOutputBufferB
	LABEL	ch_SIZEOF


;res lp 0: 227.755005
;res hp 0: 366.373993
;res lp 1: 225.977203
;res hp 1: 352.971130
;res lp 17: 209.062042
;res hp 17: 298.289459

;res lp 18: 209.745911
;res hp 18: 304.587799

;res lp 19: 210.754669
;res hp 19: 311.997467
;res lp 255: 53927.351562
;res hp 255: 21424.048828

;Module Name: Terra Cresta
;Author     : Martin Galway
;Copyright  : 1986 Imagine
;
;calc_filter:
; fr: 209.745911
; arg: 0.010000
; f_type: 1
; f_freq: 18
; f_res: 15
; f_ampl: 0.005172
; d1: 2.000000
; d2: 1.000000
; g1: -1.717430
; g2: 0.738120
; ob.freq: 44100

main
	lea	_PlaySidBase,a6
    	move.l	#ch1,psb_Chan1(a6)    
    	move.l	#ch2,psb_Chan2(a6)    
    	move.l	#ch3,psb_Chan3(a6)    
    	jsr	initializeFilter

        move.b  #1,psb_FilterType(a6)
    	move.b  #15,psb_FilterResonance(a6)
    	move.b  #18,psb_FilterFreq(a6)
    	jsr     calcFilter

	fmove.s	fr,fp0
	fmul.s	#1000,fp0
	fmove.l	fp0,d0

	fmove.s	arg,fp0
	fmul.s	#1000,fp0
	fmove.l	fp0,d1

	fmove.s	psb_FilterAmpl(a6),fp0
	fmul.s	#1000,fp0
	fmove.l	fp0,d2

	fmove.s	psb_FilterD1(a6),fp1
	fmul.s	#1000,fp1
	fmove.l	fp1,d3

	fmove.s	psb_FilterD2(a6),fp2
	fmul.s	#1000,fp2
	fmove.l	fp2,d4

	fmove.s	psb_FilterG1(a6),fp3
	fmul.s	#1000,fp3
	fmove.l	fp3,d5

	fmove.s	psb_FilterG2(a6),fp4
	fmul.s	#1000,fp4
	fmove.l	fp4,d6
    	rts

    section testData,bss
_PlaySidBase	ds.b    psb_SIZEOF
ch1		ds.b	ch_SIZEOF
ch2		ds.b	ch_SIZEOF
ch3		ds.b	ch_SIZEOF
fr		ds.l	1
arg		ds.l	1
 endif ; TEST 


    section filterCode,code

            rsreset
FILT_NONE   rs.b       1
FILT_LP     rs.b       1
FILT_BP     rs.b       1
FILT_LPBP   rs.b       1
FILT_HP     rs.b       1
FILT_NOTCH  rs.b       1
FILT_HPBP   rs.b       1
FILT_ALL    rs.b       1

ffreq_lp    ds.l    256 ; Low-pass resonance frequency table
ffreq_hp    ds.l    256 ; High-pass resonance frequency table

* in:
*   fp0 = f
* out:
*   fp0 = lp
calcResonanceLp:
    ; 227.755 - 1.7635 * f - 0.0176385 * f * f + 0.00333484 * f * f * f;
    fmove   fp0,fp1 
    fmul    fp0,fp1 * f^2
    fmove   fp1,fp2
    fmul    fp0,fp2 * f^3
    fmul.s  #0.00333484,fp2
    fmul.s  #-0.0176385,fp1
    fmul.s  #-1.7635,fp0
    fadd    fp2,fp0
    fadd    fp1,fp0
    fadd.s  #227.755,fp0
    rts

* in:
*   fp0 = f
* out:
*   fp0 = hp
calcResonanceHp:
    ; 366.374 - 14.0052 * f + 0.603212 * f * f - 0.000880196 * f * f * f;
    fmove   fp0,fp1 
    fmul    fp0,fp1 * f^2
    fmove   fp1,fp2
    fmul    fp0,fp2 * f^3
    fmul.s  #-0.000880196,fp2
    fmul.s  #0.603212,fp1
    fmul.s  #-14.0052,fp0
    fadd    fp2,fp0
    fadd    fp1,fp0
    fadd.s  #366.374,fp0
    rts

* in:
*    a6 = PlaySidBase
resetFilterVariables:
    move.b  #FILT_NONE,psb_FilterType(a6)
    clr.b   psb_FilterFreq(a6)
    clr.b   psb_FilterResonance(a6)
    bsr     calcFilter
    rts

* in:
*    a6 = PlaySidBase
resetChannelFilterStates:
    fmovecr  #$f,fp0 * zero constant
    move.l	psb_Chan1(a6),a2
	fmove.s	fp0,ch_Xn1(a2)
	fmove.s	fp0,ch_Xn2(a2)
	fmove.s	fp0,ch_Yn1(a2)
	fmove.s	fp0,ch_Yn2(a2)
	move.l	psb_Chan2(a6),a2
	fmove.s	fp0,ch_Xn1(a2)
	fmove.s	fp0,ch_Xn2(a2)
	fmove.s	fp0,ch_Yn1(a2)
	fmove.s	fp0,ch_Yn2(a2)
	move.l	psb_Chan3(a6),a2
	fmove.s	fp0,ch_Xn1(a2)
	fmove.s	fp0,ch_Xn2(a2)
	fmove.s	fp0,ch_Yn1(a2)
	fmove.s	fp0,ch_Yn2(a2)
    rts

* in:
*    a6 = PlaySidBase
calcFilter:
    printt  "TODO: verify calculation results"
    tst.b   psb_FilterEnabled(a6)
    bne.b   .yes
    rts
.yes
    movem.l d0-d2/a0,-(sp)
    ;move    #$ff0,$dff180
    bsr.b   .do
    ;move    #$000,$dff180
    movem.l (sp)+,d0-d2/a0
    rts
.do
    * Usage: d0,d1,a0,fp0-fp7

    move.b  psb_FilterType(a6),d0

;	if (f_type == FILT_NONE) {
;		f_ampl = F_ZERO;
;		d1 = d2 = g1 = g2 = F_ZERO;
;		return;
;	}
    cmp.b     #FILT_NONE,d0
    bne     .some
    fmovecr  #$f,fp0 * zero constant
    fmove.s  fp0,psb_FilterAmpl(a6)
    fmove.s  fp0,psb_FilterD1(a6)
    fmove.s  fp0,psb_FilterD2(a6)
    fmove.s  fp0,psb_FilterG1(a6)
    fmove.s  fp0,psb_FilterG2(a6)
    rts
.some
    * Calculate resonance frequency
    * fr in fp0
    fmovecr  #$f,fp0 * zero constant
 
;	filt_t fr;
;	if (f_type == FILT_LP || f_type == FILT_LPBP)
;		fr = ffreq_lp[f_freq];
;	else
;		fr = ffreq_hp[f_freq];

    cmp.b     #FILT_LP,d0
    beq     .lpbp
    cmp.b     #FILT_LPBP,d0
    beq.b   .lpbp

    lea     ffreq_hp(pc),a0
    moveq   #0,d1
    move.b  psb_FilterFreq(a6),d1
    fmove.s (a0,d1.w*4),fp0
    bra.b   .1
.lpbp
    lea     ffreq_lp(pc),a0
    moveq   #0,d1
    move.b  psb_FilterFreq(a6),d1
    fmove.s (a0,d1.w*4),fp0
.1
    * fp0 = fr
 ifd TEST
    fmove.s fp0,fr
 endif
 
    * Limit to <1/2 sample frequency, avoid div by 0 in case FILT_NOTCH below
; 	filt_t arg = fr / float(obtained.freq >> 1);
;	if (arg > 0.99)
;		arg = 0.99;
;	if (arg < 0.01)
;		arg = 0.01;

    fmove   fp0,fp1 
    ; This should represent the actual sample rate,
    ; it is constant in this case.
    fdiv.s  #44100/2,fp1  
   ; fdiv.s  #44100/2,fp1  
    fcmp.s  #0.99,fp1
    fble    .2
    fmove.s #0.99,fp1
.2  fcmp.s  #0.01,fp1
    fbge    .3
    fmove.s #0.01,fp1
.3
    * fp1 = arg

 ifd TEST
    fmove.s fp1,arg
 endif
    
	; Calculate poles (resonance frequency and resonance)
	; The (complex) poles are at
	;   zp_1/2 = (-g1 +/- sqrt(g1^2 - 4*g2)) / 2
    ;g2 = 0.55 + 1.2 * arg * arg - 1.2 * arg + float(f_res) * 0.0133333333;

    fmove.b  psb_FilterResonance(a6),fp4
    fmul.s   #0.0133333333,fp4
    fmove   fp1,fp2  * arg
    fmove   fp1,fp3
    fmul    fp1,fp3  * arg^2
    fmul.s  #-1.2,fp2
    fmul.s  #1.2,fp3
    fadd    fp4,fp2
    fadd    fp3,fp2
    fadd.s  #0.55,fp2
    * fp2 = g2

	;g1 = -2.0 * sqrt(g2) * cos(M_PI * arg);
    fmovecr #0,fp3 * constant: PI
    fmul    fp1,fp3 
    fcos    fp3
    fmove.s fp3,d2 * store this for later: cos(M_PI * arg)
    fmove   fp2,fp4
    fsqrt   fp4
    fmul    fp4,fp3
    fmul.s  #-2.0,fp3
    * fp3 = g1

    fmove   fp1,fp0
    fmove   fp3,fp1
    * fp0 = arg
    * fp1 = g1
    * fp2 = g2
    

    ; Increase resonance if LP/HP combined with BP
    ;if (f_type == FILT_LPBP || f_type == FILT_HPBP)
	;	g2 += 0.1;
    cmp.b   #FILT_LPBP,d0
    beq     .inc
    cmp.b   #FILT_HPBP,d0
    bne     .noInc
.inc
    fadd.s  #0.1,fp2
.noInc

    ; Stabilize filter
  	;if (fabs(g1) >= g2 + 1.0) {
	;	if (g1 > 0.0)
	;		g1 = g2 + 0.99;
	;	else
	;		g1 = -(g2 + 0.99);
	;}
    fmove   fp1,fp4
    fabs    fp4
    fsub.s  #1.0,fp4
    ;fcmp    fp4,fp2
    ;fbge    .noStab
    fcmp    fp2,fp4
    fblt    .noStab
    ftst    fp1
    fble    .4
    fmove   fp2,fp1
    fadd.s  #0.99,fp1
    bra     .noStab
.4
    fmove   fp2,fp1
    fadd.s   #0.99,fp1
    fneg    fp1
.noStab

    fmove.s fp1,psb_FilterG1(a6)
    fmove.s fp2,psb_FilterG2(a6)

	; Calculate roots (filter characteristic) and input attenuation
	; The (complex) roots are at
	;   z0_1/2 = (-d1 +/- sqrt(d1^2 - 4*d2)) / 2
    cmp.b #FILT_LPBP,d0
    beq .f_lpbp
    cmp.b #FILT_LP,d0
    beq .f_lpbp
 
    cmp.b #FILT_HPBP,d0
    beq .f_hpbp
    cmp.b #FILT_HP,d0
    beq .f_hpbp
 
    cmp.b #FILT_BP,d0
    beq .f_bp

    cmp.b #FILT_NOTCH,d0
    beq  .f_notch

    cmp.b #FILT_ALL,d0
    beq   .f_all
    rts

    * fp0 = arg
    * fp1 = g1
    * fp2 = g2

.f_lpbp
   ;move    #$f00,$dff180
 
 	;case FILT_LPBP:
	;case FILT_LP:		// Both roots at -1, H(1)=1
	;	d1 = 2.0; d2 = 1.0;
	;	f_ampl = 0.25 * (1.0 + g1 + g2);
	;	break;
    fmove.s #2.0,fp4
    fmove.s fp4,psb_FilterD1(a6)
    ;fmove.s #1.0,fp4
    fmovecr  #$32,fp4 * constant: 1
    fmove.s fp4,psb_FilterD2(a6)
    fadd    fp1,fp4
    fadd    fp2,fp4
    fmul.s  #0.25,fp4
    fmove.s fp4,psb_FilterAmpl(a6)

    ; terra cresta
    rts

.f_hpbp
   ; move    #$0f0,$dff180
 
    ;case FILT_HPBP:
	;case FILT_HP:		// Both roots at 1, H(-1)=1
	;	d1 = -2.0; d2 = 1.0;
	;	f_ampl = 0.25 * (1.0 - g1 + g2);
	;	break;
    fmove.s #-2.0,fp4
    fmove.s fp4,psb_FilterD1(a6)
    ;fmove.s #1.0,fp4
    fmovecr  #$32,fp4 * constant: 1
    fmove.s fp4,psb_FilterD2(a6)
    fsub    fp1,fp4
    fadd    fp2,fp4
    fmul.s  #0.25,fp4
    fmove.s fp4,psb_FilterAmpl(a6)
    rts

    * fp0 = arg
    * fp1 = g1
    * fp2 = g2

.f_bp
    ;move    #$00f,$dff180
 
    ;case FILT_BP: {		// Roots at +1 and -1, H_max=1
	;	d1 = 0.0; d2 = -1.0;
	;	float c = sqrt(g2*g2 + 2.0*g2 - g1*g1 + 1.0);
	;	f_ampl = 0.25 * (-2.0*g2*g2 - (4.0+2.0*c)*g2 - 2.0*c + (c+2.0)*g1*g1 - 2.0) 
    ;                     / (-g2*g2 - (c+2.0)*g2 - c + g1*g1 - 1.0);
	;	break;
	;	}
    fmove.s #0,fp4
    fmove.s fp4,psb_FilterD1(a6)
    fmove.s #-1.0,fp4
    fmove.s fp4,psb_FilterD2(a6)

    fmove  fp2,fp4
    fmul   fp4,fp4
    fadd   fp2,fp4
    fadd   fp2,fp4
    fmove  fp1,fp5
    fmul   fp5,fp5
    fsub   fp5,fp4
    fadd.s #1.0,fp4
    fsqrt  fp4
    * fp4 = c
    
    fmove   fp2,fp5
    fmul    fp5,fp5 
    fneg    fp5
    * fp5 = -g2*g2

    fmove   fp4,fp6
    fadd.s  #2.0,fp6
    fmul    fp2,fp6
    * fp6 = (c+2)*g2

    fsub    fp6,fp5
    fsub    fp4,fp5
    fsub.s  #1.0,fp5

    fmove   fp1,fp6
    fmul    fp6,fp6
    fadd    fp6,fp5
    * fp5 = divisor

    ; -2.0*g2*g2 
    fmove   fp1,fp6
    fmul    fp6,fp6
    fmul.s  #-2.0,fp6

    ;- (4.0+2.0*c)*g2 
    fmove   fp4,fp7
    fadd    fp4,fp7
    fadd.s  #4.0,fp7
    fmul    fp2,fp7
    fsub    fp7,fp6

    ;- 2.0*c
    fsub    fp4,fp6
    fsub    fp4,fp6

    ;(c+2.0)*g1*g1 
    fmove   fp1,fp7
    fmul    fp7,fp7
    fmove   fp4,fp3
    fadd.s  #2.0,fp3
    fmul    fp3,fp7
    fadd    fp7,fp6

    ; - 2.0)
    fsub.s  #2.0,fp6

    fdiv    fp5,fp6
    fmul.s  #0.25,fp6

    fmove.s fp6,psb_FilterAmpl(a6)
    rts

    * fp0 = arg
    * fp1 = g1
    * fp2 = g2

.f_notch
    ;move    #$f0f,$dff180
 
    ;case FILT_NOTCH:	// Roots at exp(i*pi*arg) and exp(-i*pi*arg), H(1)=1 (arg>=0.5) or H(-1)=1 (arg<0.5)
	;	d1 = -2.0 * cos(M_PI * arg); d2 = 1.0;
	;	if (arg >= 0.5)
	;		f_ampl = 0.5 * (1.0 + g1 + g2) / (1.0 - cos(M_PI * arg));
	;	else
	;		f_ampl = 0.5 * (1.0 - g1 + g2) / (1.0 + cos(M_PI * arg));
	;	break;


    ;fmovecr #0,fp3 * constant: PI
    ;fmul    fp0,fp3 
    ;fcos    fp3  
    * fp3 = cos(M_PI * arg)
    fmove.s  d2,fp3 * calculated earlier
    fmove   fp3,fp4
    fmul.s  #-2.0,fp4
    fmove.s fp4,psb_FilterD1(a6)

    ;fmove.s  #1.0,fp4
    fmovecr  #$32,fp4 * constant: 1
    fmove.s fp4,psb_FilterD2(a6)

    fcmp.s  #0.5,fp0
    fblt    .low1

    ;fmove.s  #1.0,fp4
    fmovecr  #$32,fp4 * constant: 1
    fadd    fp1,fp4
    fadd    fp2,fp4
    ;fmove.s  #1.0,fp5
    fmovecr  #$32,fp5 * constant: 1
    fsub    fp3,fp5
    fdiv    fp5,fp4
    fmul.s  #0.5,fp4
    fmove.s fp4,psb_FilterAmpl(a6)
    rts
.low1
    ;fmove.s  #1.0,fp4
    fmovecr  #$32,fp4 * constant: 1
    fsub    fp1,fp4
    fadd    fp2,fp4
    ;fmove.s  #1.0,fp5
    fmovecr  #$32,fp5 * constant: 1
    fadd    fp3,fp5
    fdiv    fp5,fp4
    fmul.s  #0.5,fp4
    fmove.s fp4,psb_FilterAmpl(a6)
    rts

    * fp0 = arg
    * fp1 = g1
    * fp2 = g2

.f_all 
    ;move    #$ff0,$dff180
 
    ;// The following is pure guesswork...
	;case FILT_ALL:		// Roots at 2*exp(i*pi*arg) and 2*exp(-i*pi*arg), H(-1)=1 (arg>=0.5) or H(1)=1 (arg<0.5)
	;	d1 = -4.0 * cos(M_PI * arg); d2 = 4.0;
	;	if (arg >= 0.5)
	;		f_ampl = (1.0 - g1 + g2) / (5.0 + 4.0 * cos(M_PI * arg));
	;	else
	;		f_ampl = (1.0 + g1 + g2) / (5.0 - 4.0 * cos(M_PI * arg));
	;	break;
  
    ;fmovecr #0,fp3 * constant: PI
    ;fmul    fp0,fp3 
    ;fcos    fp3  
    * fp3 = cos(M_PI * arg)
    fmove.s  d2,fp3 * calculated earlier
    fmove    fp3,fp4
    fmul.s   #-4.0,fp4
    fmove.s  fp4,psb_FilterD1(a6)

    fmove.s  #4.0,fp4  * could use constant $32
    fmove.s fp4,psb_FilterD2(a6)

    fcmp.s  #0.5,fp0
    fblt    .low1

    ;fmove.s #1.0,fp4
    fmovecr  #$32,fp4 * constant: 1
    fsub    fp1,fp4
    fadd    fp2,fp4
    fmove.s #5.0,fp5
    fmul.s  #4.0,fp3
    fadd    fp3,fp5
    fdiv    fp5,fp4
    fmul.s  #0.5,fp4
    fmove.s fp4,psb_FilterAmpl(a6)
    rts

.low2
    ;fmove.s #1.0,fp4
    fmovecr  #$32,fp4 * constant: 1
    fadd    fp1,fp4
    fadd    fp2,fp4
    fmove.s #5.0,fp5
    fmul.s  #4.0,fp3
    fsub    fp3,fp5
    fdiv    fp5,fp4
    fmul.s  #0.5,fp4
    fmove.s fp4,psb_FilterAmpl(a6)
    rts
    

* PAL clock = 3546895
* playback frequency in Hz: freq=clock/period
* frequency to period:      period=clock/freq


* in:
*   d0 = sample data address
*   d1 = sample data length, bytes
*   a1 = ch structure
* out:
*   ch_FilterOutputBuffer(a1) = output filtered data
filterChannel:
    movem.l d0-a6,-(sp) 
    ;move    #$0ff,$dff180
    move.l	_PlaySidBase,a6
    move    ch_SamPerOld(a1),ch_FilterOutputPeriod(a1)
    move    d1,d2
    lsr     #1,d2
    move    d2,ch_FilterOutputLength(a1)

    ; Double buffering
    move.l  ch_FilterOutputBufferA(a1),a2
    move.l  ch_FilterOutputBufferB(a1),a3
    move.l  a3,ch_FilterOutputBufferA(a1)
    move.l  a2,ch_FilterOutputBufferB(a1)

 
    subq    #1,d1
    move.l  d0,a0
.loop
    move.b  (a0)+,d0
    bsr.b   filter
    move.b  d0,(a2)+
    dbf     d1,.loop
    movem.l (sp)+,d0-a6
    ;clr     $dff180
    rts


* in:
*   d0 = input byte
*   a1 = ch structure
*   a6 = PlaySidBase
* out:
*   d0 = fitered output byte
filter:
  
    ; fp0 = xn
    ; fp1 = yn

    ; this assumes a 16-bit input?

    ;float xn = float(sum_output_filter_left) * sid.f_ampl;	
 
    ;ext.w   d0
    ;asl.w   #7,d0
    ;fmove.w  d0,fp0
    fmove.b  d0,fp0

    fmul.s   psb_FilterAmpl(a6),fp0

    ;float yn = xn + sid.d1 * sid.xn1_l 
    ;              + sid.d2 * sid.xn2_l 
    ;              - sid.g1 * sid.yn1_l 
    ;              - sid.g2 * sid.yn2_l;
    ;sum_output_filter_left = int32(yn);
    ;sid.yn2_l = sid.yn1_l; 
    ;sid.yn1_l = yn; 
    ;sid.xn2_l = sid.xn1_l;
    ;sid.xn1_l = xn;
   
    ; yn = xn + sid.d1 * sid.xn1_l
    fmove.s  ch_Xn1(a1),fp1
    fmul.s   psb_FilterD1(a6),fp1
    fadd     fp0,fp1
    
    ;  + sid.d2 * sid.xn2_l 
    fmove.s  ch_Xn2(a1),fp2
    fmul.s   psb_FilterD2(a6),fp2
    fadd     fp2,fp1
    
    ; - sid.g1 * sid.yn1_l
    fmove.s  ch_Yn1(a1),fp2
    fmul.s   psb_FilterG1(a6),fp2
    fsub     fp2,fp1
    
    ;- sid.g2 * sid.yn2_l;
    fmove.s  ch_Yn2(a1),fp2
    fmul.s   psb_FilterG2(a6),fp2
    fsub     fp2,fp1

    * Keep two previous values
    move.l   ch_Xn1(a1),ch_Xn2(a1)
    fmove.s  fp0,ch_Xn1(a1)

    move.l   ch_Yn1(a1),ch_Yn2(a1)
    fmove.s  fp1,ch_Yn1(a1)

    ;fmove.w fp1,d0
    ;asr.w   #8,d0
    fmove.b  fp1,d0
    rts


initializeFilter:
    moveq  #0,d0
    lea     ffreq_lp(pc),a0
    lea     ffreq_hp(pc),a1
.loop
    fmove.l d0,fp0
    bsr     calcResonanceLp
    fmove.s fp0,(a0)+
    fmove.l d0,fp0
    bsr     calcResonanceHp
    fmove.s fp0,(a1)+

    addq    #1,d0
    cmp     #256,d0
    bne.b   .loop    
    rts
