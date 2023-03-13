;
;		Este programa tem a fun��o de criar um timer regressivo a partir do uso do display de 7 segmentos. Para isso, 
;	utiliza-se o c�digo da aula passada, denominada "Display7Segmentos", fazendo apenas algumas altera��es.
;		O programa ir� iniciar com a interrup�o desligada e, quando um bot�o for pressionado, o display ir� decrementar
;	e, quando chegar a zero, a interrup��o ser� novamente desligada e um led ir� se acender.
;		Este � um princ�pio de um temporiazador para alguma fun��o pr�tica. O led pode ser um rel� que controla algum
;	atuador, que aciona por determinado tempo quando um bot�o � pressionado ou quando um sensor aciona ou chega a 
;	determinado valor. 
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
;							   200ms
;	<TMR1H::TMR1L> = 65536 - --------- = 15536
;							  4 * 1us
;
;	<TMR1H::TMR1L> = 15536d = 3CB0h
;
;	TMR1H = 3Ch
;	TMR1L = B0h		
;
;		Na simula��o e na pr�tica o circuito e o programa funcionaram como esperado
;

	list		p=16f628a						; Informa o microcontrolador utilizado
	
; --- inclus�es ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, habilita o Power Up Timer e habilita o Master Clear

; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnem�nico para led1 em RA3
	#define 	led2	PORTA,2				; Cria mnem�nico para led2 em RA2
	#define 	botao1	PORTB,4				; Cria mnem�nico para botao1 em RB0

; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Registradores de uso geral ---

	cblock		H'20'						; In�cio do endere�o para configura��o dos registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	cont									; Contador para base de tempo do timer1
	disp									; Contador que incrementa o display
	
	endc									; Fim da configura��o dos registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o do vetor de Reset
	
	goto		inicio						; Desvia para label inicio, programa principal
	
; Vetor de Interrup��o

	org 		H'0004'						; Origem do endere�o do vetor de Reset
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...

; -- 200ms --
	
	btfss		PIR1,TMR1IF					; Testa se a flag TMR1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o, sai da interrup��o
	bcf			PIR1,TMR1IF					; Limpa a flag TMR1IF
	movlw		H'3C'						; w = 3Ch;
	movwf		TMR1H						; reinicia TMR1H = 3Ch
	movlw		H'B0'						; w = B0h;
	movwf		TMR1L						; reinicia TMR1L = B0h				
	
; -- 200ms --

; -- 1s --

	incf		cont,F						; Incrementa cont
	movlw		H'05'						; w = 05h
	xorwf		cont,w						; Faz l�gica XOR para testar se cont j� chegou a 05h, se chegou resulta em 0
	btfss		STATUS,Z					; Se resultou em zero, a flag Z seta e pula uma linha
	goto		exit_ISR					; Se n�o resultou em zero, cont ainda n�o chegou em 05h e sai da interrup��o
	
	clrf		cont						; Limpa cont
	decfsz		disp,F						; Decrementa disp e pula uma linha quando chegar a zero
	goto		exit_ISR					; Enquanto disp n�o chegar a zero, sai da interrup��o
	bsf			led1						; Acende led1
	
; -- 1s --
	
	
; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (com nibbles reinvertidos, isto �, STATUS original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos, isto �, w original)
	
	retfie									; Retorna para execu��o principal
	
; -- Fim da recupera��o de contexto -- 


; --- Programa principal ---

inicio:

	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; Configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'10'						; w = 10h
	movwf		TRISB						; Configura todo portb como sa�da digital, exceto RB4
	bsf			PIE1,TMR1IE					; Habilita a interrup��o por overflow do timer1
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'40'						; w = C0h
	movwf		INTCON						; Desliga a interrup��o global e e habilita a interrup��o por perif�ricos
	movlw		H'21'						; w = 21h
	movwf		T1CON						; liga o timer1, prescaler em 1:4, incrementa pelo ciclo de m�quina 
	movlw		H'F3'						; w = F3h
	movwf		PORTA						; Inicia RA3 e RA2 em Low
	movlw		H'3C'						; w = 3Ch;
	movwf		TMR1H						; Inicia TMR1H = 3Ch
	movlw		H'B0'						; w = B0h;
	movwf		TMR1L						; Inicia TMR1L = B0h
	clrf		cont
	movlw		H'0F'						; w = 0Fh
	movwf		disp						; Inicia disp = 0Fh
	
	
