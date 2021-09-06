;---------------------------------------------------------------------
;---------------------------------------------------------------------
						; Universidad de Buenos Aires
						; Facultad de Ingenieria 

						; Laboratorio de microprocesadores 
						; Trabajo Practico N2 
						; Entradas/Salidas 
						;Interrupciones externas

						; Alumna : Lucia Berard
						; Padron : 101213
;----------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
;								Constantes y registros
;----------------------------------------------------------------------------------------------

;Registros auxiliares
.def	aux1 = R17
.def	aux2 = R18
.def	aux3 = R19

;Configuracion Baud Rate
.equ	FOSC = 16*10^6 ;frecuencia de oscilacion 16MHz
.equ	BAUD = 9600
.equ	BPS = 103 ;((FCPU/16/BAUD) - 1)

;----------------------------------------------------------------------------------------------
;								Configuraciones puertos
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
		clr		aux1
		ldi		aux1,(1<<ISC01)|(1<<ISC11)
		sts		EICRA,aux1
	
		ldi		aux1,  (1<<INT0)|(1<<INT1)
		out		EIMSK,aux1

		sei 
.endmacro
;----------------------------------------------------------------------------------------------
;								Inicializaciones
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
;								Macros utiles
;----------------------------------------------------------------------------------------------

.macro writeMessage
				initZ	MENSAJE	
				ldi		aux2, 68									   

	Znext:		lpm		aux1, Z+
				
	transmit:	lds		aux3, UCSR0A						
				sbrs	aux3, UDRE0						
				rjmp	transmit				
				sts		UDR0, aux1			
				dec		aux2
				brne	Znext
	clr		aux2
.endmacro

.macro receive_input

	receive:
			;Espero a recibir la info
			lds		aux3, UCSR0A
			sbrs	aux3, RXC0
			
			;Recibio data, sale del loop
			rjmp	receive
			lds		aux1, UDR0
			
			;Descarto bits con una mascara
			andi	aux1, 0x0f
			
			;Si no es 1,2,3,4 no hago nada	
			cpi		aux1, 1 
			brlo	receive
			cpi		aux1, 5
			brcc	receive
			
			;Si es un 4
			sbrc	aux1,2
			lsl		aux1	

			;Si es un 3
			cpi		aux1,3
			brne	not3
			inc		aux1

			not3:
				;Alto<->Bajo		
				eor		aux2, aux1
				out		PORTB, aux2
.endmacro