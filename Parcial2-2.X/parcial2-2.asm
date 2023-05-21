; ******************************************************************************
;   Genere la señal que se muestra (ver gráfico en la guía) utilizando TMR0 e
;   interrupciones. En RB2 hay un toggle que activa o desactiva la senal
;   la senal es 1875ms baja y 125ms alta. Si el toggle esta desactivado es una 
;   senal baja constante. 
;
;   Fosc = 8MHz.
; ******************************************************************************

	    #INCLUDE    <P16F887.INC>
	    LIST	P = 16F887

; ***************************** PIC CONFIG *************************************
	    __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
; ***************************** VARIABLES **************************************  
	    RB_FLAG	EQU 0x20
	    TMR0_VAL	EQU 0x21
	    CNT_LOW	EQU 0x22
	    CNT_HIGH	EQU 0x23
   
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	    
	    ORG	    0x04
    	    GOTO    ISR	    
	    ORG	    0x05

; ***************************** REG CONFIG *************************************  
SETUP	    MOVLW   .60		    ; TMR0 en 60 para llegar a 25[ms] con F=8MHz
	    MOVWF   TMR0_VAL
	    MOVLW   .76		    ; Cuento 75 veces 25 para llegar a 1875[ms]
	    MOVWF   CNT_LOW
	    MOVLW   .6		    ; Cuento 5 veces 25 para llegar a 125[ms]
	    MOVWF   CNT_HIGH	    
	    
	    BANKSEL TRISB	    ; Seteo RB2 input y RB4 output
	    MOVLW   b'00000100'
	    MOVWF   TRISB
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    CLRF    ANSEL
	    
	    BANKSEL WPUB	    ; Activo pull-ups RB2
	    MOVLW   b'00000100'
	    MOVWF   WPUB
	    
	    BANKSEL OPTION_REG	    ; Activo pull-ups en PORTB y asigno prescaler 256
	    MOVLW   b'00000111'
	    MOVWF   OPTION_REG
	    
	    BANKSEL IOCB	    ; Activo interrupciones por RB2
	    MOVLW   b'00000100'
	    MOVWF   IOCB
	    
	    BANKSEL INTCON	    ; Activo interrupciones por RBIE y TMR0
	    MOVLW   b'10101000'
	    MOVWF   INTCON
	    
	    BCF	    RB_FLAG, 0	    ; Arranco la flag en 0, osea que no hay senal
	    BCF	    PORTB, RB4	    ; Arranco largando un 1 por el pin RB2
	    CALL    LOAD_TMR0	    ; El timer comienza a contar los 25[ms]
	    GOTO    MAIN
	    	    
; ***************************** MAIN *******************************************
MAIN	    GOTO    $		    ; Espero interrupcion
	    
; *********************** SUB-ROUTINES *****************************************
LOAD_TMR0   MOVF    TMR0_VAL, W	    ; Cargo TMR0 con 60 para contar 25[ms]
	    MOVWF   TMR0
	    RETURN
	    
LOAD_LOW    MOVLW   .76		    ; Cuento 75 veces 25 para llegar a 1875[ms]
	    MOVWF   CNT_LOW
	    RETURN

LOAD_HIGH   MOVLW   .6		    ; Cuento 5 veces 25 para llegar a 125[ms]
	    MOVWF   CNT_HIGH
	    RETURN
	 
SET_RBFLAG  COMF    RB_FLAG
	    BCF	    PORTB, RB4	    ; Por default el pin RB4 esta apagado
	    GOTO    END_ISR
	    
CHECK_RB    BTFSC   RB_FLAG, 0	    ; Si la flag esta en 1 activo la senal
	    GOTO    SIGNAL_GEN	    ; Si la flag esta en 0 dejo todo como esta y retorno
	    GOTO    END_ISR
	    
; *********************** INTERRUPTION ROUTINE *********************************
ISR	    BTFSC   INTCON, RBIF    ; Testeo si es interrupcion de RB, si es asi modifico la flag y retorno.
	    GOTO    SET_RBFLAG
	    BTFSC   INTCON, T0IF    ; Testeo si es interrupcion de TMR0, si es asi testeo si la FLAG esta en 1.	    
	    GOTO    CHECK_RB	    ; Si la flag esta en 1 comienzo a enviar la senal, si es 0 dejo todo como esta.
	    GOTO    END_ISR
	   	    
SIGNAL_GEN  CALL    LOAD_TMR0 
	    MOVLW   0x00
	    SUBWF   CNT_LOW
	    BTFSS   STATUS, Z
	    GOTO    SIG_LOW
	    GOTO    SIG_HIGH
	    
SIG_LOW	    BCF	    PORTB, RB4
	    DECFSZ  CNT_LOW
	    GOTO    END_ISR
	    GOTO    SIG_HIGH
	    
SIG_HIGH    BSF	    PORTB, RB4
	    DECFSZ  CNT_HIGH
	    GOTO    END_ISR
	    CALL    LOAD_LOW
	    CALL    LOAD_HIGH
	    GOTO    END_ISR
	    
END_ISR	    BSF	    PORTB,  RB2
	    BCF	    INTCON, RBIF    ; Apago la flag de RBIE
	    BCF	    INTCON, T0IF    ; Apago la flag de TMR0 y vuelvo a iniciar el contador para 25[ms]
	    RETFIE
	    
	    END