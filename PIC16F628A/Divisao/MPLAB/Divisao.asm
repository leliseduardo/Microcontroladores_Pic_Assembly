;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem a função de demonstrar como fazer uma divisão de quaisquer números, uma vez que não existe
;	instruções prontas para essa tarefa.
;
;		No debug o programa funcionou como esperado, realizando a divisão.
;
	

	list p=16F628A							; Informa o microcontrolador utilizado
	
; --- Inclusão de arquivos ---

	#include <p16f628a.inc>					; Inclui o arquivo de registradores do mcu
	
; --- Fuse bits ---

;	- Clock externo de 4MHz
;	- Watch Dog Timer desligado
;	- Power Up Time ligado
;	- Master Clear ligado
;	- Brown Out Detect desligado
;	- Programação em baixa tensão desligada
;	- Proteção de código desligada
;	- Proteção da memória EEPROM desligada

	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
	
;	---	Paginação de memória ---

	#define	bank0	bcf	STATUS,RP0			; Cria um mnemônico para selecionar o banco 0 de memória	
	#define	bank1	bsf	STATUS,RP0			; Cria um mnemônico para selecionar o banco 1 de memória
	
;	--- Saídas ---

	#define	led1	PORTA,3					; Cria um mnemônico para ligar e desligar led1
	#define led2	PORTA,2					; Cria um mnemônico para ligar e desligar led2
	
;	--- Entradas ---

	#define botao1	PORTB,0					; Cria um mnemônico para botao1
	
;	--- Registradores de uso geral ---

	cblock		H'20'						; Inicio da memória de usuário
	
	A0										; Armazena um dos números que serão divididos
	B0										; Armazena um dos números que serão divididos
	C0										; Armazena o resultado da divisão

	endc
	
;	--- Vetor de reset

	org		H'0000'							; Origem no endereço 00h de memória
	goto 	inicio							; Desvia para a label inicio
	
;	--- Vetor de interrupção

	org		H'0004'							; As interrupções do processador apontar para o endereço 0004h
	retfie									; Retorna da interrupção
	
inicio:

	bank0									; Seleciona o banco 0 de memória
	movlw	H'07'							; w= 07h
	movwf	CMCON							; CMCON = 07h
	bank1									; Seleciona o banco 1 de memória
	movlw	H'13'							; w = 13h
	movwf	TRISA							; TRISA = w, configura apenas RA2 e RA3 como saídas digitais
	movlw	H'FF'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como saída digital
	bank0									; Seleciona o banco 0 de memória
	movlw	d'136'							; w = 50d
	movwf	A0								; A0 = w
	movlw	d'4'							; w = 55d
	movwf	B0								; B0 = w
	call	divisao
	
	goto 	$								; Loop infinito sem nenhuma função
	
;	--- Sub-rotinas ---

	divisao:							; Cria a subrotina divisao
	
	clrf	C0							; Limpa C0
	
	div:
	
	movf	B0,w						; w = B0
	subwf	A0,F						; Subtrai w de A0 e guarda o resultado no próprio A0
	btfss	STATUS,C					; Testa se houve carry, se houve, teve subtração e C = 1. Se não teve, C = 0
	return								; Retorna 
	incf	C0,F						; Incrementa 1 em C0 e guarda o valor no próprio C0
	goto	div							; Desvia para label div
	
	; Para fazer a divisão, o programa subtrai o divisor do dividendo e conta quantas vezes essa subtração ocorre até que
	; o dividendo chegue a zero. O número contado é o resultado. 
	
	end									; Final do programa 