;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem o objetivo de criar mnem�nicos para os bancos de mem�ria
;
	

	list p=16F628A							; Informa o microcontrolador utilizado
	
; --- Inclus�o de arquivos ---

	#include <p16f628a.inc>					; Inclui o arquivo de registradores do mcu
	
; --- Fuse bits ---

;	- Clock externo de 4MHz
;	- Watch Dog Timer desligado
;	- Power Up Time ligado
;	- Master Clear ligado
;	- Brown Out Detect desligado
;	- Programa��o em baixa tens�o desligada
;	- Prote��o de c�digo desligada
;	- Prote��o da mem�ria EEPROM desligada

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
	
;	---	Pagina��o de mem�ria ---

	#define	bank0	bcf	STATUS,RP0			; Cria um mnem�nico para selecionar o banco 0 de mem�ria	
	#define	bank1	bsf	STATUS,RP0			; Cria um mnem�nico para selecionar o banco 1 de mem�ria
	
	
	
	end										; Final do programa 