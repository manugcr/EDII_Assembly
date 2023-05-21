; *******************************************************************
; Redactar un programa que multiplique por 4 todos los números contenidos en los 
; Registros que van de 50H a 5FH (ambos inclusive). Estos números tienen su 
; nibble superior en 0 y el inferior contiene un número binario natural. El resultado 
; se guarda en el mismo lugar.
; *******************************************************************
    		
		LIST P=16F887
		#INCLUDE <p16f887.inc>

		COUNTER		EQU 0x40	; Espacios de memoria para variables auxiliares
		FIRST_DIR	EQU 0x50	; Lugar de memoria del primer valor a convertir

		ORG 0x00
		GOTO START
		ORG 0x05

; *******************************************************************
; ************************ SUBRUTINAS *******************************
; *******************************************************************
		
; Subrutina para rellenar con el valor 02h a los espacios de memoria 0x50 a 0x5F
LOAD_VALUES	MOVLW 0x10		; Cargo 15 al contador
		MOVWF COUNTER	    
		MOVLW FIRST_DIR		; Cargo el primer espacio de memoria a FSR
		MOVWF FSR		; Esto hace que la proxima escritura sea a donde diga FIRST
		MOVLW h'02'		; El valor a escribir lo guardo en w  
VAL_LOOP	MOVWF INDF		; Muevo w a donde apunte FSR
		INCF FSR, f		; Incremento FSR en 1
		DECFSZ COUNTER, f	; Decremento el contador en 1
		GOTO VAL_LOOP		; Reseteo el loop
		RETURN	
		
; *******************************************************************
; *************************** MAIN **********************************
; *******************************************************************
		
START		CALL LOAD_VALUES
		MOVLW d'16'		; Cargo 16 al contador
		MOVWF COUNTER		; Lo muevo a su variable COUNTER
		MOVLW FIRST_DIR		; Esta es la direccion donde se comieza a guardar	
		MOVWF FSR		; Hago que FSR apunte a la primer direccion de guardado
		
LOOP		RLF INDF, F		; Desplazo dos lugares hacia la izquierda
		RLF INDF, F		; Esto es equivalente a multiplicar por 2, 2 veces.
		INCF FSR, F
		DECFSZ COUNTER, F
		GOTO LOOP
		END