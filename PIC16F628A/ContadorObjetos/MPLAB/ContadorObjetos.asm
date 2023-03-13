;
;		Este programa tem a fun��o de contar objetos que acionam um determinado sensor, simulado neste projeto por um
;	bot�o. Para fazer a leitura do sensor, utiliza-se o m�dulo CCP1 do Pic, no modo de compara��o. No modo de compara��o,
;	configura-se o registrador CCP1CON = 08h, para que ele sete o pino RB3 (pino do CCP1) quando o contador do timer1
;	se igualar ao contador do CCP1. Nesta configura��o TMR1 n�o � zerado, e caso necess�rio, isso deve ser feito via
;	software.	
;
;		Tanto na simula��o quanto na pr�tica, o circuito s� funcionou quando eu iniciei <TMR1H::TMR1L> em 0.
;
;		Na simula��o, o led acende antes pois h� bouncing do bot�o, por erro de proteus. Na pr�tica, o circuito e o 
;	programa funcionaram como esperado. 
;

	list 		p=16f628a					; Informa o microcontrolador utilizado
	
	
; --- Documenta��o ---

	#include	<p16f628a.inc> 				; Inclui o documento com os registradores do Pic
	

; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura oscilador de 4MHz, Power Up Timer ligado e Master Clear Ligado


; --- Pagina��o de mem�ria ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar banco 1 de mem�ria
	
; --- Mapeamento de hardware --- 

	#define 	led1	PORTB,0				; Cria mnem�nico para led1 em RB0
	#define 	botao1	PORTB,7				; Cria mnem�nico para botao1 em RB7
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o de inicio de configura��o de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	endc									; Fim da configura��o dos registradores de uso geral
	
; --- Vetor de Reset --- 

	org			H'0000'						; Origem do endere�o de m�moria do vetor de Reset
	
	goto		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrup��o	---

	org 		H'0004'						; Origem do endere�o de mem�ria do vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	
	; Desenvolvimento da ISR...
	
	

; -- Recupera��o de contexto --

exit_ISR:									; Cria label para sair da interrup��o

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Volta para o endere�o de mem�ria que estava quando interrompeu
	
; -- Fim da recupera��o de contexto --


; --- Programa principal ---

inicio:										; Cria��o da label do programa principal

	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada digital
	movlw		H'F7'						; w = F7h
	movwf		TRISB						; Configura apenas RB3 como sa�da digital, o resto como entrada
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'F7'						; w = F3h
	movwf		PORTB						; Inicia  RA3 em Low
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'08'						; w = 0Bh
	movwf		CCP1CON						; Configura o m�dulo CCP1 em modo de compara��o, resetando TMR1 no estouro
	movlw		H'03'						; w = 03h
	movwf		T1CON						; Prescaler em 1:1, configura incremento por pulso externo, liga o timer1
	movlw		H'00'						; w = 04h
	movwf		CCPR1H						; CCPR1H = 00h
	movlw		H'0F'						; w = 0Fh
	movwf		CCPR1L						; CCPR1L = 0Fh
	movlw		H'00'						; w = 00h
	movwf		TMR1H						; TMR1H = 00h
	movlw		H'00'						; w = 00h
	movwf		TMR1L						; TMR1L = 0Fh

loop:										; Cria��o da label de loop infinito


	;movlw		H'0A'						
	;xorwf		TMR1L,w		
	;btfss		STATUS,Z
	;goto 		loop
	;bsf			PORTB,2
	;goto		$

	btfss		PORTB,3						; Testa se RB3 setou, se sim, pula uma linha
	goto 		loop						; Se n�o, desvia para label loop
	bsf			PORTB,3						; RB3 permanece setado
	goto		$							; Prende programa nesta linha
	
	
; --- Fim do programa ---


	end										; Final do programa