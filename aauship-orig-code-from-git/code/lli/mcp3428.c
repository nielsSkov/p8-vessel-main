/** 
 *  @defgroup sensor MCP3428
 *  @code #include <mcp3428.h> @endcode
 * 
 *  @brief MCP3428 interface functions
 *
 *  This is used to measure the battery voltage on the main packs
 *
 *  @author Nick Østergaard nickoe@es.aau.dk
 */
#include <stdio.h>
#include "i2cmaster.h"
#include "mcp3428.h"

uint8_t mcp_general_call_reset(uint8_t bank) {
  uint8_t s = 0;                     // status indicator
  s = i2c_start(bank+I2C_WRITE);     // set device address and write mode
  i2c_write(0x06);                   // issue general call reset (see datasheet for magic number)
  i2c_stop();                        // set stop conditon = release bus
  return s;
}

int16_t mcp_read(uint8_t bank, uint8_t ch) {
  uint8_t s = 0;                     // status indicator
  uint8_t adcupper = 0;              // upper byte
  uint8_t adclower = 0;              // lower byte

  // Config
  // PGA = 1, Resolution = 16 bits (15 SPS), Conversion mode = One shot
  s = i2c_start(bank+I2C_WRITE);
  if (s == 0) i2c_write(0b10000100 | ch << 5);         // See page 18 in the MCP3428 datasheet

  // MCP3428 read data addr
  s = i2c_start(bank+I2C_READ);      // set adc address for reading
  if (s == 0) {                      // this prevents the following in blocking execution
    adcupper = i2c_readAck();        // read 2nd byte (upper data byte)
    adclower = i2c_readNak();        // read 3rd byte (lower data byte)
    i2c_stop();                      // set stop conditon = release bus
  }

  return (adcupper << 8 | adclower);
}

