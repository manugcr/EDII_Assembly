;   ****************************************************************************
;   Escribir un código en assembler que realice una interrupción por RB cuando
;   se realice un cambio de nivel en cualquiera de los puertos RB<7:4>. En el
;   servicio a la interrupción (ISR) generar un retardo de 100[ms] e incrementar
;   un contador. Mostrar la cuenta por PORTD.
;   ****************************************************************************

	    #INCLUDE    <P16F887.INC>
	    LIST    P = 16F887

; ***************************** PIC CONFIG *************************************
	    __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
; ***************************** VARIABLES **************************************  
	    AUX	    EQU	    0x20    
	    CNT1    EQU	    0x21    ; Delay variables
	    CNT2    EQU	    0x22
	    COUNT   EQU	    0x23    ; Number to increment
   
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	    
	    ORG	    0x04
	    GOTO    IRS	    
	    ORG	    0x05
	    
; ***************************** REG CONFIG *************************************  
SETUP	    NOP			    
	    BANKSEL TRISB	    ; Set RB<7:4> as inputs.
	    MOVLW   b'11110000'	    ; Set RB<3:0> as outputs.
	    MOVWF   TRISB
	    
	    BANKSEL ANSELH	    ; Set PORTB as digital.
	    CLRF    ANSELH
	    
	    BANKSEL TRISD	    ; Set PORTD as output.
	    CLRF    TRISD
	    
	    BANKSEL OPTION_REG	    ; Enable pull-ups for RB<7:4>
	    MOVLW   b'01111111'	    ; And set pre-scaler to 256
	    MOVWF   OPTION_REG
	    
	    BANKSEL WPUB	    ; Set pull-ups for RB<7:4>
	    MOVLW   b'11110000'
	    MOVWF   WPUB
	    
	    BANKSEL INTCON	    ; Enable interrupts on PORTB.
	    MOVLW   b'10001000'
	    MOVWF   INTCON
	    
	    BANKSEL IOCB	    ; Enable RB<7:4> as interruption sources.
	    MOVLW   b'11110000'	    
	    MOVWF   IOCB
	    
	    BANKSEL PORTB	    ; Set RB<7:4> as high.
	    MOVLW   b'11110000'	    
	    MOVWF   PORTB	    
    
	    CLRF    PORTD
	    CLRF    COUNT
	    GOTO    START

; ***************************** MAIN ******************************************* 	    
START	    GOTO    $		    ; Waits for an interruption.
				    
; *********************** INTERRUPTION ROUTINE *********************************	    
IRS	    BTFSC   INTCON, RBIF    ; Check if its a RB<7:4> interruption.
	    GOTO    RB_TEST	    
	    GOTO    FINISH	    
				    
RB_TEST	    BTFSS   PORTB, 4	    ; Test which RB bit interrupted.
	    GOTO    BIT_4	    
	    BTFSS   PORTB, 5
	    GOTO    BIT_5
	    BTFSS   PORTB, 6
	    GOTO    BIT_6
	    BTFSS   PORTB, 7
	    GOTO    BIT_7
	    GOTO    FINISH
	    
    BIT_4   CALL    DELAY_100ms	    ; 
	    CALL    INC_COUNT	    
	    GOTO    FINISH
	    
    BIT_5   CALL    DELAY_100ms
	    CALL    INC_COUNT
	    GOTO    FINISH
	    
    BIT_6   CALL    DELAY_100ms
	    CALL    INC_COUNT
	    GOTO    FINISH
	    
    BIT_7   CALL    DELAY_100ms
	    CALL    INC_COUNT
	    GOTO    FINISH
	    
DELAY_100ms NOP	    
	    MOVLW   .130	    ; Esto se deberia hacer con TMR0
	    MOVWF   CNT2	    
	    MOVLW   .255
	    MOVWF   CNT1
	    DECFSZ  CNT1		   
	    GOTO    $-1		    
	    DECFSZ  CNT2		
	    GOTO    $-5	    
	    RETURN
    
INC_COUNT   INCF    COUNT, 1	    ; Increments count and show it on PORTD
	    MOVFW   COUNT	    
	    MOVWF   PORTD
	    RETURN
	    
FINISH	    BCF	    INTCON, RBIF    ; Flag clear
	    RETFIE
	    
	    END