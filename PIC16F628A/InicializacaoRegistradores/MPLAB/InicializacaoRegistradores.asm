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
	
;	--- Vetor de reset

	org		H'0000'							; Origem no endere�o 00h de mem�ria
	goto 	inicio							; Desvia para a label inicio
	
;	--- Vetor de interrup��o

	org		H'0004'							; As interrup��es do processador apontar para o endere�o 0004h
	retfie									; Retorna da interrup��o
	
inicio:

	bank0									; Seleciona o banco 0 de mem�ria
	movlw	H'07'							; w= 07h
	movwf	CMCON							; CMCON = 07h
	bank1									; Seleciona o banco 1 de mem�ria
	movlw	H'00'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como sa�da digital
	bank0									; Seleciona o banco 0 de mem�ria
	movlw	H'00'							; w = 00h
	movwf	PORTB							; PORTB = 00h, inicia todos os pinos do portb em Low
	
	
	loop:
	
	goto loop								; Loop infinito
	
	
	
	
	end										; Final do programa 