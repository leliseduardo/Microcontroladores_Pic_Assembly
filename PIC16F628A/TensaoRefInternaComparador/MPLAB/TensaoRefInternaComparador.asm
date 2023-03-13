;
;		Este programa tem a fun��o de configurar uma tens�o de refer�ncia interna para o comparador do Pic, a partir do
;	registrador VRCON. Essa refer�ncia interna funcionar� semelhante a refer�ncia feita nas �ltimas aulas sobre o com-
;	parador interno, com a diferen�a que a refer�ncia interna � conectada nas entradas n�o-inversoras do comparador. 
;	Assim, caso a tens�o do potenci�metro que ser� conectado na porta inversora seja maior que a refer�ncia, a sa�da do
;	comparador ter� n�vel baixo. Por software, no registrador CMCON, pode-se inverter essa l�gica de compara��o, fazendo
;	com que, quando a tens�o na porta inversora for maior, a sa�da apresente n�vel l�gico alto. Seria uma l�gica inversa
;	se compara��o.
;		Como tens�o de refer�ncia, ser� configurada uma tens�o de 2,5V. No registrador VRCON, caso configure-se o range de
;	refer�ncia em "Low Range", fazendo a flag VRR = 0 configura-se a tens�o de refer�ncia de acordo com a equa��o abaixo:
;	
;				VR<3:0>					|->			Sendo VR<3:0>: um valor de 0 a 15d 
;		Vref = --------- x VDD			|->			VDD: A tens�o de alimenta��o do Pic
;				  24 					
;
;					Vref			2,5V
;		VR<3:0> =  ------- x 24 = -------- x 24 = 12
;					 VDD			 5V
;
;		VR<3:0> = 12d = 1100b = Ch
;
;		Tal tens�o de refer�ncia tamb�m pode ser usada externamente, conectando ela ao pino RA2, para outras aplica��es.
;
;
;		Na simula��o e na pr�tica o circuito e o programa funcionaram perfeitamente.		
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
	
	btfss		PIR1,CMIF					; Testa se flag CMIF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o setou, sai da interrup��o
	bcf			PIR1,CMIF					; Limpa flag CMIF
	
	btfsc		CMCON,C1OUT					; Testa se a sa�da do comparador � Low, se for, pula uma linha
	goto		acende_Led					; Se n�o for, desvia para label acende_Led
	bcf			led1						; Apaga led1
	goto 		exit_ISR					; Sai da interrup��o
	
acende_Led:

	bsf			led1						; Acende led1
	
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
	movwf		TRISA						; Configura todo PORTA como entrada
	movlw		H'FE'						; w = FEh 
	movwf		TRISB						; Configura apenas RB0 como sa�da digital, o resto como entrada
	bsf			PIE1,CMIE					; Ativa a interrup��o dos comparador internos
	movlw		H'AC'						; w = ACh
	movwf		VRCON						; Habilita a tens�o de refer�ncia interna, sem RA2, Low Range, VR = 12d = Ch
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'02'						; w = 02F
	movwf		CMCON						; Comparador com refer�ncia de tens�o interna e entrada inversora 1 em RA0
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Ativa a interrup��o global e por perif�ricos
	
	bcf			led1						; Inicia led1 em Low


; --- Loop infinito ---

loop:										; Cria label para loop infinito



	goto		loop						; Loop infinito
	

; --- Sub Rotinas --- 

	
	
	
; --- Fim do programa ---

end											; Final do programa