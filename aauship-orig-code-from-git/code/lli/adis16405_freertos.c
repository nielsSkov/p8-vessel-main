/* Systems header files */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Other header files */
#include "spi.h"
#include "adis16405.h"

#define ADIS_CS 0x00 // This is just a dummy value so far

//--------------datacollecter values------
int dc_counter = 0;
int sum_counter = 0;
float dc_collector[10];
float dc_collector_avg;
float dc_collector_speed = 0;
float dc_collector_distance = 0;

//int dc_counter2 = 0;
float dc_collector2[10];
int dc_counter3 = 0;
//--------------datacollecter values end------

unsigned char sample_output_type = ADIS_STOP; // Variable to control output flow
/**
 * Datastructure for a burst read
 */
unsigned char SUPPLY_OUT[2];  //Power supply measurement 
unsigned char XGYRO_OUT[2]; //X-axis gyroscope output 
unsigned char YGYRO_OUT[2]; //Y-axis gyroscope output 
unsigned char ZGYRO_OUT[2]; //Z-axis gyroscope output 
unsigned char XACCL_OUT[2]; //X-axis accelerometer output 
unsigned char YACCL_OUT[2]; //Y-axis accelerometer output 
unsigned char ZACCL_OUT[2]; //Z-axis accelerometer output 
unsigned char XMAGN_OUT[2]; //X-axis magnetometer measurement 
unsigned char YMAGN_OUT[2]; //Y-axis magnetometer measurement 
unsigned char ZMAGN_OUT[2]; //Z-axis magnetometer measurement 
unsigned char TEMP_OUT[2]; //Temperature output 
unsigned char AUX_ADC[2]; //Auxiliary ADC measurement

/**
 * This is a function that checks of the IMU works.
 */
void adis_self_test( void ) {
	// @TODO
}

/**
 * This decodes the 14 bit raw data from the ADIS16405 sesor
 */
int adis_decode_14bit_raw(unsigned char SENSOR_OUT[2], int scale){
	int sensor = 0;
	sensor = (int)((SENSOR_OUT[0] << 8) | SENSOR_OUT[1]) &0x3fff;
	if(sensor>=0x2000)
		sensor = 0xffffc000 | sensor; 
	sensor = sensor * scale;
	return sensor;
}

/**
 * This decodes the 12 bit raw data from the ADIS16405 sesor
 */
int adis_decode_12bit_raw(unsigned char SENSOR_OUT[2], int scale){
	int sensor = 0;
	sensor = (int)((SENSOR_OUT[0] << 8) | SENSOR_OUT[1]) &0xfff;
	if(sensor>=0x800)
		sensor = 0xfffff000 | sensor;
	sensor = sensor * scale;
	return sensor;
}

/**
 * This reads all sensor data from the ADIS sesnor via burst read mode
 */
