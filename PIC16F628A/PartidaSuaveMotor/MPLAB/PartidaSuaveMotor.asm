;
;		Este programa tem como objetivo acionar um motor de maneira suave, para que n�o haja um surto de corrente nos seus
;	terminais. Para isso ser� feito o uso do PWM do m�dulo CCP, que ir� variar o duty de 0 a 100% de maneira suave, para
;	que o motor chegue a sua velocidade total de maneira suave.
;
;	*** Timer 0 ***
;
;	Overflow = (255 - TMR0) * prescaler * Ciclo de m�quina
;	Overflow = 200 * 128 * 1us
;	Oveflow = 25,6ms
;
;	*** PWM ***
;	
;	Per�odo PWM = (PR2 + 1) * Ciclo de m�quina * Prescaler do timer2
;	Per�odo PWM = 50 * 1us * 16
;   Per�odo PWM = 800us
;	Frequ�ncia PWM = 1250Hz
;
;		Quando se utiliza o timer2 para o m�dulo CCP, no modo PWM, o PR2 define o tamanho do per�odo do sinal PWM. Logo,
;	se PR2 = 255, o per�odo tem 255 de tamanho e a frequ�ncia diminui. Neste programa, para o motor fazer uma partida 
;	suave de 0 � 100% de duty, o CCPR1L deve variar de 0 at� PR2.
;		Este m�dulo deve ser mais aprofundado caso se necessite utilizar o PWM do m�dulo CCP, por�m, o conhecimento 
;	b�sico de funcionamento j� torna o uso vi�vel para diversas aplica��es.
;	
;		Na simula��o e na pr�tica o circuito e o programa funcionaram como esperado.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclus�es --- 

	#include	<p16f628a.inc> 				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, Power Up Timer habilitado e Master Clear habilitado


; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnem�nico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnem�nico para led2 em RA2
	#define 	botao1	PORTB,0				; Cria mnem�nico para botao1 em RB0
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o de in�cio para configura��o dos registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	endc									; Fim da configura��o dos registradores de uso geral
	
	
; --- Vetor de Reset ---

	org			H'0000'						; Endere�o de origem do vetor de Reset
	
	goto 		inicio						; Desvia a execu��o para o programa principal
	
; --- Vetor de interrup��o --- 

	org			H'0004'						; Endere�o de origem do vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (con nibbles invertidos)
	bank0									; Seleciona banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	btfss		INTCON,T0IF					; Testa se a flag T0IF foi setada, se foi , pula uma linha
	goto		exit_ISR					; Se n�o, sai da interrup��o
	bcf			INTCON,T0IF					; Limpa flag T0IF
	
	movlw		D'55'						; w = 55d
	movwf		TMR0						; Recarrega TMR0 = 55d, para contagem de 200
	
	movlw		D'255'						; w = 255d
	xorwf		CCPR1L,w					; Faz l�gica XOR com CCPR1L para testar se este j� chegou a 255
	btfsc		STATUS,Z					; Se j�, Z seta e N�O pula uma linha, se n�o, pula uma linha
	goto 		exit_ISR					; Sai da interrup��o
	incf		CCPR1L,F					; Incrementa CCPR1L
	
; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS_TEMP (com nibbles reinvertidos = STATUS original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos = w original)
	
	retfie									; Volta para execu��o principal

; -- Fim da recupera��o de contexto -- 
 
 
; --- Programa principal ---

inicio: 

	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'86'						; w = 86h
	movwf		OPTION_REG					; Desabilita os pull-ups internos e configura prescaler do timer0 em 1:128
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; Configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'F7'						; w = FFh
	movwf		TRISB						; Configura apenas RB3 como sa�da digital
	movlw		D'255'						; w = 49d
	movwf		PR2							; Configura limite de contagem de CCPR1L, para ajustar frequ�ncia do PWM
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'A0'						; w = A0h
	movwf		INTCON						; Habilita a interrup��o global e a interrup��o por overflow do timer0
	movlw		D'55'						; w = 55d
	movwf		TMR0						; Inicia contagem do timer0 em 55d, para contar 200
	movlw		H'F3'						; w = F3h
	movwf		PORTA						; Inicia RA3 e RA2 em Low
	movlw		H'06'						; w = 06h
	movwf		T2CON						; Liga o timer2 e configura o postscaler em 1:1 e o prescaler em 1:16
	movlw		H'0C'						; w = 0Ch
	movwf		CCP1CON						; Configura o m�dulo CCP para o modo PWM
	clrf		CCPR1L						; Limpa o contador do m�dulo CCP
	
	
	goto		$							; Programa fica preso neste endere�o e aguarda interrup��o
	
	
	end										; Fim do programa
		