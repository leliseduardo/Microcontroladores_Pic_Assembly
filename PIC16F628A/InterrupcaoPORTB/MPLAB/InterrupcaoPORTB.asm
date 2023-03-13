;
;		PIC16F628A		Clock = 4MHz		Ciclo de m�quina = 1us		
;
;		O objetivo deste programa � demonstrar a utiliza��o da interrup��o por mudan�a de estado no portb. Caso este tipo
;	de interrup��o seja habilitada, caso haja qualquer mundan�a de estado em RB7, RB6, RB5 e RB4, ser� gerada uma inter-
;	rup��o. Qualquer mudan�a de estado quer dizer que pode ser tanto uma borda de subida quanto uma borda de descida, 
;	sugerindo, ent�o, que caso esteja entrando uma onda quadrada com determinada frequ�ncia em uma dessas portas, a 
;	frequ�ncia de sa�da, isto �, a frequ�ncia da interrup��o, ser� a mesma da onda de entrada. Logo, a onda de entrada
;	n�o tem sua frequ�ncia dividida, como acontece na interrup��o externa.
;		Caso uma das portas (RB7, RB6, RB5 e RB4) esteja configurada como sa�da digital, o microcontrolador automatica-
;	mente ir� desabilitar a interrup��o nesta porta. Portanto, somente as portas configuradas como entrada digital
;	ir�o gerar a interrup��o por mudan�a de estado.
;
;		Na simula��o o programa funcionou perfeitamente, fazendo com que a sa�da RB1 ficasse em n�vel baixo apenas pelo
;	tempo de lat�ncia da interrup��o.
;


	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclus�o de arquivos ---

	#include 	<p16f628a.inc>				; Inclui o arquivo que cont�m os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Clock em 4MHz, Power Up Timer habilitado e Master Clear Habilitado

; --- Pagina��o de mem�ria ---

	#define 	bank0		bcf	STATUS,RP0	; Cria um mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1		bsf	STATUS,RP0	; Cria um mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnem�nico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnem�nico para led2 em RA2
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Cria registradores de uso geral a partir do endere�o 20h de mem�ria
	
	W_TEMP									; Armazena o conte�do de W temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	
	endc
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o para o vetor de Reset
	
	goto 		inicio						; Desvia programa para label inicio
	
	
; --- Vetor de Interrup��o

	org 		H'0004'						; Origem do endere�o para o vetor de Interrup��o
	
; --- Salvamento de contexto ---

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; --- Fim do salvamento de contexto ---

	; Desenvolvimento da ISR
	
	btfss		INTCON,RBIF					; Testa se a flag RBIF setou, se sim, pula uma linha
	goto 		exit_ISR					; Se n�o, sai da interrup��o
	bcf			INTCON,RBIF					; Limpa RBIF
	
	comf		PORTB						; Complementa portb, somente as sa�das
	
; --- Recupera��o de contexto ---

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (status original)
	movwf		STATUS						; STATUS = w (status original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (w original)	

	retfie
	
; --- Fim da recupera��o de contexto ---


; --- Programa principal ---

inicio:										; Inicia label programa principal


	bank1									; Seleciona o banco 1 de mem�ria
	bsf			OPTION_REG,7				; Habilita os pull-ups internos do portb
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'FD'						; w = FDh
	movwf		TRISB						; TRISB = FDh, configura apenas RB1 como sa�da digital
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'88'						; w = 88h
	movwf		INTCON						; INTCON = 88h, habilita a interrup��o global e a interrup��o por mudan�a de estado no portb
	

loop:										; Inicia loop infinito

	bsf			PORTB,1						; Seta RB1 (muda estado para High)

	goto loop								; Desvia para loop infinito
	
	
	
end 