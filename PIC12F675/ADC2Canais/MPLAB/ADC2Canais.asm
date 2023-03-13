;
;		O objetivo deste programa é utilizar dois canais analógicos do Pic 12F675. Para isso será configurado a flag
;	CHS0, do registrador ADCON0 para ora ler o canal 0 e ora ler o canal 1.
;		Como o professor falou e demonstrou, este tipo de comutação pode gerar erros de leitura, fazendo com que um canal
;	interfira no outro, pelo motivo, segundo ele, do tempo de aquisição. O professor disse ainda que este assunto será
;	abordado nas próximas aulas.
;
;		Na simulação e na prática o programa e o circuito funcionaram como esperado. O programa apresentou o mesmo erro
;	demonstrado pelo professor, que consiste em um ADC interferir no outro.
;


	list p=12f675							; Informa o microcontrolador utilizado
	
	
; --- Documentação ---


	#include	<p12f675.inc>				; Inclui o arquivo que contém os registradores do Pic
	
	
; --- Fuse bits ---

	
	__config	_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BOREN_OFF & _CP_OFF & _CPD_OFF
	
	; Configura clock interno de 4MHz sem saída de clock em GP4, liga o Power Up Timer e liga o Master Clear
	
	
; --- Paginação de memória ---

	
	#define 	bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define		bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
	
; --- Mapeamento de hardware ---


	#define 	led1		GPIO,5				; Cria mnemônico para led em GP5
	#define 	led2		GPIO,4				; Cria mnemônico para led em GP5
	
; --- Registradores de uso geral ---


	cblock		H'20'						; Endereço de inicio para configuração de registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	tempo									; Auxilia a criação de um delay
	adc										; Armazena a leitura de ADC
	
	endc									; Fim da configuração de registradores de uso geral
	
	
; --- Vetor de Reset ---

	
	org			H'0000'						; Endereço de origem do vetor de Reset
	
	goto 		inicio						; Desvia para o programa principal	
	
	
; --- Vetor de Interrupção ---

	
	org			H'0004'						; Endereço de origem do vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto

	; Desenvolvimento da ISR...
	
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; W_TEMP = w (original)
	
	retfie									; Retorna para o endereço que estava quando ocorreu a interrupção
	
; -- Fim da recuperação de contexto --


; --- Programa principal ---

inicio:

	bank1									; Seleciona o banco 1 de memória
	bcf			TRISIO,5					; Configura GP5 como saída digital
	bcf			TRISIO,4					; Configura GP4 como saída digital
	movlw		H'61'						; w = 61h
	movwf		ANSEL						; Configura AD Clock em Fosc/64 e habilita as entradas analógicas
	bank0									; Seleciona o banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desablita os comparadores internos
	bsf			ADCON0,ADON					; Liga o conversor AD e configura o canal 0 de conversão AD
	bcf			led1						; Inicia led1 em Low
	bcf			led2						; Inicia led2 em Low
	movlw		H'80'						; w = 80h
	movwf		adc							; adc = 80h 
	movlw		D'30'						; w = 30d
	movwf		tempo						; tempo = 30d

; -- Loop infinito --

loop:										; Cria label para loop infinito
	
	bcf			ADCON0,CHS0					; Seleciona canal 0 do conversor AD
	call		leitura_adc					; Chama a subrotina leitura_adc
	andwf		adc,w						; Faz AND entre adc e w, se resultar em zero, seta a flag Z
	btfsc		STATUS,Z					; Testa se Z é zero, se sim, pula uma linha
	goto		liga_led1					; Se Z setou, desvia para label liga_led1
	bcf			led1						; Apaga led1
	goto		continua					; Desvia para label continua
	
liga_led1:

	bsf			led1
	
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
	
	bsf			ADCON0,CHS0					; Seleciona canal 1 do conversor AD
	call		leitura_adc					; Chama a subrotina leitura_adc
	andwf		adc,w						; Faz AND entre adc e w, se resultar em zero, seta a flag Z
	btfsc		STATUS,Z					; Testa se Z é zero, se sim, pula uma linha
	goto		liga_led2					; Se Z setou, desvia para label liga_led2
	bcf			led2						; Apaga led2
	goto		continua2					; Desvia para label continua2
	
liga_led2:									; Cria label liga_led2

	bsf			led2						; Liga led2
	
continua2:

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


; --- Rotina de leitura do adc ---

leitura_adc:								; Cria label para ler o adc
	
	bsf			ADCON0,GO_DONE				; Inicia leitura do adc
	
espera_leitura:

	btfsc		ADCON0,GO_DONE				; Testa se a flag GO_DONE limpou, se sim, pula uma linha
	goto		espera_leitura				; Se não limpou, desvia para label espera_leitura
	
	movf		ADRESH,w					; w = ADRESH

	return									; Retorna para o endereço onde esta subrotina foi chamada
	
	
; --- Fim da rotina de leitura do adc ---
	
; --- Rotina de delay ---

_100us:

	decfsz		tempo,F						; Decrementa tempo e pula uma linha se chegou a zero
	goto		_100us						; Se não chegou, volta para delay_100ms
	
	movlw		D'30'						; w = 30d
	movwf		tempo						; tempo = 30d
	
	return									; Retorna para local onde a subrotina foi chamada


; --- Fim de rotina de delay ---


; --- Fim do programa --- 					

end											; Final do programa