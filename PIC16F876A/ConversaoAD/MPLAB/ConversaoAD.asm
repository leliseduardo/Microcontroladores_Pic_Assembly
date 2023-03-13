;
;		Este programa tem o objetivo de fazer a leitura do canal 0 do conversor AD, com justifica��o a direita. Por isso,
;	� feita uma manipula��o com os registradores mais e menos significativos do conversor AD para se conseguir manipular
;	o valor lido. 
;		Quando se justifica a leitura a direita, o valor lido fica da seguinte forma:
;		
;		ADRESH 				ADRESL					|			ADRESH		ADRESL  } Caso a leitura fosse justificada
;      00000011			   11111111					|		   11111111	   11000000 } a esquerda
;
;		Os bits em 1 s�o os valor lidos, sendo que os dois mais significativos ficam em ADRESH e os menos significativos
;	em ADRESL.
;		Para se ter o valor lido, desprezando os dois bits menos significativos, manipula-se o valor para ficar 
;	armazenado todo em um s� registrador de 8 bits.
;		Para isso, rotaciona-se 6 vezes os bits lidos em ADRESH para esquerda, enquanto rotaciona-se 2 vezes os bits lidos
; 	em ADRESL para a direita, resultando em:
;
;		ADRESH 				ADRESL
;      11000000			   00111111
;
;		Somando estes dois valores e armazenando em uma vari�vel, que foi chamada de adc, obt�m-se:
;
;		adc = ADRESH + ADRESL = 111111111
;
;		No c�digo, quando se faz a rota��o dos bits, coloca-se a flag C do registrador STATUS em 0. Isso quer dizer que
;	o carry � zero. O resultado disso � que a rota��o a direita ou esquerda vira, na verdade, um shift right ou left,
;	respectivamente. O carry em zero n�o permite que os bits d�em a volta no registrador, e sim que somente se movam para
;	a dire��o desejada. Caso o carry n�o fosse colocado em zero, e houvesse a rota��o pura ao inv�s do shift, o registra-
;	dor ADRESL, neste exemplo, resultaria:
;		
;		ADRESL 
;	   11111111
;			
;		ADRESL Rotacionado 2x � direita com carry igual a 1
;	   11111111 , isto �, os bits deram a volta no registrador
;
;		ADRESL Rotacionado 2x � direita com carry igual a 0
;	   00111111 , isto �, os bits apenas se moveram para direita, sem dar a volta no registrador ADRESL
;
;		O programa consiste basicamente em usar uma subrotina para configurar os registradores do ADC, uma outra sub-
;	rotina para ler o ADC e rotacionar o valor lido nos registradores mais e menos significativos, colocando o resultado
;	da soma dos dois na vari�vel adc e, no loop infinito chamar a subrotina de leitura. No loop infinito, o resultado da
; 	leitura contido na vari�vel adc � passado ao PORTB.  
;		
;		No debug o programa funcionou como esperado.
;

	list p=16f876a							; Informa o microcontrolador utilizado
	
	
; --- Documenta��o ---


	#include	<p16f876a.inc>				; Inclui o arquivo que cont�m os registradores do Pic
	
	
; --- Fuse bits ---

	
	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF  & _CP_OFF & _CPD_OFF
	
	; Configura clock  4MHz, liga o Power Up Timer e desliga o Master Clear
	
	
; --- Pagina��o de mem�ria ---

	
	#define 	bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
	
; --- Mapeamento de hardware ---


	
	
; --- Registradores de uso geral ---


	cblock		H'20'						; Endere�o de inicio para configura��o de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	adc										; Armazena a leitura de ADC
	
	endc									; Fim da configura��o de registradores de uso geral
	
	cont1		equ		H'23'				; Contador auxiliar no banco 0 de mem�ria
	cont2		equ		H'A1'				; Contador auxiliar no banco 1 de mem�ria
	
; --- Vetor de Reset ---

	
	org			H'0000'						; Endere�o de origem do vetor de Reset
	
	goto 		inicio						; Desvia para o programa principal	
	
	
; --- Vetor de Interrup��o ---

	
	org			H'0004'						; Endere�o de origem do vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto

	; Desenvolvimento da ISR...
	
	
; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; W_TEMP = w (original)
	
	retfie									; Retorna para o endere�o que estava quando ocorreu a interrup��o
	
; -- Fim da recupera��o de contexto --


; --- Programa principal ---

inicio:										; Cria label do programa principal

	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'FF'						; w = FF
	movwf		TRISA						; Configura todo PORTA como entrada
	movlw		H'00'						; w = 00
	movwf		TRISB						; Configura todo PORTB como sa�da digital
	call 		configura_ADC				; Chama subrotina configura_ADC


; -- Loop infinito --

loop:										; Cria label para loop infinito

	call		leitura_ADC					; Chama a subrotina leitura_ADC
	movf		adc,w						; w = adc
	movwf		PORTB						; PORTB = w = adc	

	goto		loop						; Desvia para loop infinito
	
	
	
; --- SubRotinas ---

leitura_ADC:								; Cria subrotina para leitura do ADC

	bank0									; Seleciona o banco 0 de mem�ria
	bsf			ADCON0,2					; Come�a a leitura do adc
	
espera_leitura:

	btfsc		ADCON0,2					; Testa se a flag GO_DONE j� limpou, se j�, pula uma linha
	goto		espera_leitura				; Se n�o limpou, desvia para label espera_leitura
	
	movlw		H'06'						; w = 06h
	movwf		cont1						; cont1 = 06h
	
rotaciona:									; Cria label rotaciona

	bcf			STATUS,C					; Limpa flag C de STATUS
	rlf			ADRESH,F					; Rotaciona conte�do de ADRESH para esquerda
	decfsz		cont1						; Decrementa cont1 e testa se j� chegou a zero, se chegou, pula uma linha
	goto		rotaciona					; Se n�o chegou a zero, desvia para label rotaciona
	
	movf		ADRESH,w					; w = ADRESH
	movwf		adc							; adc = w = ADRESH
	
	
	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'02'						; w = 02h
	movwf		cont2						; cont2 = 02h
	
	
rotaciona2:									; Cria label rotaciona2

	bcf			STATUS,C					; Limpa flag C de STATUS
	rrf			ADRESL,F					; Rotaciona conte�do de ADRESL para direita
	decfsz		cont2						; Decrementa cont2 e testa se j� chegou a zero, se chegou, pula uma linha
	goto		rotaciona2					; Se n�o chegou a zero, desvia para label rotaciona2
	
	movf		ADRESL,w					; w = ADRESL
	
	bank0									; Seleciona o banco 0 de mem�ria
	addwf		adc							; adc + w = ADRESL + ADRESH
		
		
	return									; Retorna para o endere�o onde a subrotina foi chamada







configura_ADC:

	bank1									; Seleciona o banco 1 de mem�ria
	movlw		H'80'						; w = 80
	movwf		ADCON1						; Justificado a direita, Fosc/8, todos os pinos anal�gicos habilitados
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'41'						; w = 41h
	movwf		ADCON0						; Fosc/8, canal 0 de convers�o e liga o conversor AD
	
	return									; Retorna para endere�o onde a subrotina foi chamada

; --- Fim do programa ---

	end										; Final do programa