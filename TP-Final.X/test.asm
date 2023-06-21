; ******************************************************************************
; Codigo que lee el valor analogico de un sensor de nivel conectado en RA5 para
; luego convertirlo a digital con el ADC, guardar esta conversion en un registro
; de memoria, mostrarlo en un display de barras conectado en el PORTB. Si el valor
; medido supera el 90% de su maximo enciende un buzzer a modo de alarma en RD6.
; A su vez los datos medidos son enviados a la PC mediante puerto serie cada un
; tiempo determinado, y desde la PC se puede prender o apagar el funcionamiento 
; del ADC enviando el codigo especifico.
; 
; Se utilizaron interrupciones por TMR0, ADC y TX/RX.
; ******************************************************************************
; ******************************************************************************
	    LIST	P = 16F887
	    #INCLUDE    <P16F887.INC>
	    
; ******************************************************************************
; ****************************** PIC-CONFIG ************************************
; ******************************************************************************
	    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
	    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	    
; ******************************************************************************
; ****************************** VARIABLES *************************************
; ******************************************************************************
	    ; Variables en los registros 0x70++ para tenerlas espejadas en los 4 bancos de memoria.
	    W_TEMP	EQU 0x70    ; Guardar contexto de W.
	    S_TEMP	EQU 0x71    ; Guardar contexto de STATUS.
	    ADC_READ	EQU 0x72    ; Valor ya convertido leido por el ADC.
	    TEMP	EQU 0x73    ; Variable temporal para delay de 20[us]
	    T0_VAL	EQU 0x74    ; Valor para cargar el TMR0 y contar 50[ms].
	    SEC_CNT	EQU 0x75    ; Contador para llegar a 1[s] con TMR0.
	    BUZ_VAL	EQU 0x76    ; Valor maximo para prender la alarma.
	    RX_DATA	EQU 0x77    ; Valor que llega desde la PC.
	    RX_CODE	EQU 0x78    ; Letra para prender y apagar el ADC.
	    TEMP2	EQU 0x79    ; Variable temporal para testear cuantas barras leds encender.
    
; ******************************************************************************
; ****************************** INIT ******************************************
; ******************************************************************************
	    ORG	    0x00
	    GOTO    SETUP	   
	    ORG	    0x04
	    GOTO    ISR		    ; Rutina de interrupcion.
	    ORG	    0x05
	    
; ******************************************************************************
; ****************************** REG-CONFIG ************************************
; ******************************************************************************
SETUP	    MOVLW   .60		    ; Timer de 50[ms] con pre-scaler 256.
	    MOVWF   T0_VAL
	    MOVLW   .20		    ; Contador de 20 para llegar a 1[s] -> 20*50ms = 1000ms.
	    MOVWF   SEC_CNT
	    MOVLW   .230	    ; Seteo valor maximo para prender la alarma.
	    MOVWF   BUZ_VAL
	    
	    MOVLW   0x73	    ; El ADC se prende/apaga con 73h = s
	    MOVWF   RX_CODE
	    
	    BANKSEL TRISA	    ; TRISA Input en RA5.
	    MOVLW   b'00100000'	    
	    MOVWF   TRISA
	    BANKSEL ANSEL	    ; RA5 como salida analogica.
	    MOVLW   b'00100000'	    ; Limpio ANSELH para setear PORTB digital.    
	    MOVWF   ANSEL
	    CLRF    ANSELH	    
	    BANKSEL TRISB	    ; PORTB/D como output digital.
	    CLRF    TRISB
	    CLRF    TRISD
	    BCF     TRISC, RC5	    ; Led conectado en RC5 para debug del ADC.
	    BCF	    TRISA, RA0	    ; Led conectado en RA0 para debug del PIC.
	    
	    BANKSEL OPTION_REG	    ; RBPU INTEDG T0CS T0SE PSA PS2 PS1 PS0
	    MOVLW   b'11010111'	    ; Activo clk interno y pre-scaler 256.
	    MOVWF   OPTION_REG
	    
	    CALL    INIT_UART	    ; Setup de UART y ADC.
	    CALL    INIT_ADC
	    CALL    DELAY_20us
	    CALL    INIT_INT	    ; Activo interrupciones.
	    CALL    LOAD_TMR0	    ; Inicio a contar TMR0.
	    
	    BANKSEL ADCON0
	    BSF	    ADCON0, GO	    ; El ADC comienza a convertir.
	    
	    CLRF    PIR1	    ; Limpio registros.
	    CLRF    PORTA
	    CLRF    PORTB
	    CLRF    PORTD
	    
	    BSF	    PORTC, RC5	    ; Prendo los leds de funcionamiento para corroborar que funciona el PIC.
	    BSF	    PORTA, RA0	    ; El de RA0 es general, el de RC5 es para el on/off del ADC.
	    GOTO    MAIN

