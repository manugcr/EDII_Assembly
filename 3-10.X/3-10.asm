; *******************************************************************    
; Escribir un programa que convierta un conjunto de números decimales 
; codificados ASCII en su equivalente en BCD empaquetado. Los números 
; codificados ASCII están en los Registros 20H a 30H.
; *******************************************************************
	    
; UNPACKED BCD 0x3A y 0x3B = 0x0A 0x0B = 00001010 00001011  -> 1 byte por digito
; PACKED BCD		   = 0xAB      = 1010 1011	    -> 1 nibble por digito
; Para convertir 0x3A y 0x3B a PACKED BCD 
; 1) Enmascaro el nibble menos significativo -> 0x0A y 0x0B
; 2) Hago un swap de nibbles del primer valor -> 0xA0 y 0x0B
; 3) Sumo los dos valores -> 0xA0 + 0x0B = 0xAB

		LIST P=16F887
		#INCLUDE <p16f887.inc>

		COUNTER		EQU 0x40	; Espacios de memoria para variables auxiliares
		POINTER1	EQU 0x41
		POINTER2	EQU 0x42
		TEMP		EQU 0x43

		FIRST_DIR	EQU 0x20	; Lugar de memoria del primer valor a convertir
		RESULT_DIR	EQU 0x30	; Lugar de memoria del primer valor ya convertido

		ORG 0x00
		GOTO START
		ORG 0x05

; *******************************************************************
; ************************ SUBRUTINAS *******************************
; *******************************************************************		
LOAD_VALUES	MOVLW 0x10			; Cargo 16 al contador
		MOVWF COUNTER	    
		MOVLW FIRST_DIR			; Cargo el primer espacio de memoria a FSR
		MOVWF FSR			; Esto hace que la proxima escritura sea a donde diga FIRST
		MOVLW h'30'			; El valor a escribir lo guardo en w  
VAL_LOOP	MOVWF INDF			; Muevo w a donde apunte FSR
		INCF FSR, f			; Incremento FSR en 1
		ADDLW h'01'			; Incremento en 1 mi variable a convertir 0x3A .. 0x3B .. 0x3C
		DECFSZ COUNTER, f		; Decremento el contador en 1
		GOTO VAL_LOOP			; Reseteo el loop
		RETURN
		
; *******************************************************************
; *************************** MAIN **********************************
; *******************************************************************
START		CALL LOAD_VALUES		; Cargo los valores a convertir a partir de 0x20 hasta 0x30
	    
		MOVLW d'8'			; Como tengo 16 valores, al unir entre dos me quedan 8 valores
		MOVWF COUNTER			; Entonces mi contador es de 8.
		MOVLW FIRST_DIR
		MOVWF POINTER1			; Guardo mi primera direccion 0x20 en el puntero 1
		MOVLW RESULT_DIR
		MOVWF POINTER2			; Guardo la direccion del resultado en el puntero 2

LOOP		MOVF POINTER1, W
		MOVWF FSR			; Movemos el puntero 1 al FSR
		MOVF INDF, W			; Muevo lo que tenga w a donde apunte FSR
		ANDLW h'0F'			; Enmascaro el primer nibble
		MOVWF TEMP
		SWAPF TEMP, F			; Hago swap para poder sumar los dos nibbles
		INCF FSR, F			; 0x0A = 0000 1010 -> 1010 0000
		MOVF INDF, W
		ANDLW h'0F'			; Enmascaro el primer nibble
		ADDWF TEMP, F
		MOVF POINTER2, W
		MOVWF FSR
		MOVF TEMP, W
		MOVWF INDF

		INCF POINTER1, F
		INCF POINTER1, F		; Se incrementa dos veces pq son 2 valores para 1 resultado
		INCF POINTER2, F
		DECFSZ COUNTER
		GOTO LOOP
		GOTO $
		END