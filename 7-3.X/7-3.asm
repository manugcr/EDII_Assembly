;; ******************************************************************************
;; Utilizando PORTA y PORTC para controlar la multiplexación de dos displays
;; de siete segmentos de cátodo común, desarrolle un programa que cuente desde
;; '00' hasta '99'. El contador avanza una cuenta cada un segundo y al llegar 
;; a '99' se resetea, volviendo a contar desde '00' indefinidamente.
;; ******************************************************************************
;
;	    #INCLUDE    <P16F887.INC>
;	    LIST    P = 16F887
;
;; ***************************** PIC CONFIG *************************************
;	    __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
;	    __CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
;	
;; ***************************** VARIABLES **************************************  
;	    UNITS   EQU	0x20    ; Unidades y decenas, con sus respectivos
;	    TENS    EQU	0x21    ; y sus límites 
;	    LIM_UNI EQU	0x22    
;	    LIM_TEN EQU	0x23
;	    DISP_ON EQU	0x24    ; Display a encender.
;	    DISP_Q  EQU	0x25    ; Cantidad de displays utilizados.
;	    T0_OFW  EQU	0x26    ; Overflow para el TMR0 para contar 1[s].
;	    CNT1    EQU	0x27    ; Variables para el retardo de multiplexado.
;	    CNT2    EQU	0x28
;	    SAVE_S  EQU	0x29    ; Registros para salvar contexto.
;	    SAVE_W  EQU	0x2A
;   
;; ***************************** INIT *******************************************
;	    ORG	    0x00
;	    GOTO    SETUP	    
;	    ORG	    0x04
;	    GOTO    IRS	    
;	    ORG	    0x05
;	    
;; ***************************** REG CONFIG *************************************  
;SETUP	    CLRF    UNITS	    ; Comienzo en 00 y voy hasta 99.
;	    CLRF    TENS
;	    
;	    MOVLW   .10		    ; Cargo limites por decena y unidad
;	    MOVWF   LIM_UNI
;	    MOVWF   LIM_TEN
;	    
;	    CLRF    DISP_ON	    ; Comienzo con el display 0, y voy a
;	    MOVLW   .2		    ; trabajar con dos displays en total.
;	    MOVWF   DISP_Q
;	    
;	    MOVLW   .20		    ; Voy a contar 20 veces 50[ms].
;	    MOVWF   T0_OFW	    ; Delay ~1[seg]
;	    
;	    BANKSEL TRISA	    ; PORTA y PORTC serán outputs digitales.
;	    CLRF    TRISA	    ; Output = 0
;	    BANKSEL ANSEL
;	    CLRF    ANSEL
;	    BANKSEL TRISC
;	    CLRF    TRISC
;	    
;	    BANKSEL OPTION_REG	    ; Configuro TMR0 con un prescaler de 1:256
;	    BCF	    OPTION_REG, T0CS
;	    BCF	    OPTION_REG, PSA 
;	    BSF	    OPTION_REG, PS2
;	    BSF	    OPTION_REG, PS1 
;	    BSF	    OPTION_REG, PS0 ; OPTION_REG = <1101 0111>
;	    
;	    BANKSEL INTCON	    ; Habilito interrupciones por TMR0.
;	    BSF	    INTCON, GIE
;	    BSF	    INTCON, T0IE
;	    BCF	    INTCON, T0IF    ; INTCON = <1010 0000>
;	    
;	    BANKSEL TMR0	    ; Pongo a TMR0 a contar.
;	    MOVLW   .60
;	    MOVWF   TMR0
;	    
;	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA para comenzar.
;	    GOTO    MAIN
;
;; ***************************** MAIN ******************************************* 	    
;MAIN	    MOVF    DISP_ON, W	    
;	    CALL    DISP_SEL
;	    MOVWF   PORTC
;	    MOVF    DISP_ON, W	    
;	    CALL    D_OR_U
;	    MOVWF   FSR
;	    MOVF    INDF, W	    	    
;	    CALL    D7S_ANOD
;	    MOVWF   PORTA
;	    CALL    MUX_DELAY
;	    INCF    DISP_ON
;	    MOVF    DISP_ON, W	    
;	    SUBWF   DISP_Q, W
;	    BTFSC   STATUS, Z
;	    CLRF    DISP_ON
;	    GOTO    MAIN
;
;; *********************** TABLES ***********************************************
;D7S_CATH    ADDWF   PCL, F	    ; Retorno el valor a mostrar por el display.
;	    RETLW   B'00111111'	    ; 0	    Catodo comun -> hgfedcba
;	    RETLW   B'00000110'	    ; 1
;	    RETLW   B'01011011'	    ; 2
;	    RETLW   B'01001111'	    ; 3
;	    RETLW   B'01100110'	    ; 4
;	    RETLW   B'01101101'	    ; 5
;	    RETLW   B'01111101'	    ; 6
;	    RETLW   B'00000111'	    ; 7
;	    RETLW   B'01111111'	    ; 8
;	    RETLW   B'01101111'	    ; 9
;	    
;D7S_ANOD    ADDWF   PCL, F	    ; Retorno el valor a mostrar por el display.
;	    RETLW   B'11000000'	    ; 0	    Anodo comun -> hgfedcba
;	    RETLW   B'11111001'	    ; 1
;	    RETLW   B'10100100'	    ; 2
;	    RETLW   B'10110000'	    ; 3
;	    RETLW   B'10011001'	    ; 4
;	    RETLW   B'10010010'	    ; 5
;	    RETLW   B'10000010'	    ; 6
;	    RETLW   B'11111000'	    ; 7
;	    RETLW   B'10000000'	    ; 8
;	    RETLW   B'10010000'	    ; 9
;
;DISP_SEL    ADDWF   PCL, F	    ; Tabla para elegir qué display encender.
;	    RETLW   B'11111110'
;	    RETLW   B'11111101'
;	    
;D_OR_U	    ADDWF   PCL, F	    ; Tabla para mover a FSR la dirección de
;	    RETLW   0x20	    ; las unidades o decenas según el display a
;	    RETLW   0x21	    ; encender.
;	    
;; *********************** SUB-ROUTINES *****************************************
;MUX_DELAY   MOVLW   .250	    ; Retardo por software de ~10[ms].
;	    MOVWF   CNT1	    ; Este retardo es el switching de
;	    MOVLW   .13		    ; multiplexado entre displays.
;	    MOVWF   CNT2
;    MUXL    DECFSZ  CNT1
;	    GOTO    $-1
;	    DECFSZ  CNT2
;	    GOTO    $-3
;	    RETURN
;	    
;RESET_OFW   MOVLW   .20		    ; Reseteo el overflow con 20.
;	    MOVWF   T0_OFW	    ; TMR0 cuenta 20 veces 50[ms].
;	    RETURN
;	    
;RESET_UNI   CLRF    UNITS	    ; Si llego a 09, reseto la unidad e 
;	    INCF    TENS, F	    ; incremento en 1a decena teniendo en
;	    MOVFW   TENS	    ; cuenta los limites.
;	    SUBWF   LIM_TEN, W
;	    BTFSC   STATUS, Z
;	    CLRF    TENS
;	    RETURN
;	    
;; *********************** INTERRUPTION ROUTINE *********************************
;IRS	    MOVWF   SAVE_W	    ; Salvo el contexto de W y STATUS
;	    SWAPF   STATUS,W	    
;	    MOVWF   SAVE_S	    
;	    
;	    BTFSS   INTCON, T0IF    ; Sólo atiendo interrupciones por TMR0.
;	    GOTO    END_IRS
;	    DECFSZ  T0_OFW	    ; Cada 1[s] actualizo las unidades
;	    GOTO    RESET_TMR0	    ; Cada 10[s] actualizo las decenas
;	    CALL    RESET_OFW	    ; Siempre verificando el limite
;	    INCF    UNITS, F
;	    MOVF    UNITS, W	    
;	    SUBWF   LIM_UNI, W
;	    BTFSC   STATUS ,Z
;	    CALL    RESET_UNI
;	    GOTO    END_IRS
;	    
;RESET_TMR0  MOVLW   .60
;	    MOVWF   TMR0
;	    GOTO    END_IRS
;	    
;END_IRS	    SWAPF   SAVE_S, W	    ; Salvo contexto, bajo la flag y retorno
;	    MOVWF   STATUS	    ; de la interrupcion.
;	    SWAPF   SAVE_W, F
;	    SWAPF   SAVE_W, W
;	    BCF	    INTCON, T0IF
;	    RETFIE
;	    
;	    END
    
