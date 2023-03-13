;
;		Este programa tem a função de criar um timer regressivo a partir do uso do display de 7 segmentos. Para isso, 
;	utiliza-se o código da aula passada, denominada "Display7Segmentos", fazendo apenas algumas alterações.
;		O programa irá iniciar com a interrupão desligada e, quando um botão for pressionado, o display irá decrementar
;	e, quando chegar a zero, a interrupção será novamente desligada e um led irá se acender.
;		Este é um princípio de um temporiazador para alguma função prática. O led pode ser um relé que controla algum
;	atuador, que aciona por determinado tempo quando um botão é pressionado ou quando um sensor aciona ou chega a 
;	determinado valor. 
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
;							   200ms
;	<TMR1H::TMR1L> = 65536 - --------- = 15536
;							  4 * 1us
;
;	<TMR1H::TMR1L> = 15536d = 3CB0h
;
;	TMR1H = 3Ch
;	TMR1L = B0h		
;
;		Na simulação e na prática o circuito e o programa funcionaram como esperado
;

	list		p=16f628a						; Informa o microcontrolador utilizado
	
; --- inclusões ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, habilita o Power Up Timer e habilita o Master Clear

; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnemônico para led1 em RA3
	#define 	led2	PORTA,2				; Cria mnemônico para led2 em RA2
	#define 	botao1	PORTB,4				; Cria mnemônico para botao1 em RB0

; --- Paginação de memória ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Início do endereço para configuração dos registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	cont									; Contador para base de tempo do timer1
	disp									; Contador que incrementa o display
	
	endc									; Fim da configuração dos registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endereço do vetor de Reset
	
	goto		inicio						; Desvia para label inicio, programa principal
	
; Vetor de Interrupção

	org 		H'0004'						; Origem do endereço do vetor de Reset
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...

; -- 200ms --
	
	btfss		PIR1,TMR1IF					; Testa se a flag TMR1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não, sai da interrupção
	bcf			PIR1,TMR1IF					; Limpa a flag TMR1IF
	movlw		H'3C'						; w = 3Ch;
	movwf		TMR1H						; reinicia TMR1H = 3Ch
	movlw		H'B0'						; w = B0h;
	movwf		TMR1L						; reinicia TMR1L = B0h				
	
; -- 200ms --

; -- 1s --

	incf		cont,F						; Incrementa cont
	movlw		H'05'						; w = 05h
	xorwf		cont,w						; Faz lógica XOR para testar se cont já chegou a 05h, se chegou resulta em 0
	btfss		STATUS,Z					; Se resultou em zero, a flag Z seta e pula uma linha
	goto		exit_ISR					; Se não resultou em zero, cont ainda não chegou em 05h e sai da interrupção
	
	clrf		cont						; Limpa cont
	decfsz		disp,F						; Decrementa disp e pula uma linha quando chegar a zero
	goto		exit_ISR					; Enquanto disp não chegar a zero, sai da interrupção
	bsf			led1						; Acende led1
	
; -- 1s --
	
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (com nibbles reinvertidos, isto é, STATUS original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos, isto é, w original)
	
	retfie									; Retorna para execução principal
	
; -- Fim da recuperação de contexto -- 


; --- Programa principal ---

inicio:

	bank1									; Seleciona banco 1 de memória
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; Configura apenas RA3 e RA2 como saídas digitais
	movlw		H'10'						; w = 10h
	movwf		TRISB						; Configura todo portb como saída digital, exceto RB4
	bsf			PIE1,TMR1IE					; Habilita a interrupção por overflow do timer1
	bank0									; Seleciona o banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'40'						; w = C0h
	movwf		INTCON						; Desliga a interrupção global e e habilita a interrupção por periféricos
	movlw		H'21'						; w = 21h
	movwf		T1CON						; liga o timer1, prescaler em 1:4, incrementa pelo ciclo de máquina 
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
	goto		auxiliar					; Se não foi pressionado, desvia para label auxiliar
	bsf			INTCON,GIE					; Liga a interrupção global
	bcf			led1						; Apaga led1
	
auxiliar:

	call		adiciona					; Desvia para label adiciona
	btfsc		led1						; Testa se o led1 está ligado, se NÃO estiver, pula uma linha
	call		encerra						; Se led1 estiver ligado, encerra o programa
		
	goto		loop						; Desvia para loop infinito
	
; --- Sub Rotinas ---

display:

	movlw		H'0F'						; w = H'0F', cria a máscara para o contador disp
	andwf		disp,w						; Faz lógica AND entra w e disp e o resultado são os bits do nibble menos
											; significativo, guardado em w. O resultado varia de 0 a Fh
	addwf		PCL,F						; Adiciona em PCL o valor de 0 a Fh do nibble menos sig. de disp, fazendo com
											; que haja um desvio condicional para "disp" comandos a frente
	
	; Display	  EDC.BAFG
		
	retlw		B'11101110'					; Retorna o valor binário que escreve 0 para a subrotina adiciona
	retlw		B'00101000'					; Retorna o valor binário que escreve 1 para a subrotina adiciona
	retlw		B'11001101'					; Retorna o valor binário que escreve 2 para a subrotina adiciona
	retlw		B'01101101'					; Retorna o valor binário que escreve 3 para a subrotina adiciona
	retlw		B'00101011'					; Retorna o valor binário que escreve 4 para a subrotina adiciona
	retlw		B'01100111'					; Retorna o valor binário que escreve 5 para a subrotina adiciona
	retlw		B'11100111'					; Retorna o valor binário que escreve 6 para a subrotina adiciona
	retlw		B'00101100'					; Retorna o valor binário que escreve 7 para a subrotina adiciona
	retlw		B'11101111'					; Retorna o valor binário que escreve 8 para a subrotina adiciona
	retlw		B'01101111'					; Retorna o valor binário que escreve 9 para a subrotina adiciona
	retlw		B'10101111'					; Retorna o valor binário que escreve A para a subrotina adiciona
	retlw		B'11100011'					; Retorna o valor binário que escreve b para a subrotina adiciona
	retlw		B'11000110'					; Retorna o valor binário que escreve C para a subrotina adiciona
	retlw		B'11101001'					; Retorna o valor binário que escreve d para a subrotina adiciona
	retlw		B'11000111'					; Retorna o valor binário que escreve E para a subrotina adiciona
	retlw		B'10000111'					; Retorna o valor binário que escreve 8 para a subrotina adiciona
	
	; 	Nesta subrotina, a máscara em w, através da lógica AND, obtém o valor de 0 a Fh do nibble menos significativo de
	; disp e adiciona este valor no registrador PCL. O PCL desvia para "disp" comandos a frente. Logo, se foi adicionado
	; 0 no PCL, ele vai para o próximo comando e retorna o binário que escreve zero no display, se for adicionado 8 no 
	; PCL, ele vai para o nono comando e retorna o valor binário que imprime 8 no display, e assim por diante.;	
	

adiciona:	
	
	call 		display						; Desvia para subrotina display
	movwf		PORTB						; PORTB = w, sendo que w é o valor retornado pela subrotina display
	
	return									; Retorna para o loop infinito
	
	
encerra:	
	
	bcf			INTCON,GIE					; Desliga interupção global
	movlw		H'0F'						; w = 0Fh
	movwf		disp						; Reinicia disp em 0Fh
	
	return									; Retorna para loop infinito
	
	end										; Fim do programa