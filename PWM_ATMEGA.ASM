; REGISTRO TCCR0
;		7		6		5		4		3		2		1		0
;		FOC0	WGM00	COM01	C0M00	WGM01	CS02	CS01	CS00


;
;	Modo de Comparaci�n de Salida, Modo rapido PWM
;
;	WGM01		WGM00		Descripci�n
;		0 		0 		Modo en operaci�n normal, OC0A desconectado.
;
;		0 		1 		PWM control
;
;		1 		0 		CTC
;
;
;		1 		1 		Fast pwm
;
;
;	Modo de Comparaci�n de Modo fase correcta PWM
;
;		COM01 	COM00 Descripci�n
;		0 		0 		Modo en operaci�n normal, OC0A desconectado.
;
;		0 		1 		Reservado
;
;		1 		0 		Pone a cero oc0
;
;		1 		1 		Pone a 1 oc0

;CS02,CS01,CS00 DIVISIR DE FRECUENCIA
; DDR 		SALIDA A UNO ENTRADA A CERO
; PORT		A UNO LA RESISTENCIA PUS-PULL ACTIVADA- EN OPCION SALIDA VALOR DE ESTA A CERO � A UNO
; PIN		LECTURA DEL VALOR DE ENTRADA

;	CS02 	CS01 	CS00 	Descripci�n
;	0 		0 		0 		Sin fuente de Reloj(Timer/Contador parados)
;	0 		0 		1 		Clk I/O (Sin prescalador)
;	0 		1 		0 		Clk I/O /8(Prescalador)    FRECUENCI /   4000
;	0 		1 		1 		Clk I/O /64(Prescalador)   FRECUENCIA / 16000
;	1 		0 		0 		Clk I/O /256(Prescalador)  FRECUENCIA / 32000
;	1 		0 		1 		Clk I/O /1024(Prescalador) FRECUENCIA / 64000
;	1 		1 		0 		Fuente de Reloj Externo pin T0. Reloj con flanco de bajada
;	1 		1 		1 		Fuente de Reloj Externo pin T0. Reloj con flanco de subida

; INICILAIZA EL TIMER 0 COMO PWM SALIDA POR PUERTO B4

.equ	AMP_PWM= 0xAC4	; POSICION EN RAM DEL CICLO PWM AMPERIOS REALES
; 0xAC6 
.equ	EXC_SAL= 0xA88	; POSICION TEXTO EXCESO DE SAL
.equ	SHUNT_MOS=0xA9C
;DC_PWM_0:			; INICIALIZA EL RELOJ	TCCR0 VER DC_MOTOR ATMEGA 32 EN CARPETA DATA
	LDI				R16,0B00010111	; PUERTO 4 SALIDA DE SE�AL PWM
	OUT   			DDRB, R16		; 
	LDI				R16,0B10011111	; 
	OUT   			PORTB, R16		; 
 	LDI				R16,(1<<WGM00)|(0<<WGM01)|(1<<COM00)|(1<<COM01)|(0<<CS02)|(1<<CS01)|(1<<CS00)
	OUT				TCCR0,R16
	LDI				R16,100			; VELOCIDAD INICIAL
	OUT				OCR0,R16
	RET

; INICIALIZA EL PUERTO 2 COMO PWM SALIDA POR PUERTO B7
DC_PWM_2:

	LDI				R16,0B10010111	; PUERTO 7 SALIDA DE SE�AL PWM
	OUT   			DDRB, R16		; 
	LDI				R16,0B10011111	; 
	OUT   			PORTB, R16		; 
 	LDI				R16,(1<<WGM20)|(0<<WGM21)|(0<<COM20)|(1<<COM21)|(0<<CS22)|(1<<CS21)|(1<<CS20)
	OUT				TCCR2,R16
	LDI				R16,100			; VELOCIDAD INICIAL
	OUT				OCR2,R16
	RET


