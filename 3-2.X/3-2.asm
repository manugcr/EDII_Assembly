; Escribir un programa que sume dos valores guardados en 
; los Registros 21H y 22H con resultado en 23H y 24H.
; *******************************************************
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    SUM1 EQU 0x21
	    SUM2 EQU 0x22
	    RESL EQU 0x23   ; Parte baja del resultado
	    RESH EQU 0x24   ; Parte alta del resultado (carry)
 
	    ORG 0x00
	    GOTO START	    ; Skipeo la direccion 0x04 de interrupciones
	    ORG 0x05
START
	    ; Valuo A=0x09 (9) y B=0x0A (15)
	    MOVLW 0xFF
	    MOVWF SUM1
	    MOVLW 0xFF
	    MOVWF SUM2
	
	    MOVF SUM1, w    ; Guardo el valor de SUM1 en w
	    ADDWF SUM2, w   ; Sumo el valor de SUM2 con w y guardo en w
	    MOVWF RESL	    ; Guardo el valor de w en RESL
	    CLRF RESH	    ; Limpio la variable RESH
	    BTFSC STATUS, C ; Si hay carry voy a la proxima linea, si no la skipeo
	    INCF RESH	    ; Si hay carry, seteo RESH en 1, si no termina el programa
    
	    END