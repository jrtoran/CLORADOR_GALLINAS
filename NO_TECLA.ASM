; RUTINA QUE ESPERA A QUE NO ESTEN PULSADAS LAS TECLAS
NO_TECLA:
	WDR
	CALL		LEC_TEC
	CPI			R17, 0B11111111		; IDEM
	BRNE		NO_TECLA			; SI NO COINCIDE  VA A NO_TECLA
	SER			R16					; PONE R16 TODO A 1
	LDI			R22, 00				; PONE EL RETARDO A CERO
	CLR			TEMP_TEC			; PONE A CERO EL RETARDO SALIDA TECLADO QUE ES R7
LDI LEC_REL,3	; PARA ACTUALIZAR LA MEDICION EN EL SEGUNDO 5
	RET