DC_PWM_3:							; viene de la linea 348 del programa principal
; INICIALIZA PUERTO 3 COMO SALIDA PWM POR PUERTO E3 OC3A PATA 5 
	LDI				R16,0B11101111	; PUERTO E3 SALIDA DE SE�AL PWM
	OUT   			DDRE, R16		; 
	LDI				R16,0B11111111	; 
	OUT   			PORTE, R16		; 

;	LDI				R16,(1<<COM3A1)|(0<<COM3A0)|(0<<COM3B1)|(0<<COM3B0)|(0<<COM3C1)|(0<<COM3C0)|(1<<WGM31)|(0<<WGM30)
	LDI				R16,(1<<COM3A1)|(1<<COM3A0)|(0<<COM3B1)|(0<<COM3B0)|(0<<COM3C1)|(0<<COM3C0)|(1<<WGM31)|(0<<WGM30)
	STS				TCCR3A,R16
;	LDI				R16,(0<<ICNC3)|(0<<ICES3)|(1<<WGM33)|(1<<WGM32)|(0<<CS32)|(0<<CS31)|(1<<CS30) ; EL REGISTRO 5 NO SE USA
	LDI				R16,(0<<ICNC3)|(0<<ICES3)|(1<<WGM33)|(1<<WGM32)|(0<<CS32)|(1<<CS31)|(0<<CS30) ; EL REGISTRO 5 NO SE USA(010% 60 ciclos 001 500 ciclos)
	STS				TCCR3B,R16

	LDI				R16,0x00
	STS				TCNT3H,R16
	LDI				R16,0x00
	STS				TCNT3L,R16

	LDI				R16,0x40					; CON ICR3H E ICR3L SE CONTROLA LA FECUENCIA
	STS				ICR3H,R16
	LDI				R16,0x00
	STS				ICR3L,R16

	LDI				R16,0x00					; SE CONTROLA LOS AMPERIOS EMPIEZO CON CERO
	STS				OCR3AH,R16
	LDI				R16,0x00
	STS				OCR3AL,R16
	LDI				R16,0x32						; ESTE VALOR CORRESPONDE AL 80% EN TIEMPO DE TRABAJO DEL MOS-FET VALOR DE INICIO

	STS				AMP_PWM,R16					; VALOR INICIAL DE LA INTENSIDAD AL ACTIVAR LA PRODUCCION VALOR NORMAL 50
	ldi				r24,100	; valor inicial para el control por teclado
	STS				AMP_PWM+2,R24

	RET

; RUTINA CONTROL DE LOS AMPERIOS POR LA SE�AL DEL SHUNT PATA 5 DEL MICRO E3 OC3A
DC_PWM_0A:
	CALL			PW_POT_0					; RUTINA CONTROL POR POTENCIOMETRO SELECION PUERTO DE ENTRADA LINEA 203
;	CALL			PW_PUL_0					; RUTINA CONTROL POR PULSADOR
; CONTROL DE AMPERIOS VALOR 50 EL VALOR SE GRABA EN RAM POSICION 0xAC4
;	LSR				R24

	LDS				R26,AMP_PWM
	CPI				R24,40
	BRBS			0,DC_PWM_40					; SI ES MENOR DE 40 VA A SUMARLE 10
	CPI				R24,49	
	BRBC			0,DC_PWM_0A1				; SI ES MAYOR DE 49 O IGUAL VA A DC_PWM_0A1
;INC		R26
	INC				R26							; INCREMENTA UNA UNIDAD
	CPI				R26,64
	BRBS			0,DC_PWM_0A3				; SI R26 ES MENOR DE 64 VA A DC_PWM_0A3
	LDI				R26,64						; SI ES IGUAL O MAYOR PONE 64 MAXIMA PRODUCCION
	RJMP			DC_PWM_0A3
DC_PWM_40:
	ADIW			R26,10						; INCREMENTA EN 10 UNIDADES
	RJMP			DC_PWM_0A3
DC_PWM_0A1:
	CPI				R24,60
	BRBC			0,DC_PWM_60					; SI ES MAYOR DE 60 O IGUAL VA A REDUCIR 10 UNIDADES
	CPI				R24,52
	BRBS			0,DC_PWM_0A3				; SI ES MENOR DE 52 VA A DC_PWM_0A3
	DEC				R26							; DISMINUYE UNA UNIDAD