;Ejercicio 7.3 con T0
;Según el esquema que se muestra y utilizando técnicas de multiplexado de display
;desarrolle un programa que cuente desde ´000000´al iniciarse el programa.
;El contador avanza una cuenta cada segundo y al llegar a ´999999´ vuelve a ´000000´
;y así indefinidamente. Los displays y la cuenta se manejan por la interrupción en RB0
;que se activa por flanco descendente.
;Se pide además calcular la frecuencia a la que se debe colocar el generador de onda cuadrada
;que ingresa por RB0.


LIST P=16F887
INCLUDE <p16f887.inc>
; CONFIG1
; __config 0x3FD7
    __CONFIG _CONFIG1, _FOSC_EXTRC_CLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
; CONFIG2
; __config 0x3FFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

CBLOCK 0X20
    W_AUX
    STATUS_AUX
    POSICION
    DIGIT_N
    ENDC



    ORG		0X00
    GOTO 	CONFI
    ORG		0X04
    GOTO	ISR
    ORG		0X05

CONFI
    BSF			STATUS,RP0
    BSF			STATUS,RP1
    CLRF		ANSEL
    CLRF		ANSELH
    BCF			STATUS,RP1
    CLRF		TRISA
    CLRF		TRISC
    BSF			TRISB,0
		
    ;CONFIGURO OPTION_REG
    MOVLW		B'10000011'
    MOVWF		OPTION_REG;CONFIGURO EL PRESCALER AL TMR0 Y EN 16

    ;CONFIGURO INTERRUPCIONES POR RB0 Y TMR0
    BCF			STATUS,RP0;VUELVO AL BANCO 0
    MOVLW		.56; 256-200=56, PORQUE CON 200 PULSOS T=3.2 ms, PARA 6 DISPLAYS, REFRESCO DE 19.2ms F=52Hz
    MOVWF		TMR0
    	
    MOVLW		B'10110000';HABILITO GIE, T0IE Y INTE
    MOVWF		INTCON
    
    ;OTRAS CONFIGURACIONES
    MOVLW		0X30
    MOVWF		POSICION
    MOVLW		B'00000001'
    MOVWF		DIGIT_N
    ;VALORES INICIALES
    CLRF		0X30
    CLRF		0X31
    CLRF		0X32
    CLRF		0X33
    CLRF		0X34
    CLRF		0X35
    
    
