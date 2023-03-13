;
;		O objetivo deste programa é configurar um DAC (conversor digital analógico) a partir da tensão de referência 
;	interna do Pic, configurada como saída pelo pino RA2. Para variar a tensão, será utilizada o PORTB para todo para 
;	manter fixo o primeiro nibble do registrador VRCON e variar o segundo.
;		VRCON tem que manter o primeiro nibble fixo em Eh, e variar o segundo nibble, para varia a tensão de referência. 
;	Assim, serão utilizadas 4 chaves dip switch para variar o segundo nibble do PORTB, igualando VRCON à PORTB.
;		Para usar as chaves dip switch serão habilitados os resistores de pull-up do PORTB. 
;
;		Na simulação o circuito funcionou perfeitamente.
;


	list 		p=16f628a					; Informa o microcontrolador utilizado
	
	
; --- Documentação ---

	#include	<p16f628a.inc> 				; Inclui o documento com os registradores do Pic
	

; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura oscilador de 4MHz, Power Up Timer ligado e Master Clear Ligado


; --- Paginação de memória ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar banco 1 de memória
	
; --- Mapeamento de hardware --- 

	#define 	led1	PORTB,0				; Cria mnemônico para led1 em RB0
	#define 	botao1	PORTB,7				; Cria mnemônico para botao1 em RB7
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endereço de inicio de configuração de registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	endc									; Fim da configuração dos registradores de uso geral
	
; --- Vetor de Reset --- 

	org			H'0000'						; Origem do endereço de mémoria do vetor de Reset
	
	goto		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrupção	---

	org 		H'0004'						; Origem do endereço de memória do vetor de Interrupção
	
; -- Salvamento de contexto --

exit_ISR:									; Cria label para sair da interrupção

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Volta para o endereço de memória que estava quando interrompeu
	
; -- Fim do salvamento de contexto --

	
	; Desenvolvimento da ISR...
	
	


; -- Recuperação de contexto --

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
; -- Fim da recuperação de contexto --


; --- Programa principal ---

inicio:										; Criação da label do programa principal

	bank1									; Seleciona banco 1 de memória
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada digital
	movlw		H'EF'						; w = EFh
	movwf		TRISB						; Configura apenas RB4 como saída digital, o resto como entrada
	movlw		H'7F'						; w = 7Fh
	movwf		OPTION_REG					; Habilita os pull-ups internos do PORTB
	movlw		H'E0'						; w = E0h
	movwf		VRCON						; Liga tensão de referência, saída em RA2, Low Range e inicia tensão em 0V 
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	bcf			PORTB,4						; Inicia RB4 em Low
	

loop:										; Criação da label de loop infinito

	bank0									; Seleciona banco 0 de memória
	movf		PORTB,w						; w = PORTB
	bank1									; Seleciona banco 1 de memória
	movwf		VRCON						; VRCON = PORTB

	goto loop								; Desvia para label de loop infinito
	
	
	
	
; --- Fim do programa ---


	end										; Final do programa