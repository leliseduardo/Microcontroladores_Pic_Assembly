;
;		PIC16F628A		Clock = 4MHz		Ciclo de máquina = 1us		
;
;		O objetivo deste programa é demonstrar a utilização da interrupção por mudança de estado no portb. Caso este tipo
;	de interrupção seja habilitada, caso haja qualquer mundança de estado em RB7, RB6, RB5 e RB4, será gerada uma inter-
;	rupção. Qualquer mudança de estado quer dizer que pode ser tanto uma borda de subida quanto uma borda de descida, 
;	sugerindo, então, que caso esteja entrando uma onda quadrada com determinada frequência em uma dessas portas, a 
;	frequência de saída, isto é, a frequência da interrupção, será a mesma da onda de entrada. Logo, a onda de entrada
;	não tem sua frequência dividida, como acontece na interrupção externa.
;		Caso uma das portas (RB7, RB6, RB5 e RB4) esteja configurada como saída digital, o microcontrolador automatica-
;	mente irá desabilitar a interrupção nesta porta. Portanto, somente as portas configuradas como entrada digital
;	irão gerar a interrupção por mudança de estado.
;
;		Na simulação o programa funcionou perfeitamente, fazendo com que a saída RB1 ficasse em nível baixo apenas pelo
;	tempo de latência da interrupção.
;


	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclusão de arquivos ---

	#include 	<p16f628a.inc>				; Inclui o arquivo que contém os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Clock em 4MHz, Power Up Timer habilitado e Master Clear Habilitado

; --- Paginação de memória ---

	#define 	bank0		bcf	STATUS,RP0	; Cria um mnemônico para selecionar o banco 0 de memória
	#define		bank1		bsf	STATUS,RP0	; Cria um mnemônico para selecionar o banco 1 de memória
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnemônico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnemônico para led2 em RA2
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Cria registradores de uso geral a partir do endereço 20h de memória
	
	W_TEMP									; Armazena o conteúdo de W temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	
	endc
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endereço para o vetor de Reset
	
	goto 		inicio						; Desvia programa para label inicio
	
	
; --- Vetor de Interrupção

	org 		H'0004'						; Origem do endereço para o vetor de Interrupção
	
; --- Salvamento de contexto ---

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; --- Fim do salvamento de contexto ---

	; Desenvolvimento da ISR
	
	btfss		INTCON,RBIF					; Testa se a flag RBIF setou, se sim, pula uma linha
	goto 		exit_ISR					; Se não, sai da interrupção
	bcf			INTCON,RBIF					; Limpa RBIF
	
	comf		PORTB						; Complementa portb, somente as saídas
	
; --- Recuperação de contexto ---

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (status original)
	movwf		STATUS						; STATUS = w (status original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (w original)	

	retfie
	
; --- Fim da recuperação de contexto ---


; --- Programa principal ---

inicio:										; Inicia label programa principal


	bank1									; Seleciona o banco 1 de memória
	bsf			OPTION_REG,7				; Habilita os pull-ups internos do portb
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura apenas RA3 e RA2 como saídas digitais
	movlw		H'FD'						; w = FDh
	movwf		TRISB						; TRISB = FDh, configura apenas RB1 como saída digital
	bank0									; Seleciona o banco 0 de memória
	movlw		H'88'						; w = 88h
	movwf		INTCON						; INTCON = 88h, habilita a interrupção global e a interrupção por mudança de estado no portb
	

loop:										; Inicia loop infinito

	bsf			PORTB,1						; Seta RB1 (muda estado para High)

	goto loop								; Desvia para loop infinito
	
	
	
end 