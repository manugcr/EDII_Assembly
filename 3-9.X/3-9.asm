; ***************************************************************************************    
; Escribir un programa en assembler que convierta un número de 8 bits escrito en ASCII,
; en su equivalente en BCD no empaquetado. El número se encuentra en la posición 0x20.
; ***************************************************************************************
	    
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    ASCII_NUM	    EQU 0x20
	    BCD_HIGH	    EQU 0x21
	    BCD_LOW	    EQU 0x22
	    BCD_PACKED	    EQU 0x23
	    MASK_HIGH	    EQU 0xF0
	    MASK_LOW	    EQU 0x0F
 
	    ORG 0x00
	    GOTO START
	    ORG 0x05

VALUE_NUM   MOVLW 0x32		    ; Valuo el numero ASCII a convertir
	    MOVWF ASCII_NUM
	    RETURN
	    
ASCII2BCD   MOVLW MASK_LOW	    ; Enmascaro la unidad del numero
	    ANDWF ASCII_NUM, W	    ; 0011 0010 AND 0000 1111 = 0000 0010 = 2
	    MOVWF BCD_LOW	    ; 
	    
	    MOVLW MASK_HIGH	    ; Enmascaro la decena del numero
	    ANDWF ASCII_NUM, W	    ; 0011 0010 AND 1111 0000 = 0011 0000
	    MOVWF BCD_HIGH	    ; Hago un swap de nibbles = 0000 0011 = 3
	    SWAPF BCD_HIGH, F	    ; 0x22 = 3 y 0x21 = 2
	    RETURN

UNP2PACK    SWAPF BCD_HIGH, W
	    ADDWF BCD_LOW, W
	    MOVWF BCD_PACKED
	    RETURN
	    
START	    CALL VALUE_NUM
	    CALL ASCII2BCD
	    CALL UNP2PACK

	    GOTO $
	    END