; *******************************************************************
; Realizar un programa en Lenguaje Ensamblador que transforme 10 Bytes que 
; contienen números BCD empaquetados a ASCII. Los números BCD están 
; almacenados empezando en el Registro A0H y el resultado se almacenará a partir 
; del Registro 1A0H.
; *******************************************************************

    		LIST P=16F887
		#INCLUDE <p16f887.inc>

		COUNTER		EQU 0x40	; Espacios de memoria para variables auxiliares
		
		FIRST_DIR	EQU 0xA0	; Lugar de memoria del primer valor a convertir
		RESULT_DIR	EQU 0x1A0	; Lugar de memoria del primer valor ya convertido

		ORG 0x00
		GOTO START
		ORG 0x05

; *******************************************************************
; ************************ SUBRUTINAS *******************************
; *******************************************************************
		
; *******************************************************************
; *************************** MAIN **********************************
; *******************************************************************
START
		END