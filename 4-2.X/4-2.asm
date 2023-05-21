; Enciendo leds conectados en RC
; Con interruptores en RB
; *********************************************
	     
	    LIST	P=16F887
	    #INCLUDE    <p16f887.inc>   

	    ; CONFIG1
	    ; __config 0xFFFF
	     __CONFIG _CONFIG1, _FOSC_EXTRC_CLKOUT & _WDTE_ON & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	    ; CONFIG2
	    ; __config 0xFFFF
	     __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	    
	    ORG 0x00 
	    GOTO SETUP
	    ORG 0x05
	    
; *********************************************
;		  SUB-RUTINAS
; *********************************************
BANK_0	    BCF STATUS, IRP
	    BCF STATUS, RP0	    ; Bank 0-00
	    BCF STATUS, RP1
	    RETURN
BANK_1	    BCF STATUS, IRP
	    BSF STATUS, RP0	    ; Bank 0-01
	    BCF STATUS, RP1
	    RETURN
BANK_2	    BSF STATUS, IRP
	    BCF STATUS, RP0	    ; Bank 1-10
	    BSF STATUS, RP1
	    RETURN
BANK_3	    BSF STATUS, IRP
	    BSF STATUS, RP0	    ; Bank 1-11
	    BSF STATUS, RP1
	    RETURN
	
; *********************************************
;		    MAIN
; ********************************************* 	    
SETUP	   
	    CLRF PORTB		    ; Limpio los puertos
	    CLRF PORTA
	    CALL BANK_3		    ; Vamos al banco 4
	    CLRF ANSEL		    ; Deshabilitamos entradas analogicass
	    CLRF ANSELH
	    
	    CALL BANK_1		    ; Vamos al banco 1
	    MOVLW b'11111111'	    ; Puerto A como entrada
	    MOVWF TRISA
	    MOVLW b'11110011'	    ; Puerto B como salida
	    MOVWF TRISB
	    
	    CALL BANK_0		    ; Volvemos al banco 0 e iniciamos programa
	    
 LOOP	    BTFSC   PORTA, RA4	    ; Chequeo el estado de RA4.
	    BSF	    PORTB, RB3	    ; Si está en '1', prendo RB3.
	    BTFSC   PORTB, RB0	    ; Chequeo el estado de RB0.
	    BSF	    PORTB, RB2	    ; Si está en '1', prendo RB2.
	    
	    BTFSS   PORTA, RA4	    ; Chequeo nuevamente el estado de RA4.
	    BCF	    PORTB, RB3	    ; Si ahora está apagado, apago RB3.
	    BTFSS   PORTB, RB0	    ; Chequeo nuevamente el estado de RB0.
	    BCF	    PORTB, RB2	    ; Si ahora está apagado, apago RB2.
	    GOTO    LOOP	    ; Repito indefinidamente.
	    
	    END