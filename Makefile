INCLUDE ?= -I $(VBCC)/m68k-amigaos/ndk-include/
VBCC ?= /opt/amiga
VASM ?= $(VBCC)/bin/vasmm68k_mot
VASM_FLAGS := -Fhunkexe -kick1hunks -quiet -m68030 -m68881 -nosym -showcrit -no-opt $(INCLUDE)

SOURCE   := playsid.asm 
INCLUDES := playsid_libdefs.i external.asm filter.s

TARGET   := playsid.library
LISTFILE := playsid.txt

.PHONY: all clean

all: $(TARGET)

clean:
	rm $(TARGET) $(LISTFILE)

$(TARGET) : $(SOURCE) $(INCLUDES) Makefile
	$(VASM) $< -o $@ -L $(LISTFILE) $(VASM_FLAGS)
