;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem a fun��o de demonstrar como fazer uma divis�o de quaisquer n�meros, uma vez que n�o existe
;	instru��es prontas para essa tarefa.
;
;		No debug o programa funcionou como esperado, realizando a divis�o.
;
	

	list p=16F628A							; Informa o microcontrolador utilizado
	
; --- Inclus�o de arquivos ---

	#include <p16f628a.inc>					; Inclui o arquivo de registradores do mcu
	
; --- Fuse bits ---

;	- Clock externo de 4MHz
;	- Watch Dog Timer desligado
;	- Power Up Time ligado
;	- Master Clear ligado
;	- Brown Out Detect desligado
;	- Programa��o em baixa tens�o desligada
;	- Prote��o de c�digo desligada
;	- Prote��o da mem�ria EEPROM desligada

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
	
;	---	Pagina��o de mem�ria ---

	#define	bank0	bcf	STATUS,RP0			; Cria um mnem�nico para selecionar o banco 0 de mem�ria	
	#define	bank1	bsf	STATUS,RP0			; Cria um mnem�nico para selecionar o banco 1 de mem�ria
	
;	--- Sa�das ---

	#define	led1	PORTA,3					; Cria um mnem�nico para ligar e desligar led1
	#define led2	PORTA,2					; Cria um mnem�nico para ligar e desligar led2
	
;	--- Entradas ---

	#define botao1	PORTB,0					; Cria um mnem�nico para botao1
	
;	--- Registradores de uso geral ---

	cblock		H'20'						; Inicio da mem�ria de usu�rio
	
	A0										; Armazena um dos n�meros que ser�o divididos
	B0										; Armazena um dos n�meros que ser�o divididos
	C0										; Armazena o resultado da divis�o

	endc
	
;	--- Vetor de reset

	org		H'0000'							; Origem no endere�o 00h de mem�ria
	goto 	inicio							; Desvia para a label inicio
	
;	--- Vetor de interrup��o

	org		H'0004'							; As interrup��es do processador apontar para o endere�o 0004h
	retfie									; Retorna da interrup��o
	
inicio:

	bank0									; Seleciona o banco 0 de mem�ria
	movlw	H'07'							; w= 07h
	movwf	CMCON							; CMCON = 07h
	bank1									; Seleciona o banco 1 de mem�ria
	movlw	H'13'							; w = 13h
	movwf	TRISA							; TRISA = w, configura apenas RA2 e RA3 como sa�das digitais
	movlw	H'FF'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como sa�da digital
	bank0									; Seleciona o banco 0 de mem�ria
	movlw	d'136'							; w = 50d
	movwf	A0								; A0 = w
	movlw	d'4'							; w = 55d
	movwf	B0								; B0 = w
	call	divisao
	
	goto 	$								; Loop infinito sem nenhuma fun��o
	
;	--- Sub-rotinas ---

	divisao:							; Cria a subrotina divisao
	
	clrf	C0							; Limpa C0
	
	div:
	
	movf	B0,w						; w = B0
	subwf	A0,F						; Subtrai w de A0 e guarda o resultado no pr�prio A0
	btfss	STATUS,C					; Testa se houve carry, se houve, teve subtra��o e C = 1. Se n�o teve, C = 0
	return								; Retorna 
	incf	C0,F						; Incrementa 1 em C0 e guarda o valor no pr�prio C0
	goto	div							; Desvia para label div
	
	; Para fazer a divis�o, o programa subtrai o divisor do dividendo e conta quantas vezes essa subtra��o ocorre at� que
	; o dividendo chegue a zero. O n�mero contado � o resultado. 
	
	end									; Final do programa 