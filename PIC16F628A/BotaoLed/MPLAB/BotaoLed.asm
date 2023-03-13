;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem a fun��o de acender o led1 quando o botao1 for pressionado.
;
;		Mesmo configurando TRISA com 13h, ele � configurado pelo compilador com 33h, pois RA5 � o pino master clear, que
;	� sempre configurado como entrada. 
;
;		No debug, na simula��o e na pr�tica o circuito e o programa funcionaram como esperado.
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
	
;	--- Sa�das ---

	#define	led1	PORTA,3					; Cria um mnem�nico para ligar e desligar led1
	#define led2	PORTA,2					; Cria um mnem�nico para ligar e desligar led2
	
;	--- Entradas ---

	#define botao1	PORTB,0					; Cria um mnem�nico para botao1
	
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
	movlw	H'13'							; w = 13h
	movwf	TRISA							; TRISA = w, configura apenas RA2 e RA3 como sa�das digitais
	movlw	H'FF'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como sa�da digital
	bank0									; Seleciona o banco 0 de mem�ria
	
	bcf		led1							; Inicia led1 em Low
	bcf		led2							; Inicia led2 em Low
	
;		Mesmo configurando TRISA com 13h, o compilador o carrega com 33h, pois RA5 refere-se ao master clear, e esse s�
;	pode ser configurado como entrada. 
	
	loop:
	
		btfss	botao1						; Teste se o botao1 foi pressionado, se foi, pula uma linha
		goto	set_led						; Se n�o foi pressionado, desvia para label set_led
		bcf		led1						; apaga led1
		goto 	loop						; Desvia para label loop
		
		set_led:							; Cria label apaga_led
		
			bsf	led1						; acende led1
			goto loop						; Desvia para a label loop
	
	goto loop								; Loop infinito
	
	
	
	
	end										; Final do programa 