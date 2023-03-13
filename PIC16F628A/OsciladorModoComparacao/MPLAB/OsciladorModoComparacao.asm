;
;		O objetivo deste programa � configurar e utilizar o m�dulo CCP1 do Pic no modo de compara��o. Este m�dulo compara
;	os registradores de contagem <CCPR1H::CCPR1L> com os contadores do TMR1 <TMR1H:TMR1L> e, no caso deste programa, 
;	gera uma interrup��o quando os valores s�o iguais. Configurando o modo de compara��o do modo trigger special event,
;	quando <CCPR1H::CCPR1L> e <TMR1H:TMR1L> s�o iguais, CCP1IF seta e ocorre uma interurp��o, e o contador <TMR1H:TMR1L>
;	� zerado.
;		Neste modo, <CCPR1H::CCPR1L> � fixo e n�o muda, enquanto <TMR1H:TMR1L> conta de 0 at� o valor de <CCPR1H::CCPR1L>,
;	que � quando o programa interrompe e zera <TMR1H:TMR1L>. 
;		Nesta configura��o, gera-se uma interrup��o de tempos em tempos e pode-se criar um oscilador, alternando alguma
; 	sa�da. No caso utilizou-se a sa�da RB3, que � a sa�da do m�dulo CCP1. Por�m, nesta configura��o, n�o � necess�rio
; 	que a sa�da seja este pino, pode ser qualquer um.
;		O tempo de interrup��o do modo de compara��o, nesta configura��o, pode ser calculado pela equa��o abaixo:
;
;		Interrupcao = ciclo de maquina * prescaler TMR1 * <CCPR1H::CCPR1L> 
;		Interrupcao = 1us * 1 * 0404h
;		Interrup��o = 1,028ms
;
;		Pode-se calcular o per�odo de oscila��o de um pino, feita por essa interrup��o, como se segue:
;
;		Periodo = 2 x Interupcao
;		Periodo	= 2 x 1,028ms
;		Periodo = 2,056ms
;
;		Na simula��o o programa funcionou perfeitamente, oscilando exatamente no tempo calculado e configurado.
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
	
	btfss		PIR1,CCP1IF					; Testa se a flag CCP1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o setou, sai da interrup��o
	bcf			PIR1,CCP1IF					; Limpa a flag CCP1IF
	
	movlw		H'08'						; w = 08h
	xorwf		PORTB,F						; Faz XOR com PORTB para inverter o estado de RB3

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
	bsf			INTCON,GIE					; Ativa a interrup��o global
	bsf			INTCON,PEIE					; Ativa a interrup��o por perif�ricos
	bsf			PIE1,CCP1IE					; Ativa a interrup��o do m�dulo CCP1
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'0B'						; w = 0Bh
	movwf		CCP1CON						; Configura o m�dulo CCP1 em modo de compara��o, resetando TMR1 no estouro
	bsf			T1CON,TMR1ON				; Habilita o timer1
	movlw		H'04'						; w = 04h
	movwf		CCPR1H						; CCPR1H = 04h
	movwf		CCPR1L						; CCPR1L = 04h
	bcf			PORTB,3						; Inicia RB3 em Low	

loop:										; Cria��o da label de loop infinito



	goto loop								; Desvia para label de loop infinito
	
	
	
	
; --- Fim do programa ---


	end										; Final do programa