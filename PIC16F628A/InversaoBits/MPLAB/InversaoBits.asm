;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem a unção de demonstrar como fazer a inversão de um único bit ou vários bits de um registrador.
;	Como não existe uma instrução para fazer isso, irá ser demonstrada uma forma, utilizando lógica XOR.
;		
;		No debug, na simulação e na prática o programa e o circuito funcionaram como esperado.
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
	#define saida1	PORTB,1					; Cria um mnemônico para saida1
	#define saida2	PORTB,4					; Cria um mnemônico para saida2
	
;	--- Entradas ---

	#define botao1	PORTB,0					; Cria um mnemônico para botao1
	
;	--- Constantes ---

	mascara_RB1		equ		B'00000010'		; Cria máscara para inverter estado de RB1
	mascara_RB4		equ		B'00010000'		; Cria máscara para inverter estado de RB4
	
;	--- Registradores de uso geral ---

	cblock		H'20'						; Inicio da memória de usuário
	
	T0
	T1
	
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
	movlw	H'00'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como saída digital
	bank0									; Seleciona o banco 0 de memória
	movlw	H'00'							; w = 00h
	movwf	PORTB							; PORTB = 00h, inicia todo portb em Low
	
loop:
	
	movlw	mascara_RB1						; w = mascara_RB1
	xorwf	PORTB,F							; Usa lógica XOR e mascara para inverter o bit RB1
	call 	delay500ms						; Espera 500ms
	movlw	mascara_RB4						; w = mascara_RB4
	xorwf	PORTB,F							; Usa lógica XOR e mascara para inverter o bit RB4
	call	delay500ms						; Espera 500ms
	
	goto 	loop							; Loop infinito 
	
; --- Sub-rotinas ---
	
	delay500ms:	; Cria a sub-rotina
	
		movlw	D'200' ; Move o valor 200 decimal para W
		movwf	T0 ; Move o valor de W para o registrador de uso T0
		
		aux1: ; Cria uma label auxiliar
		
			movlw	D'250' ; Move o valor decimal 250 para W
			movwf	T1 ; Move o valor de W para o registrado de uso geral T1
			
		aux2: ; Cria outra label auxiliar
		
			nop
			nop
			nop
			nop
			nop
			nop
			nop ; Gasta 7 ciclo de máquina = 7us
			
			decfsz	T1	 ; Decrementa o valor contido no T1 e pula uma linha se o valor for zero
			goto	aux2 ; Desvia para a label aux2
			
			decfsz	T0 ; Decrementa o valor contido no T0 e pula uma linha se o valor for zero
			goto 	aux1 ; Desvia o programa para a label aux1
			
			return ; Retorna para o loop infinito
			
			end