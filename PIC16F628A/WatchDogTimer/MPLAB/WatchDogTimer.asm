;
;		O objetivo deste programa � demonstrar uma utiliza��o simples do Watch Dog Timer. O programa ir� piscar um led
;	atrav�s do loop infinito e, se um bot�o for pressionado, o programa desvia para um label que prender o programa. 
;	Como o Watch Dog Timer tem seu incremento zerado apenas no loop infinito, quando o programa ficar preso na outra
;	label, isso ser� enetendido como "Erro" ou "Bug" pelo WTD, que ir� reiniciar o programa.
;		A fun��o do Watch Dog Timer � reiniciar o programa caso haja algum bug de c�digo, mal funcionamento do c�digo,
;	mal funcionamento por algum defeito no circuito, no Pic ou at� interfer�ncias externas no circuito. Ele conta com um
;	contador, que � semelhante aos timers do Pic. Esse contador, quando o WDT est� ativado, conta at� um certo valor 
;	m�nimo e, ao alcan�ar este valor, estoura e reinicia o programa. Logo, quando o WDT est� ativado, ele deve ser limpo
;	via software de tempos em tempos, para n�o estourar e n�o reiniciar o programa de forma indesejada.
;		O tempo de estouro padr�o do Watch Dog Timer � 18ms no m�nimo, mas esse tempo pode ser aumentado configurando o 
;	prescaler de 1:1 at� 1:128. Os prescalers acima de 1:1 multiplicam os 18ms pelo prescaler configurado.
;		O Watch Dog Timer tamb�m � uma alternativa de reiniciar o programa via software, o que � muito �til em algumas
;	aplica��es.
;
;		Na simula��o o programa e o circuito funcionaram perfeitamente, alternando a sa�da RA3 e, quando o bot�o � pres-
;	sionado, o programa traba com RA2 ligado. Ap�s +- 1,15 segundo, que foi o WDT programado, o programa reinicia, apaga
;	RA2 e volta a alternar RA3.
;		Na pr�tica o programa e o circuito tamb�m funcionaram, mas sem o oscilosc�pio n�o d� para ver o led em RA3 
;	alternando, pois esta sa�da alterna sem delay, portanto, na valocidade dos ciclos de m�quina, na ordem dos us.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Documenta��o ---

	#include	<p16f628a.inc>				; Inclui o documento que cont�m os registradores do Pic
	
	
; --- Fuse bits	---
	
	__config	_XT_OSC & _WDT_ON & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura clock em 4MHz, liga o WatchDog Timer, liga o Power Up Timer e liga o Master Clear

; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Mapeamento de hardware ---

	#define		led1	PORTA,3				; Cria mnem�nico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnem�nico para led2 em RA2
	#define 	botao1	PORTB,0				; Cria mnem�nico para botao1 em RB0
	#define 	botao2	PORTB,1				; Cria mnem�nico para botao2 em RB1
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o para in�cio de configura��es de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de W temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	
	endc									; Fim da configura��o de registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o do vetor de Reset
	
	goto		inicio						; Desvia para programa principal
	
; --- Vetor de Interrup��o ---	

	org 		H'0004'						; Origem do endere�o do vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de mem�ria --

	; Desenvolvimento da ISR...
	
	
; -- Recupera��o de contexto -- 

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS(com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Sai da interrup��o, volta para o endere�o do mem�ria onde foi interrompido

; -- Fim da recupera��o de contexto --

; --- Programa principal

inicio:

	bank1									; Seleciona o banco 1 de mem�ria
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; Configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'FF'						; w = FFh
	movwf		TRISB						; Configura todo portb como entrada digital
	movlw		H'8E'						; w = 8Eh
	movwf		OPTION_REG					; Configura o prescaler associado ao WDT, em 1:64
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'F3'						; w = F3h
	movwf		PORTA						; Inicia RA3 e RA2 em Low
	

; --- Loop infinito ---

loop:										; Cria label para loop infinito

	clrwdt									; Limpa a contagem do Watch Dog Timer
	movlw		H'08'						; w = 08h
	xorwf		PORTA						; Faz l�gica XOR entre w e PORTA para mudar estado de RA3
	btfss		botao1						; Testa se o bot�o est� solto, se estiver, pula uma linha
	goto		trava_Programa				; Se n�o estiver, desvia para label trava_Programa

goto loop									; Desvia para loop infinito

trava_Programa:

	bsf			led2						; Acende led1
	goto		$							; Desvia para este mesmo endere�o, neste mesmo comando, trava o programa


; --- Final do programa ---

end 										; Final do programa