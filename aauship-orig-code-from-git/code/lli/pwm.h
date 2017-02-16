#ifndef PWM_H
#define PWM_H
/**
 * @file
 * @defgroup aux PWM
 * @code #include <pwm.h> @endcode
 * @author Nick Østergaard nickoe@es.aau.dk
 *
 * @brief This file handles the raw motor and servo control for the
 * outputs.
 */

/**@{*/

//efine DCPERIOD 2000 // Period time 2 ms, 500 Hz
#define DCPERIOD 100 // Period time 0.1 ms, 10 kHz

/**
 * PWM outputs
 */ 
// OC3 timer
#define DC1 1 // OC3B
#define DC2 2 // OC3C
#define DC3 3 // OC3A
// OC1 timer
#define RC1 4 // OC1A
#define RC2 5 // OC1B
#define RC3 6 // OC1C
// OC4 timer
#define RC4 7 // OC4B
#define RC5 8 // OC4C

/**
	@brief   Initialization of all PWM putputs
	@param   none
	@return  none
*/
void pwm_init(void);

/**
	@brief   Direct interface to the OCR (Output Compare Register)
	@param   Channel define name, value
	@return  none
*/
void pwm_set(uint8_t channel, uint16_t value);

// value is: 100 = 100% , 0 = 0%

/**
	@brief   Sets the the duty cycle for the PWM output depending on type

	The two output types are a DCx and RCx type, where the DC type is ment to be a PWM
	with a duty cycle from +0% to +100% (valid parameters is 0 to 100), while the RC type is for radio control compatible
	actuators, which has a duty cycle from a pulse width of 1 ms to 2 ms, where 1 ms is -100% and 2 ms is +100%.

	@param   Channel define name, value dependent on RCx or DCx type
	@return  none
*/
void pwm_set_duty(uint8_t channel, int16_t value);

/**@}*/

#endif // PWM_H 
