;----------------------------------------------------------------------
				; Universidad de Buenos Aires
				; Facultad de Ingenieria 

				; Laboratorio de microprocesadores 
				; Trabajo Practico N3 : Puerto Serie

				; Alumna : Lucia Berard
				; Padron : 101213
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;			Resumen del programa
;----------------------------------------------------------------------
; Parpadeo de un LED conectado al PB0, en 3 frecuencias distintas
; o que lo deje ENCENDIDO FIJO, según los valores que haya en 
; las interrupciones INT0 o INT1

;----------------------------------------------------------------------
;		Conexion de pines en el Arduino UNO
;----------------------------------------------------------------------
; Pulsadores en puerto 2 y 3 del arduino y alimentados a 5V, 
; resistencia de 1Kohm para cada uno
; Led en puerto 8 del arduino en serie con resistencia 220 ohm.
;----------------------------------------------------------------------

.include "m328pdef.inc"
.include "macros.inc"


.cseg 
;Interupciones------------
.org INT0addr
	rjmp	INTaction
.org INT1addr
	rjmp	INTaction
.org 0x001A ; Timer/Counter1 Overflow
	rjmp	OVFaction
;-------------------------

.org 0x0000
	jmp		config
.org INT_VECTORS_SIZE

;----------------------------------------------------------------------
;			Configuracion de los puertos, timer e interrupciones
;----------------------------------------------------------------------
config:
	;inicializo el stack
	initSP

	;Interrupcion por overflow del timer1
	configTimer
	configTimerOverflow

	;Interrupciones
	configINT
	configINT_MSK

	;PORTB como salida(LED)
	;0x01 porque solo uso PB0 (puerto 8 arduino)
	configport DDRB,0x01

	;PORTD como entrada (Pulsadores)
	configport DDRD,0x00

	;Empieza con LED encendido fijo
	sbi PORTB, PB0

	sei

;----------------------------------------------------------------------
;							Main
;----------------------------------------------------------------------
;El main principal no hace nada, se maneja todo con interrupciones
main:
	rjmp main

;----------------------------------------------------------------------
;					Rutina de interrupcion - Pulsador
;----------------------------------------------------------------------
INTaction:
	;Leo valor de las interrupciones
	readINTs

	;Reviso cual es el estado correspondiente 
	cpi	input, STATE_00
	breq	no_clk

	cpi	input, STATE_01
	breq	clk_64

	cpi	input, STATE_10
	breq	clk_256

	cpi	input, STATE_11
	breq	clk_1024

	rjmp	INTend

INTend:
	reti

;----------------------------------------------------------------------
;						Distintas frecuencias
;----------------------------------------------------------------------
no_clk:
	;CS_000: 0xF8 = 11111 000 -> Sin Clock
	lds	aux1, TCCR1B
	andi	aux1, CS_000
	sts	TCCR1B, aux1
	sbi	PORTB, 0
	rjmp	INTend

clk_64:
	;CS_011: 0xFB = 11111 011
	lds	input, TCCR1B
	ori	input, (1<<CS10)|(1<<CS11)
	andi	input, ~((1<<CS12))
	sts	TCCR1B, input
	rjmp	INTend

clk_256:
	;CS_100: 0xFC = 11111 100
	lds	input, TCCR1B
	ori	input, (1<<CS12)
	andi	input, ~((1<<CS11) | (1<< CS10))
	sts	TCCR1B, input
	rjmp	INTend

clk_1024:
	;CS_101: 0xFD = 11111 101
	lds	input, TCCR1B
	ori	input, (1<<CS10)|(1<<CS12)
	andi	input, ~((1<<CS11))
	sts	TCCR1B, input

;----------------------------------------------------------------------
;					Rutina de interrupcion - Overflow
;----------------------------------------------------------------------
OVFaction:
	sbi	PINB, 0
reti

