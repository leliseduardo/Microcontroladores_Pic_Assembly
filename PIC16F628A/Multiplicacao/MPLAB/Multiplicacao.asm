;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem o intuito de demonstrar como se faz a operação de multiplicação em Assembly, já que esta opera-
;	ção não está implementada nas instruções do Pic.
;
;		No debug o programa funcionou como esperado e fez a multiplicação.
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
	
	A0										; Armazena um dos números que serão multiplicados
	B0										; Armazena um dos números que serão multiplicados
	C0										; Armazena o resultado da multiplicação
	C1										; Armazena o resultado da multiplicação
	
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
	movlw	d'50'							; w = 50d
	movwf	A0								; A0 = w
	movlw	d'55'							; w = 55d
	movwf	B0								; B0 = w
	call	multiplicacao
	
	goto 	$								; Loop infinito sem nenhuma função
	
;	--- Sub-rotinas ---

	multiplicacao:
	
		clrf	C0							; Limpa C0
		clrf	C1							; Limpa C1
		movf	A0,w						; w = A0
		movwf	C0							; C0 = w
		
	mult:								; Cria label multi para fazer a multiplicação
			
		decf	B0,F					; Decrementa 1 de B0 e salva nele mesmo
		btfsc	STATUS,Z				; Testa se B0 chegou a zero. Se sim, Z = 1
		return							; Sai da sub-rotina
		movf	A0,w					; w = A0
		addwf	C0,F					; Adiciona w em C0 e salva no próprio C0
		btfsc	STATUS,C				; Testa se houve transbordo em C0, se sim, C = 1
		incf	C1,F					; Se houve transbordo, incrementa C1 e salva nele mesmo
		goto	mult					; Desvia para a label mult
		
		; 	Esta sub-rotina faz a multiplicação de A0 com B0 somando A0 com A0, B0 vezes. Ou seja, 50 x 55 = 50 + 50 + ...
		;	+ 50 + 50 ... (55 vezes).
		
	
	end									; Final do programa 