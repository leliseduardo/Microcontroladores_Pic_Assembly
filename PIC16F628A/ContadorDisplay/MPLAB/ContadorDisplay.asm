;
;		O objetivo deste programa � implementar um contador a partir de dois displays de 7 segmentos multiplexados. Os
;	dois displays ir�o contar de 0 at� 99 a partir do incremento feito por um bot�o ou o decremento feito por outro bo-
;	t�o. Quando chegar a 99 o display volta pra 0 e quando chegar a 0 volta para 99.	
;
;	*** Timer 0 ***
;
;	Overflow = (256 - TMR0) * prescaler * ciclo de m�quina
;	Overflow = 256 * 32 * 1us
;	Overflow = 8,192ms 
;
;		Na pr�tica o programa e o circuito funcionaram perfeitamente
;


	list		p=16f628a						; Informa o microcontrolador utilizado
	
; --- inclus�es ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, habilita o Power Up Timer e habilita o Master Clear

; --- Mapeamento de hardware ---

	#define 	digDez	PORTA,3				; Cria mnem�nico para digDez em RA3
	#define 	digUni	PORTA,2				; Cria mnem�nico para digUni em RA2
	#define 	botao1	PORTA,0				; Cria mnem�nico para botao1 em RA0
	#define		botao2	PORTA,1				; Cria mnem�nico para botao2 em RA1

; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Registradores de uso geral ---

	cblock		H'20'						; In�cio do endere�o para configura��o dos registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	flags									; Flags para testar botoes
	
	bouncingB1a								; Anti bouncing botao 1
	bouncingB1b								; Anti bouncing botao 1 
	bouncingB2a								; Anti bouncing botao 2
	bouncingB2b								; Anti bouncing botao 2
	
	dez										; Dezena do display
	uni										; Unidade do display
	
	endc									; Fim da configura��o dos registradores de uso geral
	
	#define 	flagB1	flags,0				; Cria mnem�nico para flag de teste do botao1
	#define 	flagB2	flags,1				; Cria mnem�nico para flag de teste do botao2
	
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

	btfss		INTCON,T0IF					; Testa se a flag T0IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o, sai da interrup��o
	bcf			INTCON,T0IF					; Limpa a flag T0IF
	
	btfss		digDez						; Testa se o o display das dezenas est� ligado, se estiver, pula uma linha
	goto		apaga_digUni				; Se n�o estiver, desvia para label apaga_digUni
	bcf			digDez						; Desliga display das dezenas
	clrf		PORTB						; Limpa PORTB
	bsf			digUni						; Liga display das unidade
	goto		imprime						; Desvia para label imprime
	
apaga_digUni:
	
	bcf			digUni						; Desliga display das unidades
	clrf		PORTB						; Limpa PORTB
	bsf 		digDez						; Liga display das dezenas
	movf		dez,w						; w = dez
	call		display						; Desvia para subrotina display
	movwf		PORTB						; PORTB = w, imprime no display o valor retornado pela subrotina display
	goto		exit_ISR					; Sai da interrup��o

imprime:

	movf		uni,w						; w = uni
	call 		display						; Desvia para subrotina display
	movwf		PORTB						; PORTB = w, imprime no display o valor retornado pela subrotina display
	
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
	movlw		H'84'						; w = 84h
	movwf		OPTION_REG					; Timer0 incrementa pelo ciclo de m�quina e prescaler em 1:32
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'A0'						; w = C0h
	movwf		INTCON						; Habilita a interrup��o global e a interrup��o do timer0


	clrf		flags						; Limpa flags
	clrf		dez							; Limpa dez
	clrf		uni							; Limpa uni
	movlw		H'FF'						; w = FFh
	movwf		bouncingB1a					; bouncingB1a = FFh
	movlw		H'08'						; w = 08h
	movwf		bouncingB1b					; bouncingB1b = 08h
	movlw		H'FF'						; w = FFh
	movwf		bouncingB2a					; bouncingB1a = FFh
	movlw		H'08'						; w = 08h
	movwf		bouncingB2b					; bouncingB1b = 08h  
	
; --- Loop infinito ---

loop:										; Cria loop infinito
		
	call		press_B1					; Desvia para subrotina press_B1
	call		press_B2					; Desvia para subrotina press_B2
	
	goto		loop						; Desvia para loop infinito
	
; --- Sub Rotinas ---

; ***** Botao 1 *****

