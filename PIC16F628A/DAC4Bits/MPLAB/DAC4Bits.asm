;
;		O objetivo deste programa � configurar um DAC (conversor digital anal�gico) a partir da tens�o de refer�ncia 
;	interna do Pic, configurada como sa�da pelo pino RA2. Para variar a tens�o, ser� utilizada o PORTB para todo para 
;	manter fixo o primeiro nibble do registrador VRCON e variar o segundo.
;		VRCON tem que manter o primeiro nibble fixo em Eh, e variar o segundo nibble, para varia a tens�o de refer�ncia. 
;	Assim, ser�o utilizadas 4 chaves dip switch para variar o segundo nibble do PORTB, igualando VRCON � PORTB.
;		Para usar as chaves dip switch ser�o habilitados os resistores de pull-up do PORTB. 
;
;		Na simula��o o circuito funcionou perfeitamente.
;


	list 		p=16f628a					; Informa o microcontrolador utilizado
	
	
; --- Documenta��o ---

	#include	<p16f628a.inc> 				; Inclui o documento com os registradores do Pic
	

; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura oscilador de 4MHz, Power Up Timer ligado e Master Clear Ligado


; --- Pagina��o de mem�ria ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar banco 1 de mem�ria
	
; --- Mapeamento de hardware --- 

	#define 	led1	PORTB,0				; Cria mnem�nico para led1 em RB0
	#define 	botao1	PORTB,7				; Cria mnem�nico para botao1 em RB7
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o de inicio de configura��o de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	endc									; Fim da configura��o dos registradores de uso geral
	
; --- Vetor de Reset --- 

	org			H'0000'						; Origem do endere�o de m�moria do vetor de Reset
	
	goto		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrup��o	---

	org 		H'0004'						; Origem do endere�o de mem�ria do vetor de Interrup��o
	
; -- Salvamento de contexto --

exit_ISR:									; Cria label para sair da interrup��o

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Volta para o endere�o de mem�ria que estava quando interrompeu
	
; -- Fim do salvamento de contexto --

	
	; Desenvolvimento da ISR...
	
	


; -- Recupera��o de contexto --

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
; -- Fim da recupera��o de contexto --


; --- Programa principal ---

inicio:										; Cria��o da label do programa principal

	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada digital
	movlw		H'EF'						; w = EFh
	movwf		TRISB						; Configura apenas RB4 como sa�da digital, o resto como entrada
	movlw		H'7F'						; w = 7Fh
	movwf		OPTION_REG					; Habilita os pull-ups internos do PORTB
	movlw		H'E0'						; w = E0h
	movwf		VRCON						; Liga tens�o de refer�ncia, sa�da em RA2, Low Range e inicia tens�o em 0V 
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	bcf			PORTB,4						; Inicia RB4 em Low
	

loop:										; Cria��o da label de loop infinito

	bank0									; Seleciona banco 0 de mem�ria
	movf		PORTB,w						; w = PORTB
	bank1									; Seleciona banco 1 de mem�ria
	movwf		VRCON						; VRCON = PORTB

	goto loop								; Desvia para label de loop infinito
	
	
	
	
; --- Fim do programa ---


	end										; Final do programa