; *******************************************************	    
; Escribir un programa que compare dos números A y B. 
; 1) Si son iguales, el resultado debe ser 0. 
; 2) Si A > B, el resultado debe ser la diferencia A - B.
; 3) Y si A < B el resultado debe ser la suma A + B. 
; Considere A en posición 30D, B en 31D y R en 32D.
; *******************************************************
	    
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    VAL_A  EQU	0x20
	    VAL_B  EQU	0x21
	    REST   EQU	0x22

	    ORG	    0x00
 	    GOTO    START
	    ORG	    0x05

START	    MOVLW 0x03		; Doy valores a A y B
	    MOVWF VAL_A
	    MOVLW 0x02
	    MOVWF VAL_B
	    
	    MOVF VAL_A, w	; Resto B - A
	    SUBWF VAL_B, w
	    
	    BTFSC STATUS, Z	; Checkeo si es cero o si es mayor/menor
	    GOTO ZERO
	    BTFSS STATUS, C
	    GOTO AgB
	    
AlB	    MOVF VAL_A, w	; A menor B
	    ADDWF VAL_B, w
	    MOVWF REST
	    GOTO END_PROG
ZERO	    MOVLW 0x00		; A equals B
	    MOVWF REST
	    GOTO END_PROG
AgB	    MOVF VAL_A, w	; A mayor B
	    SUBWF VAL_B, w

	    MOVWF REST

END_PROG    
	    END