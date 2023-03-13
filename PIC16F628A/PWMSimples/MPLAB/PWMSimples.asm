;
;		O objetivo deste programa � utilizar o modo PWM do m�dulo CCP. Este m�dulo utiliza o timer 2 para fazer a contagem
;	e implementar o PWM. Simult�neamente o c�digo ir� utilizar o timer 0 para fazer a varredura de dois bot�es, que t�m a 
;	a fun��o de aumentar e diminuit o duty cicle do PWM.
;		Para configurar o PWM do m�dulo CCP, basta ligar o timer2, configurar o PR2 e o prescaler, para ajustar o per�odo
;	do PWM. Ativar o m�dulo CCP no modo PWM e, ainda, iniciar os contadores CCPR1L e CCP1CON<5:4> para ajustar o duty cicle. 
;		Para utilizar este m�dulo, n�o � necess�rio habilitar as interrup��es globais, por perif�ricos e nem do timer2,
;	o timer2 � utilizado apenas como contador nesta aplica��o.
;		Por�m, neste programa a interrup��o global e a interrup��o por overflow do timer0 foram ligadas, pois utiliza-se
;	o timer0 para fazer a varredura dos bot�es utilizados para incrementar e decrementar o duty cicle do PWM.
;		Para utilizar o PWM do m�dulo CCP, � importante configurar o pino RB3/CCP1 como sa�da, para o correto funciona-
;	mento do PWM.
;		O tempo do semiciclo ativo, isto �, do semiciclo em que o sinal PWM est� em High, pode ser calculado pela equa��o
;	do semiciclo ativo, que considera os 10bits de resolu��o do PWM, o ciclo de oscila��o e o prescaler. N�o se deve 
;	confundir ciclo de oscila��o com ciclo de m�quina, s�o coisas diferentes.
;		Obs: O PWM neste c�digo foi configurado para ter resolu�a� de 8 bits. Mas ele pode ser configurado at� 8 bits.
;
;		*** A equa��o para encontrar o per�odo de oscila��o do PWM � a seguinte: ***
;
;		Per�odo PWM = (PR2 + 1) * ciclo de m�quina * prescaler do timer2
;		Per�odo PWM	= (255 + 1) * 1us * 16
;		per�odo PWM	= 4,096ms
;		Frequ�ncia PWM = 244,14Hz
;
;		Semiciclo Ativo = (CCPR1L:CCP1CON<5:4>) * ciclo de oscila��o * prescaler
;
;		  					     1		    1
;		ciclo de oscila��o =  -------- = -------- = 250ns
;							    Fosc	   4MHz
;
;		*** TIMER0 ***
;
;		Overflow = (255 - TMR0) * prescale * ciclo de m�quina
;		Overflow = 105 * 128 * 1us
;		Overflow = 13,4ms
;
;		Tanto na simula��o quanto na pr�tica o programa e o circuito funcionaram como esperado.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclus�o de arquivos ---

	#include	<p16f628a.inc>				; Inclui o arquivos com os registradores do Pic
		
; --- Fuse bits ---

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Cristal externo de 4MHz, Power Up Timer habilitado e Master Clear habilitado

; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Mapeamento de hardware ---

	#define 	led1		PORTA,3			; Cria mnem�nico para led1 em RA3
	#define 	led2 		PORTA,2			; Cria mnem�nico para led2 em RA2
	#define		botao1		PORTB,0			; Cria mnem�nico para botao1 em RB0
	#define 	botao2		PORTB,1			; Cria mnem�nico para botao2 em RB1
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o inicial para configurar os resgistradores de uso geral
	
	W_TEMP									; Armazena valor de W temporariamente
	STATUS_TEMP								; Armazena o valor de STATUS temporariamente
	
	endc									; Termina a configura��o dos registradores de uso geral
	
	
; --- Vetor de Reset ---			

	org			H'0000'						; Endere�o de origem do vetor de Reset
	
	goto 		inicio						; Desvia para programa principal
	
	
; --- Vetor de interrup��o ---

	org			H'0004'						; Endere�o de origem do vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	btfss		INTCON,T0IF					; Testa se flag T0IF setou, se sim, pula uma linha
	goto 		exit_ISR					; Se n�o, sai da interrup��o
	bcf			INTCON,T0IF					; Limpa flag T0IF
	
	movlw		D'150'						; w = 150d
	movwf		TMR0						; Recarrega TMR0 = 150d
	
	btfss		botao1						; Testa se botao1 foi pressionado, se foi, N�O pula uma linha
	goto		incrementa_PWM				; Se botao1 foi pressionado, desvia para label incrementa_PWM
	
	btfss		botao2						; Testa se botao2 foi pressionado, se foi, N�O pula uma linha
	goto		decrementa_PWM				; Se botao2 foi pressionado, desvia para label decrementa_PWM
	
	goto		exit_ISR					; Se botao1 nem botao2 foram pressionados, sai da interrup��o
	
incrementa_PWM:

	movlw		D'255'						; w = 255d
	xorwf		CCPR1L,w					; Faz l�gica XOR com CCPR1L para testar se este reg j� chegou a 255d
	btfsc		STATUS,Z					; Se n�o chegou, Z � zero e pula uma linha para continuar incrementando
	goto		exit_ISR					; Se ja chegou, Z � um e sai da interrup��o
	incf		CCPR1L,F					; Incrementa CCPR1L
	goto		exit_ISR					; Sai da interrup��o
	
decrementa_PWM:

	movlw		D'0'						; w = 0d
	xorwf		CCPR1L,w					; Faz l�gica XOR com CCPR1L para testar se este reg j� chegou a 0d
	btfsc		STATUS,Z					; Se n�o chegou, Z � zero e pula uma linha para continuar decrementando
	goto		exit_ISR					; Se j� chegou, Z � 1 e sai da interrup��o
	decf		CCPR1L,F					; Decrementa CCPR1L
	goto		exit_ISR					; Sai da interrup��o
	
; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (com nibbles reinvertidos = STATUS original)
	movwf		STATUS						; STATUS = STATUS_TEMP (STATUS original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos = w original)
	
	retfie									; Retorna ao loop infinito

; -- Fim da recupera��o de contexto -- 


; --- Inicio do programa principal ---

inicio: 

	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'86'						; w = 86h
	movwf		OPTION_REG					; OPTION_REG = 86h, configura o prescaler do timer0 em 1:128 e desabilita os pull-ups internos
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'F7'						; w = F7h
	movwf		TRISB						; TRISB = F7h, configura apenas RB3 como sa�da digital
	movlw		D'255'						; w = 255d
	movwf		PR2							; PR2 = 255d
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; CMCON = 07h, desabilita os comparadores internos
	movlw		H'E0'						; w = E0h
	movwf		INTCON						; INTCON = E0h, habilita a interup��o global, por perif�ricos e a interrup��o do timer0
	movlw		D'150'						; w = 150d
	movwf		TMR0						; inicia contagem do TMR0 em 150d
	movlw		H'06'						; w = 06h
	movwf		T2CON						; T2CON = 06h, habilita o timer 2 e configura o prescaler 1:16
	movlw		H'0C'						; w = 0Ch
	movwf		CCP1CON						; CCP1CON = 0Ch, configura o m�dulo CCP no modo PWM
	clrf		CCPR1L						; Zera byte menos significativo do contador do PWM
	
	

; -- Loop infinito -- 

loop:										; Cria label para loop infinito


	goto loop 								; Desvia para loop infinito	
	
	

end