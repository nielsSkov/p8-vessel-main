#include "faps_parse.h"
#include "faps_process.h"
#include "pwm.h"
#include <avr/io.h>
#include <util/delay.h>
#include "config.h"
#include "crc16.h"
#include <string.h>
#include "mcp3428.h"

char str[16];  // String used for debugging via e.q. uart2_puts(itoa(mpc_read(BANK1, 4), str, 10));


int awake_flag;
/*
 * Decide what to do with a given command
 */
int process(msg_t *msg) 
{
	char buildtime[] =  __DATE__ " " __TIME__;
	char gitcommit[sizeof(__GIT_COMMIT__)] = __GIT_COMMIT__;
    char buildinfo[sizeof(buildtime)+sizeof(gitcommit)];
	int16_t duty = 0;
	int i = 0;

	int16_t meas = 0;
	uint8_t bmdata[16];

	switch (msg->devid) {
		// GENERAL LLI
		case 0:
			switch (msg->msgid) {
				case 0:
					grs_send(package(0, 0x00, 0x08, 0),0); // NACK
					break;
				case 1:
					grs_send(package(0, 0x00, 0x08, 0),0); // NACK
					break;
				case 2:
					grs_send(package(0, 0x00, 0x08, 0),0); // NACK
					break;			
				case 5:
					grs_send(package(0, 0x00, 0x05, 0),0); // PING
					break;		
				case 6:
					grs_send(package(0, 0x00, 0x06, 0),0); // PONG
					break;
				case 9:
          memcpy(buildinfo,buildtime,sizeof(buildtime)-1);
          for (i = sizeof(buildtime); i < sizeof(buildinfo); i++) {
	          buildinfo[i-1] = gitcommit[i-sizeof(buildtime)];
          }
					grs_send(package(sizeof(buildinfo), 0x00, 0x09, buildinfo),sizeof(buildinfo));
					hli_send(package(sizeof(buildinfo), 0x00, 0x09, buildinfo),sizeof(buildinfo));
					break;
				case 12:
					/* Sampling the battery monitor */

/*
					uart2_puts("BANK1:\t");
					uart2_puts(itoa(mcp_read(BANK1, CH1), str, 10));
					uart2_puts("\t");
					_delay_ms(CT); // 1/SPS ms delay is needed for the conversion time
					uart2_puts(itoa(mcp_read(BANK1, CH2), str, 10));
					uart2_puts("\t");
					_delay_ms(CT);
					uart2_puts(itoa(mcp_read(BANK1, CH3), str, 10));
					uart2_puts("\t");
					_delay_ms(CT);
					uart2_puts(itoa(mcp_read(BANK1, CH4), str, 10));
					uart2_puts("\r\n");

					uart2_puts("BANK2:\t");
					uart2_puts(itoa(mcp_read(BANK2, CH1), str, 10));
					uart2_puts("\t");
					_delay_ms(CT); // 1/SPS ms delay is needed for the conversion time
					uart2_puts(itoa(mcp_read(BANK2, CH2), str, 10));
					uart2_puts("\t");
					_delay_ms(CT);
					uart2_puts(itoa(mcp_read(BANK2, CH3), str, 10));
					uart2_puts("\t");
					_delay_ms(CT);
					uart2_puts(itoa(mcp_read(BANK2, CH4), str, 10));
					uart2_puts("\r\n");
*/

					meas = mcp_read(BANK1, CH1);
					bmdata[0] = meas >> 8;
					bmdata[1] = meas;
					_delay_ms(CT);
					meas = mcp_read(BANK1, CH2);
					bmdata[2] = meas >> 8;
					bmdata[3] = meas;
					_delay_ms(CT);
					meas = mcp_read(BANK1, CH3);
					bmdata[4] = meas >> 8;
					bmdata[5] = meas;
					_delay_ms(CT);
					meas = mcp_read(BANK1, CH4);
					bmdata[6] = meas >> 8;
					bmdata[7] = meas;

					meas = mcp_read(BANK2, CH1);
					bmdata[8] = meas >> 8;
					bmdata[9] = meas;
					_delay_ms(CT);
					meas = mcp_read(BANK2, CH2);
					bmdata[10] = meas >> 8;
					bmdata[11] = meas;
					_delay_ms(CT);
					meas = mcp_read(BANK2, CH3);
					bmdata[12] = meas >> 8;
					bmdata[13] = meas;
					_delay_ms(CT);
					meas = mcp_read(BANK2, CH4);
					bmdata[14] = meas >> 8;
					bmdata[15] = meas;

          hli_send(package(16, 0, 13, bmdata), 16);
					return;
			}

		// ACTUATORS
		case 10: 
			switch (msg->msgid) {
				case 0:
					break;
				case 1:
					break;
				case 2:
					break;
				case 3:
					duty = (int16_t) (msg->data[0]);
					duty = (duty << 8) & 0xFF00; 
					duty = (duty | ((msg->data[1])&0xFF));
					pwm_set_duty(RC1, duty );
					grs_ack();
					awake_flag = 0;
					break;
				case 4:
				case 5:
					duty = (int16_t) (msg->data[0]);
					duty = (duty << 8) & 0xFF00; 
					duty = (duty | ((msg->data[1])&0xFF));
					pwm_set_duty(RC2, duty );
					grs_ack();
					awake_flag = 0;
					break;
				case 6:
				case 7:
					duty = (int16_t) (msg->data[0]);
					duty = (duty << 8) & 0xFF00; 
					duty = (duty | ((msg->data[1])&0xFF));
					pwm_set_duty(RC3, duty );
					grs_ack();
					awake_flag = 0;
					break;
				case 8:
				case 9:
					duty = (int16_t) (msg->data[0]);
					duty = (duty << 8) & 0xFF00; 
					duty = (duty | ((msg->data[1])&0xFF));
					pwm_set_duty(RC4, duty );
					grs_ack();
					awake_flag = 0;
					break;
				case 10:
				case 11:
					duty = (int16_t) (msg->data[0]);
					duty = (duty << 8) & 0xFF00; 
					duty = (duty | ((msg->data[1])&0xFF));
					pwm_set_duty(RC5, duty );
					grs_ack();
					awake_flag = 0;
					break;
				case 12:
				case 13:
					pwm_set_duty(DC1, msg->data[0]);
					grs_ack();
					awake_flag = 0;
					break;
				case 14:
				case 15:
					pwm_set_duty(DC2, msg->data[0]);
					grs_ack();
					awake_flag = 0;
					break;
				case 16:
				case 17:
					pwm_set_duty(DC3, msg->data[0]);
					grs_ack();
					awake_flag = 0;
					break;
				case 18:
					break;
				case 19:
					duty = (int16_t) (msg->data[0]);
					duty = (duty << 8) & 0xFF00;
					duty = (duty | ((msg->data[1])&0xFF));
					pwm_set_duty(RC1, duty );
					duty = (int16_t) (msg->data[2]);
					duty = (duty << 8) & 0xFF00;
					duty = (duty | ((msg->data[3])&0xFF));
					pwm_set_duty(RC2, duty );
					awake_flag = 0;
					break;
				case 20:
					break;
				case 21:
					duty = (int16_t) ((msg->data[0] << 8) & 0xFF00) | (msg->data[1]&0xFF);
              if (duty == 0)
                PORTF &= ~(1<<DCDIR1);
              else
	    					PORTF |= (1<<DCDIR1);
					pwm_set_duty(DC1, duty );
					awake_flag = 0;
					break;
				case 22:
					duty = (int16_t) ((msg->data[0] << 8) & 0xFF00) | (msg->data[1]&0xFF);
              if (duty == 0)
                PORTF &= ~(1<<DCDIR2);
              else
	    					PORTF |= (1<<DCDIR2);
					pwm_set_duty(DC2, duty );
					awake_flag = 0;
					break;
				case 23:
					duty = (int16_t) ((msg->data[0] << 8) & 0xFF00) | (msg->data[1]&0xFF);
              if (duty == 0)
                PORTF &= ~(1<<DCDIR3);
              else
	    					PORTF |= (1<<DCDIR3);
					pwm_set_duty(DC3, duty );
					awake_flag = 0;
					break;
				case 34:
					PORTF &= ~(1<<DCDIR1);
					break;
				case 35:
					PORTF &= ~(1<<DCDIR2);
					break;
				case 36:
					PORTF &= ~(1<<DCDIR3);
					break;

			}
	}
}

