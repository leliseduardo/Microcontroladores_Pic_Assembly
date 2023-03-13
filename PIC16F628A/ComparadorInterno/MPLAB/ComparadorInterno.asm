;
;		O objetivo deste programa é fazer a configuração dos comparadores internos e utilizar sua interrupção. Será usado
;	o modo de dois comparadores independêntes e apenas um deles será utilizado no programa. O comparador irá simplesmente
;	comparar um valor de referência na porta inversora (RA0) com um valor que varia de acordo com um potenciômetro na 
; 	entrada não inversora (RA3). Como se sabe, quando o valor da porta inversora é maior, a saída apresenta nível lógico
;	baixo, enquanto se o valor da porta não inversora for maior, a saída apresenta nível lógico alto. 
;		No modo que será utilizado, que é o modo de dois comparadores independente, as saídas dos comparadores alteram o
;	estado de uma flag interna, denominada C1OUT para o comparador 1 e C2 OUT para o comparador 2. Neste modo, a saída
;	do comparador é lida internamente, por software.
;		Quando a saída muda de estado, seja de Low para High ou de High para Low, caso a interrupção dos comparadores 
;	internos esteja ativada, a flag CMIF seta para indicar que ouve uma mudança de estado da saída do comparador, gerando,
;	assim, uma interrupção.
;		Neste programa, a interrupção do comparador terá a única função de acender o led caso a saída do comparador esteja
;	e nível alto e apagar o led caso a saída esteja em nível baixo. 	
;
;
;
;		Na simulação e na prática o circuito e o programa funcionaram perfeitamente.	
;


	list		p=16f628a					; Informa o microcontrolador utilizado
	

; --- Documentação ---

	#include	<p16f628a.inc>				; Inclui o documento que contém os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura clock em 4MHz, ativa o Power Up Timer e ativa o Master Clear

; --- Paginação de memória ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar banco 1 de memória 
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTB,0				; Cria mnemônico para led1 em RA3
	#define 	led2 	PORTB,1				; Cria mnemônico para led2 em RA2
	#define		botao1	PORTB,7				; Cria mnemônico para botao1 em RB0
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endereço de início para configuração de registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	endc									; Fim da configuração dos registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endereço de memória para o vetor de Reset
	
	goto 		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrupção ---

	org			H'0004'						; Origem do endereço de memória para o vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	btfss		PIR1,CMIF					; Testa se flag CMIF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não setou, sai da interrupção
	bcf			PIR1,CMIF					; Limpa flag CMIF
	
	btfsc		CMCON,C1OUT					; Testa se a saída do comparador é Low, se for, pula uma linha
	goto		acende_Led					; Se não for, desvia para label acende_Led
	bcf			led1						; Apaga led1
	goto 		exit_ISR					; Sai da interrupção
	
acende_Led:

	bsf			led1						; Acende led1
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Retorna para endereço que estava quando ocorreu a interrupção
	
; -- Fim da recuperação de contexto --


; --- Programa principal --- 

inicio:										; Cria label para programa principal

	bank1									; Seleciona o banco 1 de memória
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada
	movlw		H'FE'						; w = FEh 
	movwf		TRISB						; Configura apenas RB0 como saída digital, o resto como entrada
	bsf			PIE1,CMIE					; Ativa a interrupção dos comparador internos
	bank0									; Seleciona banco 0 de memória
	movlw		H'04'						; w = 04F
	movwf		CMCON						; Configura dois comparadores internos independentes
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Ativa a interrupção global e por periféricos
	
	bcf			led1						; Inicia led1 em Low


; --- Loop infinito ---

loop:										; Cria label para loop infinito



	goto		loop						; Loop infinito
	

; --- Sub Rotinas --- 

	
	
	
; --- Fim do programa ---

end											; Final do programa