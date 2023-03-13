;
;		O objetivo deste programa � utilizar o conversor AD do Pic 12F675. Para isso, ser�o configurados os registradores
;	ANSEL, ADCON0 para ligar o ADC, come�ar a leitura e, ainda, configurar o tempo de amostragem.
;		A l�gica do programa ser� feita a partir da leitura de um potenci�metro pelo ADC e um led em GP5. Quando a leitura
;	do ADC for maior que 128, o led apagar�, e quando for menor, o led acender�.
;		Para fazer essa compara��o, ser� utilizado a l�gica AND entre a leitura do ADC e o registrador de uso geral adc,
;	que ser� configurado em 80h = 10000000b = 128d. Logo:
;
;		10000000b = 128d	
;			AND
;		01111111b = 127d
;			=
;		00000000b = 0d
;
;		Logo, todo n�mero abaixo de 128 resultar� em zero pela l�gica and. Resultando em 0, a flag Z do registrador STATUS
;	seta e, a partir da�, ser� feita uma l�gica para acender e apagar o led. Se a flag n�o setar, leitura do ADC � maior
;	que 128 e o led apaga, se Z setar, leitura do ADC menor que 128 e o led acende.
;
;		Na simula��o e na pr�tica o circuito e o programa funcionaram perfeitamente.
;


	list p=12f675							; Informa o microcontrolador utilizado
	
	
; --- Documenta��o ---


	#include	<p12f675.inc>				; Inclui o arquivo que cont�m os registradores do Pic
	
	
; --- Fuse bits ---

	
	__config	_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BOREN_OFF & _CP_OFF & _CPD_OFF
	
	; Configura clock interno de 4MHz sem sa�da de clock em GP4, liga o Power Up Timer e liga o Master Clear
	
	
; --- Pagina��o de mem�ria ---

	
	#define 	bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
	
; --- Mapeamento de hardware ---


	#define 	led		GPIO,5				; Cria mnem�nico para led em GP5
	
	
; --- Registradores de uso geral ---


	cblock		H'20'						; Endere�o de inicio para configura��o de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	tempo									; Auxilia a cria��o de um delay
	adc										; Armazena a leitura de ADC
	
	endc									; Fim da configura��o de registradores de uso geral
	
	
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

inicio:

	bank1									; Seleciona o banco 1 de mem�ria
	bcf			TRISIO,5					; Configura GP5 como sa�da digital
	movlw		H'11'						; w = 11h
	movwf		ANSEL						; Configura AD Clock em Fosc/8 e habilita as entradas anal�gicas
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desablita os comparadores internos
	bsf			ADCON0,ADON					; Liga o conversor AD e configura o canal 0 de convers�o AD
	bcf			led							; Inicia led em Low
	movlw		H'80'
	movwf		adc							; Limpa adc 
	movlw		D'30'						; w = 30d
	movwf		tempo						; tempo = 30d

; -- Loop infinito --

loop:										; Cria label para loop infinito
	
	bsf			ADCON0,GO_DONE				; Inicia leitura do adc
	
espera_leitura:								; Cria label para esperar a leitura do adc

	btfsc		ADCON0,GO_DONE				; Testa se a flag GO_DONE limpou, se sim, pula uma linha
	goto		espera_leitura				; Se n�o limpou, desvia para label espera_leitura
	
	movf		ADRESH,w					; w = ADRESH
	andwf		adc,w						; Faz AND entre adc e w, se resultar em zero, seta a flag Z
	btfsc		STATUS,Z					; Testa se Z � zero, se sim, pula uma linha
	goto		liga_led					; Se Z setou, desvia para label liga_led
	bcf			led							; Apaga led
	goto		continua					; Desvia para label continua
	
liga_led:

	bsf			led
	
continua:

	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	call		_100us						; Espera 100us
	
	; Espera 1ms no total
	
	
goto loop									; Retorna para loop infinito


; --- SubRotinas ---

_100us:

	decfsz		tempo,F						; Decrementa tempo e pula uma linha se chegou a zero
	goto		_100us						; Se n�o chegou, volta para delay_100ms
	
	movlw		D'30'						; w = 30d
	movwf		tempo						; tempo = 30d
	
	return									; Retorna para local onde a subrotina foi chamada


; --- Fim do programa --- 					

end											; Final do programa