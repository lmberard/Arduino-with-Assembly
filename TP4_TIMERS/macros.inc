;---------------------------------------------------------------------
;---------------------------------------------------------------------
			; Universidad de Buenos Aires
			; Facultad de Ingenieria 

			; Laboratorio de microprocesadores 
			; Trabajo Practico N4 
			; Alumna : Lucia Berard
			; Padron : 101213
;----------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
;			Constantes y registros
;----------------------------------------------------------------------------------------------

;Registros auxiliares
.def	aux1 = R16
.def	aux2 = R17

;Registro para entrada de interrupciones
.def	input = R19

;Configuracion Baud Rate
.equ	FOSC = 16*10^6 ;frecuencia de oscilacion 16MHz
.equ	BAUD = 9600
.equ	BPS = 103 ;((FCPU/16/BAUD) - 1)

;Configuracion rutinas de interrupcion:
.equ	MASK_INTs = 0x0C; 0000 11 00 ->ubicacion de INT0 e INT1

;Estados posibles - Configuracion frecuencia de parpadeo
.equ	STATE_01 = 0x04 ; 0000 01 00 -> clk 64
.equ	STATE_10 = 0x08 ; 0000 10 00 -> clk 256
.equ	STATE_11 = 0x0C ; 0000 11 00 -> clk 1024
.equ	STATE_00 = 0x00 ; 0000 00 00 -> fijo

;Modos del CLOCK
.equ	CS_011 = 0xFB	; 11111 011 -> clk 64
.equ	CS_100 = 0xFC	; 11111 100 -> clk 256
.equ	CS_101 = 0xFD	; 11111 101	-> clk 1024
.equ	CS_000 = 0xF8	; 11111 000 -> Sin Clock

;----------------------------------------------------------------------------------------------
;				Configuraciones 
;----------------------------------------------------------------------------------------------
;Configuracion resistencias de pull up---------------------------------------------------------
.macro configpullup
	clr		aux1
	ldi		aux1, @0	
	out		@1,aux1
	clr		aux1
.endmacro

;Configuracion de los puertos -----------------------------------------------------------------
.macro configport
	ldi		aux1, @1
	out		@0, aux1 
.endmacro

;Configuracion Puerto Serie -------------------------------------------------------------------
.macro configUBRRO
	ldi		aux1, 0x00
	sts		UBRR0H, aux1 
	ldi		aux1, BPS
	sts		UBRR0L, aux1
.endmacro

.macro configUCSR0B
	ldi		aux1, (1<<RXEN0) | (1<<TXEN0) 
	sts		UCSR0B, aux1
.endmacro

.macro configUCSR0C
	ldi		aux1, (1<<UCSZ01) | (1<<UCSZ00)
	sts		UCSR0C, aux1
.endmacro


;Configuracion de las interrupciones ----------------------------------------------------------
.macro configINT
	lds		aux1, EICRA
	ori		aux1, (1 << ISC00)
	andi		aux1, ~((1<<ISC01))
	sts		EICRA, aux1

	lds		aux1, EICRA
	ori		aux1, (1 << ISC10)
	andi		aux1, ~((1<<ISC11))
	sts		EICRA, aux1
.endmacro

.macro configINT_MSK
	ldi		aux1,  (1<<INT0)|(1<<INT1)
	out		EIMSK,aux1
.endmacro

;Configuracion del timer ----------------------------------------------------------------------
.macro configTimer
	;Modo Normal y Pin Tn flanco descendente

	;WGM[1:0] = 00
	lds		aux1, TCCR1A
	andi		aux1, 0xfc ; 111111 00
	sts		TCCR1A, aux1
	 
	;WGM[2] = 0 
	;CS[2:0] 110: flanco descendente externo
	lds		aux1, TCCR1B
	andi		aux1, 0xf6 ; 1111 0 110
	sts		TCCR1B, aux1 
.endmacro

.macro configTimerOverflow
	ldi		aux1, (1<<TOIE1)
	sts		TIMSK1, aux1
.endmacro

;Recordatorio: usar SEI despues de agregar estas macros!
;----------------------------------------------------------------------------------------------
;			Inicializaciones
;----------------------------------------------------------------------------------------------

;Inicializacion del Stack Pointer--------------------------------------------------------------
.macro initSP
	ldi		aux1, HIGH(RAMEND)
	out		SPH, aux1	
	ldi		aux1, LOW(RAMEND)
	out		SPL, aux1
.endmacro


; esta macro inicializa el puntero Z a una posicion en ROM-------------------------------------
.macro	initZ
	ldi		Zh,HIGH(@0<<1) 
	ldi		Zl,LOW(@0<<1)
.endmacro

;----------------------------------------------------------------------------------------------
;			Leer Interrupcion
;----------------------------------------------------------------------------------------------
.macro readINTs
	;Obtengo la señal del interruptor y guardo en aux
	in		aux1, PIND
	;Aplico mascara para que solo traiga los valores de INT0 e INT1
	andi		aux1, MASK_INTs
	;Espero
	debounceTime
	;Guardo la señal en input
	in		input, PIND
	andi		input, MASK_INTs
	;Comparo para evitar errores.
	cp		aux1, input
	brne		INTend
.endmacro

;----------------------------------------------------------------------------------------------
;			Delay por timer
;----------------------------------------------------------------------------------------------
.macro delayByTimer
	clr		aux2
	out		TCNT0, aux2

	lds		aux2, TCCR0A
	andi		aux2, ~((1 << WGM01)|(1<<WGM00))
	out		TCCR0A, aux2

	lds		aux2, TCCR0B
	ori		aux2, (1<<CS02)|(1<<CS00)
	andi		aux2, ~((1 << WGM02)|(1<<CS01))
	out		TCCR0B, aux2

	delayLoop:
		in		aux2, TIFR0
		sbrs		aux2, TOV0
		rjmp		delayLoop

		ldi		aux2, 0
		out		TCCR0A, aux2
		out		TCCR0B, aux2
		ldi		aux2, 0x01
		out		TIFR0, aux2

.endmacro

;----------------------------------------------------------------------------------------------
;			Debounce Time con delay por timer
;----------------------------------------------------------------------------------------------
.macro debounceTime
		ldi		aux2, 2

	debounceLoop:
		delayByTimer
		dec		aux2
		cpi		aux2,0
		brne		debounceLoop
.endmacro
