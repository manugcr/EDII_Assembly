;   ****************************************************************************
;   Escribir un programa que lea de dos botones conectados a RB1 y RB2 y actue
;   sobre un LED conectado en RB3.
;   * Si se presiona RB1, se enciende el LED por 10 segundos y luego se apaga.
;   * Si se presiona RB2, se enciende el LED por 5 segundos y luego se apaga.
;   Cualquier cambio en los botones mientras esté encendido el LED no deberá
;   modificar el estado del LED.
;   ****************************************************************************

	    #INCLUDE    <P16F887.INC>
	    LIST    P = 16F887

; ***************************** PIC CONFIG *************************************
	    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
; ***************************** VARIABLES **************************************
	    AUX	    EQU	    0x20    
	    CNT1    EQU	    0x21    ; Delay variables
	    CNT2    EQU	    0x22    
	    CNT3    EQU	    0x23    
   
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	  
	    ORG	    0x04
	    GOTO    IRS		    
	    ORG	    0x05
	    
; ***************************** REG CONFIG *************************************     	    
SETUP	    NOP			    
	    BANKSEL TRISB	    ; RB<2:1> as inputs
	    MOVLW   b'00000110'	    
	    MOVWF   TRISB
	    
	    BANKSEL ANSELH	    ; PORTB as digital
	    CLRF    ANSELH
	    
	    BANKSEL INTCON	    ; Enable interruptions for PORTB
	    MOVLW   b'10001000'
	    MOVWF   INTCON
	    
	    BANKSEL OPTION_REG	    ; Enable pull-ups for RB<2:1>
	    BCF	    OPTION_REG, 7
	    BANKSEL WPUB
	    BSF	    WPUB, 1
	    BSF	    WPUB, 2
	    
	    BANKSEL IOCB
	    MOVLW   b'00000110'	    ; Enable RB<2:1> as interuption source
	    MOVWF   IOCB	 
	    
	    BANKSEL PORTB	    ; Set RB<2:1> HIGH on PORTB
	    MOVLW   b'00000110'	    
	    MOVWF   PORTB	        
	    
	    GOTO    START

; ***************************** MAIN *******************************************     
START	    GOTO    $		    ; Waits for an interuption.
				    
; *********************** INTERRUPTION ROUTINE *********************************
	    
IRS	    BTFSC   INTCON, RBIF    
	    CALL    BIT_TEST	    ; Test which PORTB bit interrupted
	    BCF	    INTCON, RBIF
	    RETFIE		    
	    
BIT_TEST    MOVFW   PORTB	    
	    MOVWF   AUX		    
	    BTFSS   AUX, 1	    
	    CALL    LED_RB1	    
	    BTFSS   AUX, 2	    
	    CALL    LED_RB2	    
	    RETURN		    
				    
				    
LED_RB1	    BSF	    PORTB, 3	    ; RB2 interruption, turn on led for 10s
	    CALL    DELAY_10S	    
	    BCF	    PORTB, 3
	    BCF	    INTCON, RBIF
	    RETFIE
	    
LED_RB2	    BSF	    PORTB, 3	    ; RB2 interruption, turn on led for 5s
	    CALL    DELAY_5S	    
	    BCF	    PORTB, 3
	    BCF	    INTCON, RBIF
	    RETFIE
	    
DELAY_10S   MOVLW   .51		    ; Esto se deberia hacer con TMR0
	    MOVWF   CNT3	    
	    MOVLW   .255
	    MOVWF   CNT2
	    MOVLW   .255
	    MOVWF   CNT1
	    DECFSZ  CNT1	    
	    GOTO    $-1		    
	    DECFSZ  CNT2	    
	    GOTO    $-5	    
	    DECFSZ  CNT3	    
	    GOTO    $-9	    
	    RETURN
	    
DELAY_5S    MOVLW   .26		    ; Esto se deberia hacer con TMR0
	    MOVWF   CNT3	    
	    MOVLW   .255
	    MOVWF   CNT2
	    MOVLW   .255
	    MOVWF   CNT1
	    DECFSZ  CNT1	    
	    GOTO    $-1		   
	    DECFSZ  CNT2	    
	    GOTO    $-5	    
	    DECFSZ  CNT3	    
	    GOTO    $-9	    
	    RETURN
	    
	    END