 ; ******************************************************************************
; Realizar un programa que obtenga el valor de la tecla pulsada en un teclado
; matricial 4x4 y lo almacene en código BCD empaquetado. Debe colocarla en un
; buffer circular de 32 registros desde la posición 20H. La resolución de cual
; es la tecla apretada y su almacenamiento se resuelve integramente dentro de
; la rutina de interrupción. 
; Extra: Mostrar la ultima tecla pulsada en un display de 7seg de anodo comun.
; ******************************************************************************

	    #INCLUDE    <P16F887.INC>
	    LIST	P = 16F887

; ***************************** PIC CONFIG *************************************
	    __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
; ***************************** VARIABLES **************************************  
	    COL_ON	EQU 0x40    ; Declaro variables a partir de 70h que esta
	    COL_ON_AUX	EQU 0x41    ; espejado en los 4 bancos
	    COLUMN	EQU 0x42    
	    ROW		EQU 0x43
	    MAX_COL	EQU 0x44
	    MAX_ROW	EQU 0x45
	    BUFF_INIT	EQU 0x46
	    BUFF_LIM	EQU 0x47
	    BUFF_W	EQU 0x48
	    AUX		EQU 0x4B
	    STATUS_TEMP	EQU 0x4C
	    W_TEMP	EQU 0x4D
   
; ***************************** INIT *******************************************
	    ORG	    0x00
	    GOTO    SETUP	    
	    ORG	    0x04
	    GOTO    IRS	    
	    ORG	    0x05

; ***************************** REG CONFIG *************************************  
SETUP	    MOVLW   .4		    ; Es un teclado de 4x4
	    MOVWF   MAX_COL
	    MOVWF   MAX_ROW
	    
	    MOVLW   0x20	    ; El buffer empieza en 0x20
	    MOVWF   BUFF_INIT	    ; y termina en 0x40 -> (0x20 + 32)=0x40
	    MOVWF   BUFF_W
	    MOVLW   0x40	
	    MOVWF   BUFF_LIM
	    
	    BANKSEL TRISB	    ; El teclado esta conectado en PORTB
	    MOVLW   b'11110000'	    ; RB<7:4> Entradas - RB<3:0> Salidas
	    MOVWF   TRISB	    
	    BANKSEL ANSELH	    ; Seteo entradas digitales
	    CLRF    ANSELH
	    
	    BANKSEL TRISC	    ; Seteo PORTC como output, aca se conecta
	    CLRF    TRISC	    ; el display 7seg
	    
	    BANKSEL OPTION_REG	    ; Activo pull-ups en PORTB
	    BCF	    OPTION_REG, 7 
	    BANKSEL IOCB	    ; Activo interrupciones por RB<7:4>
	    MOVLW   b'11110000'
	    MOVWF   IOCB
	    BANKSEL WPUB	    ; Activo pull-ups RB<7:4>
	    MOVLW   b'11110000'
	    MOVWF   WPUB
	    
	    BANKSEL INTCON	    ; Activo interrupciones globales y RB
	    MOVLW   b'10001000'
	    MOVWF   INTCON
	    
	    CLRF    AUX		    ; Limpio variables e inicializo
	    CLRF    PORTB
	    CLRF    PORTC
	    COMF    PORTC	    ; Inicializo con el display apagado
	    GOTO    MAIN
	    	    
; ***************************** MAIN *******************************************
MAIN	    GOTO    $		    ; Espero interrupcion
	    
; *********************** TABLES ***********************************************	    
D7S_ANOD    ADDWF   PCL, F	    ; Anodo comun -> hgfedcba
	    RETLW   B'11111000'	    ; (0,0) = 7	    
	    RETLW   B'10011001'	    ; (1,0) = 4
	    RETLW   B'11111001'	    ; (2,0) = 1
	    RETLW   B'10001110'	    ; (3,2) = F
	    RETLW   B'10000000'	    ; (0,1) = 8
	    RETLW   B'10010010'	    ; (1,1) = 5
	    RETLW   B'10100100'	    ; (2,1) = 2
	    RETLW   B'11000000'	    ; (3,1) = 0
	    RETLW   B'10010000'	    ; (0,2) = 9
	    RETLW   B'10000010'	    ; (1,2) = 6
	    RETLW   B'10110000'	    ; (2,2) = 3
	    RETLW   B'10000110'	    ; (3,0) = E
	    RETLW   B'10001000'	    ; (0,3) = A
	    RETLW   B'10000011'	    ; (1,3) = B
	    RETLW   B'11000110'	    ; (2,3) = C
	    RETLW   B'10100001'	    ; (3,3) = D
	    
