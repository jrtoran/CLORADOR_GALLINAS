; ********* RUTINA LEER DATOS DE LA EEPROM EL DATO EN R24
; LA DIRECION EN R16 (HIGH) Y R17 (LOW); R16 ES PARA ACADER A LA PARTE ALTA DE DE LA EEPROM
; NO ES NECESARIO PONER EL VALOR SE PONE UN 0 PARA ACEDER A LOS PROMEROS 256 BITS
EEPROM_RW:	
	SBIC				EECR,EEWE	
	RJMP				EEPROM_RW			; VERIFICA QUE NO ESTA OCUPADA LA EEPROM
;2� PASO ESCRIBIR LA DIRECCION DE LA QUE SE QUIERE LEER EL DATO EN EL REGISTRO EEAR
	LDI					R16,00
	OUT					EEARH, R16 	   		; DIRECION $1F
	OUT					EEARL, R17 			; DIRECION $1E
;3� ACTIVAR EL BIT DE LECTURA
	SBI					EECR, EERE			; BIT DE LECTURA
	NOP
;4� EL DATO SE ENCUENTRA EN EL REGISTRO EEDR Y PASA AL REGISTRO R18
	IN					R18, EEDR
	RET
; **** RUTINA ESCRIBIR EN EEPROM EN R16(HIG) Y R17(LOW) DIRECION  EN R18 EL DATO **
;  OJO R16 ES PUESTO A CERO EN LA RUTINA SOLO ACEDE A LOS 256 BIT INICIALES
; PASO 1� ESPERAR A QUE EL REGISTRO EEWE DE EECR SEA CERO CONTROL DE EEPRON ($1C)
EEPROM_ES:	
	SBIC				EECR,EEWE	
	RJMP				EEPROM_ES
; 2 PASO ESCRIBIR LA DIRECCION EN LA QUE ELMACENAR EL DATO 
	LDI					R16,00
	OUT					EEARH, R16 	   	
	OUT					EEARL, R17 		; DIRECION $1E
; 3 PASO ESCRIBIR EL DATO A ELMACENAR EN EL REGISTRO EEDR
	OUT					EEDR, R18 
; 4 PASO Escribir un uno en el bit EEMWE del registro EECR.
	SBI					EECR, EEMWE
; 5 PASO Escribir un uno en el bit EEWE del registro EECR
	SBI					EECR, EEWE
	RET
