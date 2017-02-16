/* Systems header files */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Other header files */
#include "spi.h"
#include "adis16405.h"


#define ADIS_CS 0x00 // This is just a dummy value so far


/**
 * This is a function that checks of the IMU works.
 */
void adis_self_test( void ) {
	// @TODO
}

/**
 * This decodes the 14 bit raw data from the ADIS16405 sesor
 */

int32_t adis_decode_14bit_raw(int16_t sensor, uint32_t scale){
	int32_t out;

	// Makes sure that we only copy the 14-bit data we are interrested in and that
	// the new variables is 32-bit
	out = (int32_t) (0x00003fff & sensor);

	// Handle negative values
	if(out>=0x2000)
		out = 0xffffc000 | out; 
	out = out * scale;

	return out;
}

/**
 * This decodes the 12 bit raw data from the ADIS16405 sesor
 */
int32_t adis_decode_12bit_raw(uint16_t sensor, uint32_t scale){
	int32_t out;

	// Makes sure that we only copy the 12-bit data we are interrested in and that
	// the new variables is 32-bit
	out = (int32_t) (0x00000fff & sensor);

	if(out>=0x800) 
		out = 0xfffff000 | sensor;
//	out = out * scale;
	
	return out;
}


/*
 * This function prints the temperature to stdout.
 * The scale factor is 0.14 degrees celcius per LSB, while 0x0000 = 25
 * degrees celcius.
 * 
 * WARNING: This does not work yet
 */
float adis_get_temp( void ) {
	unsigned char tmp[2]; // Temporary variable
	uint16_t temp = 255;
	float temperature = 0;
	unsigned char c[64];


	spiTransferWord(0x1600);
	temp = spiTransferWord(0x0000);
	temperature =	(adis_decode_12bit_raw(temp,140)+25000);

	return temperature;
}

int32_t adis_get_xacc( void ) {
	unsigned char tmp[2]; // Temporary variable
	uint16_t temp = 255;
	float temperature = 0;
	unsigned char c[64];


	spiTransferWord(0x0A00);
	temp = spiTransferWord(0x0000);
	temperature =	adis_decode_14bit_raw(temp,1);

	return temperature;
}

/**
 * Software reset
 *
 * Stops the sensor operation and runs the device through its start-up
 * sequence.
 */
void adis_soft_reset( void ) {
	spiTransferWord(0xBE80);
}

/**
 * Restoring sensors to factory calibration
 */
void adis_reset_factory( void ) {
	spiTransferWord(0xBE02);
}

/**
 * Testing for device number, base 10 value is the model number
 */
uint8_t is_adis16405( void ) {
	spiTransferWord(0x5600);
	if (spiTransferWord(0x0000) == 0x4015) {
		return 1; // The device is a ADIS16405
	} else {
		return 0; // Device not connected or is not a ADIS16405
	}
}


/**
 * Raw burst read
 */
int adis_burst_read( adis16_t *data ) {
	/* Initiate burst read */
	spiTransferWord(0x3E00);

	/* Read all data from the burst read at put in struct */
	data->supply = spiTransferWord(0x0000);
	data->xgyro  = spiTransferWord(0x0000);
	data->ygyro  = spiTransferWord(0x0000);
	data->zgyro  = spiTransferWord(0x0000);
	data->xaccl  = spiTransferWord(0x0000);
	data->yaccl  = spiTransferWord(0x0000);
	data->zaccl  = spiTransferWord(0x0000);
	data->xmagn  = spiTransferWord(0x0000);
	data->ymagn  = spiTransferWord(0x0000);
	data->zmagn  = spiTransferWord(0x0000);
	data->temp   = spiTransferWord(0x0000);
	data->adc    = spiTransferWord(0x0000);

	return 1;
}
/*

		adis_burst_read(&adis_data);
		xacc = adis_decode_14bit_raw(adis_data.xaccl,1);
		w2bptr(adis_decode_14bit_raw(adis_data.xaccl,1);, xacca);
		grs_send(package(2, 0x14, 0x03, &xacca), 2);
*/
/**
 * Decode and pack the burst readed data
 */
int adis_decode_burst_read_pack(uint8_t data[sizeof(adis8_t)]) {
	adis_burst_read(&adis_data_raw); // Collect raw measurements
	w2bptr(adis_decode_14bit_raw(adis_data_raw.supply,1), adis_data_decoded.supply);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.xgyro,1), adis_data_decoded.xgyro);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.ygyro,1), adis_data_decoded.ygyro);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.zgyro,1), adis_data_decoded.zgyro);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.xaccl,1), adis_data_decoded.xaccl);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.yaccl,1), adis_data_decoded.yaccl);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.zaccl,1), adis_data_decoded.zaccl);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.xmagn,1), adis_data_decoded.xmagn);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.ymagn,1), adis_data_decoded.ymagn);
	w2bptr(adis_decode_14bit_raw(adis_data_raw.zmagn,1), adis_data_decoded.zmagn);
	w2bptr(adis_decode_12bit_raw(adis_data_raw.temp,1), adis_data_decoded.temp);
	w2bptr(adis_decode_12bit_raw(adis_data_raw.adc,1), adis_data_decoded.adc);
}

/**
 * Reduce already burst read and decoded pack of IMU data
 */
void adis_reduce_decoded_burst(void) {
	adis_data_decoded_reduced.zgyro[0] = adis_data_decoded.zgyro[0];
	adis_data_decoded_reduced.zgyro[1] = adis_data_decoded.zgyro[1];
	adis_data_decoded_reduced.xaccl[0] = adis_data_decoded.xaccl[0];
	adis_data_decoded_reduced.xaccl[1] = adis_data_decoded.xaccl[1];
	adis_data_decoded_reduced.yaccl[0] = adis_data_decoded.yaccl[0];
	adis_data_decoded_reduced.yaccl[1] = adis_data_decoded.yaccl[1];
	adis_data_decoded_reduced.xmagn[0] = adis_data_decoded.xmagn[0];
	adis_data_decoded_reduced.xmagn[1] = adis_data_decoded.xmagn[1];
	adis_data_decoded_reduced.ymagn[0] = adis_data_decoded.ymagn[0];
	adis_data_decoded_reduced.ymagn[1] = adis_data_decoded.ymagn[1];
	adis_data_decoded_reduced.adc[0] = adis_data_decoded.adc[0];
	adis_data_decoded_reduced.adc[1] = adis_data_decoded.adc[1];
}

/**
 * Word to byte-array pointer
 * Converts a 16-bit word to a 2 elements 8-bit byte array
 */
void w2bptr(int16_t word, uint8_t array[2]) {
	array[0] = (word >> 8) & 0x00FF;
	array[1] = word & 0x00FF;
}

void adis_set_sample_rate(void) {
	spiTransferWord(0xB601); // spiTransferWord(0xB601); i.e. 20 Hz does not work properly!
	spiTransferWord(0xB700);
}
