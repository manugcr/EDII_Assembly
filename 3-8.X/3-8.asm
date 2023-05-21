; *******************************************************	    
; Escribir un programa para almacenar el valor 33D en 
; 15 posiciones contiguas de la memoria de datos, 
; empezando en la dirección 0x30.
; *******************************************************
	    
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    COUNT EQU 0x20  ; La cantidad de valores a guardar
	    FIRST EQU 0x30  ; Esta seria la direccion donde comienza a guardar
 
	    ORG 0x00
	    GOTO START	    ; Skipeo la direccion 0x04 de interrupciones
	    ORG 0x05
START
	    MOVLW 0x0F	    ; Cargo 15 al contador
	    MOVWF COUNT	    
	    MOVLW FIRST	    ; Cargo el primer espacio de memoria a FSR
	    MOVWF FSR	    ; Esto hace que la proxima escritura sea a donde diga FIRST
	    MOVLW .33	    ; Guardo 33d a w
	    
LOOP	    MOVWF INDF	    ; Muevo w a donde apunte FSR
	    INCF FSR, f	    ; Incremento FSR en 1
	    DECFSZ COUNT, f ; Decremento el contador en 1
	    GOTO LOOP	    ; Reseteo el loop
	    GOTO $
	    END