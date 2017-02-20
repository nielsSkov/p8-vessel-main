#ifndef	_FAPS_PROCESS_H
#define	_FAPS_PROCESS_H

#include	"faps_parse.h"

#define ARRAY_SIZE(x) (sizeof((x)) / sizeof((x)[0]))

uint8_t pack[256];

char *package(uint8_t len, uint8_t devid, uint8_t msgid, int8_t data[250]);
void hli_send(uint8_t ptr[], uint8_t len);
void grs_send(uint8_t ptr[], uint8_t len);

void grs_ack(void);
void grs_nack(void);
#endif	/* _FAPS_PROCESS_H */
