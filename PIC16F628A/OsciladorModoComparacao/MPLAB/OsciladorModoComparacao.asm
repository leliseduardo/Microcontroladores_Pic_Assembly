;
;		O objetivo deste programa é configurar e utilizar o módulo CCP1 do Pic no modo de comparação. Este módulo compara
;	os registradores de contagem <CCPR1H::CCPR1L> com os contadores do TMR1 <TMR1H:TMR1L> e, no caso deste programa, 
;	gera uma interrupção quando os valores são iguais. Configurando o modo de comparação do modo trigger special event,
;	quando <CCPR1H::CCPR1L> e <TMR1H:TMR1L> são iguais, CCP1IF seta e ocorre uma interurpção, e o contador <TMR1H:TMR1L>
;	é zerado.
;		Neste modo, <CCPR1H::CCPR1L> é fixo e não muda, enquanto <TMR1H:TMR1L> conta de 0 até o valor de <CCPR1H::CCPR1L>,
;	que é quando o programa interrompe e zera <TMR1H:TMR1L>. 
;		Nesta configuração, gera-se uma interrupção de tempos em tempos e pode-se criar um oscilador, alternando alguma
; 	saída. No caso utilizou-se a saída RB3, que é a saída do módulo CCP1. Porém, nesta configuração, não é necessário
; 	que a saída seja este pino, pode ser qualquer um.
;		O tempo de interrupção do modo de comparação, nesta configuração, pode ser calculado pela equação abaixo:
;
;		Interrupcao = ciclo de maquina * prescaler TMR1 * <CCPR1H::CCPR1L> 
;		Interrupcao = 1us * 1 * 0404h
;		Interrupção = 1,028ms
;
;		Pode-se calcular o período de oscilação de um pino, feita por essa interrupção, como se segue:
;
;		Periodo = 2 x Interupcao
;		Periodo	= 2 x 1,028ms
;		Periodo = 2,056ms
;
;		Na simulação o programa funcionou perfeitamente, oscilando exatamente no tempo calculado e configurado.
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
	
	btfss		PIR1,CCP1IF					; Testa se a flag CCP1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não setou, sai da interrupção
	bcf			PIR1,CCP1IF					; Limpa a flag CCP1IF
	
	movlw		H'08'						; w = 08h
	xorwf		PORTB,F						; Faz XOR com PORTB para inverter o estado de RB3

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
	bsf			INTCON,GIE					; Ativa a interrupção global
	bsf			INTCON,PEIE					; Ativa a interrupção por periféricos
	bsf			PIE1,CCP1IE					; Ativa a interrupção do módulo CCP1
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'0B'						; w = 0Bh
	movwf		CCP1CON						; Configura o módulo CCP1 em modo de comparação, resetando TMR1 no estouro
	bsf			T1CON,TMR1ON				; Habilita o timer1
	movlw		H'04'						; w = 04h
	movwf		CCPR1H						; CCPR1H = 04h
	movwf		CCPR1L						; CCPR1L = 04h
	bcf			PORTB,3						; Inicia RB3 em Low	

loop:										; Criação da label de loop infinito



	goto loop								; Desvia para label de loop infinito
	
	
	
	
; --- Fim do programa ---


	end										; Final do programa