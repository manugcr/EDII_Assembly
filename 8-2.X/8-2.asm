; ******************************************************************************
;   Genere la señal que se muestra (ver gráfico en la guía) utilizando TMR0 e
;   interrupciones. T=2s donde por 1s se generan picos cada 100ms
; ******************************************************************************

	    #INCLUDE    <P16F887.INC>
	    LIST	P = 16F887

; ***************************** PIC CONFIG *************************************
	    __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
; ***************************** VARIABLES **************************************  
	    T0_OFW1	EQU 0x20    ; Overflows para contar 1[s] y 2[s].
	    T0_OFW2	EQU 0x21
	    FLAG	EQU 0x22    ; Flag para togglear RC0.
	    W_TEMP	EQU 0x23
	    STATUS_TEMP	EQU 0x24
   
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	    
	    ORG	    0x04
    	    GOTO    IRS	    
	    ORG	    0x05

; ***************************** REG CONFIG *************************************  
SETUP	    MOVLW   .20		    ; Cuento 20 veces 50ms para llegar a 1[s]
	    MOVWF   T0_OFW1
	    MOVLW   .2		    ; Cuento 2 veces para llegar a 2[s]
	    MOVWF   T0_OFW2	
	    
	    BANKSEL OPTION_REG	    ; Pongo pre-scaler en 256 y selecciono reloj interno
	    MOVLW   b'10000111'	    
	    MOVWF   OPTION_REG

	    BANKSEL TRISC	    ; La senal sale por RC0
	    BCF	    TRISC, 0	    
	    
	    BANKSEL INTCON	    ; Activo interrupciones globales y por TMR0
	    MOVLW   b'10100000'
	    MOVWF   INTCON
	    
	    BANKSEL PORTC
	    CALL    LOAD_TMR0	    ; Arranco a contar 50[ms]
	    GOTO    MAIN
	    	    
; ***************************** MAIN *******************************************
MAIN	    GOTO    $		    ; Espero interrupcion
	    
; *********************** SUB-ROUTINES *****************************************
LOAD_TMR0   MOVLW   .60		    ; Cargo TMR0 con 60 para contar 50[ms]
	    MOVWF   TMR0
	    RETURN
	
RESET_OFW1  MOVLW   .20		    ; Cargo el contador de 20 para 1[s]
	    MOVWF   T0_OFW1
	    RETURN
	    
RESET_OFW2  MOVLW   .2		    ; Cargo el contador de dos para 2[s]
	    MOVWF   T0_OFW2
	    RETURN
	    
CHECK_STAT  BTFSS   FLAG, 0	    ; Testeo si RC0 esta prendido/apagado
	    COMF    PORTC
	    GOTO    END_IRS
	    
RESET_ALL   BCF	    FLAG, 0	    ; Bajo la flag de toggleo, reseteo todos los overflows y toggleo RC0.
	    CALL    RESET_OFW1	    
	    CALL    RESET_OFW2
	    COMF    PORTC
	    GOTO    END_IRS
	    
; *********************** INTERRUPTION ROUTINE *********************************
IRS	    MOVWF   W_TEMP	    ; Salvo contexto
	    SWAPF   STATUS, W
	    MOVWF   STATUS_TEMP

	    BTFSS   INTCON, T0IF    ; Testeo si es interrupcion de TMR0.
	    GOTO    END_IRS	    
	    GOTO    SIGNAL_GEN
	   	    
SIGNAL_GEN  DECFSZ  T0_OFW1	    ; Decremento en 1 el overflow de 20, si es cero paso 1 segundo entonces
	    GOTO    CHECK_STAT	    ; testeo si se tiene que apagar o prender la senal.
	    CALL    RESET_OFW1	    
	    BSF	    FLAG, 0
	    DECFSZ  T0_OFW2	    ; Si OFW2 es cero siginifica que pasaron dos segundos y ya paso el periodo completo
	    GOTO    END_IRS	    ; entonces reseteo todo de nuevo, si no dejo como esta.
	    GOTO    RESET_ALL	    ; Reseteo todo
	    
END_IRS	    BCF	    INTCON, T0IF    ; Apago la flag de TMR0 y vuelvo a iniciar el contador para 50[ms]
	    CALL    LOAD_TMR0
	    
	    SWAPF   STATUS_TEMP, W  ; Retorno contexto.
	    MOVWF   STATUS
	    SWAPF   W_TEMP, F
	    SWAPF   W_TEMP, W
	    RETFIE
	    
	    END