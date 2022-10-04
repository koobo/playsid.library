INCLUDE = -I$(HOME)/A/Asm/Include 
INCLUDE ?= -I $(VBCC)/m68k-amigaos/ndk-include/
VBCC ?= /opt/amiga
VASM ?= $(VBCC)/bin/vasmm68k_mot
VASM_FLAGS := -Fhunkexe -kick1hunks -quiet -m68030 -m68881 -nosym -showcrit -no-opt $(INCLUDE)

SOURCE   := playsid.asm 
INCLUDES := playsid_libdefs.i external.asm filter.s filter_parameters.bin

TARGET   := playsid.library
LISTFILE := playsid.txt

.PHONY: all clean

all: $(TARGET)

clean:
	rm $(TARGET) $(LISTFILE)

$(TARGET) : $(SOURCE) $(INCLUDES) Makefile
	$(VASM) $< -o $@ -L $(LISTFILE) $(VASM_FLAGS)
	cp $@ ~/H/

filter_parameters.bin: generate_filter_params.py
	python $< >/tmp/$@
	$(VASM) -Fbin /tmp/$@ -o $@ 
	