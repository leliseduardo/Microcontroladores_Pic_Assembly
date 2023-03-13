;
;		Este programa tem a função de contar objetos que acionam um determinado sensor, simulado neste projeto por um
;	botão. Para fazer a leitura do sensor, utiliza-se o módulo CCP1 do Pic, no modo de comparação. No modo de comparação,
;	configura-se o registrador CCP1CON = 08h, para que ele sete o pino RB3 (pino do CCP1) quando o contador do timer1
;	se igualar ao contador do CCP1. Nesta configuração TMR1 não é zerado, e caso necessário, isso deve ser feito via
;	software.	
;
;		Tanto na simulação quanto na prática, o circuito só funcionou quando eu iniciei <TMR1H::TMR1L> em 0.
;
;		Na simulação, o led acende antes pois há bouncing do botão, por erro de proteus. Na prática, o circuito e o 
;	programa funcionaram como esperado. 
;

	list 		p=16f628a					; Informa o microcontrolador utilizado
	
	
; --- Documentação ---

	#include	<p16f628a.inc> 				; Inclui o documento com os registradores do Pic
	

; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura oscilador de 4MHz, Power Up Timer ligado e Master Clear Ligado


; --- Paginação de memória ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar banco 1 de memória
	
; --- Mapeamento de hardware --- 

	#define 	led1	PORTB,0				; Cria mnemônico para led1 em RB0
	#define 	botao1	PORTB,7				; Cria mnemônico para botao1 em RB7
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endereço de inicio de configuração de registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	endc									; Fim da configuração dos registradores de uso geral
	
; --- Vetor de Reset --- 

	org			H'0000'						; Origem do endereço de mémoria do vetor de Reset
	
	goto		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrupção	---

	org 		H'0004'						; Origem do endereço de memória do vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	
	; Desenvolvimento da ISR...
	
	

; -- Recuperação de contexto --

exit_ISR:									; Cria label para sair da interrupção

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Volta para o endereço de memória que estava quando interrompeu
	
; -- Fim da recuperação de contexto --


; --- Programa principal ---

inicio:										; Criação da label do programa principal

	bank1									; Seleciona banco 1 de memória
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada digital
	movlw		H'F7'						; w = F7h
	movwf		TRISB						; Configura apenas RB3 como saída digital, o resto como entrada
	bank0									; Seleciona banco 0 de memória
	movlw		H'F7'						; w = F3h
	movwf		PORTB						; Inicia  RA3 em Low
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'08'						; w = 0Bh
	movwf		CCP1CON						; Configura o módulo CCP1 em modo de comparação, resetando TMR1 no estouro
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

loop:										; Criação da label de loop infinito


	;movlw		H'0A'						
	;xorwf		TMR1L,w		
	;btfss		STATUS,Z
	;goto 		loop
	;bsf			PORTB,2
	;goto		$

	btfss		PORTB,3						; Testa se RB3 setou, se sim, pula uma linha
	goto 		loop						; Se não, desvia para label loop
	bsf			PORTB,3						; RB3 permanece setado
	goto		$							; Prende programa nesta linha
	
	
; --- Fim do programa ---


	end										; Final do programa