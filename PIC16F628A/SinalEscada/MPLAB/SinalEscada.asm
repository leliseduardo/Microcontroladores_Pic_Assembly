;
;		O objetivo deste programa é gerar um sinal do tipo escada no pino RA2, a partir da tensão de referência de saída
;	neste pino. Para isso será implementado uma interrupção do timer1 a cada 500ms, que terá como função diminuir o valor
;	das flags VR, de forma que na saída RA2 será gerado um sinal do tipo escada.
;
;	*** Timer 1 ***
;	
;	Overflow = (65536 - <TMR1H::TMR1L>) * prescaler * ciclo de máquina
;		
;											Overflow
;	(65536 - <TMR1H::TMR1L>) = 	---------------------------------
;								   prescaler * ciclo de máquina	
;
;										Overflow
;	<TMR1H::TMR1L> = 65536 - ---------------------------------
;								prescaler * ciclo de máquina
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
;		Na simulação o programa funcionou como esperado
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
	
	btfss		PIR1,TMR1IF					; Testa se flag TMR1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não setou, sai da interrupção
	bcf			PIR1,TMR1IF					; Limpa flag TMR1IF
	movlw		H'0B'						; w = 0Bh
	movwf		TMR1H						; Inicia TMR1H = 0Bh
	movlw		H'DC'						; w = DCh
	movwf		TMR1L						; Inicia TMR1L = DCh 
	
	bank1									; Seleciona banco 1 de memória
	decf		VRCON,F						; Decrementa registrador VRCON
	movlw		H'E0'						; w = CFh
	xorwf		VRCON,w						; Faz XOR entre w e VRCON para testar se VRCON chegou a CFh
	btfss		STATUS,Z					; Se chegou, seta a flag Z e pula uma linha
	goto		exit_ISR					; Se não chegou, sai da interrupção
	movlw		H'EF'						; w = EFh
	movwf		VRCON						; Reinicia VRCON = EFh
	bank0

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
	movwf		TRISA						; Configura todo PORTA como entrada, inclusive RA2, necessário para que a
											; a tensão de referência funcione neste pino
	movlw		H'FE'						; w = FEh 
	movwf		TRISB						; Configura apenas RB0 como saída digital, o resto como entrada
	movlw		H'EF'						; w = ACh
	movwf		VRCON						; Habilita a tensão de referência, conectada em RA2, Low Range, tensão máxima
	bsf			PIE1,TMR1IE					; Habilita a interrupção do timer1
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						; w = 07F
	movwf		CMCON						; Desliga os comparadores internos
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Habilita a interrupção global e por periféricos
	movlw		H'31'						; w = 21h
	movwf		T1CON						; Habilita o timer1, prescale em 1:4, incrementa com o ciclo de máquina
	movlw		H'0B'						; w = 0Bh
	movwf		TMR1H						; Inicia TMR1H = 0Bh
	movlw		H'DC'						; w = DCh
	movwf		TMR1L						; Inicia TMR1L = DCh 
	
	bcf			led1						; Inicia led1 em Low



; --- Loop infinito ---

loop:										; Cria label para loop infinito



	goto		loop						; Loop infinito
	

; --- Sub Rotinas --- 

	
	
	
; --- Fim do programa ---

	end										; Final do programa