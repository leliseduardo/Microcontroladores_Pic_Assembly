;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa mostra uma forma de criar um anti-bouncing por software. Isto �, evitar interfer�ncias do clique do
;	bot�o na leitura do mesmo.
;
;		Mesmo configurando TRISA com 13h, ele � configurado pelo compilador com 33h, pois RA5 � o pino master clear, que
;	� sempre configurado como entrada. 
;
;		Na pr�tica e na simula��o este programa n�o � eficiente, pois com um clique os leds trocam de estado v�rias
;	vezes devido ao pequeno delay, da ordem de us. Por�m, a l�gica de delay p�de ser vista e compreendida atrav�s do 
;	debug do programa. Com delays maiores esta l�gica funcionaria perfeitamente, apesar de n�o ser a melhor solu��o para
;	o bouncing de bot�es. 

	

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
	
;	--- Registradores de uso geral ---

	cblock		H'20'						; Inicio da mem�ria de usu�rio
	
	bouncing
	
	endc
	
;	--- Constantes ---

	tempoBouncing	equ	D'250'				; Cria uma constante, que ser� o tempo para evitar o bouncing
	
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
	
	bsf		led1							; Inicia led1 em Low
	bcf		led2							; Inicia led2 em Low
	
;		Mesmo configurando TRISA com 13h, o compilador o carrega com 33h, pois RA5 refere-se ao master clear, e esse s�
;	pode ser configurado como entrada. 
	
	loop:
	
		movlw	tempoBouncing				; w = Tempobouncing
		movwf	bouncing					; bouncing = w
		
		leitura_botao:
		
			btfsc	botao1					; Teste se bot�o foi pressionado
			goto leitura_botao				; desvia para label leitura_botao
			decfsz	bouncing				; Decrementa 1 de bouncing e pula uma linha se chegar a zero
			goto leitura_botao				; Desvia para label leitura_botao
			
			comf	PORTA					; Inverte o estado de cada bit do PORTA
	
	goto loop								; Loop infinito
	
	
	
	
	end										; Final do programa 