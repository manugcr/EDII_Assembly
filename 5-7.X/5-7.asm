;   ****************************************************************************
;   Ejercicio 5.7:
;   Usando interrupciones por RB0, muestre mediante un display de 7 segmentos el
;   n�mero de veces que sucedi� un flanco descendiente. Considerar resistencias
;   de pull-up internas habilitadas para PORTB. Mostrar el resultado por PORTD.
;   ****************************************************************************
	    #INCLUDE    <P16F887.INC>
	    LIST    P = 16F887

; ***************************** PIC CONFIG *****************************
	    __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
; ***************************** VARIABLES ******************************
	    D7S_0   EQU 0x20    ; Registros que almacenar�n los valores
	    D7S_1   EQU 0x21    ; binarios para encender los LEDs de un
	    D7S_2   EQU 0x22    ; display de 7 segmentos contando desde
	    D7S_3   EQU 0x23    ; 0 hasta 9.
	    D7S_4   EQU 0x24
	    D7S_5   EQU 0x25
	    D7S_6   EQU 0x26
	    D7S_7   EQU 0x27
	    D7S_8   EQU 0x28
	    D7S_9   EQU 0x29
	
; ***************************** INIT ***********************************	    
	    ORG	0x00
	    GOTO	SETUP	   
	    ORG	0x04
	    GOTO	ISR	    ; Subrutina de interrupcion
	    ORG	0x05

; ***************************** REG CONFIG *****************************
 SETUP    ;	      hgfedcba	    COM CATHODE
	    MOVLW   b'00111111'	    ; 0
	    MOVWF   D7S_0
	    MOVLW   b'00000110'	    ; 1
	    MOVWF   D7S_1
	    MOVLW   b'01011011'	    ; 2
	    MOVWF   D7S_2
	    MOVLW   b'01001111'	    ; 3
	    MOVWF   D7S_3
	    MOVLW   b'01100110'	    ; 4
	    MOVWF   D7S_4
	    MOVLW   b'01101101'	    ; 5
	    MOVWF   D7S_5
	    MOVLW   b'01111101'	    ; 6
	    MOVWF   D7S_6
	    MOVLW   b'00000111'	    ; 7
	    MOVWF   D7S_7
	    MOVLW   b'01111111'	    ; 8
	    MOVWF   D7S_8
	    MOVLW   b'01101111'	    ; 9
	    MOVWF   D7S_9
	    
	    BANKSEL INTCON	    ; Habilito interrupciones por RB0.
	    MOVLW   b'10010000'
	    MOVWF   INTCON
	    
	    BANKSEL IOCB	    ; Habilito RB0 como interrupcio en cambio
	    CLRF    IOCB	    ; de estado.
	    BSF	    IOCB,0
	    
	    BANKSEL OPTION_REG	    ; Habilito las resistencias de pull-up de
	    MOVLW   b'00000000'	    ; PORTB y las interrupciones por flanco de
	    MOVWF   OPTION_REG	    ; bajada. 
	    BANKSEL TRISB	    
	    CLRF    TRISB
	    BSF	    TRISB, 0	    ; Seteo RB0 como input.
	    
	    BANKSEL ANSELH	    ; Seteo PORTB como digital.
	    CLRF    ANSELH
	    BANKSEL TRISD	    ; Seteo PORTD como output digital.
	    CLRF    TRISD
	    
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTB para comenzar.
	    MOVLW   0x20	    ; Cargo el FSR con la primera direcci�n de
	    MOVWF   FSR		    ; memoria con los valores para los LEDs.
	    GOTO    START

;-------------------INICIO DEL PROGRAMA-----------------------------------------    
START	    MOVFW   INDF	    ; Cargo PORTD con 0 (valor inicial).
	    MOVWF   PORTD
	    GOTO    $		    ; No hago nada. Espero una interrupci�n.
	    
;-------------------RUTINA DE INTERRUPCI�N--------------------------------------
	    
ISR	    BTFSC   INTCON, INTF    ; Si fue interrupci�n por RB0...
	    CALL    COUNT	    ; Voy a COUNT.
	    GOTO    FINISH	    ; Sino, vuelvo.
	    
COUNT	    INCF    FSR		    ; Incremento FSR y muestro INDF por PORTD.
	    MOVFW   INDF
	    MOVWF   PORTD
	    MOVFW   FSR
	    SUBLW   0x29	    ; Si llegu� a la posici�n 29, reseteo a FSR
	    BTFSC   STATUS,Z	    ; y vuelvo.
	    CALL    RESET_FSR
	    RETURN
	    
RESET_FSR   MOVLW   0x1F	    ; Reseteo a FSR en 0x1F y no en 0x20 porque
	    MOVWF   FSR		    ; en COUNT lo primero que hago es INCF FSR.
	    RETURN
	    
FINISH	    BCF	    INTCON, INTF    ; Bajo la flag de interrupci�n por RB0 y
	    RETFIE		    ; vuelvo.
	    
	    END