press_B1:
	
	btfss		flagB1						; Testa se flagB1 est� setada, se estiver, pula uma linha
	goto		testa_B1					; Se n�o estiver, desvia para label testa_B1
	btfss		botao1						; Testa se botao1 est� solto, se estiver, pula uma linha
	return									; Se estiver pressionado, retorna para loop infinito
	bcf			flagB1						; Limpa flagB1

testa_B1:

	btfsc		botao1						; Testa se botao1 est� pressionado, se estiver, pula uma linha
	goto		recarrega_B1				; Se n�o estiver, desvia para recarrega_B1
	decfsz		bouncingB1a,F				; Decrementa bouncingB1a e testa se chegou a zero, se chegou, pula uma linha
	return									; Se n�o chegou, retorna
	movlw		H'FF'						; w = FFh
	movwf		bouncingB1a					; bouncingB1a = FFh
	decfsz		bouncingB1b,F				; Decrementa bouncingB1b e testa se chegou a zero, se chegou, pula uma linha
	return									; Se n�o chegou, retorna
	movlw		H'08'						; w = 08h
	movwf		bouncingB1b					; bouncingB1b = 08h
	bsf			flagB1						; Seta flagB1
	incf		uni,F						; Incrementa uni
	movlw		H'0A'						; w = 0Ah
	xorwf		uni,w						; Faz XOR entre w e uni, para testar se uni chegou a 0Ah
	btfss		STATUS,Z					; Se chegou, Z seta para 1 e pula uma linha
	return									; Se n�o chegou, retorna
	clrf		uni							; Zera uni
	incf		dez,F						; Incrementa dez 
	movlw		H'0A'						; w = 0Ah
	xorwf		dez,w						; Faz XOR entre w e dez, para testar se dez chegou a 0A
	btfss		STATUS,Z					; Se chegou, seta Z e pula uma linha
	return									; Se n�o chegou, retorna
	clrf		dez							; Zera dez
	return									; Retorna

recarrega_B1:

	movlw		H'FF'						; w = FFh
	movwf		bouncingB1a					; bouncingB1a = FFh
	movlw		H'08'						; w = 08h
	movwf		bouncingB1b					; bouncingB1b = 08h
	return									; Retorna 

; ***** Botao 2 *****

press_B2:

	btfss		flagB2						; Testa se flagB2 est� setada, se estiver, pula uma linha
	goto 		testa_B2					; Se n�o estiver, desvia para testa_B2
	btfss		botao2						; Testa se botao2 est� solto, se estiver, pula uma linha
	return									; Se n�o estiver, retorna
	bcf			flagB2						; Limpa flagB2

testa_B2:

	btfsc		botao2						; Testa se botao2 est� pressionado, se estiver, pula uma linha
	goto		recarrega_B2				; Se n�o estiver, desvia para recarrega_B2
	decfsz		bouncingB2a,F				; Decrementa bouncingB2a e testa se chegou a zero, se chegou, pula uma linha
	return									; Se n�o chegou, retorna
	movlw		H'FF'						; w = FFh
	movwf		bouncingB2a					; bouncingB2a = FFh
	decfsz		bouncingB2b,F					; Decrementa bouncingB2b e testa se chegou a zero, se chegou, pula uma linha
	return									; Se n�o chegou, retorna
	movlw		H'08'						; w = 08h	
	movwf		bouncingB2b					; bouncingB2b = 08h
	bsf			flagB2						; Seta flagB2
	decf		uni,F						; Decrementa uni
	movlw		H'FF'						; w = FFh
	xorwf		uni,w						; Faz XOR entre w e uni, para testar se uni chegou at� FFh
	btfss		STATUS,Z					; Se chegou, seta a flag Z e pula uma linha
	return									; Se n�o chegou, retorna
	movlw		H'09'						; w = 09h
	movwf		uni							; uni = 09h
	decf		dez,F						; Decrementa dez
	movlw		H'FF'						; w = FFh
	xorwf		dez,w						; Faz XOR entre w e dez, para testar se dez chegou a FFh
	btfss		STATUS,Z					; Se chegou, seta a flag Z e pula uma linha
	return									; Se n�o chegou, retorna
	movlw		H'09'						; w = 09h
	movwf		dez							; dez = 09h
	return
	
recarrega_B2:

	movlw		H'FF'						; w = FFh
	movwf		bouncingB2a					; bouncingB1a = FFh
	movlw		H'08'						; w = 08h
	movwf		bouncingB2b					; bouncingB1b = 08h
	return	

; ***** Display ****

display:

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
	

	
	
	end										; Fim do programa