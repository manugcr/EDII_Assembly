; *******************************************************************    
; Escribir un programa que convierta un conjunto de Números Hexadecimales 
; codificados ASCII en su equivalente en Hexadecimal no empaquetado. Los 
; números codificados ASCII son 8 y están almacenados a partir del Registro 21H.
; Al resultado colocarlo a partir de la posición 31H
; *******************************************************************

		LIST P=16F887
		#INCLUDE <p16f887.inc>

		COUNTER		EQU 0x40	; Espacios de memoria para variables auxiliares
		POINTER1	EQU 0x41
		POINTER2	EQU 0x42
		TEMP		EQU 0x43
		
		FIRST_DIR	EQU 0x21	; Lugar de memoria del primer valor a convertir
		RESULT_DIR	EQU 0x31	; Lugar de memoria del primer valor ya convertido

		ORG 0x00
		GOTO START
		ORG 0x05

; *******************************************************************
; ************************ SUBRUTINAS *******************************
; *******************************************************************		
LOAD_VALUES	MOVLW 0x08			; Cargo 8 valores a las posiciones de memoria
		MOVWF COUNTER	    
		MOVLW FIRST_DIR			
		MOVWF FSR			
		MOVLW h'3E'			
VAL_LOOP	MOVWF INDF			
		INCF FSR, f			
		ADDLW h'01'			; Este ADD es para que los valores sean distintos
		DECFSZ COUNTER, f		; 0x30 .. 0x31 .. 0x32
		GOTO VAL_LOOP			
		RETURN
		
; *******************************************************************
; *************************** MAIN **********************************
; *******************************************************************
START		CALL LOAD_VALUES		; Cargo los valores a convertir a partir de 0x21

		MOVLW d'8'			; Cargo el contador con 8 iteraciones
		MOVWF COUNTER			
		MOVLW FIRST_DIR			; Guardo mi primera direccion 0x21 en el puntero 1
		MOVWF POINTER1			
		MOVLW RESULT_DIR		; Guardo la direccion del resultado en el puntero 2
		MOVWF POINTER2			
		
LOOP		MOVF POINTER1, W
		MOVWF FSR			; Movemos el puntero 1 al FSR
		MOVF INDF, W
		ANDLW h'0F'			; Enmascaro el primer nibble
		MOVWF TEMP
		MOVF POINTER2, W
		MOVWF FSR
		MOVF TEMP, W
		MOVWF INDF			; Guardo el nibble en la posicion del puntero2 (resultado)
		INCF POINTER1, F
		INCF POINTER2, F
		DECFSZ COUNTER
		GOTO LOOP
		
		GOTO $
		END