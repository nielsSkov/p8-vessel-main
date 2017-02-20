//#define CRC16 0x8005
//#define CRC16 0x1021
#define CRC16 0x31C3

//uint16_t gen_crc16(const uint8_t *data, uint16_t size, uint16_t CRC16);

uint16_t crc16_ccitt_calc(char *pD, int l);
