;
;		O objetivo deste programa é configurar o PWM em 10 bits e calcular o semiciclo ativo, que nada mais é do que o 
;	semiciclo do PWM em que o sinal está em High. Para isso, será calculado o valor necessário para inicia o contador de
;	10 bits (<CCPR1L::CCP1L<5:4>), para que o semiciclo ativo tenha 45% do período.
;		Um fato interessanta é que neste porgrama não haverá rotina de interrupção de no loop infinito. O programa ficará
;	preso em um endereço ("loop infinito") e, mesmo assim, o PWM será executado, pois é um recurso de hardware.
;
;		*** A equação para encontrar o período de oscilação do PWM é a seguinte: ***
;
;		Período PWM = (PR2 + 1) * ciclo de máquina * prescaler do timer2
;		Período PWM	= (49 + 1) * 1us * 16
;		período PWM	= 800us
;		Frequência PWM = 1250Hz
;
;		Semiciclo Ativo = (CCPR1L:CCP1CON<5:4>) * ciclo de oscilação * prescaler
;
;		  					     1		    1
;		ciclo de oscilação =  -------- = -------- = 250ns
;							    Fosc	   4MHz
;
;		*** TIMER0 ***
;
;		Overflow = (255 - TMR0) * prescale * ciclo de máquina
;		Overflow = 105 * 128 * 1us
;		Overflow = 13,4ms
;
;		Na simulação o programa funcionou como esperado, com o PWM com o período de 800us e o semiciclo ativo com um 
;	tempo de 360us, que representa 45% do período total.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclusão de arquivos ---

	#include	<p16f628a.inc>				; Inclui o arquivos com os registradores do Pic
		
; --- Fuse bits ---

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Cristal externo de 4MHz, Power Up Timer habilitado e Master Clear habilitado

; --- Paginação de memória ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define		bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
; --- Mapeamento de hardware ---

	#define 	led1		PORTA,3			; Cria mnemônico para led1 em RA3
	#define 	led2 		PORTA,2			; Cria mnemônico para led2 em RA2
	#define		botao1		PORTB,0			; Cria mnemônico para botao1 em RB0
	#define 	botao2		PORTB,1			; Cria mnemônico para botao2 em RB1
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endereço inicial para configurar os resgistradores de uso geral
	
	W_TEMP									; Armazena valor de W temporariamente
	STATUS_TEMP								; Armazena o valor de STATUS temporariamente
	
	endc									; Termina a configuração dos registradores de uso geral
	
	
; --- Vetor de Reset ---			

	org			H'0000'						; Endereço de origem do vetor de Reset
	
	goto 		inicio						; Desvia para programa principal
	
	
; --- Vetor de interrupção ---

	org			H'0004'						; Endereço de origem do vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (com nibbles reinvertidos = STATUS original)
	movwf		STATUS						; STATUS = STATUS_TEMP (STATUS original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos = w original)
	
	retfie									; Retorna ao loop infinito

; -- Fim da recuperação de contexto -- 


; --- Inicio do programa principal ---

inicio: 

	bank1									; Seleciona banco 1 de memória
	movlw		H'86'						; w = 86h
	movwf		OPTION_REG					; OPTION_REG = 86h, configura o prescaler do timer0 em 1:128 e desabilita os pull-ups internos
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura apenas RA3 e RA2 como saídas digitais
	movlw		H'F7'						; w = F7h
	movwf		TRISB						; TRISB = F7h, configura apenas RB3 como saída digital
	movlw		D'49'						; w = 255d
	movwf		PR2							; PR2 = 255d
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; CMCON = 07h, desabilita os comparadores internos
	movlw		H'E0'						; w = E0h
	movwf		INTCON						; INTCON = E0h, habilita a interupção global, por periféricos e a interrupção do timer0
	movlw		D'150'						; w = 150d
	movwf		TMR0						; inicia contagem do TMR0 em 150d
	movlw		H'06'						; w = 06h
	movwf		T2CON						; T2CON = 06h, habilita o timer 2 e configura o prescaler 1:16
	movlw		H'0C'						; w = 0Ch
	movwf		CCP1CON						; CCP1CON = 0Ch, configura o módulo CCP no modo PWM
	
	movlw		B'00010110'					; w = 00010110b
	movwf		CCPR1L						; CCPR1L = 00010110b
	bsf			CCP1CON,5					; Seta o bit 5 do registrador CCP1CON
	bcf			CCP1CON,4					; Limpa o bit 4 do registrador CCP1CON
	
	
; --- Como calcular o tempo do semiciclo ativo ---
;
;	Semiciclo Ativo = (CCPR1L:CCP1CON<5:4>) * ciclo de oscilação * prescaler
;
;	Deseja-se um semiciclo ativo de 45% do período
;
;	Período = 800ms
;	Semiciclo = 800ms * 0,45 = 360us
;
;	Semiciclo Ativo = (CCPR1L:CCP1CON<5:4>) * ciclo de oscilação * prescaler
;
;								          Semiciclo Ativo
;	(CCPR1L:CCP1CON<5:4>) = ---------------------------------------------
;								   ciclo de oscilação * prescaler
;
;							   360us			
;	(CCPR1L:CCP1CON<5:4>) = ------------
;							 250ns * 16
;
;   (CCPR1L:CCP1CON<5:4>) = 90
;
;	Logo, a contegem do contador do módulo CCP deve começar em 90, para um semiciclo ativo do PWM em 45%
;
;	90d = 0001011010b
;
;		CCPR1L	 		CCP1CON,5		CCP1CON,4	
;	   00010110b			1b				0b
;		 	
;	
; --- Fim do cálculo do semiciclo ativo ---


; -- Loop infinito -- 

	goto		$							; Programa fica preso neste endereço

end