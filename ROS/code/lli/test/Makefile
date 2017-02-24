# Makefile for the LLI

# This makefile is based on the Teacup fimware makefile under the license
# 	GNU General Public License

# Change these to suit your hardware    
#MCU_TARGET = atmega328p
MCU_TARGET = atmega2560

# CPU clock rate
F_CPU = 16000000UL
#F_CPU = 20000000L

# Programmer settings for "make program"
AVRDUDE = avrdude
AVRDUDECONF = /etc/avrdude.conf

# Programmer port
PROGPORT = /dev/ttyACM0
#PROGPORT = /dev/ttyUSB0

# Programmer baud rate
#
# This depends on the bootloader (or programmer) in use.
# Examples:
#
# Arduino Diecimilia with genuine bootloader:        19200
# Optiboot                                 					 115200
#
# Set PROGBAUD to 0 (Zero) for programmers.
PROGBAUD = 115200
#PROGBAUD = 0

# Firmware upload device type.
#PROGID = stk500v1
PROGID = stk500v2 # Default bootloader for arduino mega 2560
#PROGID = arduino # Used with optiboot bootloader
#PROGID = avr910
#PROGID = usbasp

PROGRAM = test_uart

# Stuff below this line should probably not be edited!
SOURCES = $(PROGRAM).c \
uart.c 
ARCH = avr-
CC = $(ARCH)gcc
OBJDUMP = $(ARCH)objdump
OBJCOPY = $(ARCH)objcopy

GITCOMMIT= -D'__GIT_COMMIT__="$(shell git rev-parse HEAD)"'
CFLAGS=$(GITCOMMIT) -I. $(INC) -g -DF_CPU=$(F_CPU) -mmcu=$(MCU_TARGET) -Os		
LDFLAGS = -Wl,--as-needed -Wl,--gc-sections
LIBS = -lm

ifeq ($(PROGBAUD),0)
PROGBAUD_FLAG =
else
PROGBAUD_FLAG = -b$(PROGBAUD)
endif

OBJ = $(patsubst %.c,%.o,${SOURCES})
.SUFFIXES: .c .cc .cpp .C .o .out .s .S .hex .ee.hex .h .hh .hpp
.PHONY: all program clean size doc bootloader

all: $(PROGRAM).hex $(PROGRAM).lst $(PROGRAM).sym size

program: $(PROGRAM).hex
	@echo ""
	@echo "UPLOADING"
	$(AVRDUDE) -c$(PROGID) $(PROGBAUD_FLAG) -p$(MCU_TARGET) -P$(PROGPORT) -F -U flash:w:$^

clean:
	rm -rf *.o *.elf *.lst *.map *.sym *.lss *.eep *.srec *.bin *.hex *.al *.i *.s *~ doc

bootloader:
	@echo "* * * Implement this with optiboot! * * *"

doc: Doxyfile *.c *.h
	doxygen $<

%.o: %.c Makefile
	@echo "  CC        $@"
	@$(CC) -c $(CFLAGS) -o $@ $(subst .o,.c,$@)

%.elf: $(OBJ)
	@echo "  LINK      $@"
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

%.lst: %.elf
	@echo "  OBJDUMP   $@"
	@$(OBJDUMP) -h -S $< > $@

%.hex: %.elf
	@echo "  OBJCOPY   $@"
	@$(OBJCOPY) -j .text -j .data -O ihex -R .eeprom -R .fuse -R .lock $< $@

%.bin: %.elf
	@echo "  OBJCOPY   $@"
	@$(OBJCOPY) -j .text -j .data -O binary $< $@

%.sym: %.elf
	@echo "  SYM       $@"
	@$(OBJDUMP) -t $< | perl -ne 'BEGIN { printf "  ADDR  NAME                  SIZE\n"; } /([0-9a-f]+)\s+(\w+)\s+O\s+\.(bss|data)\s+([0-9a-f]+)\s+(\w+)/ && printf "0x%04x  %-20s +%d\n", eval("0x$$1") & 0xFFFF, $$5, eval("0x$$4")' | sort -k1 > $@

size: $(PROGRAM).elf
	@echo "    SIZES             ATmega...  '168    '328(P)    '644(P)    '1280"
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(text)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    FLASH : %5d bytes          %3d%%      %3d%%       %3d%%      %3d%%\n", $$a, ceil($$a * 100 / (14 * 1024)), ceil($$a * 100 / (30 * 1024)),ceil($$a * 100 / (62 * 1024)), ceil($$a * 100 / (126 * 1024)) }' 
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(data|bss)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    RAM   : %5d bytes          %3d%%      %3d%%       %3d%%      %3d%%\n", $$a, ceil($$a * 100 / (1 * 1024)), ceil($$a * 100 / (2 * 1024)),ceil($$a * 100 / (4 * 1024)), ceil($$a * 100 / (8 * 1024)) }'
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(eeprom)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    EEPROM: %5d bytes          %3d%%      %3d%%       %3d%%      %3d%%\n", $$a, ceil($$a * 100 / (1 * 1024)), ceil($$a * 100 / (2 * 1024)), ceil($$a * 100 / (2 * 1024)), ceil($$a * 100 / (4 * 1024)) }'


