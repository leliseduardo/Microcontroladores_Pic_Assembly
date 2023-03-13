;
;		O objetivo deste programa é demonstrar a configuração de um RTC (real time clock) a partir do timer1. Para isso,	
;	será utilizado um clock externo a partir de um cristal oscilador de 32.768KHz. Isto é, o contador do timer1 irá 
;	incrementar a partir deste oscilador, e não mais pelo ciclo de máquina.
;
;	Overflow = (65536 - <TMR1H::TMR1L>) * prescaler * periodo clock
;
;										Overflow
;	<TMR1H::TMR1L> = 65536 - ------------------------------ 
;							  prescaler * periodo de clock	
;
;	Overflow = 1s
; 	prescaler = 1
;	periodo de clock = (1 / 32768Hz) = 0,00003051757813
;
;	<TMR1H::TMR1L> = 32768d = 8000h
;
;	TMR1H = 80h
;	TMR1L = 00h 
;	
;	Basta setar o bit mais significativo de TMR1H: bsf TMR1H,7
;
;		Vale ressaltar que, quando se usa o oscilador externo no timer1, por exemplo, a contagem do contador do timer1
;	ocorre a partir da borda de descida de cada oscilação do clock externo. Assim, o tempo de interrupção ocorre sempre
;	exatamente no tempo configurado. Porém, ainda existe um tempo de latência pois, para executar a rotina de interrupção,
;	o programa passa primeiro pelo salvamento de contexto e depois pela recuperação de contexto, que demora alguns ciclos
;	de máquina para serem feitos.
;		Sendo assim, neste exemplo a interrupção acontecerá sempre a cada 1s exatos, porém, a mudança de estado do RA3,
;	por exemplo, será 1s mais alguns ciclos de máquina, provenientes do salvamento de contexto. No caso desta aplicação,
;	a recuperação de contexto não irá interferir, pois ocorre após a rotina de interrupção e, como demora apenas alguns 
;	ciclos de máquina (microsegundos), não terá havido outra interrupção neste tempo.
;		Assim, se o salvamento de contexto demora 5us para executar, e a atualização da hora no display (por exemplo) 
;	ocorre após esse tempo, então pode-se calcular o tempo necessário para o display atrasar 1s.
;
;		1s / 5us = 200000 -> Número de interrupções para o salvamento de contexto completar 1s no total
;		200000 / 3600 = 55,55 horas -> Número de horas para o display atrasar 1s
;		365 * 24 = 8760 horas -> Número de horas que contém em 1 ano
;		8760 / 55,55 = 157,70 s -> Total de segundos atrasados em 1 ano
;		157,7 / 60 = 2,63 minutos -> Total de minutos atrasados em 1 ano
;		
;		Assim, percebe-se que a latência de interrupção gera aproximadamente 2,63 minutos de atraso em 1 ano. Para corri-
;	gir este tempo de latência teria que ser feita uma manipulação de código para compensar a contagem com esse tempo de
; 	latência, mas não é uma coisa simples, uma vez que o tempo para 1 incremento é:
;		1 / 32757 = 30,52 us -> Tempo para incrementar 1 no contador do timer.
;		Ou seja, o tempo para incremento é maior que o tempo de latência e isso complica o método de correção de tempo
;	de latência de interrupção.
;		Ainda, caso precise realmente de boa precisão do relógio, pode-se utilizar um artifício de código para o relógio
;	se autoajustar de tempos em tempos, uma vez que o atraso ocorre apenas na atualização do display e não na execução
;	do Pic. Logo, pode-se configurar um autoajuste a cada 15 dias, por exemplo.
;		Porém, de toda forma, o tempo de latência é da ordem de us (microsegundos) e, como visto, no ano o atraso do 
; 	relógio seria na ordem dos segundos. Essa precisão está mais do que ótima para a grande maioria dos projetos.
;		
;
;		Na prática o circuito e o programa funcionaram como esperado.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- inclusões ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, habilita o Power Up Timer e habilita o Master Clear

; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnemônico para led1 em RA3
	#define 	led2	PORTA,2				; Cria mnemônico para led2 em RA2
	#define 	botao1	PORTB,0				; Cria mnemônico para botao1 em RB0

; --- Paginação de memória ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Início do endereço para configuração dos registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	
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
	
	btfss		PIR1,TMR1IF					; Testa se a flag TMR1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não, sai da interrupção
	bcf			PIR1,TMR1IF					; Limpa a flag TMR1IF
	bsf			TMR1H,7						; Recarrega <TMR1H::TMR1L> = 8000h	
	
	movlw		H'08'						; w = 08h
	xorwf		PORTA						; Inverte o estado de RA4 através da lógica XOR entra w e porta
	
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
	movlw		H'FF'						; w = FFh
	movwf		TRISB						; Configura todo portb como entrada digital
	bsf			PIE1,TMR1IE					; Habilita a interrupção por overflow do timer1
	bank0									; Seleciona o banco 0 de memória
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Habilita a interrupção gloabal e por periféricos
	movlw		H'0B'						; w = 01h
	movwf		T1CON						; liga o timer1, prescaler em 1:1, liga osc externo e incrementa por clock externo
	movlw		H'F3'						; w = F3h
	movwf		PORTA						; Inicia RA3 e RA2 em Low
	bsf			TMR1H,7						; Ou TMR1H = 10000000, inicia a contagem do timer1 com <TMR1H::TMR1L> = 8000h

; --- Loop infinito ---

	goto		$							; Mantém o programa preso nesta linha, neste endereço de memória
	
	
	
	end										; Fim do programa