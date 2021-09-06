;----------------------------------------------------------------------
				; Universidad de Buenos Aires
				; Facultad de Ingenieria 

				; Laboratorio de microprocesadores 
				; Trabajo Practico N3 : Puerto Serie

				; Alumna : Lucia Berard
				; Padron : 101213
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;						Resumen del programa
;----------------------------------------------------------------------
/*1) Al encender el microcontrolador, el programa deberá transmitir el texto 
				*** Hola Labo de Micro *** 
			Escriba 1, 2, 3 o 4 para controlar los LEDs 

El texto de arriba deberá mostrarse en el terminal serie 

2) Si en el terminal serie se aprieta la tecla ‘1’,se enciende/apaga el LED 1 (toggle).
 Si se aprieta la tecla ‘2’, ocurre lo propio con el LED 2 
 y así lo propio para los cuatro LEDs.  
*/

;----------------------------------------------------------------------
;				Conexion de pines en el Arduino UNO
;----------------------------------------------------------------------
; 4 leds conectados en serie con resistencias de 220 ohm en los pines:
;  8, 9, 10 y 11 del arduino 

;----------------------------------------------------------------------
.include "m328pdef.inc"
.include "macros.inc"

.cseg 
.org 0x0000
	jmp		config

.org INT_VECTORS_SIZE

;----------------------------------------------------------------------
;				Configuracion de los puertos
;----------------------------------------------------------------------

config:
	; Inicializo el stack
	initSP

	; Declaro PortB como salida (LEDs)
	configport DDRB,0xff 

	; Configuro BAUD RATE
	configUBRRO

	; Habilito receptor y emisor
	configUCSR0B

	; 8bit data, 1 stop bit, sin paridad
	configUCSR0C

;----------------------------------------------------------------------
;							Main
;----------------------------------------------------------------------

main:	
	;Escribo el mensaje inicial 						
	writeMessage
	
	;Espero recibir un mensaje para prender los LEDs
	loop:				
		receive_input
		rjmp loop
;----------------------------------------------------------------------
;							Mensaje
;----------------------------------------------------------------------
					
MENSAJE:
.DB '*','*','*',' ','H','o','l','a',' ','L','a','b','o',' ','d','e',' ','M','i','c','r','o',' ','*','*','*','\n','E','s','c','r','i','b','a',' ','1',',','2',',','3',' ','o',' ','4',' ','p','a','r','a',' ','c','o','n','t','r','o','l','a','r',' ','l','o','s',' ','L','E','D','s'