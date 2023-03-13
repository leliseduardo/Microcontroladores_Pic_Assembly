;
;		PIC16F628A		Clock = 4MHz		Ciclo de m�quina = 1us		
;
;		O objetivo deste programa � demonstrar e configurar a interrup��o do timer2. 
;
;		Timer 2
;
;		Overflow = PR2 * Prescaler * Postscaler * ciclo de m�quina
;		Overflow = 101 * 4 * 5 * 1us
;		Overflow = 2,02ms
;
;		Na simula��o o programa funcionou como esperado, com o tempo de overflow correto, como configurado.
;


	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclus�o de arquivos ---

	#include 	<p16f628a.inc>				; Inclui o arquivo que cont�m os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Clock em 4MHz, Power Up Timer habilitado e Master Clear Habilitado

; --- Pagina��o de mem�ria ---

	#define 	bank0		bcf	STATUS,RP0	; Cria um mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1		bsf	STATUS,RP0	; Cria um mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnem�nico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnem�nico para led2 em RA2
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Cria registradores de uso geral a partir do endere�o 20h de mem�ria
	
	W_TEMP									; Armazena o conte�do de W temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	
	endc
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o para o vetor de Reset
	
	goto 		inicio						; Desvia programa para label inicio
	
	
; --- Vetor de Interrup��o

	org 		H'0004'						; Origem do endere�o para o vetor de Interrup��o
	
; --- Salvamento de contexto ---

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; --- Fim do salvamento de contexto ---

	; Desenvolvimento da ISR
	
	btfss		PIR1,TMR2IF					; Testa se flag TMR2IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o, sai da interrup��o
	bcf			PIR1,TMR2IF					; Limpa flag TMR2IF
	
	comf		PORTB						; Complementa portb, somente as sa�das
	
; --- Recupera��o de contexto ---

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (status original)
	movwf		STATUS						; STATUS = w (status original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (w original)	

	retfie
	
; --- Fim da recupera��o de contexto ---


; --- Programa principal ---

inicio:										; Inicia label programa principal


	bank1									; Seleciona o banco 1 de mem�ria
	bsf			PIE1,TMR2IE					; Habilita a interrup��o por oveflow do timer2
	movlw		H'65'						; w = 101d
	movwf		PR2							; Inicia o PR2 = 101d, isto �, TMR2 conta ate 101d e zera quando estoura
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'FD'						; w = FDh
	movwf		TRISB						; TRISB = FDh, configura apenas RB1 como sa�da digital
	bank0									; Seleciona o banco 0 de mem�ria
	bsf			INTCON,GIE					; Habilita a interrup��o global
	bsf			INTCON,PEIE					; Habilita a interrup��o por perif�ricos
	movlw		B'00100101'					; w = B'00100101'
	movwf		T2CON						; Postscaler = 1:5, prescaler = 1:4 e timer2 habilitado
	

loop:										; Inicia loop infinito


	goto loop								; Desvia para loop infinito
	
	
	
end 