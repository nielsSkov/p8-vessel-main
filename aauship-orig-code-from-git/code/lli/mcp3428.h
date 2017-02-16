#ifndef MCP3428_H
#define MCP3428_H
/**
 * @file
 * @defgroup sensor MCP3428
 * @code #include <mcp3428.h> @endcode
 * @author Nick Østergaard nickoe@es.aau.dk
 *
 * @brief MCP3428 interface functions
 * @section DESCRIPTION
 * This is the header file for the MCP3428 interface used for
 * the battery monitor (BM).
 */

/**@{*/

#define MCP3428addr 0xD0  // General ADC address
#define BANK1       0xD8  // Starboard connector
#define BANK2       0xD4  // Port connector
#define CH1         0x00  // Channel 1
#define CH2         0x01  // Channel 2
#define CH3         0x02  // Channel 3
#define CH4         0x03  // Channel 4
//#define SPS          240  // 12 bits 1 mV/LSB
#define SPS           60  // 14 bits 250 μV/LSB
//#define SPS           15  // 16 bits 62.5 μV/LSB
#define CT          1000/SPS // Conversion time

/* Function prototypes */

/**
 @brief MCP3428 general call reset

 Used to manually make a power on reset, strictly not nessesary, but it probably
 good to do after i2c initialization.

 @param   bank (BANK1 or BANK2)
 @retval  0 device accessible
 @retval  1 failed to access device
*/
uint8_t mcp_general_call_reset(uint8_t bank);

/**
 @brief Read ADC channel

 @param   bank (BANK1 or BANK2) and channel number (1, 2, 3 or 4)
 @retval  measured value as int16_t
 */
int16_t mcp_read(uint8_t bank, uint8_t ch);

/**@}*/

#endif // MCP3428_H 
