;
;			PIC16F628A			Clock = 4MHz		Ciclo de m�quina = 1us
;		
;		Este programa tem a fun��o de introduzir o uso da interrup��o, utilizando o estouro do timer0.
;
;		Overflow = Contagem * prescaler * ciclo de m�quina
;		Overflow = (256 - TMR0) * 1:2 * 1/(4MHz/4)
;		Overflow = 256 * 2 * 1us
;		Overflow = 512us
;
;		Tempo medido pelo debug = 528us
;
;		O tempo medido � maior do que o calculado pois existe o tempo de lat�ncia, que � o tempo que o processador leva
;	para entrar realmente na execu��o da rotina de interrup��o. Esse tempo leva em conta o salvamento de contexto, os 
;	teste de overflow, a recupera��o de contexto e a recarga do timer0, entre outros, dependendo da aplica��o.
;

	list p=16f628a							; Informa o microcontrolador utilizado
	
; --- Inclus�o de arquivos ---

	#include <p16f628a.inc>
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDTE_OFF & _PWRTE_ON	& _MCLRE_ON	& _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_ON
	
	; Clock de 4MHz e apenas Master Clear e Power Up Timer habilitados
	
; --- Pagina��o de mem�ria ---

	#define 	bank0 	bcf	STATUS,RP0		; Cria um mnem�nico para o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria um mnem�nico para o banco 1 de mem�ria
	
; --- Sa�das ---

	#define 	led1	PORTA,3				; Cria um mnem�nico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria um mnem�nico para led2 em RA2
	
; --- Entradas ---

	#define 	botao1	PORTB,0				; Cria um mnem�nico para botao1 em RB0
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Cria resgistadores de uso geral a partir do endere�o 20h 
	
	W_TEMP									; Armazena conte�do de W temporariamente
	STATUS_TEMP								; Armazena conte�do de STATUS temporariamente
	
	endc
	
; --- Vetor de Reset ---

	org 		H'0000'						; Origem do endere�o do vetor de Reset
	goto inicio								; Desvia para a label inicio
	
	
; --- Vetor de Interrup��o ---

	org 		H'0004'						; Origem do endere�o do vetor de Interrup��o
	
; --- Salva contexto ---

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; Grava status em w com os nibbles invertidos
	bank0									; Seleciona o banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = w, isto �, STATUS_TEMP � igual ao STATUS com os nibbles invertidos

; --- Final do salvamento de contexto ---

	
	btfss		INTCON,T0IF					; Testa se T0IF setou, se sim, houve estouro do timer0
	goto 		exit_ISR					; Se n�o T0IF n�o setou, sai da interrup��o
	bcf			INTCON,T0IF					; Se T0IF setou, houve a interrup��o e deve-se limpar T0IF
	comf		PORTA						; Complementa PORTA, isto �, inverte todos os seus bits 
	
	
; --- Recupera contexto ---

exit_ISR:									; Cria label para auxiliar a sa�da da ISR e recuperar contexto

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP, logo, w � igual ao STATUS com os nibbles reinvertidos
	movwf		STATUS						; STATUS = w, logo, recupera o conte�do original de STATUS
	swapf		W_TEMP,F					; Inverte os nibbles do registrador W_TEMP
	swapf		W_TEMP,w					; w = W_TEMP, ou seja, reinverte os nibbles de W_TEMP e w recupera o conte�do
											; original
	retfie									; Retorna na interrup��o
	
;		No salvamento e recupera��o de contexto, se usa a instru��o SWAPF, que inverte os nibbles de um registrador e a
;	salvam em algum outro (ou o mesmo) registrador. Se usa este comando pois o comando MOVF altera a flag Z do registrador
;	STATUS, logo, altera seu cont�do original. O comando SWAPF n�o altera nenhuma flag do STATUS.

inicio:

	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; CMCON = w = 07h
	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'80'						; w = 80h
	movwf		OPTION_REG					; OPTION_REG = w = FFh, desabilita os pull-ups internos
	movlw		H'F3'						; w = F3h = 11110011b
	movwf		TRISA						; TRISA	= w = F3h
	movlw		H'FF'						; w = FFh
	movwf		TRISB						; TRISB = w = FFh
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'A0'						; w = 00h
	movwf		INTCON						; INTCON = 00h, Habilita a interrup global e a interrup por overflow do timer0

	
loop:										; Cria label do loop infinito


	goto loop								; Desvia para label loop
	
	


	end										; Final do programa
	
	