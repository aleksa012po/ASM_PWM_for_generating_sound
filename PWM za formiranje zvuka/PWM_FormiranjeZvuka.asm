;
; PWM_FormiranjeZvuka.asm
;
; Created: 9/28/2022 10:41:54 AM
; Author : Alex
;

//Arduino Asembler, PWM za formiranje zvuka, umesto dosadašnjih petlji.

.include "m328pdef.inc"
.org 0x0000
rjmp main_song

.def sp_Loop = r18			// Spoljasni loop register
.def un_LoopL = r24			// Unutrasnji loop LOW registar
.def un_LoopH = r25			// Unutrasnji loop HIGH registar
.equ value = 39998			// Unutrasnja loop vrednost
// TONOVI
.equ _c4 = 239 ; (16000000 / 256) / 261.63 (frekvencija note C4) - 1
.equ _d4 = 213 ; (16000000 / 256) / 293.66 (frekvencija note D4) - 1
.equ _e4 = 190 ; (16000000 / 256) / 329.63 (frekvencija note E4) - 1
.equ _f4 = 179 ; (16000000 / 256) / 349.23 (frekvencija note F4) - 1
.equ _g4 = 159 ; (16000000 / 256) / 392.00 (frekvencija note G4) - 1
.equ _a4 = 141 ; (16000000 / 256) / 440.00 (frekvencija note A4) - 1
.equ _b4 = 126 ; (16000000 / 256) / 493.88 (frekvencija note B4) - 1
.equ _c5 = 118 ; (16000000 / 256) / 554.37 (frekvencija note C5) - 1
// PWM
.equ c4_ = 120 ;(16000000 / 256) / 261.63 / 2(frequency of C) - 1
.equ d4_ = 107 ;(16000000 / 256) / 293.66 / 2(frequency of D) - 1
.equ e4_ = 95 ;(16000000 / 256) / 329.63 / 2(frequency of E) - 1
.equ f4_ = 90 ;(16000000 / 256) / 349.23 / 2(frequency of F) - 1
.equ g4_ = 80 ;(16000000 / 256) / 392.00 / 2(frequency of G) - 1
.equ a4_ = 71 ;(16000000 / 256) / 440.00 / 2(frequency of A) - 1
.equ b4_ = 63 ;(16000000 / 256) / 493.88 / 2(frequency of B) - 1
.equ c5_ = 59 ;(16000000 / 256) / 523.25 / 2(frequency of C) - 1

.macro tone
	// wgm 2.0 = 0x00000111 = 7. fast PWM, TOP = OCR0A
	// Prescaler 256, 0x00000100
	// cs02.0 = 2, 0x00000010, Clear on Compare Match, set at BOTTOM, non inverting mode
	ldi r16, 0b00100011
	out TCCR0A, r16
	ldi r16, 0b00001100
	out TCCR0B, r16
	// OCR0A = _a za 440Hz
	ldi r16, @0
	out OCR0A, r16
	// OCR0B = OCR0A / 2 da bi duty cycle bio 50%
	ldi r17, @1
	out OCR0B, r17
	// Izlaz je na D5, OCR0B
	sbi ddrd, 5			// Set Bit in I/O Register
.endmacro

.macro mute
	cbi ddrd, 5			//Clear Bit in I/O Register
.endmacro

.macro delayms
	push r18
	push r24
	push r25

	ldi r18, @0/10
	call delay10ms

	pop r25
	pop r24
	pop r18
.endmacro

// Sijaj sijaj zvezdo mala

main_song:
	mute
	delayms 300
	tone _c4, c4_	// DO
	delayms 300

	mute
	delayms 300
	tone _c4, c4_	// DO
	delayms 300

	mute
	delayms 300
	tone _g4, g4_	// SOL
	delayms 300

	mute
	delayms 300
	tone _g4, g4_	// SOL
	delayms 300

	mute
	delayms 300
	tone _a4, a4_	// LA
	delayms 300

	mute
	delayms 300
	tone _a4, a4_	// LA
	delayms 300

	mute
	delayms 300
	tone _g4, g4_	// SOL fa fa mi mi re re do
	delayms 500

	mute
	delayms 300
	tone _f4, f4_	// FA
	delayms 300

	mute
	delayms 300
	tone _f4, f4_	// FA
	delayms 300

	mute
	delayms 300
	tone _e4, e4_	// MI
	delayms 300

	mute
	delayms 300
	tone _e4, e4_	// MI
	delayms 300

	mute
	delayms 300
	tone _d4, d4_	// RE
	delayms 300

	mute
	delayms 300
	tone _d4, d4_	// RE
	delayms 300

	mute
	delayms 300
	tone _c4, c4_	// DO
	delayms 400

	delayms 2000
	jmp main_song

	// Delay
	delay10ms:
		ldi un_LoopL, low(value)	// Inicijalizuje unutrasnji loop counter
		ldi un_LoopH, low(value)

	loop1:
		sbiw un_LoopL, 1			// Umanjuje unutrasnji loop registar za 1
		brne loop1				

		dec sp_Loop					// Umanjuje spoljasnji loop register za 1
		brne delay10ms
		nop
		ret