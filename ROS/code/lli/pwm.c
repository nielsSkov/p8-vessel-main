


#include <avr/io.h>
#include "config.h"
#include "pwm.h"

/*
f_OCnA = fclk_IO/(2*N*(1+OCRnA)
*/
// Initialiser PWM
void pwm_init(void) {
	// Enable all PWM pins as outputs
	DDRE = (1<<DCPWM1) | (1<<DCPWM2) | (1<<DCPWM3);
	DDRB = (1<<RCPWM1) | (1<<RCPWM2) | (1<<RCPWM3);
	DDRH = (1<<RCPWM4) | (1<<RCPWM5);


// DCPWM1
  OCR3B = 0; // Initialize at zero
  TCCR3A |= (1<<COM3B1);//COM1A1 Clear OCnA when match counting up,Set on 

// DCPWM2
  OCR3C = 0; // Initialize at zero
  TCCR3A |= (1<<COM3C1);//COM1A1 Clear OCnA when match counting up,Set on 

// DCPWM3
  OCR3A = 0; // Initialize at zero
  TCCR3A |= (1<<COM3A1);//COM1A1 Clear OCnA when match counting up,Set on 

  TCCR3B |= (1<<WGM33) | (1<<CS31);// Phase and Freq correct ICR1=Top   //Mode 8: Phase and Freq. Correct PWM top=ICR1
  ICR3 = DCPERIOD; // Period time 2 ms, 500 Hz



// RCPWM1
  OCR1A = 1500; //set 1.5ms pulse  1000=1ms  2000=2ms
  TCCR1A |= (1<<COM1A1);//COM1A1 Clear OCnA when match counting up,Set on 

// RCPWM2
  OCR1B = 1500; //set 1.5ms pulse  1000=1ms  2000=2ms
  TCCR1A |= (1<<COM1B1);//COM1A1 Clear OCnA when match counting up,Set on 

// RCPWM3
  OCR1C = 1500; //set 1.5ms pulse  1000=1ms  2000=2ms
  TCCR1A |= (1<<COM1C1);//COM1A1 Clear OCnA when match counting up,Set on 

  TCCR1B |= (1<<WGM13) | (1<<CS11);// Phase and Freq correct ICR1=Top
  ICR1 = 20000; // Period time 20 ms, 50 Hz



// RCPWM4
  OCR4B = 1500; //set 1.5ms pulse  1000=1ms  2000=2ms
  TCCR4A |= (1<<COM4B1);//COM1A1 Clear OCnA when match counting up,Set on 

// RCPWM5
  OCR4C = 1500; //set 1.5ms pulse  1000=1ms  2000=2ms
  TCCR4A |= (1<<COM4C1);//COM1A1 Clear OCnA when match counting up,Set on 

  TCCR4B |= (1<<WGM43) | (1<<CS41);// Phase and Freq correct ICR1=Top
  ICR4 = 20000; // Period time 20 ms, 50 Hz
}

void pwm_set(uint8_t channel, uint16_t value) {
	switch (channel) {
		case DC1: // OC3B
			OCR3B = value;
			break;
		case DC2: // OC3C
			OCR3C = value;
			break;
		case DC3: // OC3A
			OCR3A = value;
			break;
		case RC1: // OC1A
			OCR1A = value;
			break;
		case RC2: // OC1B
			OCR1B = value;
			break;
		case RC3: // OC1C
			OCR1C = value;
			break;
		case RC4: // OC4B
			OCR4B = value;
			break;
		case RC5: // OC4C
			OCR4C = value;
			break;
	}
}

/*
 * The int16_t value ensures that a number larger than 8 bits can be fed
 * to pwm_set(), and the (value & 0x00FF) ensures that the value it is called
 * with is okay.
 */
void pwm_set_duty(uint8_t channel, int16_t value) {
	if ( (channel >= DC1) && (channel <= DC3 ) ) { // Full range duty cycle, as for ordinary PWM (+0% to +100%)
		if(value < -100){
			value=-100;
		} else if (value > 100){
			value=100;
		};
		value = value * (DCPERIOD/100);
	}
	else if ( (channel >= RC1) && (channel <= RC5) ) { // Small range duty cycle, as for RC PWM (-100% = -500 to +100% = 500)
		if(value < -500){
			value=-500;
		} else if (value > 500){
			value=500;
		};
		value = value + 1500;

	}
	pwm_set(channel, value);
}

