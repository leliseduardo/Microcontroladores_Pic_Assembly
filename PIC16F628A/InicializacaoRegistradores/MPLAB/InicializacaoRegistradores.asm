;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem o objetivo de criar mnemônicos para os bancos de memória
;
	

	list p=16F628A							; Informa o microcontrolador utilizado
	
; --- Inclusão de arquivos ---

	#include <p16f628a.inc>					; Inclui o arquivo de registradores do mcu
	
; --- Fuse bits ---

;	- Clock externo de 4MHz
;	- Watch Dog Timer desligado
;	- Power Up Time ligado
;	- Master Clear ligado
;	- Brown Out Detect desligado
;	- Programação em baixa tensão desligada
;	- Proteção de código desligada
;	- Proteção da memória EEPROM desligada

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
	
;	---	Paginação de memória ---

	#define	bank0	bcf	STATUS,RP0			; Cria um mnemônico para selecionar o banco 0 de memória	
	#define	bank1	bsf	STATUS,RP0			; Cria um mnemônico para selecionar o banco 1 de memória
	
;	--- Vetor de reset

	org		H'0000'							; Origem no endereço 00h de memória
	goto 	inicio							; Desvia para a label inicio
	
;	--- Vetor de interrupção

	org		H'0004'							; As interrupções do processador apontar para o endereço 0004h
	retfie									; Retorna da interrupção
	
inicio:

	bank0									; Seleciona o banco 0 de memória
	movlw	H'07'							; w= 07h
	movwf	CMCON							; CMCON = 07h
	bank1									; Seleciona o banco 1 de memória
	movlw	H'00'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como saída digital
	bank0									; Seleciona o banco 0 de memória
	movlw	H'00'							; w = 00h
	movwf	PORTB							; PORTB = 00h, inicia todos os pinos do portb em Low
	
	
	loop:
	
	goto loop								; Loop infinito
	
	
	
	
	end										; Final do programa 