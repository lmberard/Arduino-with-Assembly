;---------------------------------------------------------------------
;---------------------------------------------------------------------
						; Universidad de Buenos Aires
						; Facultad de Ingenieria 

						; Laboratorio de microprocesadores 
						; Trabajo Practico Integrador 

						; Alumna : Lucia Berard
						; Padron : 101213
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;						Resumen del programa
;----------------------------------------------------------------------
; Estudiar la carga y descarga en condensadores:
;	Generar con FAST PWM una señal de 50 Hz con un DC de 50%
;	Verificar la frecuencia generada con el modo de captura del timer1
;	Adquirir con el ADC valores de voltaje sobre el capacitor
;	Transmitir esos valores a una pc por via serial
;	Graficar los resultados obtenidos

;----------------------------------------------------------------------
;				Conexion de pines en el Arduino UNO
;----------------------------------------------------------------------
; Circuito RC
; R = 220 ohm
; C = 10 uF
; (valido cualquier circuito con tau entre 1,5ms y 2 ms)
; Puertos 8, 2 y 6 conectados a la resistencia.
; Puerto A0 conectado a la otra pata de la resistencia y al capacitor
; La otra pata del capacitor conectado a GND

;----------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;								Constantes y registros
;----------------------------------------------------------------------------------------------

.equ FCPU = 16*10^6 ;frecuencia de oscilacion 16MHz
.equ BAUD = 9600 
.equ BPS = 103 ;((FCPU/16/BAUD) - 1)
.equ VALOR_CONT  = 8000
.def count = R17

.include "m328Pdef.inc"

;Interrupciones---------
.org 0x0016
	rjmp transmitir
;-----------------------

.org 0x0000
	rjmp config
.org INT_VECTORS_SIZE
;--------------------------------------------------------------------
;			Configuracion de los puertos, timer e interrupciones
;--------------------------------------------------------------------

config:
	;Inicializo el Stack Pointer
	rcall initSP
	
	;PORTB pin 0: (puerto 8 arduino) ICP1
	sbi		DDRB, 0	
	;PORTD pin 6: (puerto 6 arduino) PWM			
	sbi		DDRD, 6				
	;PORTC pin 0: (puerto A0 arduino) Entrada analogica ADC 
	cbi		DDRC, 0
	;PORTD pin 2: (puerto 2 arduino) Entrada INT0
	cbi		DDRD, 2
	;PORTB pin 1: Activa int por captura
	;sbi PORTB, 1
	
	;PWM: Fast PWM, Prescaler en 1024, Duty Cicle del 50%
	rcall configPWM
		
	;Timer1 Modo normal, prescaler 1024, flanco ascendente
	rcall configTimer1 

	;Timer1 interrupcion por captura
	;rcall configINT_Timer1 

	;Puerto serie: BaudRate, Velocidad normal, habilito transmision y recepcion. Asincronico, sin paridad y 8 bits de datos
	rcall configSerialPort

	;ADC: Registro de salida a la izquierda y configuro la entrada ADC0
	rcall configADC

	;ADC: Habilito ADC, inicio, prescaler de 128 y deshabilito el buffer de la entrada
	rcall initADC

	;Interrupcion: Cualquier cambio en el PIN activa la interrupción, habilito y borro flags
	;rcall configINT0

	;Activo interrupciones globales
	sei
;----------------------------------------------------------------------
;							Programa 
;----------------------------------------------------------------------
transmitir:		
	lds		R16, UCSR0A      
	sbrs	R16, UDRE0      
	rjmp	transmitir
	
	lds		R16, ADCH
	sts		UDR0, R16
	jmp		transmitir
	sei
;----------------------------------------------------------------------
;							Rutinas 
;----------------------------------------------------------------------
;Inicializacion del Stack Pointer---------------------------------
initSP:
	ldi		R16, HIGH(RAMEND)
	out		SPH, R16	
	ldi		R16, LOW(RAMEND)
	out		SPL, R16
	ret

;PWM-------------------------------------------------------------
configPWM:
	;Fast PWM
	ldi		R16, (1<<COM0A1) | (1<<WGM00) | (1<<WGM01) | (1<<WGM02) ;10000011
	out		TCCR0A, R16
	;Prescaler en 1024
	ldi		R16, (1<<CS02) | (1<<CS00) ;00000101
	out		TCCR0B, R16
	;Timer en cero
	clr		R16
	out		TCNT0, R16
	;Duty Cicle del 50%
	ldi		R16, 126
	out		OCR0A, R16
	ret

;Configuracion Timer--------------------------------------------
configTimer1:
	ldi		R16, (1<<ICES1) | (1<<CS10) | (1<<CS12) ;0b01000101
	sts		TCCR1B, R16
	ret

configINT_Timer1:
	ldi		R16,(1<<ICIE1) ;0b00100000 
	sts		TIMSK1, R16
	ret
;Puerto serie-----------------------------------------------------
configSerialPort:

	;Habilito transmision y recepcion
	ldi		R16, (1<<TXEN0) | (1<<RXEN0) ;0b00001000
	sts		UCSR0B, R16

	;Asincronico, sin paridad y 8 bits de datos
	ldi		R16, (1<<UCSZ00) | (1<<UCSZ01) ;0b00000110
	sts		UCSR0C, R16

	;Configuro Baud rate
	clr		R16
	sts		UBRR0H, R16
	ldi		R16, BPS 
	sts		UBRR0L, R16
	ret

habilitarINTRecep:
;Modifico UCSR0B para habilitar las interrupciones por recepcion
	lds		R16, UCSR0B      
	sbr		R16, (1<<RXCIE0) ;0b10000000
	sts		UCSR0B, R16
	ret

;ADC---------------------------------------------------------------
configADC:
	;Registro de salida a la izquierda y configuro la entrada ADC0
	ldi		R16, 0b01100000	;(1<<ADLAR) | (1<<REFS0)
	sts		ADMUX, R16   
	ret

initADC:
	;Habilito el ADC, el inicio de la conversion y un prescaler de 128 para el clock interno
	ldi		R16, 0b11100111;(1<<ADEN) | (1<<ADSC) | (1<<ADPS2) | (1<<ADPS1)| (1<<ADPS0)  
	sts		ADCSRA, R16  
	ret

;Interrupcion-----------------------------------------------------
configINT0:
	ldi		R16, (1<<ISC00)
	sts		EICRA, R16
	;Habilito interrupcion
	ldi		R16, (1<<INT0) ; o INTF0?
	out		EIMSK, R16
	;Borro flags
	ldi		R16, (1<<INTF0)
	out		EIFR, R16
	ret
;----------------------------------------------------------------------
;							Mensajes 
;----------------------------------------------------------------------
/*
Mensaje_error: 
	.db "Error en Frecuencia o Duty Cycle", 0
Mensaje_verificacion: 
	.db "Frecuencia y Duty Cycle correctos", 0	
*/
