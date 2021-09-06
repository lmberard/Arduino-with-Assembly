; Universidad de Buenos Aires
; Facultad de Ingenieria 

; Laboratorio de microprocesadores 
; Trabajo Practico N1 : Manejo de puertos

; Alumna : Lucia Berard
; Padron : 101213
; Fecha	 : 19/05/2021
;----------------------------------------------------------------------
.include "m328pdef.inc"
			
.equ PBUTTON_1		= 0			;PortB
.equ PBUTTON_2		= 7			;PortD
.equ LED_PIN		= 2			;PortD

;----------------------------------------------------------------------
.DSEG 
.ORG SRAM_START

;----------------------------------------------------------------------
.cseg							
.org 0x0000						
rjmp config

.org INT_VECTORS_SIZE			

config:
	;Inicializacion del stack pointer
	LDI		R16,HIGH(RAMEND)
    OUT		SPH,R16 
    LDI		R16,LOW(RAMEND)
    OUT		SPL,R16 
	;Configuracion del puerto
	ldi		r20,0xFF		
	out		DDRD,r20		
	cbi		PORTD,LED_PIN
	ldi		r20,0x00
	out		DDRB,r20
	;Configuracion R pull up		 
	;ldi		r20,0x00
	;out		PORTD,r20

main:
	rcall	pbutton_input
	rcall	mainloop
	rjmp	main

;----------------------------------------------------------------------
;Verifico si se presiono el pulsador de encendido
pbutton_input:
	sbis	PINB, PBUTTON_1				
	rjmp	pbutton_input
	rcall	delay					
	sbis	PINB, PBUTTON_1				
	rjmp	pbutton_input
	ret
	rcall	delay

;Parpadeo--------------------------------------------------------------

mainloop:
	;Blink:
	rcall	delay
	sbi		PORTD,LED_PIN			;prendo
	rcall	delay
	cbi		PORTD,LED_PIN
	;Espero el botón de apagado
	sbis	PIND, PBUTTON_2
	rjmp	mainloop
	rcall	delay				
	sbis	PIND, PBUTTON_2			
	rjmp	mainloop
	cbi		PORTD,LED_PIN			;apago el led
ret

;Delay--------------------------------------------------------------
delay:
		ldi		r20, 100 
	loop3: 
		ldi		r21, 100  
	loop2: 
		ldi		r22, 100
	loop1: 
		dec		r22
		brne	loop1
		dec		r21
		brne	loop2 
		dec		r20 
		brne	loop3 
		ret
