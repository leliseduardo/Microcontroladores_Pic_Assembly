;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem a função de acender o led1 quando o botao1 for pressionado.
;
;		Mesmo configurando TRISA com 13h, ele é configurado pelo compilador com 33h, pois RA5 é o pino master clear, que
;	é sempre configurado como entrada. 
;
;		No debug, na simulação e na prática o circuito e o programa funcionaram como esperado.
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
	
;	--- Saídas ---

	#define	led1	PORTA,3					; Cria um mnemônico para ligar e desligar led1
	#define led2	PORTA,2					; Cria um mnemônico para ligar e desligar led2
	
;	--- Entradas ---

	#define botao1	PORTB,0					; Cria um mnemônico para botao1
	
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
	movlw	H'13'							; w = 13h
	movwf	TRISA							; TRISA = w, configura apenas RA2 e RA3 como saídas digitais
	movlw	H'FF'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como saída digital
	bank0									; Seleciona o banco 0 de memória
	
	bcf		led1							; Inicia led1 em Low
	bcf		led2							; Inicia led2 em Low
	
;		Mesmo configurando TRISA com 13h, o compilador o carrega com 33h, pois RA5 refere-se ao master clear, e esse só
;	pode ser configurado como entrada. 
	
	loop:
	
		btfss	botao1						; Teste se o botao1 foi pressionado, se foi, pula uma linha
		goto	set_led						; Se não foi pressionado, desvia para label set_led
		bcf		led1						; apaga led1
		goto 	loop						; Desvia para label loop
		
		set_led:							; Cria label apaga_led
		
			bsf	led1						; acende led1
			goto loop						; Desvia para a label loop
	
	goto loop								; Loop infinito
	
	
	
	
	end										; Final do programa 