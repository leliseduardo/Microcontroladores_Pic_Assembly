;
;		Este programa tem o objetivo de criar um PWM a partir da interrupção dos comparadores internos, configurados com
;	dois comparadores independente. O código utilizado é o mesmo da aula passada, denominada "ComparadorInterno".
;		Para criar o PWM, coloca-se um sinal senoidal na porta não-inversora e um potenciômetro na porta inversora. Assim,
;	quando o sinal senoidal (não-inversora) for maior que a tensão do potenciômetro (inversora), a saída é High, e do
; 	contrário, a saída é Low. Assim, quanto maior a tensão do potenciômetro, menor é o semiciclo ativo do sinal PWM.
;		Nesta aula foi utilizado um sinal senoidal para gerar o PWM, comparando o sinal com uma tensão de referência.
;	Porém, pode-se usar também um sinal do tipo triangular, gerada pela carga e descarga de um capacitor num circuito
;	RC. Utilizando um oscilador com um CI 555, consegue-se esta onda triangular, pela carga e descarga do capacitor.
;	Ainda, podem ser estudados no futuro outros tipos de osciladores com circuito RC, capazes de fornecer um sinal tri-
;	angular.
;
;
;		Na simulação o circuito e o programa funcionaram perfeitamente.		
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