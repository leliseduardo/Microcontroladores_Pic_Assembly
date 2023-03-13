;
;		O objetivo deste programa é multiplexar dois displays de 7 segmentos, isto é, num tempo muito rápidos alternar
;	entre o acionamento de ambos, de forma que os dois aparentem estar permanentemente ligados.
;		Para fazer a multiplexação, será usado o timer0 com tempo de overflow calculado abaixo.
;
;	*** Timer 0 ***
;
;	Overflow = (256 - TMR0) * prescaler * ciclo de máquina
;	Overflow = 256 * 32 * 1us
;	Overflow = 8,192ms 
;
;		Na prática o programa funcionou como esperado
;


	list		p=16f628a						; Informa o microcontrolador utilizado
	
; --- inclusões ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, habilita o Power Up Timer e habilita o Master Clear

; --- Mapeamento de hardware ---

	#define 	digDez	PORTA,3				; Cria mnemônico para led1 em RA3
	#define 	digUni	PORTA,2				; Cria mnemônico para led2 em RA2
	#define 	botao1	PORTB,4				; Cria mnemônico para botao1 em RB0

; --- Paginação de memória ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Início do endereço para configuração dos registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	dez										; Dezena do display
	uni										; Unidade do display
	
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

	btfss		INTCON,T0IF					; Testa se a flag T0IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não, sai da interrupção
	bcf			INTCON,T0IF					; Limpa a flag T0IF
	
	btfss		digDez						; Testa se o o display das dezenas está ligado, se estiver, pula uma linha
	goto		apaga_digUni				; Se não estiver, desvia para label apaga_digUni
	bcf			digDez						; Desliga display das dezenas
	clrf		PORTB						; Limpa PORTB
	bsf			digUni						; Liga display das unidade
	goto		imprime						; Desvia para label imprime
	
apaga_digUni:
	
	bcf			digUni						; Desliga display das unidades
	clrf		PORTB						; Limpa PORTB
	bsf 		digDez						; Liga display das dezenas
	movf		dez,w						; w = dez
	call		display						; Desvia para subrotina display
	movwf		PORTB						; PORTB = w, imprime no display o valor retornado pela subrotina display
	goto		exit_ISR					; Sai da interrupção

imprime:

	movf		uni,w						; w = uni
	call 		display						; Desvia para subrotina display
	movwf		PORTB						; PORTB = w, imprime no display o valor retornado pela subrotina display
	
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
	movlw		H'84'						; w = 84h
	movwf		OPTION_REG					; Timer0 incrementa pelo ciclo de máquina e prescaler em 1:32
	bank0									; Seleciona o banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'A0'						; w = C0h
	movwf		INTCON						; Habilita a interrupção global e a interrupção do timer0
	bcf			digDez						; Desliga display das dezenas
	bcf			digUni						; Desliga display das unidades
	
	
; --- Loop infinito ---

loop:										; Cria loop infinito
		
	movlw		D'3'						; w = 3d
	movwf		dez							; dez = 3d
	movlw		D'2'						; w = 2d
	movwf		uni							; uni = 2ds
	
	goto		loop						; Desvia para loop infinito
	
; --- Sub Rotinas ---

display:

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
	

	
	
	end										; Fim do programa