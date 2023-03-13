;
;		Este programa tem a fun��o de demonstrar como criar uma base de tempo a partir do timer1. A base de tempo tem
;	a fun��o de, a partir de um tempo m�nimo de overflow, criar outras bases de tempo com o aux�lio de um registrador
;	de uso geral (vari�vel). Neste exemplo, ser� criada uma base de tempo de 1s.
;
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
;							   200ms
;	<TMR1H::TMR1L> = 65536 - --------- = 15536
;							  4 * 1us
;
;	<TMR1H::TMR1L> = 15536d = 3CB0h
;
;	TMR1H = 3Ch
;	TMR1L = B0h
;
;		Na simula��o e na pr�tica o programa funcionou como esperado.
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
	cont									; Contador para base de tempo de 1s
	
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
	
	btfss		PIR1,TMR1IF					; Testa se a flag TMR1IF setou, se sim, pula uma linha
	goto 		exit_ISR					; Se n�o, sai da interrup��o
	bcf			PIR1,TMR1IF					; Limpa a flag TMR1IF
	movlw		H'3C'						; w = 3Ch
	movwf		TMR1H						; reinicia TMR1H = 3Ch
	movlw		H'B0'						; w = B0h
	movwf		TMR1L						; reinicia TMR1L = B0h
	
	incf		cont,F						; Incrementa cont
	movlw		H'05'						; w = 05h
	xorwf		cont,w						; Faz l�gica XOR de w com cont
	btfss		STATUS,Z					; Se a l�gica XOR resultou em zero, Z = 1 e pula uma linha
	goto		exit_ISR					; Se n�o, sai da interrup��o
	
	clrf		cont						; Limpa cont
	movlw		H'80'						; w = 80h
	xorwf		PORTB						; Alterna RB7 com l�gica XOR
	
; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS_TEMP (com nibbles reinvertidos = STATUS original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos = w original)
	
	retfie									; Volta para execu��o principal

; -- Fim da recupera��o de contexto --

inicio:

	bank1									; Seleciona banco 1 de mem�ria 
	bcf			TRISB,7						; Configura RB7 como sa�da digital
	bsf			PIE1,TMR1IE					; Habilita a interrup��o por overflow do timer1
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	bcf			PORTB,7						; Inicia RB7 em Low
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Habilita a interrup��o global e por perif�ricos
	movlw		H'21'						; w = 01h
	movwf		T1CON						; Prescaler em 1:4, incrementa pelo ciclo de m�quina e habilita o timer1
	movlw		H'3C'						; w = 3Ch
	movwf		TMR1H						; Inicia TMR1H = 3Ch
	movlw		H'B0'						; w = B0h
	movwf		TMR1L						; Inicia TMR1L = B0h
	clrf		cont						; Limpa registrador de uso geral cont
	

goto			$							; Programa fica preso neste endere�o e aguarda interrup��o


end											; Fim do programa 
