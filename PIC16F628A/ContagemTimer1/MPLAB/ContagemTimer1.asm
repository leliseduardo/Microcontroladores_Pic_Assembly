;
;		O objetivo deste programa é entender, através do debug, a contagem de 16 bits do timer1. Entender como os dois
;	registradores de 8 bits incrementam e como estouram.
;
;		No debug, o programa funcionou como esperado, e foi possível compreender melhor o funcionamento do timer1, assim 
;	como sua contagem de 16 bits através de dois registradores de 8 bits.
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
	
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS_TEMP (com nibbles reinvertidos = STATUS original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos = w original)
	
	retfie									; Volta para execução principal

; -- Fim da recuperação de contexto --

inicio:

	nop
	nop
	nop
	nop
	
	movlw		H'01'						; w = 01h
	movwf		T1CON						; Configura prescaler 1:1, incrementa com ciclo de máquina e ativa timer1
	
	nop
	nop
	nop
	nop


goto			$							; Programa fica preso neste endereço


end											; Fim do programa 