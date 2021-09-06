; Universidad de Buenos Aires
; Facultad de Ingenieria 

; Laboratorio de microprocesadores 
; Trabajo Practico N1 : Manejo de puertos

; Alumna : Lucia Berard
; Padron : 101213
; Fecha	 : 19/05/2021
.include "m328pdef.inc" 
;----------------------------------------------------
.equ LED_PIN	= 2
;----------------------------------------------------
.DSEG 
.ORG SRAM_START
;----------------------------------------------------
.cseg 
.org 0x0000 
	rjmp main 
.org INT_VECTORS_SIZE 
;----------------------------------------------------
main: 
	;Inicializacion del stack pointer
	LDI		R16,HIGH(RAMEND)
    OUT		SPH,R16 
    LDI		R16,LOW(RAMEND)
    OUT		SPL,R16 
	; Configuro puerto B 
	ldi		r20,0xff  
	out		DDRD,r20 

;----------------------------------------------------
blink: 
	sbi PORTD,LED_PIN ; encendido del led 
	rcall delay
	cbi PORTD,LED_PIN ; apagado del led 
	rcall delay
	rjmp blink
;----------------------------------------------------
delay: 
	ldi		r20, 100 
	loop3: 
		ldi		r21, 100
	loop2: 
		ldi		r22, 100
	loop1: 
		dec		r22 
		brne	loop1