void adis_burst_read(void * pvParameters) {
	unsigned char addr[2]; // Temporary variable
	portTickType xLastWakeTime; // Variable for the vTaskDelayUntil()

	xLastWakeTime = xTaskGetTickCount(); // Start the counting for the ticktimer

	while(1){
		if (sample_output_type > ADIS_STOP) { // Do not sample
			if (sample_output_type >= ADIS_SILENT) { // Do the sampling
        led_set(2);
        addr[0] = 0x3e;
        addr[1] = 0x00;
        spi0_send(addr,1,ADIS_CS); //Initiate burst read mode
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(SUPPLY_OUT,1,ADIS_CS); //Power supply measurement 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(XGYRO_OUT,1,ADIS_CS); //X-axis gyroscope output 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(YGYRO_OUT,1,ADIS_CS); //Y-axis gyroscope output 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(ZGYRO_OUT,1,ADIS_CS); //Z-axis gyroscope output 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(XACCL_OUT,1,ADIS_CS); //X-axis accelerometer output 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(YACCL_OUT,1,ADIS_CS); //Y-axis accelerometer output 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(ZACCL_OUT,1,ADIS_CS); //Z-axis accelerometer output 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(XMAGN_OUT,1,ADIS_CS); //X-axis magnetometer measurement 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(YMAGN_OUT,1,ADIS_CS); //Y-axis magnetometer measurement 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(ZMAGN_OUT,1,ADIS_CS); //Z-axis magnetometer measurement 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(TEMP_OUT,1,ADIS_CS); //Temperature output 
        vTaskDelay(.01/portTICK_RATE_MS);
        spi0_send(AUX_ADC,1,ADIS_CS); //Auxiliary ADC measurement
      }

			if (sample_output_type == ADIS_CSV) { // Output CSV format
				// Supply voltage decoding
				unsigned int voltage;
				voltage = (unsigned int)((SUPPLY_OUT[0] << 8) | SUPPLY_OUT[1]) & 0x3fff;
				voltage = voltage * 242;
				printf("%d,",voltage);
				//======================GYROS=======================
				//xgyro
				printf("%d,",adis_decode_14bit_raw(XGYRO_OUT,50)); // Print the recieved data

				//ygyro
				printf("%d,",adis_decode_14bit_raw(YGYRO_OUT,50)); // Print the recieved data

				//zgyro
				printf("%d,",adis_decode_14bit_raw(ZGYRO_OUT,50)); // Print the recieved data

				//======================ACCLEROMETERS=======================
				//xaccl
				printf("%d,",adis_decode_14bit_raw(XACCL_OUT,3330)); // Print the recieved data

				//yaccl
				printf("%d,",adis_decode_14bit_raw(YACCL_OUT,3330)); // Print the recieved data

				//zaccl
				printf("%d,",adis_decode_14bit_raw(ZACCL_OUT,3330)); // Print the recieved data

				//======================MAGNETOMETERS=======================
				//xmag
				printf("%d,",adis_decode_14bit_raw(XMAGN_OUT,500)); // Print the recieved data

				//ymag
				printf("%d,",adis_decode_14bit_raw(YMAGN_OUT,500)); // Print the recieved data

				//zmag
				printf("%d,",adis_decode_14bit_raw(ZMAGN_OUT,500)); // Print the recieved data

				// Temperature @TODO This is not tested yet
				printf("%d,",(adis_decode_12bit_raw(TEMP_OUT,140)+25000)); // Print the recieved data

				// ADC @TODO This is not tested or verified yet
				printf("%d\n\r",adis_decode_12bit_raw(AUX_ADC,810)); // Print the recieved data
			}

			if (sample_output_type == ADIS_BIN) { // Output binary format
				printf("%c%c", SUPPLY_OUT[0], SUPPLY_OUT[1]);  //Power supply measurement 
				printf("%c%c", XGYRO_OUT[0], XGYRO_OUT[1]); //X-axis gyroscope output 
				printf("%c%c", YGYRO_OUT[0], YGYRO_OUT[1]); //Y-axis gyroscope output 
				printf("%c%c", ZGYRO_OUT[0], ZGYRO_OUT[1]); //Z-axis gyroscope output 
				printf("%c%c", XACCL_OUT[0], XACCL_OUT[1]); //X-axis accelerometer output 
				printf("%c%c", YACCL_OUT[0], YACCL_OUT[1]); //Y-axis accelerometer output 
				printf("%c%c", ZACCL_OUT[0], ZACCL_OUT[1]); //Z-axis accelerometer output 
				printf("%c%c", XMAGN_OUT[0], XMAGN_OUT[1]); //X-axis magnetometer measurement 
				printf("%c%c", YMAGN_OUT[0], YMAGN_OUT[1]); //Y-axis magnetometer measurement 
				printf("%c%c", ZMAGN_OUT[0], ZMAGN_OUT[1]); //Z-axis magnetometer measurement 
				printf("%c%c", TEMP_OUT[0], TEMP_OUT[1]); //Temperature output 
				printf("%c%c", AUX_ADC[0], AUX_ADC[1]); //Auxiliary ADC measurement
				printf("\n\r"); // Newline and return
			}

			led_clear(2);
		}

//------Here a datacollecter is implemented---

		dc_collector[dc_counter] = 9.82*((float)(adis_decode_14bit_raw(XACCL_OUT,3330))/1000000);	// Collect 10 values
//		printf("accx=\t%d\n\r",(int)(dc_collector[dc_counter]*1000)); // Prints in mili g
		dc_counter++;

		if (dc_counter == 10){
			dc_collector_avg  = 0;
			for( sum_counter = 0 ; sum_counter < 10 ; sum_counter++){
				dc_collector_avg = dc_collector_avg + dc_collector[sum_counter];	// Sum up the last 10 values
			}
			dc_collector_avg = dc_collector_avg/10;						// Calculate average of 10 collected values
			printf("avg\t%d mm/s^2\t",(int)(dc_collector_avg*1000));
			
			// Integrate twice
			dc_collector_speed = dc_collector_speed + (dc_collector_avg*0.5);
			printf("Speed=\t%d mm/s\t",(int)(dc_collector_speed*1000));
			dc_collector_distance = dc_collector_distance + (dc_collector_speed*0.5);

		printf("Distance:\t%d mm\n\r",(int)(dc_collector_distance*1000));

			dc_counter = 0;
		}
//------Here a datacollecter is implemented (end)---


		vTaskDelayUntil( &xLastWakeTime, 50/portTICK_RATE_MS);
	}
}

