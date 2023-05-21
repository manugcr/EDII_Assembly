
		#INCLUDE    <P16F887.INC>
		LIST    P = 16F887

		__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
		__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

		NUM0 EQU b'10101010'
		NUM1 EQU b'01010101'
		NUM2 EQU b'00001111'
		NUM3 EQU b'11110000'
		
		ORG 0x00

		BANKSEL TRISA
		BSF TRISA, RA4
		BSF TRISB, RB0
		CLRF TRISD
		BANKSEL ANSEL
		CLRF ANSEL
		CLRF ANSELH
		
		BCF STATUS, RP0
		BCF STATUS, RP1
		
LOOP		BTFSC PORTA, RA4
		GOTO UNO
		GOTO CERO
CERO		BTFSS PORTB, RB0
		GOTO PRIMER_VALOR
		GOTO SEGUNDO_VALOR
UNO		BTFSS PORTB, RB0
		GOTO TERCER_VALOR
		GOTO CUARTO_VALOR
PRIMER_VALOR	MOVLW NUM1
		MOVWF PORTD
		GOTO LOOP
SEGUNDO_VALOR	MOVLW NUM2
		MOVWF PORTD
		GOTO LOOP
TERCER_VALOR	MOVLW NUM3
		MOVWF PORTD
		GOTO LOOP
CUARTO_VALOR	MOVLW NUM3
		MOVWF PORTD
		GOTO LOOP

		END
		