; *******************************************************	    
; Escribir un programa que su ejecución demore 
; un 1ms  = 1000us (Cristal de 4MHz).
; *******************************************************
	    
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    COUNT EQU 0x21
 
	    ORG 0x00
 	    GOTO START	    ; Skipeo la direccion 0x04 de interrupciones
	    ORG 0x05
START
	    MOVLW 0xFA	    ; 1us (0xFA = 250)
	    MOVWF COUNT	    ; 1us
LOOP
	    NOP		    ; 1us
	    DECFSZ COUNT, f ; 1us o 2us
	    GOTO LOOP	    ; 2us
	    END
	    
; 1000us = 1us + 1us + (LIM-1)*1us + 2us +(LIM-1)*2us + LIM*1us
; 1000us = 4us + (LIM-1)*1us + (LIM-1)*2us + LIM*1us
; 996us	 = LIM*1us - 1us + LIM*2us - 2us + LIM*1us
; 999us	 = LIM(1+2+1)
; LIM	 = 999/4 us = 250us