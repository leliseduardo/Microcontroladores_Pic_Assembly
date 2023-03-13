;
;		O objetivo deste programa é demonstrar uma utilização simples do Watch Dog Timer. O programa irá piscar um led
;	através do loop infinito e, se um botão for pressionado, o programa desvia para um label que prender o programa. 
;	Como o Watch Dog Timer tem seu incremento zerado apenas no loop infinito, quando o programa ficar preso na outra
;	label, isso será enetendido como "Erro" ou "Bug" pelo WTD, que irá reiniciar o programa.
;		A função do Watch Dog Timer é reiniciar o programa caso haja algum bug de código, mal funcionamento do código,
;	mal funcionamento por algum defeito no circuito, no Pic ou até interferências externas no circuito. Ele conta com um
;	contador, que é semelhante aos timers do Pic. Esse contador, quando o WDT está ativado, conta até um certo valor 
;	mínimo e, ao alcançar este valor, estoura e reinicia o programa. Logo, quando o WDT está ativado, ele deve ser limpo
;	via software de tempos em tempos, para não estourar e não reiniciar o programa de forma indesejada.
;		O tempo de estouro padrão do Watch Dog Timer é 18ms no mínimo, mas esse tempo pode ser aumentado configurando o 
;	prescaler de 1:1 até 1:128. Os prescalers acima de 1:1 multiplicam os 18ms pelo prescaler configurado.
;		O Watch Dog Timer também é uma alternativa de reiniciar o programa via software, o que é muito útil em algumas
;	aplicações.
;
;		Na simulação o programa e o circuito funcionaram perfeitamente, alternando a saída RA3 e, quando o botão é pres-
;	sionado, o programa traba com RA2 ligado. Após +- 1,15 segundo, que foi o WDT programado, o programa reinicia, apaga
;	RA2 e volta a alternar RA3.
;		Na prática o programa e o circuito também funcionaram, mas sem o osciloscópio não dá para ver o led em RA3 
;	alternando, pois esta saída alterna sem delay, portanto, na valocidade dos ciclos de máquina, na ordem dos us.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Documentação ---

	#include	<p16f628a.inc>				; Inclui o documento que contém os registradores do Pic
	
	
; --- Fuse bits	---
	
	__config	_XT_OSC & _WDT_ON & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura clock em 4MHz, liga o WatchDog Timer, liga o Power Up Timer e liga o Master Clear

; --- Paginação de memória ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
; --- Mapeamento de hardware ---

	#define		led1	PORTA,3				; Cria mnemônico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnemônico para led2 em RA2
	#define 	botao1	PORTB,0				; Cria mnemônico para botao1 em RB0
	#define 	botao2	PORTB,1				; Cria mnemônico para botao2 em RB1
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endereço para início de configurações de registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de W temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	
	endc									; Fim da configuração de registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endereço do vetor de Reset
	
	goto		inicio						; Desvia para programa principal
	
; --- Vetor de Interrupção ---	

	org 		H'0004'						; Origem do endereço do vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de memória --

	; Desenvolvimento da ISR...
	
	
; -- Recuperação de contexto -- 

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS(com nibbles reinvertidos)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Sai da interrupção, volta para o endereço do memória onde foi interrompido

; -- Fim da recuperação de contexto --

; --- Programa principal

inicio:

	bank1									; Seleciona o banco 1 de memória
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; Configura apenas RA3 e RA2 como saídas digitais
	movlw		H'FF'						; w = FFh
	movwf		TRISB						; Configura todo portb como entrada digital
	movlw		H'8E'						; w = 8Eh
	movwf		OPTION_REG					; Configura o prescaler associado ao WDT, em 1:64
	bank0									; Seleciona o banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'F3'						; w = F3h
	movwf		PORTA						; Inicia RA3 e RA2 em Low
	

; --- Loop infinito ---

loop:										; Cria label para loop infinito

	clrwdt									; Limpa a contagem do Watch Dog Timer
	movlw		H'08'						; w = 08h
	xorwf		PORTA						; Faz lógica XOR entre w e PORTA para mudar estado de RA3
	btfss		botao1						; Testa se o botão está solto, se estiver, pula uma linha
	goto		trava_Programa				; Se não estiver, desvia para label trava_Programa

goto loop									; Desvia para loop infinito

trava_Programa:

	bsf			led2						; Acende led1
	goto		$							; Desvia para este mesmo endereço, neste mesmo comando, trava o programa


; --- Final do programa ---

end 										; Final do programa