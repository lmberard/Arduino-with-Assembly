;----------------------------------------------------------------------
				; Universidad de Buenos Aires
				; Facultad de Ingenieria 

				; Laboratorio de microprocesadores 
				; Trabajo Practico N4 : PWM

				; Alumna : Lucia Berard
				; Padron : 101213
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;			Resumen del programa
;----------------------------------------------------------------------
;El programa aumenta y disminuye el brillo de un LED. 
;Para eso se dispone de 2 pulsadores (UP, DOWN), un led y una resistencia 220ohm.
;Para la variación de brillo se usa PWM para modificar el ciclo de trabajo de una señal (sin modificar su frecuencia). 
;Con esta señal se alimentará el LED, de forma que el valor medio de la señal será proporcional al brillo del LED, a 
;mayor ancho de pulso, más brillo.

;----------------------------------------------------------------------
;			Conexion de pines en el Arduino UNO
;----------------------------------------------------------------------
; Pulsadores en puerto 2 y 3 del arduino y alimentados a 5V
; Led en puerto 9 del arduino en serie con resistencia 220 ohm.

;----------------------------------------------------------------------
.include "m328pdef.inc"
.include "macros.inc"

;Interrupciones:
.org INT0addr
	rjmp	INT0action
.org INT1addr
	rjmp	INT1action

.cseg 
.org 0x0000
	jmp	config

.org INT_VECTORS_SIZE

;----------------------------------------------------------------------
;			Configuracion de los puertos
;----------------------------------------------------------------------

config:
	; Inicializo el stack
	initSP

	; Declaro PortB como salida (LED)
	configport DDRB,0xff 

	;Declaro PortD como entrada (pulsadores)
	configport DDRD,0x00

	; Configuro interrupciones
	configINT

	; Configuro timer
	configtimer

;----------------------------------------------------------------------
;			Main
;----------------------------------------------------------------------
;El loop principal no hace nada, todo lo hacen las interrupciones
main:	
	rjmp	main

;-----------------------------------------------------------------------
;			Rutinas de interrupción 
;-----------------------------------------------------------------------
;Incrementa
INT0action:
	;Verifico el maximo
	cpi	aux1, 0xff
	breq	INT0end
	ldi	aux2, 10
	add	aux1, aux2
	sts	OCR1AL, aux1  

	INT0end:
		reti

;Disminuye
INT1action:
	;Verifico el minimo
	cpi	aux1, 0x00
	breq	INT1end
	ldi	aux2, 10
	sub	aux1, aux2
	sts	OCR1AL, aux1
	
	INT1end:
		reti 