; ******************************************************************************
; ****************************** MAIN ******************************************
; ******************************************************************************    
MAIN	    MOVF    RX_DATA, W	    ; Testeo el codigo que llega desde la PC.
	    SUBWF   RX_CODE, W	    ; Si este codigo es igual a RX_CODE apagamos/prendemos el ADC.
	    BTFSC   STATUS,Z	    ; Si es distinto no hago nada.
	    CALL    ADC_OFF_ON

	    MOVF    ADC_READ, W	    ; Restas para convertir mostrar el numero binario
	    MOVWF   TEMP2	    ; en una escala de 0-100%
	    MOVLW   .3		    ; Se resta de a 25 para ver la cantidad de barras a encender.
	    SUBWF   TEMP2, W	    ; Basicamente se verifica si la medicion esta entre el rango de 25 unidades
	    BTFSS   STATUS, C	    ; Se toma 25 pq 256/10 ~= 25
	    GOTO    ZERO_LED
	    MOVLW   .25
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    ONE_LED
	    MOVLW   .50
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    TWO_LED
	    MOVLW   .75
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    THREE_LED
	    MOVLW   .100
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    FOUR_LED
	    MOVLW   .125
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    FIVE_LED
	    MOVLW   .150
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    SIX_LED
	    MOVLW   .175
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    SEVEN_LED
	    MOVLW   .200
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    EIGHT_LED
	    MOVLW   .225
	    SUBWF   TEMP2, W
	    BTFSS   STATUS, C
	    GOTO    NINE_LED	    ; No se testea el ultimo caso ya que se hace por descarte.
	    GOTO    TEN_LED
	    GOTO    MAIN
	     
; ******************************************************************************
; ****************************** SUB-ROUTINES **********************************
; ******************************************************************************
;------- Rutina para iniciar interrupciones.
INIT_INT    NOP
	    BANKSEL PIE1	    ; - ADIE RCIE TXIE SSPIE CCP1IE TMR2IE TMR1IE
	    MOVLW   b'01100000'	    ; Activamos interrupciones por ADC y RCIE
	    MOVWF   PIE1
	    BANKSEL INTCON	    ; GIE PEIE T0IE INTE RBIE T0IF INTF RBIF
	    MOVLW   b'11100000'	    ; Activo interrupciones globales y por perifericos y por TMR0.
	    MOVWF   INTCON
	    RETURN

;------- Rutinas para el ADC.
INIT_ADC    NOP
	    BANKSEL ADCON0	    ; ADCS1 ADCS0 CHS3 CHS2 CHS1 CHS0 GO/DONE ADON
	    MOVLW   b'10010001'	    ; Prendemos el ADC, Seteamos pin RA5/AN4 a medir y
	    MOVWF   ADCON0	    ; un conversion-clock de Fosc/32.
	    BANKSEL ADCON1	    ; ADFM - VCFG1 VCFG0 - - - -
	    MOVLW   b'00000100'	    ; Justificacion izquierda, ADRESH con 8 bits y ADRESH 2 bits msb.
	    MOVWF   ADCON1	    ; Voltage reference como Vdd y Vcc del pic.
	    RETURN
DELAY_20us  MOVLW   .10		    ; Delay de ~20ms para funcionamiento del ADC.
	    MOVWF   TEMP
	    DECFSZ  TEMP, F
	    GOTO    $-1
	    RETURN

;------- Rutinas para comunicacion serie.
INIT_UART   NOP
	    BANKSEL SPBRG	    ; Seteamos baud-rate = 9600bps
	    MOVLW   d'25'
	    MOVWF   SPBRG
	    BANKSEL TXSTA	    
	    MOVLW   b'00100100'	    ; Configuro TXSTA como 8 bit transmission, tx habilitado, modo async, high speed baud rate
	    MOVWF   TXSTA
	    BANKSEL RCSTA	    ; Serial port enable, Continuous Receive
	    MOVLW   b'10010000'	    ; Habilito recepción y pines de puerto
	    MOVWF   RCSTA
	    BANKSEL PIR1
	    RETURN
;------- Rutina para enviar un dato por TX.	
SEND_TX	    MOVF    ADC_READ, W	    ; Muevo lo que leyo el ADC a W y lo cargo en TXREG.
	    BANKSEL TXREG	    ; Cuando se carga TXREG este comienza a enviarlo por TX.
	    MOVWF   TXREG
	    BANKSEL TXSTA
	    BTFSS   TXSTA, TRMT	    ; Si el TRMT es 1, el dato ya se envio, si no espero.
	    GOTO    $-1
	    RETURN
	    
;------- Rutinas para prender y apagar el buzzer en PORTD RD6.
BUZ_OFF	    BSF	    PORTD, RD6	    ; El buzzer se activa con 0 y se apaga con 1.
	    GOTO    MAIN
BUZ_ON	    BCF	    PORTD, RD6
	    GOTO    MAIN
	
