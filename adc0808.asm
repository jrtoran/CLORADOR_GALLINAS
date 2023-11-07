; LEER DEL CONVERTIDOR ANALOGICO DIGITAL 0808

ADC0808:
; RUTINA PARA EL CONTROL DE ADC0808
; ENTRADAS A=ADCA (LINEA B-3) B=ADCB (LINEA B-4) C=ADCC (LINEA B-5)
; LINEA ALE Y START START ( PUERTO B-6) 
; LINEA EOC EOC (PUERTO B LINEA 7)
; LINEA OE OE (PUERTO C LINEA 1)
; PASOS   	1� SELECIONAR LINEA A LEER
;			2� ACTIVAR START
;			3� PONER START A CERO
;			4� ESPERAR A QUE LA LINEA EOC SE PONGA A 1 FIN CONVERSION
;			5� PONER A 1 LA LINEA OE PARA LEER EL RESULTADO
;			6� PONER EL PUERTO A EN ENTRADA Y ALMACENAR EL VALOR
;			7� PONER LA LINEA OE A CERO PARA QUE EL CONVERTIDOR PONGA LA SALIDA
;			EN ALTA IMPEDANCIA 
; RESULTADO EN R24

	CBI   PORTD, OE			; Y LINEA OE CONTROL DE LINEA SALIDA A CERO ALTA 
							; IMPEDANCIA
	SBI   PORTB, START		; ACTIVAR LA CONVERSION
	LDI   R25, 4			; PEQUE�O RETARDO
	RCALL RETARDO			; RUTINA RETARDO
	CBI   PORTB, START		; BAJAMOS LINEA START

FCONV:
	CBI   PORTD,clk
	NOP
	SBI   PORTD,clk
	SBIS  PINB, EOC			; SI LA LINEA ESTA A UNO SALTA LA PROXIMA INSTRUCION
	RJMP  FCONV				; ESPERA EL FINAL DE LA CONVERSION
	CLR   R16				; r16 a cero para
	OUT   DDRA, R16			; pora poner el puerto como entrada..
	SBI	  PORTD, OE			; ACTIVA LA LECTURA
	NOP
	IN    R24,PINA			; LEE EL VALOR DEL PUERTO Y LO ALMACENA EN R24
;	STS   $024E, R24		; LO GRABA EL RAM POSICION $024E
	CBI	  PORTD, OE			; DESACTIVA LA LECTURA SALIDA EN ALTA IMPEDANCIA
	SER   R16 				; PONE R16 A FF....
    OUT   DDRA,R16   		; PARA DEJAR EL PUERTO A COMO SALIDA DATOS
	RET

