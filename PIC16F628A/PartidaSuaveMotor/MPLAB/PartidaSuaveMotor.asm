;
;		Este programa tem como objetivo acionar um motor de maneira suave, para que não haja um surto de corrente nos seus
;	terminais. Para isso será feito o uso do PWM do módulo CCP, que irá variar o duty de 0 a 100% de maneira suave, para
;	que o motor chegue a sua velocidade total de maneira suave.
;
;	*** Timer 0 ***
;
;	Overflow = (255 - TMR0) * prescaler * Ciclo de máquina
;	Overflow = 200 * 128 * 1us
;	Oveflow = 25,6ms
;
;	*** PWM ***
;	
;	Período PWM = (PR2 + 1) * Ciclo de máquina * Prescaler do timer2
;	Período PWM = 50 * 1us * 16
;   Período PWM = 800us
;	Frequência PWM = 1250Hz
;
;		Quando se utiliza o timer2 para o módulo CCP, no modo PWM, o PR2 define o tamanho do período do sinal PWM. Logo,
;	se PR2 = 255, o período tem 255 de tamanho e a frequência diminui. Neste programa, para o motor fazer uma partida 
;	suave de 0 à 100% de duty, o CCPR1L deve variar de 0 até PR2.
;		Este módulo deve ser mais aprofundado caso se necessite utilizar o PWM do módulo CCP, porém, o conhecimento 
;	básico de funcionamento já torna o uso viável para diversas aplicações.
;	
;		Na simulação e na prática o circuito e o programa funcionaram como esperado.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclusões --- 

	#include	<p16f628a.inc> 				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, Power Up Timer habilitado e Master Clear habilitado


; --- Paginação de memória ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnemônico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnemônico para led2 em RA2
	#define 	botao1	PORTB,0				; Cria mnemônico para botao1 em RB0
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endereço de início para configuração dos registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	endc									; Fim da configuração dos registradores de uso geral
	
	
; --- Vetor de Reset ---

	org			H'0000'						; Endereço de origem do vetor de Reset
	
	goto 		inicio						; Desvia a execução para o programa principal
	
; --- Vetor de interrupção --- 

	org			H'0004'						; Endereço de origem do vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (con nibbles invertidos)
	bank0									; Seleciona banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	btfss		INTCON,T0IF					; Testa se a flag T0IF foi setada, se foi , pula uma linha
	goto		exit_ISR					; Se não, sai da interrupção
	bcf			INTCON,T0IF					; Limpa flag T0IF
	
	movlw		D'55'						; w = 55d
	movwf		TMR0						; Recarrega TMR0 = 55d, para contagem de 200
	
	movlw		D'255'						; w = 255d
	xorwf		CCPR1L,w					; Faz lógica XOR com CCPR1L para testar se este já chegou a 255
	btfsc		STATUS,Z					; Se já, Z seta e NÃO pula uma linha, se não, pula uma linha
	goto 		exit_ISR					; Sai da interrupção
	incf		CCPR1L,F					; Incrementa CCPR1L
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS_TEMP (com nibbles reinvertidos = STATUS original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos = w original)
	
	retfie									; Volta para execução principal

; -- Fim da recuperação de contexto -- 
 
 
; --- Programa principal ---

inicio: 

	bank1									; Seleciona banco 1 de memória
	movlw		H'86'						; w = 86h
	movwf		OPTION_REG					; Desabilita os pull-ups internos e configura prescaler do timer0 em 1:128
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; Configura apenas RA3 e RA2 como saídas digitais
	movlw		H'F7'						; w = FFh
	movwf		TRISB						; Configura apenas RB3 como saída digital
	movlw		D'255'						; w = 49d
	movwf		PR2							; Configura limite de contagem de CCPR1L, para ajustar frequência do PWM
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'A0'						; w = A0h
	movwf		INTCON						; Habilita a interrupção global e a interrupção por overflow do timer0
	movlw		D'55'						; w = 55d
	movwf		TMR0						; Inicia contagem do timer0 em 55d, para contar 200
	movlw		H'F3'						; w = F3h
	movwf		PORTA						; Inicia RA3 e RA2 em Low
	movlw		H'06'						; w = 06h
	movwf		T2CON						; Liga o timer2 e configura o postscaler em 1:1 e o prescaler em 1:16
	movlw		H'0C'						; w = 0Ch
	movwf		CCP1CON						; Configura o módulo CCP para o modo PWM
	clrf		CCPR1L						; Limpa o contador do módulo CCP
	
	
	goto		$							; Programa fica preso neste endereço e aguarda interrupção
	
	
	end										; Fim do programa
		