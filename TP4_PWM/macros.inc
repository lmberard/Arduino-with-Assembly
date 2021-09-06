;---------------------------------------------------------------------
;---------------------------------------------------------------------
		; Universidad de Buenos Aires
		; Facultad de Ingenieria 
		; Laboratorio de microprocesadores 
		; Trabajo Practico N4 : PWM
		; Alumna : Lucia Berard
		 Padron : 101213
;----------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
;				Constantes y registros
;----------------------------------------------------------------------------------------------

;Registros auxiliares
.def	aux1 = R17
.def	aux2 = R18


;----------------------------------------------------------------------------------------------
;				Configuraciones puertos
;----------------------------------------------------------------------------------------------

;Configuracion de los puertos -----------------------------------------------------------------
.macro configport
	ldi		aux1, @1
	out		@0, aux1 
.endmacro

;Configuracion de las interrupciones ----------------------------------------------------------
.macro configINT
	clr		aux1
	ldi		aux1,(1 << ISC11 | 0 << ISC10 | 1 << ISC01 | 0 << ISC00 )
	sts		EICRA,aux1
	
	ldi		aux1,  (1<<INT0)|(1<<INT1)
	out		EIMSK,aux1
	
	sei 
.endmacro

;Configuracion del timer ----------------------------------------------------------------------
.macro configtimer
	ldi		aux1, ( 1<<CS10 | 1<<WGM12)
	sts		TCCR1B, aux1
	ldi		aux1, ( 1<<COM1A1 |1<<WGM10)
	sts		TCCR1A, aux1
.endmacro
;----------------------------------------------------------------------------------------------
;				Inicializaciones
;----------------------------------------------------------------------------------------------

;Inicializacion del Stack Pointer--------------------------------------------------------------
.macro initSP
	ldi		aux1, HIGH(RAMEND)
	out		SPH, aux1	
	ldi		aux1, LOW(RAMEND)
	out		SPL, aux1
.endmacro