/*
 * This function prints the temperature to stdout.
 * The scale factor is 0.14 degrees celcius per LSB, while 0x0000 = 25
 * degrees celcius.
 * 
 * WARNING: This does not work yet
 */
void adis_get_temp( void ) {
	unsigned char tmp[2]; // Temporary variable
	unsigned char addr[2]; // Address to TEMP_OUT
	int temp = 255;
	int temperature = 0;

	addr[0] = 0x16; // This is the address, and it is in read mode
	addr[1] = 0x00; // This is the data portion, wich the IMU ignores when readiing
	memcpy(tmp,addr,2); // Copy address to temporay variable
	spi0_send(tmp,1,ADIS_CS); // Send data
	tmp[0] = 0x00;
	tmp[1] = 0x00;
	vTaskDelay(.01/portTICK_RATE_MS);
	spi0_send(tmp,1,ADIS_CS); // Send some random data, we now grab the temperature
	temp = (int)((tmp[0] << 8) | tmp[1]) &0xfff;
	if(temp>=0x800)
		temp = 0xfffff000|temp;
	temperature = 25000 + temp*140;
	printf("The temperature is 0x%02x%02x = %d\n\r",tmp[0],tmp[1],temp); // Print the recieved data
	printf("The calculeted temperature is %i mdegrees c\n\r",temperature); // Print the calculated temperature
}

/**
 * Restoring sensors to factory calibration
 */
void adis_reset_factory( void ) {
	unsigned char tmp[2]; // Temporary variable
	unsigned char addr[2]; // Address to TEMP_OUT
	addr[0] = 0xbe; // This is the address for restoring factory calibration
	addr[1] = 0x02; // This is the data portion, wich the IMU ignores when readiing
	memcpy(tmp,addr,2); // Copy address to temporay variable
	spi0_send(tmp,1,ADIS_CS); // Send data
	printf("The IMU have been restored to factory calibration\n\r"); // Print the recieved data
}

/**
 * Gyroscope presission automatic bias null calibration
 */
void adis_recalibrate_gyros( void ) {
	unsigned char tmp[2]; // Temporary variable
	unsigned char addr[2]; // Address to TEMP_OUT
	addr[0] = 0xbe; // This is the address for restoring factory calibration
	addr[1] = 0x10; // This is the data portion, wich the IMU ignores when readiing
	memcpy(tmp,addr,2); // Copy address to temporay variable
	spi0_send(tmp,1,ADIS_CS); // Send data
	printf("The gyros are being recalibrated.\n\rDON'T TOUCH THE IMU! FFS\n\r"); // Print the recieved data
	led_flash(0);
	led_set(0);
	for(int i = 30; i>0 ; i--){
		printf("%i second(s) left\n\r",i);
		vTaskDelay(1000/portTICK_RATE_MS);
	}
	led_clear(0);
	led_set(1);
	vTaskDelay(500/portTICK_RATE_MS);
	led_clear(1);
	printf("The gyros have been recalibrated.\n\r"); // Print the recieved data
}

/**
 * Function to start outputting samples
 */
void adis_output( unsigned char task ) {
	sample_output_type = task;
}





/**
 *Function to send data to other functions
 */
 
float data_read(int data_type){
	switch (data_type) {
		case 1:
			return (float)adis_decode_14bit_raw(SUPPLY_OUT,250);
			break;
		case 2:
			return (float)adis_decode_14bit_raw(XGYRO_OUT,50);
			break;
		case 3:
			return (float)adis_decode_14bit_raw(YGYRO_OUT,50);
			break;
		case 4:
			return (float)adis_decode_14bit_raw(ZGYRO_OUT,50);
			break;
		case 5:
			return (float)adis_decode_14bit_raw(XACCL_OUT,3330);
			break;
		case 6:
			return (float)adis_decode_14bit_raw(YACCL_OUT,3330);
			break;
		case 7:
			return (float)adis_decode_14bit_raw(ZACCL_OUT,3330);
			break;
		case 8:
			return (float)adis_decode_14bit_raw(XMAGN_OUT,500);
			break;
		case 9:
			return (float)adis_decode_14bit_raw(YMAGN_OUT,500);
			break;
		case 10:
			return (float)adis_decode_14bit_raw(ZMAGN_OUT,500);
			break;
		case 11:
			return (float)(adis_decode_12bit_raw(TEMP_OUT,140)+25000);
			break;
		case 12:
			return (float)adis_decode_12bit_raw(AUX_ADC,810);
			break;
		case 13:
			return dc_collector_distance;
			break;
	}
	printf("Wrong data read parameter");
	return 0;
}

