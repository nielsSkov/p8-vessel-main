/*! \file spi.c \brief SPI interface driver. */
//*****************************************************************************
//
// File Name	: 'spi.c'
// Title		: SPI interface driver
// Author		: Pascal Stang - Copyright (C) 2000-2002
// Created		: 11/22/2000
// Revised		: 06/06/2002
// Version		: 0.6
// Target MCU	: Atmel AVR series
// Editor Tabs	: 4
//
// NOTE: This code is currently below version 1.0, and therefore is considered
// to be lacking in some functionality or documentation, or may not be fully
// tested.  Nonetheless, you can expect most functions to work.
//
// This code is distributed under the GNU Public License
//		which can be found at http://www.gnu.org/licenses/gpl.txt
//
//*****************************************************************************

#include <avr/io.h>
#include <avr/interrupt.h>

#include <util/delay.h>

#include "spi.h"

// Define the SPI_USEINT key if you want SPI bus operation to be
// interrupt-driven.  The primary reason for not using SPI in
// interrupt-driven mode is if the SPI send/transfer commands
// will be used from within some other interrupt service routine
// or if interrupts might be globally turned off due to of other
// aspects of your program
//
// Comment-out or uncomment this line as necessary
//#define SPI_USEINT

// global variables
volatile uint8_t spiTransferComplete;

// SPI interrupt service handler
#ifdef SPI_USEINT
SIGNAL(SIG_SPI)
{
	spiTransferComplete = TRUE;
}
#endif

// access routines
void spiInit()
{
#if defined (__AVR_ATmega128__) || defined (__AVR_ATmega2560__)
	// setup SPI I/O pins
	PORTB |= (1<<1); // set SCK hi
	DDRB |= (1<<1); // set SCK as output
	DDRB &= ~(1<<3); // set MISO as input
	DDRB |= (1<<2); // set MOSI as output
	DDRB |= (1<<0); // SS must be output for Master mode to work
#elif defined __AVR_ATmega8__
  // setup SPI I/O pins
  sbi(PORTB, 5);  // set SCK hi
  sbi(DDRB, 5);   // set SCK as output
  cbi(DDRB, 4);   // set MISO as input
  sbi(DDRB, 3);   // set MOSI as output
  sbi(DDRB, 2);   // SS must be output for Master mode to work
#else
	// setup SPI I/O pins
	sbi(PORTB, 7);	// set SCK hi
	sbi(DDRB, 7);	// set SCK as output
	cbi(DDRB, 6);	// set MISO as input
	sbi(DDRB, 5);	// set MOSI as output
	sbi(DDRB, 4);	// SS must be output for Master mode to work
#endif
	
	// setup SPI interface :
	// master mode
	SPCR |= (1<<MSTR);
	// clock = f/4
//	SPCR &= ~(1<<SPR0);
//	SPCR &= ~(1<<SPR1);
	// clock = f/8
	SPCR |= (1<<SPR0);
	SPCR &= ~(1<<SPR1);
	SPCR |= (1<<SPI2X);
	// clock = f/16
//	SPCR &= ~(1<<SPR0);
//	SPCR |= (1<<SPR1);
	// clock polarity, select clock phase positive-going in middle of data
	SPCR |= (1<<CPOL);
	// Data order MSB first
	SPCR &= ~(1<<DORD);
	// enable SPI
	SPCR |= (1<<SPE);
	// clock phase
	SPCR |= (1<<CPHA);
	// some other possible configs
	//outp((1<<MSTR)|(1<<SPE)|(1<<SPR0), SPCR );
	//outp((1<<CPHA)|(1<<CPOL)|(1<<MSTR)|(1<<SPE)|(1<<SPR0)|(1<<SPR1), SPCR );
	//outp((1<<CPHA)|(1<<MSTR)|(1<<SPE)|(1<<SPR0), SPCR );
	
	// clear status
	SPSR;
	spiTransferComplete = TRUE;

	// enable SPI interrupt
	#ifdef SPI_USEINT
	SPRC |= (1<<SPIE);
	#endif
}
/*
void spiSetBitrate(uint8_t spr)
{
	outb(SPCR, (inb(SPCR) & ((1<<SPR0)|(1<<SPR1))) | (spr&((1<<SPR0)|(1<<SPR1)))));
}
*/
void spiSendByte(uint8_t data)
{
	// send a byte over SPI and ignore reply
	#ifdef SPI_USEINT
		while(!spiTransferComplete);
		spiTransferComplete = FALSE;
	#else
		while(!(SPSR & (1<<SPIF)));
	#endif

	SPDR = data;
}

uint8_t spiTransferByte(uint8_t data)
{
	#ifdef SPI_USEINT
	// send the given data
	spiTransferComplete = FALSE;
	SPDR = data;
	// wait for transfer to complete
	while(!spiTransferComplete);
	#else
	// send the given data
	SPDR = data;
	// wait for transfer to complete
	while(!(SPSR & (1<<SPIF)));
	#endif
	// return the received data
	return SPDR;
}

uint16_t spiTransferWord(uint16_t data)
{
	uint16_t rxData = 0;

	// CS low
	PORTB &= ~(1<<0);
	// send MS byte of given data
	rxData = (spiTransferByte((data>>8) & 0x00FF))<<8;
	// send LS byte of given data
	rxData |= (spiTransferByte(data & 0x00FF));
	// CS high
	PORTB |= (1<<0); 
	_delay_us(7);

	// return the received data
	return rxData;
}
