;
;		PIC16F628A		Clock = 4 MHz		Ciclo de máquina = 1us
;
;		Este programa tem a função de utilizar a interrupção do timer0 como temporizador. Ao clicar no botao1, o led1 
;	ficará aceso por um determinado tempo, definido pela base de tempo. Daí apagará após esse tempo.
;
;		Timer 0
;
;		Overflow = (256 - TMR0) * prescaler * ciclo de máquina
;		Overflow = 256 * 128 * 1us
;		Overflow = 33ms
;		
;		Para configurar a base de tempo foi utilizada a variável cont = 128. Logo, a base de tempo para temporizar o led
;	ficou com: overflow * cont = 33ms * 128 = +-4,22s.
;
;		Na simulação e na prática o circuito e o programa funcionaram como esperado.	
;

	list		p=16f628a					; Informa o microcontrolador utilizado

; --- Inclusão de arquivos ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC	& _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Clock de 4MHz, Power Up Time e Master Clear habilitados

; --- Paginação de memória ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
; --- Saídas ---

	#define 	led1	PORTA,3				; Cria um mnemônico para led1 em RA3
	#define 	led2	PORTA,2				; Cria um mnemônico para led2 em RA2
	
; --- Entradas ---

	#define 	botao1	PORTB,0				; Cria um mnemônico para botao1 em RB0
	#define 	botao2	PORTB,1				; Cria um mnemônico para botao2 em RB1
	
; --- Registadores de uso geral ---

	cblock		H'20'						; Cria registradores de uso geral a partir do endereço 20h de memória
	
	W_TEMP									; Armazena conteúdo de W temporariamente
	STATUS_TEMP								; Armazena conteúdo de STATUS temporariamente
	cont									; Base de tempo para o timer0
	
	endc

; --- Vetor de Reset ---

	org			H'0000'						; Origem do endereço do vetor de Reset
	goto 		inicio						; Desvia para label inicio
	
; --- Vetor de Interrupção
	org 		H'0004'						; Origem do endereço do vetor de Interrupção
	
; --- Salva contexto ---
	
	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = w = STATUS (com nibbles invertidos)
	
; --- Final do salvamento de contexto ---

	btfss		INTCON,T0IF					; Testa se T0IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não, saí da interrupção
	bcf			INTCON,T0IF					; Limpa flag T0IF, para uma nova interrupção
	movlw		D'0'						; w = D'10'
	movwf		TMR0						; Recarrega TMR0 com 10d
	
	decfsz		cont,F						; Decrementa cont e testa se chegou a zero, se sim, pula uma linha
	goto		exit_ISR					; Se não, saí da interrupção
	
	movlw		D'128'						; w = 6d
	movwf		cont						; Recarrega cont com 6d
	
	bcf			led1						; Apaga led1
	bcf			INTCON,T0IE					; Desabilita a interrupção do timer0
	bsf			led2						; Liga led2
	
; --- Recupera contexto ---

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (nibbles invertidos) = STATUS (original)
	movwf		STATUS						; STATUS = w = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP = w (original)
	
	retfie
	
; --- Fim da interrupção
	
	
inicio:

	bank0									; Seleciona o banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; CMCON = 07h, desabilita os comparadores internos
	movlw		H'80'						; w = 'A0'
	movwf		INTCON						; INTCON = A0h, habilita interrupção global e desabilita a interrupção do timer0
	bank1									; Seleciona o banco 1 de memória
	movlw		H'86'						; w = 86h
	movwf		OPTION_REG					; OPTION_REG = 86h, desabilita os pull-ups internos, associa o prescaler do timer 0 e configura para 1:128
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura RA3 e RA2 como saídas digital
	movlw		H'FF'						; w = FFh
	movwf		TRISB						; TRISB = FFh, configura todo portb como entrada digital
	bank0									; Seleciona o banco 0 de memória
	movlw		D'0'						; w = 10d
	movwf		TMR0						; TMR0 inicia sua contagem em 10d
	bcf			led1						; Inicia led1 em Low
	bcf			led2						; Inicia led2 em Low
	movlw		D'128'						; w = 6d
	movwf		cont						; cont = 6d
	
	
loop:										; Cria loop infinito


	btfss		botao1						; Testa se botao1 foi pressionado, se foi, NÃO pula uma linha
	goto 		acende_Led1					; Desvia para label acende_Led1

	goto		loop						; Desvia para label loop	 
	
acende_Led1:

	bsf			led1						; Liga led1
	bcf			led2						; Apaga led2
	bsf			INTCON,T0IE					; Habilita a interrupção do timer0
	
	goto 		loop						; Desvia para loop infinito
	
end