MAIN	
    GOTO		$
    
ISR
    ;GUARDO CONTEXTO
    MOVWF		W_AUX
    SWAPF		STATUS,W
    MOVWF		STATUS_AUX
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    
    BTFSC		INTCON,T0IF
    CALL		TMR0_ISR
    BTFSC		INTCON,INTF
    CALL		INT_ISR
    
FIN_ISR
    
    ;PONGO CONTEXTO
    SWAPF		STATUS_AUX,W
    MOVWF		STATUS
    SWAPF		W_AUX,F
    SWAPF		W_AUX,W
    
    RETFIE
    


TMR0_ISR;REFRESCO DEL DISPLAY
    BCF			INTCON,T0IF;LIMPIO BANDERA
    MOVLW		.56
    MOVWF		TMR0
    
    MOVF		DIGIT_N,W
    MOVWF		PORTA
    MOVF		POSICION,W
    MOVWF		FSR
    
    MOVF		INDF,W
    CALL		TABLA
    MOVWF		PORTC
    INCF		POSICION,F
    BCF			STATUS,C
    RLF			DIGIT_N
    
    MOVLW		0X36
    SUBWF		POSICION,W
    BTFSS		STATUS,Z
    RETURN
    MOVLW		0X30
    MOVWF		POSICION
    MOVLW		B'00000001'
    MOVWF		DIGIT_N
    RETURN
    
INT_ISR
    BCF			INTCON,INTF;LIMPIO BANDERA
   
    MOVLW		0X30
    MOVWF		FSR
LAZO
    INCF		INDF,F
    MOVLW		.10
    SUBWF		INDF,W
    BTFSS		STATUS,Z
    RETURN		;VUELVO CUANDO LE PUDE SUMAR 1 Y ES MENOR A 10
    CLRF		INDF
    INCF		FSR,F
    MOVLW		0X36
    SUBWF		FSR,W
    BTFSS		STATUS,Z
    GOTO		LAZO
    RETURN
    
    
    
    
    
    
TABLA	
    ADDWF		PCL
    RETLW		0x40	; 0010 0000
    RETLW		0x79	; 0111 1001
    RETLW		0x24	; 0010 0010
    RETLW		0x30	; 0011 0000
    RETLW		0x19	; 0001 1001
    RETLW		0x12
    RETLW		0x02
    RETLW		0x78
    RETLW		0x00	; 0000 0000
    RETLW		0x18	; 0001 1000
    
    
    END
		
		

		
		
		
		