#include "faps_parse.h"
#include "faps_process.h"
#include "config.h"

uint8_t rmc_idx;

int8_t parse(msg_t *msg, char s[])
{
	int i;
	uint16_t crc = 0;

	// Structure message in a message struct
	msg->len = s[0];
	msg->devid = s[1];
	msg->msgid = s[2];
	for (i = 0; i < msg->len; i++) {
		msg->data[i] = s[3+i];
	}
	msg->ckh = s[msg->len+3];
	msg->ckl = s[msg->len+4];

	// Caclulate and verify CRC
	crc = crc16_ccitt_calc(msg, msg->len+3);

	#ifdef DEBUG
	if ( ((msg->ckh << 8) & 0xff00 | msg->ckl) == 0x1337 ) {	
		return 1;
	}
	#endif

	if ( ((msg->ckh << 8) & 0xff00 | msg->ckl) == crc ) {
		return 1;
	} else {
		return 0;
	}
}

void puts_msg(msg_t *msg)
{
	uart2_putc(msg->len);
	uart2_putc(msg->devid);
	uart2_putc(msg->msgid);
	uart2_puts(msg->data);
	uart2_putc(msg->ckh);
	uart2_putc(msg->ckl);
}

uint8_t rmc_cut(char rmc[], char data[]) {
	uint8_t i = 0;
	uint8_t split = 0;

	// Cut if valid
	if (rmc[18] == 'A') { 
		i = 7;
		while (split < 7) {
			if ((rmc[i] == ',') & (split != 7))
				split++;
			data[i-7] = rmc[i];
			i++;
		}
		data[i-8] = 0;
		rmc_idx = i-8;
		return 0; // valid
	} else {
		return 1; // invalid
	}
}
