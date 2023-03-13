;
;		O objetivo deste programa � demonstrar o uso pr�tico do Watch Dog Timer. O programa far� com que um led pisque
;	a cada 500ms, simulando um atuador de ind�stria, por exemplo. Quando algum problema acontencer, o led, ou o atuador
;	da industria, n�o pode continuar ligado indefinidamente por causa deste problema. Por isso, ativa-se o WDT e, caso 
;	ocorra o tal problema, o WDT reinicia o programa e desliga o led ou o atuador. 
;		Para que isso funcione corretamente, a sa�da que controla o led ou o atuador deve iniciar desligado, para caso 
; 	haja algum problema, o WDT reinicia e esta sa�da permane�a desligada.
;		Para contar os 500ms de oscila��o do led, ser� utilizado e configuado o timer1. Ainda, para simular o erro de
;	funcionamento do Pic, o cristal oscilador ser� retirado, demonstrando que o WDT reinicia o programa e mant�m a 
; 	sa�da do led ou atuador desligada at� que seja corrigido o problema. 
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
;
;		Na pr�tica o circuito funcionou como esperado. Quando o WDT est� ativado e retira-se o cristal oscilador, o 
;	Pic reinicia e desliga led1, quando o WDT est� desativado e retira-se o cristal oscilador, se o led1 estiver ligado,
;	ele assim permanece. Assim, fica provado a import�ncia do Watch Dog Timer para a seguran�a e estabilidade de 
;	circuitos e sistemas com Pic.	
;

list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Documenta��o ---

	#include	<p16f628a.inc>				; Inclui o documento que cont�m os registradores do Pic
	
	
; --- Fuse bits	---
	
	__config	_XT_OSC & _WDT_ON & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura clock em 4MHz, liga o WatchDog Timer, liga o Power Up Timer e liga o Master Clear

; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Mapeamento de hardware ---

	#define		led1	PORTA,3				; Cria mnem�nico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnem�nico para led2 em RA2
	#define 	botao1	PORTB,0				; Cria mnem�nico para botao1 em RB0
	#define 	botao2	PORTB,1				; Cria mnem�nico para botao2 em RB1
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o para in�cio de configura��es de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de W temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	
	endc									; Fim da configura��o de registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o do vetor de Reset
	
	goto		inicio						; Desvia para programa principal
	
; --- Vetor de Interrup��o ---	

	org 		H'0004'						; Origem do endere�o do vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de mem�ria --

	; Desenvolvimento da ISR...
	
; ***** Timer 1 *****

	btfss		PIR1,TMR1IF					; Testa se a flag TMR1IF setou, se sim, pla uma linha
	goto		exit_ISR					; Se n�o setou, sai da interrup��o
	bcf			PIR1,TMR1IF					; Limpa flag TMR1IF
	
	movlw		H'08'						; w = 08h
	xorwf		PORTA,F						; Faz l�gica XOR entre w e PORTA para mudar estado de RA3

; ***** Fim do Timer1 *****
	
; -- Recupera��o de contexto -- 

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS(com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Sai da interrup��o, volta para o endere�o do mem�ria onde foi interrompido

; -- Fim da recupera��o de contexto --

; --- Programa principal ---

inicio:

	bank1									; Seleciona o banco 1 de mem�ria
	movlw		H'F7'						; w = F7h
	movwf		TRISA						; Configura apenas RA3 sa�da digital
	movlw		H'FF'						; w = FFh
	movwf		TRISB						; Configura todo portb como entrada digital
	movlw		H'8B'						; w = 8Eh
	movwf		OPTION_REG					; Configura o prescaler associado ao WDT, em 1:8
	bsf			PIE1,TMR1IE					; Liga a interrup��o por overflow do timer1
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'C0'						; w = A0h
	movwf		INTCON						; Ativa a interrup��o global e por perif�ricos
	movlw		H'31'						; w = 31h
	movwf		T1CON						; Liga o timer1, incrementa pelo ciclo de m�quina e prescaler em 1:8
	movlw		H'0B'						; w = 0Bh
	movwf		TMR1H						; Inicia TMR1H = 0Bh
	movlw		H'DC'						; w = DCh
	movwf		TMR1L						; Inicia TMR1L = DCh			
	
	bcf			led1						; Inicia led1 desligado
	

; --- Loop infinito ---

loop:										; Cria label para loop infinito

	clrwdt									; Limpa a contagem do Watch Dog Timer

goto loop									; Desvia para loop infinito

; --- Final do programa ---

end 										; Final do programa