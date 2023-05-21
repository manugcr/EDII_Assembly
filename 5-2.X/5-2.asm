;   ****************************************************************************
;   Escribir un programa que prenda un LED que se va desplazando cada vez que
;   se pulsa la tecla conectada a RB0. Al pulsar por primera vez la tecla, se
;   enciende el LED conectado a RB1, y al llegar a RB3 vuelve a RB1 y así
;   indefinidamente. El programa principal no realiza tarea alguna y todo se
;   desarrolla dentro de la subrutina de interrupción
;   ****************************************************************************
	    
	    LIST	P = 16F887
	    #INCLUDE    <P16F887.INC>
	    
; ***************************** PIC CONFIG *************************************
	    __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	    
; ***************************** VARIABLES **************************************
	    COUNT   EQU 0x20    ; Variable que se mostrará por PORTB.
	    COUNT1  EQU 0x21
	    COUNT2  EQU 0x22
	    COUNT3  EQU 0x23
	    STATUS_TEMP EQU 0x24
	    W_TEMP EQU 0x25
   
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	   
	    ORG	    0x04
	    GOTO    IRS		    ; Interruption routine
	    ORG	    0x05
	    
; ***************************** REG CONFIG *************************************   
SETUP	    NOP			    
	    BANKSEL TRISB	    ; RB0 is the only input
	    MOVLW   b'00000001'	    
	    MOVWF   TRISB
	    
	    BANKSEL ANSELH	    ; PORTB as digital
	    CLRF    ANSEL
	    CLRF    ANSELH
	    
	    BANKSEL OPTION_REG	    ; Enable pull-ups for RB0
	    BCF	    OPTION_REG, 7
	    BCF	    OPTION_REG, 6
	    BANKSEL WPUB
	    BSF	    WPUB, 0
	    
	    BANKSEL INTCON	    ; Enable interruptions and RB0 interruptions
	    MOVLW   b'10010000'	    
	    MOVWF   INTCON
	    
;	    BANKSEL IOCB	    ; RB0 as interruption source
;	    MOVLW   b'00000001'
;	    MOVWF   IOCB
	    
	    BANKSEL PORTB	    ; Return to bank 0
	    BCF	    PORTB, RB1
	    BCF	    PORTB, RB2
	    BCF	    PORTB, RB3
	    CALL    SET_COUNT	  
	    GOTO    START

; ***************************** MAIN ******************************************* 	    
START	    BSF	    PORTB, RB7
	    GOTO    $		    ; Waits for an interruption
	    
; *********************** INTERRUPTION ROUTINE *********************************	   
IRS	    MOVWF   W_TEMP
	    SWAPF STATUS,W
	    MOVWF STATUS_TEMP
	    
	    BTFSC   INTCON, INTF    ; Checks if RB0 interruption
	    CALL    ROTATE	    ; Rotate led
	    BCF	    INTCON, INTF    ; Turn off RB0 flag
	    
	    SWAPF STATUS_TEMP,W
	    MOVWF STATUS
	    SWAPF W_TEMP,F
	    SWAPF W_TEMP,W
	    RETFIE
	    
ROTATE	    BCF	    STATUS, C	    ; Clear carry and rotate count left.
	    RLF	    COUNT, 1	    ; If 4th bit is ON, reset count.
	    BTFSC   COUNT, 4
	    CALL    RESET_COUNT
	    MOVF    COUNT, W	    ; Turn on leds on PORTB
	    MOVWF   PORTB
	    RETURN
	    
SET_COUNT   MOVLW   b'00000001'	    ; Initial count value
	    MOVWF   COUNT
	    RETURN
	    
RESET_COUNT CALL    SET_COUNT
	    RLF	    COUNT, 1	    
	    RETURN
	    
	    END