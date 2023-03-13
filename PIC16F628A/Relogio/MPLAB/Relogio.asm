;
;		O objetivo deste programa � demonstrar a configura��o de um RTC (real time clock) a partir do timer1. Para isso,	
;	ser� utilizado um clock externo a partir de um cristal oscilador de 32.768KHz. Isto �, o contador do timer1 ir� 
;	incrementar a partir deste oscilador, e n�o mais pelo ciclo de m�quina.
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
;	ocorre a partir da borda de descida de cada oscila��o do clock externo. Assim, o tempo de interrup��o ocorre sempre
;	exatamente no tempo configurado. Por�m, ainda existe um tempo de lat�ncia pois, para executar a rotina de interrup��o,
;	o programa passa primeiro pelo salvamento de contexto e depois pela recupera��o de contexto, que demora alguns ciclos
;	de m�quina para serem feitos.
;		Sendo assim, neste exemplo a interrup��o acontecer� sempre a cada 1s exatos, por�m, a mudan�a de estado do RA3,
;	por exemplo, ser� 1s mais alguns ciclos de m�quina, provenientes do salvamento de contexto. No caso desta aplica��o,
;	a recupera��o de contexto n�o ir� interferir, pois ocorre ap�s a rotina de interrup��o e, como demora apenas alguns 
;	ciclos de m�quina (microsegundos), n�o ter� havido outra interrup��o neste tempo.
;		Assim, se o salvamento de contexto demora 5us para executar, e a atualiza��o da hora no display (por exemplo) 
;	ocorre ap�s esse tempo, ent�o pode-se calcular o tempo necess�rio para o display atrasar 1s.
;
;		1s / 5us = 200000 -> N�mero de interrup��es para o salvamento de contexto completar 1s no total
;		200000 / 3600 = 55,55 horas -> N�mero de horas para o display atrasar 1s
;		365 * 24 = 8760 horas -> N�mero de horas que cont�m em 1 ano
;		8760 / 55,55 = 157,70 s -> Total de segundos atrasados em 1 ano
;		157,7 / 60 = 2,63 minutos -> Total de minutos atrasados em 1 ano
;		
;		Assim, percebe-se que a lat�ncia de interrup��o gera aproximadamente 2,63 minutos de atraso em 1 ano. Para corri-
;	gir este tempo de lat�ncia teria que ser feita uma manipula��o de c�digo para compensar a contagem com esse tempo de
; 	lat�ncia, mas n�o � uma coisa simples, uma vez que o tempo para 1 incremento �:
;		1 / 32757 = 30,52 us -> Tempo para incrementar 1 no contador do timer.
;		Ou seja, o tempo para incremento � maior que o tempo de lat�ncia e isso complica o m�todo de corre��o de tempo
;	de lat�ncia de interrup��o.
;		Ainda, caso precise realmente de boa precis�o do rel�gio, pode-se utilizar um artif�cio de c�digo para o rel�gio
;	se autoajustar de tempos em tempos, uma vez que o atraso ocorre apenas na atualiza��o do display e n�o na execu��o
;	do Pic. Logo, pode-se configurar um autoajuste a cada 15 dias, por exemplo.
;		Por�m, de toda forma, o tempo de lat�ncia � da ordem de us (microsegundos) e, como visto, no ano o atraso do 
; 	rel�gio seria na ordem dos segundos. Essa precis�o est� mais do que �tima para a grande maioria dos projetos.
;		
;
;		Na pr�tica o circuito e o programa funcionaram como esperado.
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- inclus�es ---

	#include	<p16f628a.inc>				; Inclui o arquivo com os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Configura clock de 4MHz, habilita o Power Up Timer e habilita o Master Clear

; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnem�nico para led1 em RA3
	#define 	led2	PORTA,2				; Cria mnem�nico para led2 em RA2
	#define 	botao1	PORTB,0				; Cria mnem�nico para botao1 em RB0

; --- Pagina��o de mem�ria ---

	#define		bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar o banco 1 de mem�ria
	
; --- Registradores de uso geral ---

	cblock		H'20'						; In�cio do endere�o para configura��o dos registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	
	endc									; Fim da configura��o dos registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o do vetor de Reset
	
	goto		inicio						; Desvia para label inicio, programa principal
	
; Vetor de Interrup��o

	org 		H'0004'						; Origem do endere�o do vetor de Reset
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	btfss		PIR1,TMR1IF					; Testa se a flag TMR1IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se n�o, sai da interrup��o
	bcf			PIR1,TMR1IF					; Limpa a flag TMR1IF
	bsf			TMR1H,7						; Recarrega <TMR1H::TMR1L> = 8000h	
	
	movlw		H'08'						; w = 08h
	xorwf		PORTA						; Inverte o estado de RA4 atrav�s da l�gica XOR entra w e porta
	
; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (com nibbles reinvertidos, isto �, STATUS original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (com nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (com nibbles reinvertidos, isto �, w original)
	
	retfie									; Retorna para execu��o principal
	
; -- Fim da recupera��o de contexto -- 


; --- Programa principal ---

inicio:

	bank1									; Seleciona banco 1 de mem�ria
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; Configura apenas RA3 e RA2 como sa�das digitais
	movlw		H'FF'						; w = FFh
	movwf		TRISB						; Configura todo portb como entrada digital
	bsf			PIE1,TMR1IE					; Habilita a interrup��o por overflow do timer1
	bank0									; Seleciona o banco 0 de mem�ria
	movlw		H'07'						; w = 07h
	movwf		CMCON						; Desabilita os comparadores internos
	movlw		H'C0'						; w = C0h
	movwf		INTCON						; Habilita a interrup��o gloabal e por perif�ricos
	movlw		H'0B'						; w = 01h
	movwf		T1CON						; liga o timer1, prescaler em 1:1, liga osc externo e incrementa por clock externo
	movlw		H'F3'						; w = F3h
	movwf		PORTA						; Inicia RA3 e RA2 em Low
	bsf			TMR1H,7						; Ou TMR1H = 10000000, inicia a contagem do timer1 com <TMR1H::TMR1L> = 8000h

; --- Loop infinito ---

	goto		$							; Mant�m o programa preso nesta linha, neste endere�o de mem�ria
	
	
	
	end										; Fim do programa