; --- Loop infinito ---

loop:										; Cria loop infinito
		
	btfsc		botao1						; Testa se botao1 foi pressionado, se foi, pula uma linha
	goto		auxiliar					; Se n�o foi pressionado, desvia para label auxiliar
	bsf			INTCON,GIE					; Liga a interrup��o global
	bcf			led1						; Apaga led1
	
auxiliar:

	call		adiciona					; Desvia para label adiciona
	btfsc		led1						; Testa se o led1 est� ligado, se N�O estiver, pula uma linha
	call		encerra						; Se led1 estiver ligado, encerra o programa
		
	goto		loop						; Desvia para loop infinito
	
; --- Sub Rotinas ---

display:

	movlw		H'0F'						; w = H'0F', cria a m�scara para o contador disp
	andwf		disp,w						; Faz l�gica AND entra w e disp e o resultado s�o os bits do nibble menos
											; significativo, guardado em w. O resultado varia de 0 a Fh
	addwf		PCL,F						; Adiciona em PCL o valor de 0 a Fh do nibble menos sig. de disp, fazendo com
											; que haja um desvio condicional para "disp" comandos a frente
	
	; Display	  EDC.BAFG
		
	retlw		B'11101110'					; Retorna o valor bin�rio que escreve 0 para a subrotina adiciona
	retlw		B'00101000'					; Retorna o valor bin�rio que escreve 1 para a subrotina adiciona
	retlw		B'11001101'					; Retorna o valor bin�rio que escreve 2 para a subrotina adiciona
	retlw		B'01101101'					; Retorna o valor bin�rio que escreve 3 para a subrotina adiciona
	retlw		B'00101011'					; Retorna o valor bin�rio que escreve 4 para a subrotina adiciona
	retlw		B'01100111'					; Retorna o valor bin�rio que escreve 5 para a subrotina adiciona
	retlw		B'11100111'					; Retorna o valor bin�rio que escreve 6 para a subrotina adiciona
	retlw		B'00101100'					; Retorna o valor bin�rio que escreve 7 para a subrotina adiciona
	retlw		B'11101111'					; Retorna o valor bin�rio que escreve 8 para a subrotina adiciona
	retlw		B'01101111'					; Retorna o valor bin�rio que escreve 9 para a subrotina adiciona
	retlw		B'10101111'					; Retorna o valor bin�rio que escreve A para a subrotina adiciona
	retlw		B'11100011'					; Retorna o valor bin�rio que escreve b para a subrotina adiciona
	retlw		B'11000110'					; Retorna o valor bin�rio que escreve C para a subrotina adiciona
	retlw		B'11101001'					; Retorna o valor bin�rio que escreve d para a subrotina adiciona
	retlw		B'11000111'					; Retorna o valor bin�rio que escreve E para a subrotina adiciona
	retlw		B'10000111'					; Retorna o valor bin�rio que escreve 8 para a subrotina adiciona
	
	; 	Nesta subrotina, a m�scara em w, atrav�s da l�gica AND, obt�m o valor de 0 a Fh do nibble menos significativo de
	; disp e adiciona este valor no registrador PCL. O PCL desvia para "disp" comandos a frente. Logo, se foi adicionado
	; 0 no PCL, ele vai para o pr�ximo comando e retorna o bin�rio que escreve zero no display, se for adicionado 8 no 
	; PCL, ele vai para o nono comando e retorna o valor bin�rio que imprime 8 no display, e assim por diante.;	
	

adiciona:	
	
	call 		display						; Desvia para subrotina display
	movwf		PORTB						; PORTB = w, sendo que w � o valor retornado pela subrotina display
	
	return									; Retorna para o loop infinito
	
	
encerra:	
	
	bcf			INTCON,GIE					; Desliga interup��o global
	movlw		H'0F'						; w = 0Fh
	movwf		disp						; Reinicia disp em 0Fh
	
	return									; Retorna para loop infinito
	
	end										; Fim do programa