;DEC		R26
	CPI				R26,2
	BRBC			0,DC_PWM_0A3				; SI ES MAYOR DE 2 O IGUAL NO HACE NADA SI ES MENOR LO PONE A 2
	LDI				R26,2
	RJMP			DC_PWM_0A3
DC_PWM_60:
	SUBI			R26,10						; INCREMENTA 10 UNIDADES

DC_PWM_0A3:


CPI			R26, 64
BRBS		0,DC_PWM_0A3_A		; SI ES MENOR DE 64 VA A
LDI			R26,64

DC_PWM_0A3_A:
	STS		AMP_PWM,R26
; PARA PONER EN LA LINEA 1 AL FINAL EL PORCENTAJE DE PRODUCCION


; O J O SELECIONAR REGISTRO DE CONTROL
;	OUT				OCR0,R24					; SALIDA TIMER 0
;	OUT				OCR2,R24					; SALIDA TIMER 2
;LSR	R24
STS		AMP_PWM+3,R26
	STS				OCR3AH,R26					; SALIDA TIMER 3 LOS DOS REGISTROS SI NO NO FUNCIONA
	STS				OCR3AL,R26
;	STS				OCR3BH,R26					; SALIDA TIMER 3 LOS DOS REGISTROS SI NO NO FUNCIONA
;	STS				OCR3BL,R26
;	STS				OCR3CH,R26					; SALIDA TIMER 3 LOS DOS REGISTROS SI NO NO FUNCIONA
;	STS				OCR3CL,R26

;	COM				R24

;	LDI				R16,128						; ESCRIBIR LINEA 2
;	CALL			ENVINT						; En subrrutina Env_doi Envia instrucion para escribir en linea 1
;	LDI				YH, HIGH(LIN1)				; POSICION BIT ALTO DEL TEXTO A ENVIAR ram en 070
;	LDI				YL, LOW(LIN1)				; POSICION BIT BAJO DEL TEXTO A ENVIAR
;	LDI				R17,20						; NUMERO DE DIGITOS A ENVIAR A PANTALLA
;	CALL			ENVIARTEXTO					; RUTINA EN ESTE FICHERO PRECISA SUBRRUTINA ENV_DOI	
;	RJMP			DC_PWM_0A
; AQUI EL CONTROL DE CORTE POR EXCESO DE PICO DE AMPERIOS
	LDS				R24,AMP_PWM 
	CPI				R24,0x02D
	BRBS			0,DC_PWM_CORTE				; SI EL % ES MENOR DE  VA A OPCION CORTE POR EXCESO DE AMPERIOS
	RET
;       20x4        16x4   tipo de display
; linea 1-128 		128 
; linea 2-192		192
; linea 3-148		144
; linea 4-212		208

DC_PWM_CORTE:								; OPCION CORTE POR EXCESO  DE SAL

	LDI				R16,0x22			; SE PONE UN VALOR FIJO PARA MEDIR LA  SAL 50% DE PRODUCCION 0x020
	STS				OCR3AH,R16
	LDI				R16,0x22
	STS				OCR3AL,R16	
LDI				R25,250
CALL			RETARDO
LDI				R25,250
CALL			RETARDO
LDI				R25,250
CALL			RETARDO
LDI				R25,250
CALL			RETARDO

	LDI				R18,P_SAL			; LINEA DE ENTRADA EN EL CONVERTIDOR PCF8591
	LDI				R26,210; RAMC_SAL		; NUMERO DE MEDICIONES	
	CALL			ADC_P

	CALL			RADC				; PRESENTA EN LINEA 3 LA MEDICION DE SAL REAL
	STS				$A98, R1			; DECENAS
	STS				$A99, R2			; UNIDADES
	STS				$A9B, R3			; DECIMAS	