/*
 * Prepare messages
 */
char *package(uint8_t len, uint8_t devid, uint8_t msgid, int8_t data[]) {
	uint8_t i = 0;
	uint16_t crc = 0x0000;

	pack[0] = '$';
	pack[1] = len;
	pack[2] = devid;
	pack[3] = msgid;
	for (i = 0; i < len; i++) {
		pack[i+4] = data[i];
	}
	
	crc = crc16_ccitt_calc(pack+1,len+3);
	
	pack[i+4] = (crc >> 8) & 0x00FF;
	pack[i+5] = crc & 0x00FF;

	return pack;
}

/*
 * Send to HLI
 */
void hli_send(uint8_t ptr[], uint8_t len) {
	int i;

	for (i=0; i<len+6; i++) {
		uart_putc(*(ptr+i));
	}
}

/*
 * Send to GRS
 */
void grs_send(uint8_t ptr[], uint8_t len) {
	int i;

	for (i=0; i<len+6; i++) {
		uart2_putc(*(ptr+i));
	}
}

/*
 * GRS ACK
 */
void grs_ack(void) {
	grs_send(package(0, 0x00, 0x07, NULL), 0); // GRS ACK
}

/*
 * GRS NACK
 */
void grs_nack(void) {
	grs_send(package(0, 0x00, 0x08, NULL), 0); // GRS NACK
}