ROWS_TEST   ADDWF   PCL, F	    ; Roto un 0 en las 4 filas del teclado
	    RETLW   B'11111110'	    
	    RETLW   B'11111101'
	    RETLW   B'11111011'
	    RETLW   B'11110111'
	    
; *********************** SUB-ROUTINES *****************************************
RESET_BUFF  MOVF    BUFF_INIT, W    ; Resetea direccion donde empieza a 
	    MOVWF   BUFF_W	    ; Guardar datos
	    RETURN    
	    
SAVE	    MOVWF   AUX		    ; Guarda el dato en la direccion de mem
	    MOVF    BUFF_W, W	    ; que deberia ir, testeando de no
	    MOVWF   FSR		    ; pasarse de las 32 variables
	    MOVF    AUX, W
	    MOVWF   INDF
	    INCF    BUFF_W, F
	    MOVF    BUFF_W, W
	    SUBWF   BUFF_LIM, W
	    BTFSC   STATUS, Z
	    CALL    RESET_BUFF
	    RETURN
	    
; *********************** INTERRUPTION ROUTINE *********************************
IRS	    MOVWF   W_TEMP	    ; Salvo contexto
	    SWAPF   STATUS, W
	    MOVWF   STATUS_TEMP
	    
	    BTFSS   INTCON, RBIF    ; Testeo si es interrupcion por PORTB
	    GOTO    END_IRS
	    GOTO    GET_KEY
	    
GET_KEY	    MOVF    PORTB, W	    ; Guardo el valor de la columna prendida
	    ANDLW   0xF0	    ; en el nibble superior
	    MOVWF   COL_ON	    
	    MOVWF   COL_ON_AUX	    
	    SWAPF   COL_ON, F
    TEST    RRF	    COL_ON, F	    ; Loop de verificacion de columnas, termina
	    BTFSS   STATUS, C	    ; despues de recorrer las 4.
	    GOTO    ROW_DEC	    
	    INCF    COLUMN, F
	    MOVF    COLUMN, W
	    SUBWF   MAX_COL, W
	    BTFSC   STATUS, Z
	    GOTO    END_IRS
	    GOTO    TEST
	    
ROW_DEC	    MOVF    ROW, W	    ; Loop de verificacion de filas, termina
	    CALL    ROWS_TEST	    ; cuando encuentra la fila presionada
	    MOVWF   PORTB
	    MOVF    COL_ON_AUX, W
    	    SUBWF   PORTB, W
	    ANDLW   0xF0
	    BTFSC   STATUS, Z
	    GOTO    SHOW_RES
	    INCF    ROW
	    MOVF    ROW, W
	    SUBWF   MAX_ROW, W
	    BTFSC   STATUS, Z
	    GOTO    END_IRS
	    GOTO    ROW_DEC
	    
SHOW_RES    BCF	    STATUS, C
	    RLF	    ROW, F
	    RLF	    ROW, W
	    ADDWF   COLUMN, W
	    CALL    D7S_ANOD
	    MOVWF   PORTC
	    CALL    SAVE
	    GOTO    END_IRS
	    
END_IRS	    CLRF    PORTB	    ; Limpio el puerto del teclado
	    MOVF    PORTB, W	
    	    BCF	    INTCON, RBIF    ; Bajo la flag de interrupcion
	    CLRF    ROW		    ; Limpio fila y columna
	    CLRF    COLUMN
	    
	    SWAPF   STATUS_TEMP, W  ; Retorno contexto.
	    MOVWF   STATUS
	    SWAPF   W_TEMP, F
	    SWAPF   W_TEMP, W
	    RETFIE
	    
	    END