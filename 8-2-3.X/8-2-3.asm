; ******************************************************************************
;   Genere la señal que se muestra (ver gráfico en la guía) utilizando TMR0 e
;   interrupciones. Con un toggle en RB2
; ******************************************************************************

	    #INCLUDE    <P16F887.INC>
	    LIST	P = 16F887

; ***************************** PIC CONFIG *************************************
	    __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
; ***************************** VARIABLES **************************************  
	    RB_FLAG	EQU 0x20
	    T0_FLAG	EQU 0x21
	    TMR0_VAL	EQU 0x22
	    T0_OFW1	EQU 0x23
	    T0_OFW2	EQU 0x24
	    T0_OFW3	EQU 0x25
	
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	    
	    ORG	    0x04
    	    GOTO    ISR	    
	    ORG	    0x05

; ***************************** REG CONFIG *************************************  
SETUP	    MOVLW   .60		    ; TMR0 en 60 para llegar a 50[ms]
	    MOVWF   TMR0_VAL
	    MOVLW   .40
	    MOVWF   T0_OFW1
	    MOVLW   .2
	    MOVWF   T0_OFW2
	    MOVLW   .2
	    MOVWF   T0_OFW3
	    
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
	    CALL    LOAD_TMR0
	    GOTO    MAIN
	    	    
; ***************************** MAIN *******************************************
MAIN	    GOTO    $		    ; Espero interrupcion
	    
; *********************** SUB-ROUTINES *****************************************
LOAD_TMR0   MOVF    TMR0_VAL, W	    ; Cargo TMR0 con 60 para contar 50[ms]
	    MOVWF   TMR0
	    RETURN
	 
SET_RBFLAG  COMF    RB_FLAG
	    BCF	    PORTB, RB4
	    GOTO    END_ISR
	    
CHECK_RB    BTFSC   RB_FLAG, 0	    ; Si la flag esta en 1 activo la senal
	    GOTO    SIGNAL_GEN	    ; Si la flag esta en 0 dejo todo como esta y retorno
	    GOTO    END_ISR
	    
CHECK_T0    BTFSS   T0_FLAG, 0
	    GOTO    DOUBLE
	    GOTO    END_ISR
	    
DOUBLE	    DECFSZ  T0_OFW3
	    GOTO    END_ISR
	    GOTO    TOG_RB4

TOG_RB4	    BTFSS   PORTB, RB4
	    GOTO    RB4_ON
	    GOTO    RB4_OFF
	    
RB4_ON      BSF	    PORTB, RB4	
	    MOVLW   .2
	    MOVWF   T0_OFW3
	    GOTO    END_ISR
  
RB4_OFF     BCF	    PORTB, RB4	
	    MOVLW   .2
	    MOVWF   T0_OFW3
	    GOTO    END_ISR
	    
RESET_OFW1  MOVLW   .40
	    MOVWF   T0_OFW1
	    RETURN
	    
RESET_OFW2  MOVLW   .2
	    MOVWF   T0_OFW2
	    RETURN	
	    
RESET_ALL   BCF	    T0_FLAG, 0
	    CALL    RESET_OFW1
	    CALL    RESET_OFW2
	    CALL    TOG_RB4
	    GOTO    END_ISR
	    
	    
; *********************** INTERRUPTION ROUTINE *********************************
ISR	    BTFSC   INTCON, RBIF    ; Testeo si es interrupcion de RB, si es asi pongo la FLAG en 1 y vuelvo
	    GOTO    SET_RBFLAG
	    BTFSC   INTCON, T0IF    ; Testeo si es interrupcion de TMR0, si es asi testeo si la FLAG esta en 1	    
	    GOTO    CHECK_RB
	    GOTO    END_ISR
	   	    
SIGNAL_GEN  DECFSZ  T0_OFW1
	    GOTO    CHECK_T0
	    CALL    RESET_OFW1
	    BSF	    T0_FLAG, 0
	    DECFSZ  T0_OFW2
	    GOTO    END_ISR
	    GOTO    RESET_ALL
	    
END_ISR	    BSF	    PORTB,  RB2
	    BCF	    INTCON, RBIF    ; Apago la flag de RBIE
	    BCF	    INTCON, T0IF    ; Apago la flag de TMR0 y vuelvo a iniciar el contador para 50[ms]
	    CALL    LOAD_TMR0
	    RETFIE
	    
	    END