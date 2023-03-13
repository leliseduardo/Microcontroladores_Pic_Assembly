;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa mostra uma forma de criar um anti-bouncing por software. Isto é, evitar interferências do clique do
;	botão na leitura do mesmo.
;
;		Mesmo configurando TRISA com 13h, ele é configurado pelo compilador com 33h, pois RA5 é o pino master clear, que
;	é sempre configurado como entrada. 
;
;		Na prática e na simulação este programa não é eficiente, pois com um clique os leds trocam de estado várias
;	vezes devido ao pequeno delay, da ordem de us. Porém, a lógica de delay pôde ser vista e compreendida através do 
;	debug do programa. Com delays maiores esta lógica funcionaria perfeitamente, apesar de não ser a melhor solução para
;	o bouncing de botões. 

	

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
	
;	--- Registradores de uso geral ---

	cblock		H'20'						; Inicio da memória de usuário
	
	bouncing
	
	endc
	
;	--- Constantes ---

	tempoBouncing	equ	D'250'				; Cria uma constante, que será o tempo para evitar o bouncing
	
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
	
	bsf		led1							; Inicia led1 em Low
	bcf		led2							; Inicia led2 em Low
	
;		Mesmo configurando TRISA com 13h, o compilador o carrega com 33h, pois RA5 refere-se ao master clear, e esse só
;	pode ser configurado como entrada. 
	
	loop:
	
		movlw	tempoBouncing				; w = Tempobouncing
		movwf	bouncing					; bouncing = w
		
		leitura_botao:
		
			btfsc	botao1					; Teste se botão foi pressionado
			goto leitura_botao				; desvia para label leitura_botao
			decfsz	bouncing				; Decrementa 1 de bouncing e pula uma linha se chegar a zero
			goto leitura_botao				; Desvia para label leitura_botao
			
			comf	PORTA					; Inverte o estado de cada bit do PORTA
	
	goto loop								; Loop infinito
	
	
	
	
	end										; Final do programa 