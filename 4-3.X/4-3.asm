; Enciendo leds conectados en RC
; Con interruptores en RB
; *********************************************
	     
	    LIST	P=16F887
	    #INCLUDE    <p16f887.inc>   
	    
	    COUNT   EQU 0x20
	    LIM	    EQU 0x21
	    
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

PRESSED	    BTFSS PORTA, RA4
	    GOTO PRESSED
	    CALL ADD
	    RETURN
	    
ADD	    INCF COUNT, f
	    SUBWF LIM, w	    
	    BTFSC STATUS, Z	    
	    CLRF COUNT		    
	    RETURN		
	    
; *********************************************
;		    MAIN
; ********************************************* 	    
SETUP	    CLRF PORTB		    ; Limpio los puertos
	    CLRF PORTA
	    CALL BANK_3		    ; Vamos al banco 4
	    CLRF ANSEL		    ; Deshabilitamos entradas analogicass
	    CLRF ANSELH
	    
	    CALL BANK_1		    ; Vamos al banco 1
	    MOVLW b'11111111'	    ; Puerto RA4 como entrada
	    MOVWF TRISA
	    MOVLW b'11110000'	    ; Puerto RB0-RB3 como salida
	    MOVWF TRISB
	    
	    CALL BANK_0		    ; Volvemos al banco 0 e iniciamos programa
	    
	    MOVLW d'15'
	    MOVWF LIM

START	    MOVF COUNT, w
	    MOVWF PORTB
LOOP	    BTFSC PORTA, RA4
	    GOTO LOOP
	    CALL PRESSED
	    GOTO START
	    END