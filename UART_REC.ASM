; RUTINA PARA LA TRANSMISION DE DATOS A TRAVES DE LA UART
; CONFIGURAR A 9600 EN UBRRH Y UBRRL VALORES 00 Y 33

;		fOSC
;UBRR= _________ - 1  EJEMPLO UBRR =(8.000.000 /16X 1.200) -1  ESTO DA 416,66 OSEA 1A0 0CF PARA 2400
;		16BAUD
; TABLA DE VALORES Y ERRORES PAG 168 Y SIGUIENTES
UART_INI_REC:  			;BAUDIOS A 2.400
		LDI			R25, 00
		OUT			UBRRH, R25		; REGISTRO ALTO
		LDI			R25, 0xCF
		OUT			UBRRL, R25		; REGISTRO BAJO
;						UCSRA
;		Bit 7 	6 	5 		4 	3 	2 	1 	0
;			RXC	RXC	UDRE	FE	DOR PE 	U2X MPCM

; CONFIGURAR 8 BIT 1 STOP NO PARIDAD Y ASINCRONO EN UCSRB
;BIT 7 RXC: Recepci�n completa del USART.
;BIT 6 RXC: Transmisi�n completa del USART.
;BIT 5 UDRE: Registro de datos vac�o del USART.
;BIT 4 FE: Error de frame.
;BIT 3 DOR: Datos sobre-escritos.
;BIT 2 PE: Error de paridad.
;BIT 1 U2X: Velocidad de transmisi�n doble.
;BIT 0 MPCM: Modo de comunicaci�n multiprocesador.

		LDI			R25, 00
		OUT			UCSRA, R25
;							UCSRB:
;		Bit 	7 		6 		5 		4 		3 		2 		1 		0
;				RXCIE 	RXCIE 	UDRIE 	RXEN 	TXEN 	UCSZ2 	RXB8 	TXB8
;RXCIE: Habilitaci�n de interrupci�n de RX Completa.
;RXCIE: Habilitaci�n de interrupci�n de TX Completa.
;UDRIE: Habilitaci�n de interrupci�n de Registro de Datos Vac�o del USART.
;RXEN: Habilitaci�n de Receptor.
;TXEN: Habilitaci�n de Transmisor.
;UCSZ2: Tama�o del car�cter. JUNTO CON UCSZ1 Y UCSZ0 DEL REGISTRO UCSRC
;RXB8: Bit 8 de datos de Recepci�n (En el caso que haya sido configurado a 9 bits).
;TXB8: Bit 8 de datos de Transmisi�n (En el caso que haya sido configurado a 9 bits).
		LDI			R25, 0B10010000 ; ACTIVAR RECEPCION solo
		OUT			UCSRB, R25

;UCSRC:
;		Bit 	7 		6 		5 		4 		3 		2 		1 		0
;				URSEL 	UMSEL 	UPM1 	UPM0 	USBS 	UCSZ1 	UCSZ0 	UCPOL

;URSEL: Registro de Selecci�n. Con 1 se escribe en UCSRC y con 0 en UBRRH (UCSRC y UBRRH tienen la misma direcci�n).
;UMSEL: Selecci�n del moodo USART, 1 s�ncrona y 0 as�ncrona.
;UPM1:0. Modo de paridad.
;USBS: Selecci�n del bit de Stop, 1 dos bits y 0 un bit.
;Seleccionando tama�o del car�cter:
;UCPOL: Polaridad del reloj (Obviamente solo en modo s�ncrono), 1 flanco ascendente y 0 flanco descendente.

		LDI			R25, 0x86
		OUT			UCSRC, R25
		RET
UART_INI_REC_A:	; EJECUTAR LA RUTINA SIN INICIALIZAR
		LDI   		YH, (LIN1)     	; direcion alta donde se pone el texto en RAM
		LDI   		YL, (LIN1)     	; direccion baja donde se pone el texto en RAM 
		LDI			R16, 16			; NUMERO DE DATOS A RECIBIR
; RECIBIR TEXTO Y GRABAR EN RAM

UART_RXC:
		RCALL		UART_RXC1		; VERIFICAR LA RECEPCION COMPLETA DEL BIT
		IN			R0, UDR
		ST    		Y, R0			; guardamos en RAM POSICION EL CONTENIDO DE R0
		ADIW  		YL,1			; INCREMENTAMOS LA POSICION EN RAM PARA GUARDAR EL SIGUIENTE DATO      		
		DEC			R16      		; Hemos terminado..?? 
		BRNE		UART_RXC	  	; NO...seguimos cargando 
		RCALL		LINEA1_A		; ESCRIBIMOS EN PANTALLA LA LINEA RECIBIDA
		LDI   		YH, (LIN2)     	; direcion alta donde se pone el texto en RAM
		LDI   		YL, (LIN2)     	; direccion baja donde se pone el texto en RAM 
		LDI			R16, 16			; NUMERO DE DATOS A RECIBIR
UART_RXC_1:
		RCALL		UART_RXC1		; VERIFICAR LA RECEPCION COMPLETA DEL BIT
		IN			R0, UDR
		ST    		Y, R0			; guardamos en RAM POSICION EL CONTENIDO DE R0
		ADIW  		YL,1			; INCREMENTAMOS LA POSICION EN RAM PARA GUARDAR EL SIGUIENTE DATO      		
		DEC			R16      		; Hemos terminado..?? 
		BRNE		UART_RXC_1	  	; NO...seguimos cargando 
		RCALL		LINEA2B			; ESCRIBIMOS EN PANTALLA LA LINEA RECIBIDA

		RET
        
UART_RXC1:  ; Rutina verificacion del termino DE LA RECEPCION
		SBIS		UCSRA, RXC		; VERIFICA EL TERMINO DE LA RECEPCION
		RJMP		UART_RXC1		; EN CUYO CASO SALTA ESTA INSTRUCION
		RET


