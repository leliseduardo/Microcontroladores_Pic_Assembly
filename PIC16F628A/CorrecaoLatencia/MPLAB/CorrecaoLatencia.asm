;
;		Este programa tem o objetivo de demosntrar como corrigir o erro de latência da interrupção do timer. Para fazer 
;	tal correção, é necessário, através do debug, descobrir qual é o tempo de latência da interrupção e, a partir disso,
;	subtrair do contador do timer1 o tempo extra de latência. Isto é, já que a cada ciclo de máquina o contador incrementa
;	1, basta descobrir o tempo de latência e subtrair esse tempo diretamente no contador. 
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
;							   500us
;	<TMR1H::TMR1L> = 65536 - --------- = 65036
;							  1 * 1us
;
;	<TMR1H::TMR1L> = 65036d = FE0Ch
;
;	TMR1H = FEh
;	TMR1L = 0Ch
;
;	Tempo de latência obtido pelo debug = 14us
;
;							  (500us - 14us)
;	<TMR1H::TMR1L> = 65536 - ---------------- = 65050 (Valor corrigido considerando a latência de interrupção)
;							  	  1 * 1us
;
;	<TMR1H::TMR1L> = 65050d = FE1Ah
;
;	TMR1H = FEh
;	TMR1L = 1Ah	
;
;		No debug e na simulação o programa funcionou como esperado, com o tempo de Overflow exato, com o tempo de 
;	latência corrigido.
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
	cont									; Contador para base de tempo de 1s
	
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
	
	btfss		PIR1,TMR1IF					; Testa se a flag TMR1IF setou, se sim, pula uma linha
	goto 		exit_ISR					; Se não, sai da interrupção
	bcf			PIR1,TMR1IF					; Limpa a flag TMR1IF
	movlw		H'FE'						; w = 3Ch
	movwf		TMR1H						; reinicia TMR1H = 3Ch
	movlw		H'1A'						; w = B0h
	movwf		TMR1L						; reinicia TMR1L = B0h
	
	movlw		H'40'						; w = 40h
	xorwf		PORTB						; Alterna RB6 com lógica XOR
	
; -- 500us --
	
	incf		cont,F						; Incrementa cont
	movlw		H'08'						; w = 08h
	xorwf		cont,w						; Faz lógica XOR de w com cont
	btfss		STATUS,Z					; Se a lógica XOR resultou em zero, Z = 1 e pula uma linha
	goto		exit_ISR					; Se não, sai da interrupção
	
	clrf		cont						; Limpa cont
	movlw		H'80'						; w = 80h
	xorwf		PORTB						; Alterna RB7 com lógica XOR
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS_TEMP (com nibbles reinvertidos = STATUS original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos = w original)
	
	retfie									; Volta para execução principal

; -- Fim da recuperação de contexto --

inicio:

	bank1									; Seleciona banco 1 de memória 
	bcf			TRISB,7						; Configura RB7 como saída digital
	bcf			TRISB,6						; Configura RB6 como saída digital
	bsf			PIE1,TMR1IE					; Habilita a interrupção por overflow do timer1
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	bcf			PORTB,7						; Inicia RB7 em Low
	bcf			PORTB,6						; Inicia RB6 em Low
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Habilita a interrupção global e por periféricos
	movlw		H'01'						; w = 01h
	movwf		T1CON						; Prescaler em 1:1, incrementa pelo ciclo de máquina e habilita o timer1
	movlw		H'FE'						; w = 3Ch
	movwf		TMR1H						; Inicia TMR1H = 3Ch
	movlw		H'1A'						; w = B0h
	movwf		TMR1L						; Inicia TMR1L = B0h
	clrf		cont						; Limpa registrador de uso geral cont
	

goto			$							; Programa fica preso neste endereço e aguarda interrupção


end											; Fim do programa 
