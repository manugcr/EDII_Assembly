; Escribir un programa que sume dos valores de 16bits
; *******************************************************
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>

	    ; Declaro las variables y las guardo en un espacio de memoria
	    SUM1L EQU 0x21	; Parte baja del primer sumando
	    SUM1H EQU 0x22	; Parte alta del primer sumando
	    SUM2L EQU 0x23	; Parte baja del segundo sumando
	    SUM2H EQU 0x24	; Parte alta del segundo sumando
	    RESL  EQU 0x25	; Parte baja del resultado 
	    RESH  EQU 0x26	; Parte alta del resultado
	    CARRY EQU 0x27	; Carry de parte alta
 
	    ORG 0x00
	    GOTO START		; Skipeo la direccion 0x04 de interrupciones
	    ORG 0x05
	    
START
	    MOVLW 0xFF		; Valuo A y B
	    MOVWF SUM1L
	    MOVLW 0x01
	    MOVWF SUM1H
	    MOVLW 0xFF
	    MOVWF SUM2L
	    MOVLW 0x01
	    MOVWF SUM2H

	    MOVF SUM1L, w	; Suma de la parte baja
	    ADDWF SUM2L, w
	    MOVWF RESL			    
	    BTFSC STATUS, C	; Si hay carry en la parte baja
	    INCF RESH		; incremento 1 la parte alta

	    MOVF SUM1H, w	; Suma de la parte alta
	    ADDWF SUM2H, w
	    BTFSC STATUS, C	; Si hay carry en la parte alta
	    INCF CARRY		; incremento 1 el carry
	    
	    ADDWF RESH, w	; Sumo el valor anterior con el carry de la
	    MOVWF RESH		; parte baja si es que hay y guardo el resultado
	    END    