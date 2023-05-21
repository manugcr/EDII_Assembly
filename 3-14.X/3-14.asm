; **************************************************************************
; Escribir un programa que convierta un conjunto de números de 4 bits en su 
; equivalente en código Gray. Estos números tienen su nibble
; superior en 0 y el inferior contiene un número binario natural. 
; Son 20 números ubicados a partir del Registro 120H. Utilizar tabla.
; **************************************************************************
		
		LIST P=16F887
		#INCLUDE <p16f887.inc>

		COUNTER		EQU 0x110   
		POINTER		EQU 0x111   
		FIRST_DIR	EQU 0x20   ; Lugar de memoria del primer valor a convertir
	
		ORG 0x00
		GOTO START
		ORG 0x05
		
; *******************************************************************
; ************************ SUBRUTINAS *******************************
; *******************************************************************

; Desplazarme entre bancos de memoria
BANK_0	    BCF STATUS, IRP	    ; Bank 0-00
            BCF STATUS, RP0	    
            BCF STATUS, RP1
            RETURN
BANK_1	    BCF STATUS, IRP	    ; Bank 0-01
            BSF STATUS, RP0
            BCF STATUS, RP1
            RETURN
BANK_2	    
;	    BSF STATUS, IRP	    ; De manera indirecta
;	    BCF FSR, 7
	    BSF STATUS, IRP	    ; Bank 1-10
            BCF STATUS, RP0 
            BSF STATUS, RP1
            RETURN
BANK_3	    BSF STATUS, IRP	    ; Bank 1-11 
            BSF STATUS, RP0	    
            BSF STATUS, RP1
            RETURN		

; Subrutina para cargar valores a posiciones de memoria consecutivas
LOAD_VALUES	MOVLW d'20'	    ; Cargo 20 al contador, es decir 20 valores
		MOVWF COUNTER	    
		MOVLW FIRST_DIR	
		MOVWF FSR			
		MOVLW h'10'	    ; Escribe 08h en los 20 lugares  
VAL_LOOP	MOVWF INDF			
		INCF FSR, f
		ADDLW d'01'	    ; Sumo 1 a cada valor para que sean distintos
		DECFSZ COUNTER, f   ; 0x10 .. 0x11 .. 0x12 ..
		GOTO VAL_LOOP		
		RETURN

; *******************************************************************
; ********************* TABLA BIN to GRAY ***************************
; *******************************************************************		
TABLE	    ADDWF PCL, f	; 0 1 3 2 7 6 4 5 F E C D 8 9 B A
            RETLW 0x00		; 0 -> B 0000 -> G 0000 
            RETLW 0x01		; 1 -> B 0001 -> G 0001
            RETLW 0x03		; 2 -> B 0010 -> G 0011
            RETLW 0x02		; 3 -> B 0011 -> G 0010
            RETLW 0x07		; 4 -> B 0100 -> G 0110
            RETLW 0x06		; 5 -> B 0101 -> G 0111
            RETLW 0x04		; 6 -> B 0110 -> G 0101
            RETLW 0x05		; 7 -> B 0111 -> G 0100
            RETLW 0x0F		; 8 -> B 1000 -> G 1100
            RETLW 0x0E		; 9 -> B 1001 -> G 1101
            RETLW 0x0C		; A -> B 1010 -> G 1111
            RETLW 0x0D		; B -> B 1011 -> G 1110
            RETLW 0x08		; C -> B 1100 -> G 1010
            RETLW 0x09		; D -> B 1101 -> G 1011
            RETLW 0x0B		; E -> B 1110 -> G 1001
            RETLW 0x0A		; F -> B 1111 -> G 1000
		
; *******************************************************************
; *************************** MAIN **********************************
; *******************************************************************
START	    CALL BANK_2		; Me desplazo al banco 2 
	    CALL LOAD_VALUES
	    
            MOVLW d'20'		; Cargo 20 al contador por que son 20 valores
            MOVWF COUNTER
            MOVLW FIRST_DIR	; Cargo la direccion del primer numero a FSR
            MOVWF POINTER
	    
LOOP	    MOVF POINTER, w
            MOVWF FSR
            MOVF INDF, w
            ANDLW b'00001111'		; Enmascaro el 2do nibble
            CALL TABLE
            MOVWF INDF
            INCF POINTER, f 
            DECFSZ COUNTER
            GOTO LOOP
	    GOTO $
            END