Low Level Interface (LLI)
=========================

The LLI consists of a AVR microcontroller in the form of an easy available
Arduino type board.

Use `make` to compile and `make install` to upload it onto the AVR. Use `make test` to compile a helloworld example that just blinks with a led. (Not implemented yet)

You can also generate Doxygen documentaiton with `make doc`.

Some other random notes
-----------------------
Compile a source file:
`avr-gcc main.c -I. -g -DF_CPU=16000000 -mmcu=atmega328p -Os -o blink.elf`

Make the hex file to be uploaded:
`avr-objcopy -O ihex -R .eeprom blink.elf blink.hex`

Program (upload) with the optiboot bootloader installed:
`avrdude -p m328p -P /dev/ttyACM0 -c arduino -b 115200 -U flash:w:blink.hex`

Program (upload) with the ISP:
`avrdude -p m328p -c usbasp -U flash:w:blink.hex`

Source files
------------
`lli.c` is the main file

`faps_parse.{c,h}` recieve data 

`faps_process.{c,h}` handle data and command logic

`config.h` is the configuration file for the device

`adis16405.{c,h}` is functions to work with the IMU

`pwm.{c,h}` is functions to set the PWM outputs

`uart.{c,h}` is the derivative work by David A. Mellis from the original Peter Fleury UART library under GPL. http://beaststwo.org/avr-uart/index.shtml

`i2cmaster.{S,h} is from Peter Fleyru I2C library under GPS. http://homepage.hispeed.ch/peterfleury/avr-software.html

`spi.{c,h}` is from Pascal Stang's avrlib, no license is specified, seems like public domain. http://www.procyonengineering.com/embedded/avr/avrlib/
