; ******************************************************************************
; Utilizando PORTA y PORTC para controlar la multiplexación de dos displays
; de siete segmentos de cátodo común, desarrolle un programa que cuente desde
; '00' hasta '99'. El contador avanza una cuenta cada un segundo y al llegar 
; a '99' se resetea, volviendo a contar desde '00' indefinidamente.
; ******************************************************************************

	    #INCLUDE    <P16F887.INC>
	    LIST    P = 16F887

; ***************************** PIC CONFIG *************************************
	    __CONFIG	_CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG	_CONFIG2, _BOR4V_BOR40V & _WRT_OFF
;	    __CONFIG	_CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF
		
; ***************************** VARIABLES **************************************  
	    UNITS   EQU	0x20    ; Unidades y decenas, con sus respectivos
	    TENS    EQU	0x21    ; límites 
	    LIM_UNIT EQU 0x22    
	    LIM_TENS EQU 0x23
	    DISP_ON EQU	0x24    ; Display a encender.
	    DISP_Q  EQU	0x25    ; Cantidad de displays utilizados.
	    CNT1    EQU	0x27    ; Variables para el retardo de multiplexado.
	    CNT2    EQU	0x28
	    SAVE_S  EQU	0x29    ; Registros para salvar contexto.
	    SAVE_W  EQU	0x2A
   
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	    
	    ORG	    0x04
	    GOTO    IRS	    
	    ORG	    0x05
	    
; ***************************** REG CONFIG *************************************  
SETUP	    CLRF    UNITS	    ; Comienzo en 00 y voy hasta 99.
	    CLRF    TENS
	    
	    MOVLW   d'10'	    ; Cargo limites por decena y unidad
	    MOVWF   LIM_UNIT
	    MOVWF   LIM_TENS
	    
	    CLRF    DISP_ON	    ; Comienzo con el display 0, y voy a
	    MOVLW   d'2'	    ; trabajar con dos displays en total.
	    MOVWF   DISP_Q
	    
	    BANKSEL TRISC	    ; PORTA y PORTD output digital
	    BCF	    TRISA, 0
	    CLRF    TRISC	    ; PORTD son los bits de seleccion
	    CLRF    TRISD	    ; del display.	    
	    MOVLW   b'00000001'	    ; RB0 como input
	    MOVWF   TRISB
	    
	    BANKSEL ANSEL	    ; Ponemos los pines como digitales
	    CLRF    ANSEL
	    CLRF    ANSELH
	    
	    BANKSEL OPTION_REG	    ; Pull-ups para RB0
	    BCF	    OPTION_REG, 7
	    BANKSEL WPUB
	    BSF	    WPUB, 0
	    
	    BANKSEL INTCON	    ; Habilito interrupciones por PORTB
	    MOVLW   b'10010000'	    
	    MOVWF   INTCON
	    
	    BANKSEL IOCB	    ; RB0 como fuente de interrupcion
	    MOVLW   b'00000001'
	    MOVWF   IOCB
	    
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTA para comenzar.
	    BSF	    PORTB, 0
	    GOTO    MAIN

; ***************************** MAIN ******************************************* 	    
MAIN	    BSF	    PORTA, 0
	    MOVF    DISP_ON, W
	    CALL    DISP_SEL
	    MOVWF   PORTD
	    MOVF    DISP_ON, W
	    CALL    T_OR_U
	    MOVWF   FSR
	    MOVF    INDF, W
	    CALL    D7S_ANOD
	    MOVWF   PORTC
	    CALL    DELAY_10ms
	    INCF    DISP_ON
	    MOVF    DISP_ON, W
	    SUBWF   DISP_Q, W
	    BTFSC   STATUS, Z
	    CLRF    DISP_ON
	    GOTO    MAIN

; *********************** TABLES ***********************************************
D7S_CATH    ADDWF   PCL, F	    ; Retorno el valor a mostrar por el display.
	    RETLW   B'00111111'	    ; 0	    Catodo comun -> hgfedcba
	    RETLW   B'00000110'	    ; 1
	    RETLW   B'01011011'	    ; 2
	    RETLW   B'01001111'	    ; 3
	    RETLW   B'01100110'	    ; 4
	    RETLW   B'01101101'	    ; 5
	    RETLW   B'01111101'	    ; 6
	    RETLW   B'00000111'	    ; 7
	    RETLW   B'01111111'	    ; 8
	    RETLW   B'01101111'	    ; 9
	    
D7S_ANOD    ADDWF   PCL, F	    ; Retorno el valor a mostrar por el display.
	    RETLW   B'11000000'	    ; 0	    Anodo comun -> hgfedcba
	    RETLW   B'11111001'	    ; 1
	    RETLW   B'10100100'	    ; 2
	    RETLW   B'10110000'	    ; 3
	    RETLW   B'10011001'	    ; 4
	    RETLW   B'10010010'	    ; 5
	    RETLW   B'10000010'	    ; 6
	    RETLW   B'11111000'	    ; 7
	    RETLW   B'10000000'	    ; 8
	    RETLW   B'10010000'	    ; 9

DISP_SEL    ADDWF   PCL, F	    ; Tabla para elegir qué display encender.
	    RETLW   B'11111110'
	    RETLW   B'11111101'
	    
T_OR_U	    ADDWF   PCL, F	    ; Tabla para mover a FSR la dirección de
	    RETLW   0x20	    ; las unidades o decenas según el display a
	    RETLW   0x21	    ; encender.
	    
; *********************** SUB-ROUTINES *****************************************
DELAY_10ms  MOVLW   .13		    ; Retardo por software de ~10[ms].
	    MOVWF   CNT2	    ; Este retardo es el switching de
    LOOP    MOVLW   .255	    ; multiplexado entre displays
	    MOVWF   CNT1
	    DECFSZ  CNT1
	    GOTO    $-1
	    DECFSZ  CNT2
	    GOTO    $-5
	    RETURN
	    
RESET_UNIT  CLRF    UNITS
	    INCF    TENS, F
	    MOVF    TENS, W
	    SUBWF   LIM_TENS, W
	    BTFSC   STATUS, Z
	    CLRF    TENS
	    RETURN
	    
; *********************** INTERRUPTION ROUTINE *********************************
IRS	    MOVWF   SAVE_W	    ; Salvo el contexto de W y STATUS
	    SWAPF   STATUS, W	    
	    MOVWF   SAVE_S	    
	    
	    CALL    DELAY_10ms
	    BTFSS   PORTB, 0
	    GOTO    END_IRS
	    
	    BTFSS   INTCON, INTF
	    GOTO    END_IRS
	    INCF    UNITS, F
	    MOVF    UNITS, W
	    SUBWF   LIM_UNIT, W
	    BTFSC   STATUS, Z
	    CALL    RESET_UNIT
	    GOTO    END_IRS
	    
END_IRS	    SWAPF   SAVE_S, W	    ; Salvo contexto y bajo la flag.
	    MOVWF   STATUS
	    SWAPF   SAVE_W, F
	    SWAPF   SAVE_W, W
	    BCF	    INTCON, INTF
	    BCF	    INTCON, RBIF
	    RETFIE
	    
	    END