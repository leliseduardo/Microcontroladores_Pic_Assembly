;
;		PIC16F628A		Clock = 4 MHz		Ciclo de m�quina = 1us
;
;		Este programa tem a fun��o de demonstrar a diferen�a entra interrup��o por timers e delay, e mostrar que a inter-
;	rup��o � uma forma muito melhor de se temporizar algo em um programa, por v�rios motivos. A interrup��o n�o trava o 
;	programa para temporizar e tem prioridade sobre outras execu��es, fazendo com que sua rotina seja executada assim que
; 	o timer temporizar o tempo programado.
;
;		Timer 0
;
;		Overflow = (256 - TMR0) * prescaler * ciclo de m�quina
;		Overflow = 250 * 4 * 1us
;		Overflow = 1ms
;		
;		Para configurar a base de tempo foi utilizada a vari�vel cont1 = 10 e cont2 = 50. Logo, a base de tempo para 
;	temporizar ficou com: overflow * cont1 * cont2 = 1ms * 10 * 50 = 500ms.
;
;		Na simula��o o programa funcionou como esperado, demonstrando que a interrup��o tem prioridade sobre o delay e 
; 	demonstrando que o delay n�o temporiza de forma exata em determinadas situa��es. 		
;

	list		p=16f628a					; Informa o microcontrolador utilizado

; --- Inclus�o de arquivos ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC	& _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Clock de 4MHz, Power Up Time e Master Clear habilitados

; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Sa�das ---

	#define 	led1	PORTA,3				; Cria um mnem�nico para led1 em RA3
	#define 	led2	PORTA,2				; Cria um mnem�nico para led2 em RA2
	
; --- Entradas ---

	#define 	botao1	PORTB,0				; Cria um mnem�nico para botao1 em RB0
	#define 	botao2	PORTB,1				; Cria um mnem�nico para botao2 em RB1
	
; --- Registadores de uso geral ---

	cblock		H'20'						; Cria registradores de uso geral a partir do endere�o 20h de mem�ria
	
	W_TEMP									; Armazena conte�do de W temporariamente
	STATUS_TEMP								; Armazena conte�do de STATUS temporariamente
	cont1									; Base de tempo para o timer0
	cont2									; Base de tempo para o timer0
	tempo1									; Tempo auxiliar para delay
	tempo2									; Tempo auxiliar para delay
	
	endc

; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o do vetor de Reset
	goto 		inicio						; Desvia para label inicio
	
; --- Vetor de Interrup��o
	org 		H'0004'						; Origem do endere�o do vetor de Interrup��o
	
; --- Salva contexto ---
	
	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = w = STATUS (com nibbles invertidos)
	
; --- Final do salvamento de contexto ---

	btfss		INTCON,T0IF					; Testa se T0IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o, sa� da interrup��o
	bcf			INTCON,T0IF					; Limpa flag T0IF, para uma nova interrup��o
	movlw		D'6'						; w = D'10'
	movwf		TMR0						; Recarrega TMR0 com 10d
	
	decfsz		cont1,F						; Decrementa cont1 e testa se chegou a zero, se sim, pula uma linha
	goto		exit_ISR					; Se n�o, sa� da interrup��o
	
	movlw		D'10'						; w = 10d
	movwf		cont1						; Recarrega cont com 10d
	
	decfsz		cont2,F						; Decrementa cont2 e testa se chegou a zero, se sim, pula uma linha
	goto		exit_ISR					; Se n�o, sa� da interrup��o
	
	movlw		D'50'						; w = 50d
	movwf		cont2						; Recarrega cont2 com 50d	
	
	comf		PORTA						; Complementa porta
	
; --- Recupera contexto ---

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (nibbles invertidos) = STATUS (original)
	movwf		STATUS						; STATUS = w = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP = w (original)
	
	retfie
	
; --- Fim da interrup��o
	
	
inicio:

	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; CMCON = 07h, desabilita os comparadores internos
	movlw		H'A0'						; w = 'A0'
	movwf		INTCON						; INTCON = A0h, habilita interrup��o global e desabilita a interrup��o do timer0
	bank1									; Seleciona o banco 1 de mem�ria
	movlw		H'81'						; w = 86h
	movwf		OPTION_REG					; OPTION_REG = 86h, desabilita os pull-ups internos, associa o prescaler do timer 0 e configura para 1:4
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura RA3 e RA2 como sa�das digital
	movlw		H'F3'						; w = FFh
	movwf		TRISB						; TRISB = FFh, configura todo portb como entrada digital
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		D'6'						; w = 10d
	movwf		TMR0						; TMR0 inicia sua contagem em 10d
	bcf			led1						; Inicia led1 em Low
	bsf			led2						; Inicia led2 em High
	movlw		D'10'						; w = 10d
	movwf		cont1						; cont1 = 10d
	movlw		D'50'						; w = 50d
	movwf		cont2						; cont2 = 50d
	movlw		B'11110111'					; w = B'11110111'
	movwf		PORTB						; PORTB inicia com RB3 em Low e RB4 em High
	
	
loop:										; Cria loop infinito

	comf		PORTB						; Complementa portb
	call		delay500ms					; Chama subrotina de delay

	goto		loop						; Desvia para label loop	
	
	
; --- Sub-rotinas ---
	
	delay500ms:	; Cria a sub-rotina
	
		movlw	D'200' ; Move o valor 200 decimal para W
		movwf	tempo1 ; Move o valor de W para o registrador de uso geral no endere�o 0C
		
		aux1: ; Cria uma label auxiliar
		
			movlw	D'250' ; Move o valor decimal 250 para W
			movwf	tempo2 ; Move o valor de W para o registrado de uso geral no endere�o 0D
			
		aux2: ; Cria outra label auxiliar
		
			nop
			nop
			nop
			nop
			nop
			nop
			nop ; Gasta 7 ciclo de m�quina = 7us
			
			decfsz	tempo2 ; Decrementa o valor contido no endere�o 0D e pula uma linha se o valor for zero
			goto	aux2 ; Desvia para a label aux2
			
			decfsz	tempo1 ; Decrementa o valor contido no endere�o 0C e pula uma linha se o valor for zero
			goto 	aux1 ; Desvia o programa para a label aux1
			
			return ; Retorna para o loop infinito
			
	
	
end