LDI			R19,46
STS			$A9A,R19
	CALL			APAGAR_FUENTE				; APAGA LOS MOS-FET NO EL OSCILADOR




	CALL			LEDPANT						; ACTUALIZA LOS LED DE LA PANTALLA
;	ESCRIBE  LINEA 2 EXCESO DE SAL
	LDI				R16, 192			; 11000000 escribir en linea 2 linea (192)( linea 4 seria 212)
	CALL			ENVINT				; RUTINA PARA ENVIAR A LA PANTALLA UNA INSTRUCION, " ESCRIBIR LINEA 2"
	LDI				YH, HIGH (EXC_SAL)	; POSICION ALTA DEL TAXTO EN RAM 080
	LDI				YL, LOW  (EXC_SAL)	; direccion BAJA DEL TEXTO EN RAM  "EXCESO DE SAL"    	
  	LDI				R17,20   			; bytes a enviar 
	CALL			ENVIARTEXTO			; RUTINA PARA 
;	ESCRIBE  LINEA 3 EQUIPO DETENIDO
	LDI				R16, 148			; 11000000 escribir en linea 2 linea (192)( linea 4 seria 212)
	CALL			ENVINT				; RUTINA PARA ENVIAR A LA PANTALLA UNA INSTRUCION, " ESCRIBIR LINEA 2"
	LDI				YH, HIGH (LIN_2S)	; POSICION ALTA DEL TAXTO EN RAM 080
	LDI				YL, LOW  (LIN_2S)	; direccion BAJA DEL TEXTO EN RAM  "EQUIPO DETENIDO"    	
  	LDI				R17,20   			; bytes a enviar 
	CALL			ENVIARTEXTO			; RUTINA PARA 
; BORRA LINEA 1
	LDI				R16, 128			; 11000000 escribir en linea 2 linea (192)( linea 4 seria 212)
	CALL			ENVINT				; RUTINA PARA ENVIAR A LA PANTALLA UNA INSTRUCION, " ESCRIBIR LINEA 2"
	LDI				YH, HIGH (BORRAR_LINEA)	; POSICION ALTA DEL TAXTO EN RAM 080
	LDI				YL, LOW  (BORRAR_LINEA)	; direccion BAJA DEL TEXTO EN RAM  "CONSULTAR MANUAL"    	
  	LDI				R17,20   			; bytes a enviar 
	CALL			ENVIARTEXTO			; RUTINA PARA 
; BORRA LINEA 4
	LDI				R16, 212			; 11000000 escribir en linea 2 linea (192)( linea 4 seria 212)
	CALL			ENVINT				; RUTINA PARA ENVIAR A LA PANTALLA UNA INSTRUCION, " ESCRIBIR LINEA 2"
	LDI				YH, HIGH (BORRAR_LINEA)	; POSICION ALTA DEL TAXTO EN RAM 080
	LDI				YL, LOW  (BORRAR_LINEA)	; direccion BAJA DEL TEXTO EN RAM  "CONSULTAR MANUAL"    	
  	LDI				R17,20   			; bytes a enviar 
	CALL			ENVIARTEXTO			; RUTINA PARA 

	LDI				R19,5				; TIEMPO DE ESPERA PARA REARME
DC_PWM_CORTE1:
	NOP
	NOP

	SBRS			CONTROL_1,0			; SALTA LA PROXIMA INSTRUCION SI ES UNO,
	RJMP			DC_PWM_CORTE1		; AJUSTE DE SEGUNDO
	CLT									; PONE A CERO EL BIT T DE SREG
	BLD				CONTROL_1,0			; PASA EL REGISTRO T A CONTROL_1
	DEC				R19
	BRBS			1,DC_PWM_CORTE2		; SI LLEGA A CERO SALTA A RUT_2_B SI NO NO
