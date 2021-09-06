;----------------------------------------------------------------------
				; Universidad de Buenos Aires
				; Facultad de Ingenieria 

				; Laboratorio de microprocesadores 
	; Trabajo Practico N2 : Entradas/Salidas - Interrupciones externas

				; Alumna : Lucia Berard
				; Padron : 101213

;----------------------------------------------------------------------
;						Resumen del programa
;----------------------------------------------------------------------

;El display inicialmente mostrará el dígito “5”.
;PD2 decrementa el contador
;PD3 incrementa el contador
;Verificar los limites. Si llega a 0 o 9 frena en ese valor.

;----------------------------------------------------------------------
;				Conexion de pines en el Arduino UNO
;----------------------------------------------------------------------

;Display 7 segmentos:
;(g,f,e,d,c,b,a) = (PD7,PB5,PB4,PB3,PB2,PB1,PB0)

;Interrupciones
;pd2	= 2  (PortD - 2) 
;pd3 = 3	 (PortD - 3)

;----------------------------------------------------------------------
.include "m328pdef.inc"
.include "macros.inc"

;----------------------------------------------------------------------
;						Interrupciones
;----------------------------------------------------------------------

.org INT0addr
	rjmp	INT0action
.org INT1addr
	rjmp	INT1action
.cseg
.org 0x00
	jmp		main

;-----------------------------------------------------------------------
;							Main
;-----------------------------------------------------------------------

 .org INT_VECTORS_SIZE
 
 main:
	; Configuro en los puertos
 	configports

	; Configuro el stack
	initSP 

	; Configuro las interrupciones externas
	configINT

	; Inicializo el display
	initDisplay
	showDigit

	; Loop principal 
	loop:
		showDigit
		nop
		jmp		loop
		
;-----------------------------------------------------------------------
;					Rutina de interrupción - INT0
;-----------------------------------------------------------------------
INT0action:
	rcall	delay
	rcall	decrement
INT0end:
	reti 

INT1action:
	rcall	delay
	rcall	increment
INT1end:
	reti 

;-----------------------------------------------------------------------
;						Decremento del contador
;-----------------------------------------------------------------------
decrement:
	cpi		counter,MIN_VALUE
	breq	return
	dec		counter
ret
;-----------------------------------------------------------------------
;						Incremento del contador
;-----------------------------------------------------------------------
increment:
	cpi		counter,MAX_VALUE
	breq	return
	inc		counter	
ret

return:
	ret

;-----------------------------------------------------------------------
;				Delay temporal para evitar rebotes
;-----------------------------------------------------------------------
delay:

	ldi dummyreg1, DELAY_TIME 

	loop1:
		sbic	PIND, PD3
		jmp		INT0end
		sbic	PIND, PD2
		jmp		INT1end
		ldi		dummyreg2, DELAY_TIME

	loop2:
		ldi		dummyreg3, DELAY_TIME
	
	loop3:
		dec		dummyreg3
		brne	loop3 
		dec		dummyreg2
		brne	loop2
		dec		dummyreg1
		brne	loop1
		ret
ret


;-----------------------------------------------------------------------
;					Tabla ROM: Display 7 Segmentos
;-----------------------------------------------------------------------
 .org 0x0100

 TABLE_DISPLAY:
	.db 0x3F,0x06,0x9B,0x8F,0xA6,0xAD,0xBD,0x07,0xBF,0xA7 
