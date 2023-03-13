;
;		O objetivo deste programa � gerar um sinal do tipo escada no pino RA2, a partir da tens�o de refer�ncia de sa�da
;	neste pino. Para isso ser� implementado uma interrup��o do timer1 a cada 500ms, que ter� como fun��o diminuir o valor
;	das flags VR, de forma que na sa�da RA2 ser� gerado um sinal do tipo escada.
;
;	*** Timer 1 ***
;	
;	Overflow = (65536 - <TMR1H::TMR1L>) * prescaler * ciclo de m�quina
;		
;											Overflow
;	(65536 - <TMR1H::TMR1L>) = 	---------------------------------
;								   prescaler * ciclo de m�quina	
;
;										Overflow
;	<TMR1H::TMR1L> = 65536 - ---------------------------------
;								prescaler * ciclo de m�quina
;
;							   500ms
;	<TMR1H::TMR1L> = 65536 - --------- = 3036
;							  8 * 1us
;
;	<TMR1H::TMR1L> = 3036d = 0BDCh
;
;	TMR1H = 0Bh
;	TMR1L = DCh	
;
;		Na simula��o o programa funcionou como esperado
;



	list		p=16f628a					; Informa o microcontrolador utilizado
	

; --- Documenta��o ---

	#include	<p16f628a.inc>				; Inclui o documento que cont�m os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura clock em 4MHz, ativa o Power Up Timer e ativa o Master Clear

; --- Pagina��o de mem�ria ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar banco 1 de mem�ria 
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTB,0				; Cria mnem�nico para led1 em RA3
	#define 	led2 	PORTB,1				; Cria mnem�nico para led2 em RA2
	#define		botao1	PORTB,7				; Cria mnem�nico para botao1 em RB0
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o de in�cio para configura��o de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	endc									; Fim da configura��o dos registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o de mem�ria para o vetor de Reset
	
	goto 		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrup��o ---

	org			H'0004'						; Origem do endere�o de mem�ria para o vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	btfss		PIR1,TMR1IF					; Testa se flag TMR1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o setou, sai da interrup��o
	bcf			PIR1,TMR1IF					; Limpa flag TMR1IF
	movlw		H'0B'						; w = 0Bh
	movwf		TMR1H						; Inicia TMR1H = 0Bh
	movlw		H'DC'						; w = DCh
	movwf		TMR1L						; Inicia TMR1L = DCh 
	
	bank1									; Seleciona banco 1 de mem�ria
	decf		VRCON,F						; Decrementa registrador VRCON
	movlw		H'E0'						; w = CFh
	xorwf		VRCON,w						; Faz XOR entre w e VRCON para testar se VRCON chegou a CFh
	btfss		STATUS,Z					; Se chegou, seta a flag Z e pula uma linha
	goto		exit_ISR					; Se n�o chegou, sai da interrup��o
	movlw		H'EF'						; w = EFh
	movwf		VRCON						; Reinicia VRCON = EFh
	bank0

; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Retorna para endere�o que estava quando ocorreu a interrup��o
	
; -- Fim da recupera��o de contexto --


; --- Programa principal --- 

inicio:										; Cria label para programa principal

	bank1									; Seleciona o banco 1 de mem�ria
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada, inclusive RA2, necess�rio para que a
											; a tens�o de refer�ncia funcione neste pino
	movlw		H'FE'						; w = FEh 
	movwf		TRISB						; Configura apenas RB0 como sa�da digital, o resto como entrada
	movlw		H'EF'						; w = ACh
	movwf		VRCON						; Habilita a tens�o de refer�ncia, conectada em RA2, Low Range, tens�o m�xima
	bsf			PIE1,TMR1IE					; Habilita a interrup��o do timer1
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07F
	movwf		CMCON						; Desliga os comparadores internos
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Habilita a interrup��o global e por perif�ricos
	movlw		H'31'						; w = 21h
	movwf		T1CON						; Habilita o timer1, prescale em 1:4, incrementa com o ciclo de m�quina
	movlw		H'0B'						; w = 0Bh
	movwf		TMR1H						; Inicia TMR1H = 0Bh
	movlw		H'DC'						; w = DCh
	movwf		TMR1L						; Inicia TMR1L = DCh 
	
	bcf			led1						; Inicia led1 em Low



; --- Loop infinito ---

loop:										; Cria label para loop infinito



	goto		loop						; Loop infinito
	

; --- Sub Rotinas --- 

	
	
	
; --- Fim do programa ---

	end										; Final do programa