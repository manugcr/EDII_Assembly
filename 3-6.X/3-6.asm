; *******************************************************	    
; Escribir un programa que su ejecución demore 
; un 1s = 1000ms  = 1.000.000us (Cristal de 4MHz).
; *******************************************************
	    
	    LIST P=16F887
	    #INCLUDE <p16f887.inc>
	    
	    ; Declaro las variables y las guardo en un espacio de memoria
	    COUNT1  EQU	0x21
	    COUNT2  EQU	0x22
	    COUNT3  EQU	0x23

	    ORG	    0x00
 	    GOTO    START
	    ORG	    0x05
	    
DELAY	    MOVLW d'72'		; El valor mas alto es 00 no FF
	    MOVWF COUNT1	; pq primero decrementa despues hace el condicional
	    MOVLW d'2'		; los ciclos son de (1-256) por cada loop
	    MOVWF COUNT2	; al sumarse n loops la formula es recursiva con el resultado anterior
	    MOVLW d'1'		; cyc() = 2 + 3*(VAL-1)
	    MOVWF COUNT3	; es 1 loop de dos ciclos y 255 loops de tres ciclos 
LOOP	    DECFSZ COUNT1, f	; cyc(CONT1, CONT2, CONT3) = 3*CONT1 + 770*CONT2 + 197122*CONT3 - 197885 = 1,000,000
	    GOTO LOOP		;			   = 3*CONT1 + 770*CONT2 + 197122*CONT3 = 197885 + 1,000,000
	    DECFSZ COUNT2, f	;			   = 3*CONT1 + 770*CONT2 + 197122*CONT3 = 1,197,885
	    GOTO LOOP		;
	    DECFSZ COUNT3, f	; para CONT3 --> Res/CONT3 = 
	    GOTO LOOP		;
	    RETURN
	   
START
	    CALL DELAY
	    GOTO $
	    END
	    
	    ; Valuo los contadores
;START	    MOVLW d'72'		; El valor mas alto es 00 no FF
;	    MOVWF COUNT1	; pq primero decrementa despues hace el condicional
;	    MOVLW d'2'		; los ciclos son de (1-256) por cada loop
;	    MOVWF COUNT2	; al sumarse n loops la formula es recursiva con el resultado anterior
;	    MOVLW d'1'		; cyc() = 2 + 3*(VAL-1)
;	    MOVWF COUNT3	; es 1 loop de dos ciclos y 255 loops de tres ciclos 
;	    
;DELAY	    DECFSZ COUNT1, f	; cyc(CONT1, CONT2, CONT3) = 3*CONT1 + 770*CONT2 + 197122*CONT3 - 197885 = 1,000,000
;	    GOTO DELAY		;			   = 3*CONT1 + 770*CONT2 + 197122*CONT3 = 197885 + 1,000,000
;	    DECFSZ COUNT2, f	;			   = 3*CONT1 + 770*CONT2 + 197122*CONT3 = 1,197,885
;	    GOTO DELAY		;
;	    DECFSZ COUNT3, f	; para CONT3 --> Res/CONT3 = 
;	    GOTO DELAY		;		 1,197,885/197122	= 6 ex 15153 --> 0x06
;	    GOTO $		; 
;	    END			; para CONT2 --> mod/CONT2 = 
	    			;		 15153/770		= 19 ex 523  --> 0x13
				; 
				; para CONT1 --> mod/CONT1 = 
				;		     523/3		= 174 ex 1   --> 0xAE
				;					Como sobra un ciclo lo resto --> 0xAD