;------- Rutinas para prender y apagar las mediciones dependiendo lo que se envie desde la PC.
ADC_OFF_ON  CLRF    RX_DATA	    ; Hacemos CLRF del valor recibido para que no quede en loop infinito.
	    BANKSEL ADCON0	    ; Si el ADC estaba encendido lo apagamos y el led RC5 se apaga.
	    BTFSC   ADCON0, ADON    ; Si el ADC estaba apagado lo prendemos y el led RC5 se enciende.
	    GOTO    ADC_OFF	    ; El ADC se apaga y se prende controlando el bit ADON.
	    GOTO    ADC_ON	    ; Para apagar/prender tambien tenemos que controlar el bit GO/DONE.
ADC_OFF	    BCF	    ADCON0, ADON
	    BCF	    ADCON0, 1
	    BANKSEL PORTD
	    BCF	    PORTC, RC5
	    RETURN
ADC_ON	    BSF	    ADCON0, ADON
	    BSF	    ADCON0, 1
	    BANKSEL PORTD
	    BSF	    PORTC, RC5
	    RETURN
	    
;------- Rutinas para resetear el timer0.
LOAD_SEC    MOVLW   .20		    ; Cargamos el contador con 20 cuentas.
	    MOVWF   SEC_CNT
	    RETURN
;------- Rutina para cargar el TMR0 con 60 -> 50[ms].
LOAD_TMR0   MOVF    T0_VAL, W	    ; Cargamos timer con T0_VAL.
	    MOVWF   TMR0
	    RETURN
	    
;------- Rutinas para prender y apagar el LED de RA0.
TOG_LED	    CALL    LOAD_SEC	    ; Resetea la cuenta de 1[s]
	    MOVLW   0x01	    ; Switchea el status del led en RA0
	    XORWF   PORTA, F
	    GOTO    END_ISR
	    
;------- Rutinas para convertir el numero decimal a escala 0-100%   
ZERO_LED    MOVLW   b'00000000'	    ; Despues de testear en que rango esta el valor del ADC
	    BANKSEL PORTB	    ; Se encienden los leds correspondientes y se apagan los que no van.
	    MOVWF   PORTB	    ; Tambien se apaga el buzzer y se prende solo cuando se encienden
	    BCF	    PORTD, RD2	    ; los 10 leds, es decir que esta en el rango del 90% maximo.
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN     
ONE_LED	    MOVLW   b'00000001'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
TWO_LED	    MOVLW   b'00000011'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
THREE_LED   MOVLW   b'00000111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
FOUR_LED    MOVLW   b'00001111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
FIVE_LED    MOVLW   b'00011111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
SIX_LED	    MOVLW   b'00111111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
SEVEN_LED   MOVLW   b'01111111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
EIGHT_LED   MOVLW   b'11111111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BCF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
NINE_LED    MOVLW   b'11111111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BSF	    PORTD, RD2
	    BCF	    PORTD, RD3
	    GOTO    BUZ_OFF
	    GOTO    MAIN 
TEN_LED	    MOVLW   b'11111111'
	    BANKSEL PORTB
	    MOVWF   PORTB
	    BSF	    PORTD, RD2
	    BSF	    PORTD, RD3
	    GOTO    BUZ_ON
	    GOTO    MAIN 
	    
; ******************************************************************************
; ************************* INTERRUPTION-ROUTINE *******************************
; ******************************************************************************
ISR	    MOVWF   W_TEMP	    ; Salvo contexto.
	    SWAPF   STATUS, W
	    MOVWF   S_TEMP
	    
	    BTFSC   INTCON, T0IF    ; Testeo si es interrupcion de TMR0.
	    GOTO    T0_INT
	    BTFSC   PIR1, ADIF	    ; Testeo si es interrupcion de ADC.
	    GOTO    ADC_INT
	    BTFSC   PIR1, RCIF	    ; Testeo si es interrupcion de RX.
	    GOTO    RX_INT
	    GOTO    END_ISR
	    
ADC_INT	    BCF	    PIR1, ADIF	    ; Limpio la flag.
	    MOVF    ADRESH, W	    ; Muevo la medicion a W.
	    MOVWF   ADC_READ	    ; Guardo la medicion en ADC_READ.
	    CALL    DELAY_20us	    
	    BSF	    ADCON0, GO	    ; Vuelvo a dejar el ADC en medicion.
	    GOTO    END_ISR
	   
T0_INT	    BCF	    INTCON, T0IF    ; Limpio flag de T0 y vuelvo a iniciar TMR0.
	    CALL    LOAD_TMR0
	    DECFSZ  SEC_CNT, F	    ; Contador de 20 ciclos, si conto 20 paso 1[s]
	    GOTO    END_ISR
	    CALL    SEND_TX	    ; Envio los datos.
	    GOTO    TOG_LED
	    
RX_INT	    BCF	    PIR1, RCIF	    ; Limpio bandera de RX.
	    MOVF    RCREG, W
	    MOVWF   RX_DATA	    ; Lo que llego de la interrupcion se guarda en el registro TX_DATA.
	    GOTO    END_ISR

END_ISR	    SWAPF   S_TEMP, W	    ; Retorno contexto.
	    MOVWF   STATUS
	    SWAPF   W_TEMP, F
	    SWAPF   W_TEMP, W
	    RETFIE
	    
	    END