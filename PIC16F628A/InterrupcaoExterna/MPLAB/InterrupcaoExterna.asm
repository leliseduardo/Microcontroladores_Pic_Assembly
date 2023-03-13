;
;		PIC16F628A		Clock = 4MHz		Ciclo de m�quina = 1us		
;
;		O objetivo deste programa � demonstrar como funciona e como se configura uma interrup��o externa.
;		
;		Na simula��o o circuito funcionou como esperado, gerando a interrup��o externa e complementando o portb.
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
	
	btfss		INTCON,INTF					; Testa se a flag INTF setou, se sim, pula uma linha
	goto 		exit_ISR					; Se n�o, sai da interrup��o
	bcf			INTCON,INTF					; Limpa INTF
	
	comf		PORTB						; Complementa portb
	
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
	bsf			OPTION_REG,6				; Configura interrup��o externa por borda de subida
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'FD'						; w = FDh
	movwf		TRISB						; TRISB = FDh, configura apenas RB1 como sa�da digital
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'90'						; w = 90h
	movwf		INTCON						; INTCON = 90h, habilita a interrup��o global e a interrup��o externa em RB0
	bcf			PORTB,1						; Inicia RB1 em Low
	

loop:										; Inicia loop infinito



	goto loop								; Desvia para loop infinito
	
	
	
end 
