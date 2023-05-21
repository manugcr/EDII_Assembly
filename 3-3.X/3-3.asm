; *******************************************************	    
; Escribir un programa que resuelva la ecuación: 
; (A + B) - C (posiciones 21H, 22H y 23H)
; *******************************************************
	    
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    VAL_A EQU 0x21
	    VAL_B EQU 0x22
	    VAL_C EQU 0x23
	    RES_L EQU 0x24
	    RES_H EQU 0x25
	    TEMP1 EQU 0x26
	    TEMP2 EQU 0x27
 
	    ORG 0x00
 	    GOTO START		    ; Skipeo la direccion 0x04 de interrupciones
	    ORG 0x05
	    

	    
START	    
	    MOVLW 0x05		    ; Doy valores a A, B y C
	    MOVWF VAL_A
	    MOVLW 0x02
	    MOVWF VAL_B
	    MOVLW 0x0A
	    MOVWF VAL_C		    
	    
	    MOVF VAL_B, W
	    SUBWF VAL_A, W
	    MOVWF RES_L
	    BTFSC STATUS, C
	    GOTO END_PROG
	    COMF RES_L, F
	    INCF RES_L, F
	    INCF RES_H, F
END_PROG
	    GOTO $
	    END
	    
;	    MOVF VAL_A, W	    ; SUMO A+B, guardo en RES_L
;	    ADDWF VAL_B, W
;	    MOVWF RES_L
;	    
;	    BTFSC STATUS, C	    ; Si la suma anterior da carry
;	    INCF RES_H		    ; Lo guardo en RES_H
;	    
;	    MOVF VAL_C, W	    ; RES_L = RES_L - VAL_C
;	    SUBWF RES_L, F
	    
;	    ; Como se resta en complemento a dos, paso a BCD
;	    BTFSC STATUS,C	    ; Si el bit de acarreo está a 1, el resultado es positivo
;	    GOTO POSITIVE	    ; Saltar al caso positivo
;	    
;NEGATIVE    COMF W,W		    ; Complementar W para obtener su valor absoluto
;	    INCF W,W		    ; Sumar 1 a W para obtener su valor absoluto
;	    GOTO NEG_END
;	    
;POSITIVE    MOVLW 0x0A		    ; Cargar el valor 10 en W
;	    MOVWF TEMP1		    ; Guardar W en TEMP1
;	    CLRF TEMP2		    ; Limpiar TEMP2
;	    
;LOOP	    RLF W,F		    ; Rotar a la izquierda W y guardar el bit de acarreo en C
;	    RLF TEMP2,F		    ; Rotar a la izquierda TEMP2 y guardar C en el bit menos significativo
;	    SUBWF TEMP2,W	    ; Restar TEMP2 a TEMP1 y guardar el resultado en W
;	    BTFSC STATUS,C	    ; Si el bit de acarreo está a 1, la resta fue exitosa
;	    GOTO NEXT		    ; Saltar al siguiente paso
;	    MOVF TEMP2,W	    ; Si no, restaurar W con el valor original de TEMP2
;	    
;NEXT	    DECFSZ TEMP1,F	    ; Decrementar TEMP1 y verificar si es cero
;	    GOTO LOOP		    ; Si no es cero, repetir el bucle principal
;	    MOVF TEMP2,W	    ; Si es cero, mover TEMP2 a W para obtener el resultado en BCD
;	    
;	    ; Si el resultado original era negativo, se le agrega un signo menos en BCD
;	    BTFSS STATUS,C	    ; Si el bit de acarreo está a 0, el resultado era negativo
;	    GOTO POS_END	    ; Saltar al final del caso positivo 
;	    
;NEG_END	    MOVLW 0x6D
;	    MOVWF TEMP1
;	    SWAPF W, F
;	    IORWF TEMP1, W
;	    
;POS_END	    MOVWF RES_L
;	    GOTO $
;	    END
	    
;	    MOVF VAL_A, W	    ; Carga VAL_A en W
;	    ADDWF VAL_B, W	    ; Suma VAL_B a W y guarda el resultado en RL
;	    MOVWF RES_L
;	    
;	    BTFSC STATUS, C
;	    BSF RES_H, 0
;	    
;	    MOVF VAL_C, W	    ; Carga VAL_C en W
;	    SUBWF RES_L, F	    ; RL = RL - W
;	    
;	    GOTO $
;	    END