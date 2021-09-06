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

;Registro para el contador
.def	counter = R18

;Registros auxiliares
.def	dummyreg1 = R19
.def	dummyreg2 = R20
.def	dummyreg3 = R21

;Registros y mascaras para leer los valores de la tabla
.def	PART_B = R22
.def	PART_D = R23
.equ	MASK_D = 0x80
.equ	MASK_B = 0x3F

;Constantes de configuracion del programa
.equ	MAX_VALUE = 9
.equ	MIN_VALUE = 0
.equ	START_VALUE = 5
.equ	DELAY_TIME = 96


;----------------------------------------------------------------------------------------------
;								Configuraciones puertos
;----------------------------------------------------------------------------------------------
;Configuracion resistencias de pull up---------------------------------------------------------
.macro configpullup
		clr			dummyreg
		ldi			dummyreg, @0	;(PORTD pull-ups activados)
		out			@1,dummyreg
.endmacro

;Configuracion de los puertos -----------------------------------------------------------------
.macro configports
	;Pongo el puerto D como salida y los PIN INT0 e INT1 como entrada
	ldi		dummyreg1, (1<<DDD7)
	out		DDRD, dummyreg1 

	; Se habilitan las resistencias de pull up de PD2 Y PD3
	ldi		dummyreg1,(1<<PD3)|(1<<PD2)		
	out		PORTD,dummyreg1						

	ldi		dummyreg1, 0XFF
	out		DDRB, dummyreg1
	ldi		dummyreg1,0
	out		PORTB,dummyreg1
.endmacro

;Configuracion de las interrupciones ----------------------------------------------------------
.macro configINT
		clr		dummyreg1
		ldi		dummyreg1,(1<<ISC01)|(1<<ISC11)
		sts		EICRA,dummyreg1
	
		ldi		dummyreg1,  (1<<INT0)|(1<<INT1)
		out		EIMSK,dummyreg1

		sei 
.endmacro
;----------------------------------------------------------------------------------------------
;								Inicializaciones
;----------------------------------------------------------------------------------------------

;Inicializacion del Stack Pointer--------------------------------------------------------------
.macro initSP
	ldi		dummyreg1, HIGH(RAMEND)
	out		SPH, dummyreg1	
	ldi		dummyreg1, LOW(RAMEND)
	out		SPL, dummyreg1
.endmacro


; esta macro inicializa el puntero Z a una posicion en ROM-------------------------------------
.macro	initZ
		ldi			Zh,HIGH(@0<<1) 
		ldi			Zl,LOW(@0<<1)
.endmacro

;Inicializacion del contador en un valor especifico--------------------------------------------
.macro initCont
		clr			contador
		ldi			contador,ValorInic
		leerNum 	contador
.endmacro

;----------------------------------------------------------------------------------------------
;								Macros para el display
;----------------------------------------------------------------------------------------------

; Inicio del display --------------------------------------------------------------------------
.macro initDisplay
		clr			counter
		ldi			counter,START_VALUE
		getNumber	counter
.endmacro

; Borra el display ----------------------------------------------------------------------------
.macro clearDisplay
		ldi			dummyreg,0x00
		out			PORTB, dummyreg
		
		ldi			dummyreg, 0x00
		out			PORTD, dummyreg
.endmacro

; Muestra el display --------------------------------------------------------------------------
.macro showDigit
		getNumber	counter
		out			PORTB,PART_B
		out			PORTD,PART_D
.endmacro

; Lee valores de la tabla ---------------------------------------------------------------------
.macro getNumber 
		;Inicializo puntero y luego lo pongo en la posicion que quiero leer
		initZ		TABLE_DISPLAY
		add			ZL, @0 
	
		;Cargo los valores
		lpm			PART_B,Z
		lpm			PART_D,Z
	
		;Aplico las mascaras
		andi		PART_D, MASK_D
		andi		PART_B, MASK_B
.endmacro