;	MOV				R24,R19
;	STS				UDR1,R24			; ENVIA POR LA RS EL TIEMPO DE RETARDO
;	CALL CADENA_UART
; PRESENTACION DE TIEMPO QUE FALTA
; ESCRIBE LINEA 1 " EN ESPERA
;	LDI				R16,192			; 11000000 escribir en linea 1 linea (192)
;	CALL			ENVINT
;	LDI				YH,HIGH(EN_ESPERA)	; POSICION ALTA DEL TAXTO EN RAM
;	LDI				YL,LOW (EN_ESPERA)	; direccion BAJA DEL TEXTO EN RAM      	
; 	LDI				R17,20 				; bytes a enviar 
;	CALL			ENVIARTEXTO			; RUTINA PARA ENVIAR TEXTO E PANRALLA

; ESCRIBE LINEA 2
	MOV				R24,R19
	CALL			RADC
	STS				$6A3,R1
	STS				$6A4,R2
	STS				$6A5,R3
;	LDI				R16,148				; 11000000 escribir en linea 2 linea (192)
;	CALL			ENVINT
;	LDI				YH,HIGH (N_SEG)		; POSICION ALTA DEL TAXTO EN RAM 080
;	LDI				YL,LOW  (N_SEG)		; direccion BAJA DEL TEXTO EN RAM      	
 ; 	LDI				R17,20 				; bytes a enviar 
;	CALL			ENVIARTEXTO			; RUTINA PARA ENVIAR TEXTO E PANRALLA
; ENVIA SEGUNDOS DE ESPERA A NEXTION
PUSH	R19							; SALVA EL CONTROL DE SEGUNDOS ENESPERA
		LDI			R19,116			; ENVIA UNA t
		LDI			R27,57			; TEXTO 9
		LDI			R16,3			; NUMERO DE CARACTERES A ESCRIBIR
		LDI			YH,HIGH(N_ESP)	
		LDI			YL,LOW (N_ESP)
		CALL		P_NEXTION_TEXTO	
POP		R19
RJMP  DC_PWM_CORTE1
DC_PWM_CORTE2:
CALL	ENCENDER_FUENTE
LDI R27,0x030
STS	AMP_PWM,R27

RJMP	DC_PWM_0A


PW_POT_0:			; CONTROL DE LA VELOCIDAD POR POTENCIOMETRO RESULTADO EN R24
	CLR				R24
; CONFIGURAR TENSION DE REFERENCIA A VDD, FORMA DE ALMACENAMIENTO CON EL REGISTRO ADLAR A 1 Y CANAL A LEER
;	LD1				R16, (0<<REFS1)|(1<<REFS0)|(0<<ADLAR) LEER LINEA ADC0 ES LA PATA 40
;	LDI				R16,0B11100000				; SE�AL INTERNA DE REFERENCIA A  VDC BIT 7Y6 A 2,5VOLTIOS
												; BIT DE ADLAR A 1 
	LDI				R26,140; RAMC_SAL			; NUMERO DE MEDICIONES
	LDI				R18,6;P_SAL					; LINEA DE ENTRADA EN EL CONVERTIDOR
	CALL			ADC_P
	STS				AMP_PWM+4,R24
;	CALL			RADC
;	STS				$7DE,R1
;	STS				$7DF,R2						; VALOR DE LAS DECENAS LO COLOCA EN LA LINEA 1 DE MODELO
;	STS				$7E0,R3						; VALOR DE LAS UNIDADES
	RET

; CONTROL DE LA POTENCIA POR EL TECLADO TECLAS + Y -	
PW_PUL_0:
	STS				AMP_PWM+2,R24				; LEE DE RAM		
	CLR				R16
	OUT				DDRA, R16					; PUERTO A COMO ENTRADA
	OUT				PORTA, R16					; CON VALOR 1 EN TODAS LAS SALIDAS
	CBI				PORTC, TEC					; pone a 0 el bit de PARA ACTIVAR EL TECLADO
	NOP
	IN				R17, PINA					; lee el valor del puerto a y lo almacena en r17
	SER				R16							; PONE R16 TODO A 1
	SBI				PORTC, TEC					; pone a 1 el bit PARA DESACTIVAR TECLADO
	OUT				DDRA, R16					; PUERTO A COMO SALIDA
	CPI				R17, 0B11101111				; TECLA +	SUBE PRODUCCION
	BREQ			PWM_B
	CPI				R17, 0B11111101				; TECLA -	BAJA PRODUCCION
	BREQ			PWM_A_0
