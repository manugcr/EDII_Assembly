; *******************************************************	    
; Escribir un programa para almacenar el valor 57d en 
; 48 posiciones contiguas de la memoria de datos, 
; empezando en la dirección 0x1A0.
; *******************************************************
	    
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    COUNT EQU 0x20  ; Variable del contador
 
	    ORG 0x00
	    GOTO START	    ; Skipeo la direccion 0x04 de interrupciones
	    ORG 0x05
START
	    MOVLW 48d	    ; Cargo 48 al contador
	    MOVWF COUNT	    
	    BSF STATUS, IRP ; Seteo el bit IRP de status para poder direccionar a 1A0
	    MOVLW 0xA0	    
	    MOVWF FSR	    ; Seteo file select al registro 0x1A0
	    MOVLW 57d	    ; Valor a setear
	    MOVWF INDF	    ; Seteo el valor que se va a guardar en 0x1A0
LOOP
	    INCF FSR	    ; Incremento las posiciones de memoria 0x1A0 ... 0x1A1 ...
			    ; Cada vez que incremento la posicion de memoria se carga con INDF
	    DECFSZ COUNT    ; Si el contador llega a cero skipeo y termina
	    GOTO LOOP	    ; Si el contador no es 0 vuelvo al loop
	    END210