ldi	r24,100	; valor inicial para el control por teclado " CUANDO NO SE PULSA SE PONE A 100 NI SUBE NI BAJA
	STS				AMP_PWM+2,R24
	RET

PWM_A_0:
	INC				R24
	INC				R24
	INC				R24
	INC				R24
	INC				R24
	INC				R24
	CPI				R24,103
	BRBS			0,PWM_AA
	LDI				R24,104
PWM_AA:
	STS				AMP_PWM+2,R24
	RET

PWM_B:
	DEC				R24
	DEC				R24
	DEC				R24
	DEC				R24
	DEC				R24
	DEC				R24
	CPI				R24,96
	BRBC			0,PWM_BB
	LDI				R24,96
PWM_BB:
	STS				AMP_PWM+2,R24	
	RET
; ESTA ES LA OPCION PARA CONTROLAR LOS MOS ANTIGUA
	LDI				R16,0b11100000				; SE�AL DE REFERENCIA A 5 VOLTIOS BIT 7 A CERO PARA SE�AL 2,5 BIT 7 A UNO 0B11100000
	ADD				R16,R18						; EN R18 EL CANAL A LEER Y GANANCIA VER PAG 245
	OUT				ADMUX,R16
	LDI				R16,0B11010111				; PREESCALA A 128 "8.000.000/128=62.500Hz
	OUT				ADCSRA,R16
ADC_P2B_0:
	IN				R16,ADCSRA
	NOP
	BST				R16,6						; CARGA EN EL REGISTRO T DE SREG EL 6 ACSRA
	BRTS			ADC_P2B_0					; SALTA A ADC_P1 SI EL REGISTRO ES UNO SE PONE A CERO AL TERMINAR 
	IN	 			R24,ADCH
	RET
; OPCION PONER EN PANTALLA EL % DE PRODUCCION
PONER_AJUSTE:

	PUSH			R24
	LDS				R24,AMP_PWM+3
	LSL				R24
	LDI				R19,200
	MUL				R24,R19
	MOV				R24,R1

DC_PWM_0A4:
	CALL			RADC
	STS				$AAC,R1						; VALOR DE LAS CENTENAS
	STS				$AAD,R2						; VALOR DE LAS DECENAS LO COLOCA EN LA LINEA 1 DE MODELO
	STS				$AAE,R3						; VALOR DE LAS UNIDADES
	LDI				R24,37						; SIMBOLO ASCI DEL %
	STS				$AAF,R24
	POP				R24

; SE�AL DEL SHUNT AMPERIOS LINEA 1 POSICION 00
	CLR				R24
	LDI				R26,140; RAMC_SAL			; NUMERO DE MEDICIONES
	LDI				R18,6;P_SAL					; LINEA DE ENTRADA EN EL CONVERTIDOR
	CALL			ADC_P
	STS				AMP_PWM+4,R24
	CALL			RADC
	STS				$AA2,R1						; VALOR DE LAS CENTENAS
	STS				$AA3,R2						; VALOR DE LAS DECENAS LO COLOCA EN LA LINEA 1 DE MODELO
	STS				$AA4,R3						; VALOR DE LAS UNIDADES			

	LDI				R16,128				; ESCRIBIR LINEA 1 MODELO DEL EQUIPO
	CALL			ENVINT				; En subrrutina Env_doi Envia instrucion para escribir en linea 1
	LDI				YH,HIGH(SHUNT_MOS)	; POSICION BIT ALTO DEL TEXTO A ENVIAR ram en 070
	LDI				YL,LOW (SHUNT_MOS)	; POSICION BIT BAJO DEL TEXTO A ENVIAR
	LDI				R17,20				; NUMERO DE DIGITOS A ENVIAR A PANTALLA
	CALL			ENVIARTEXTO			; RUTINA EN ESTE FICHERO PRECISA SUBRRUTINA ENV_DOI

	RET
