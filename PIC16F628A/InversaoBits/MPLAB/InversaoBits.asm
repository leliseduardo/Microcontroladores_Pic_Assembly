;
;		PIC16F628A			Clock = 4 MHz	
;
;		Este programa tem a un��o de demonstrar como fazer a invers�o de um �nico bit ou v�rios bits de um registrador.
;	Como n�o existe uma instru��o para fazer isso, ir� ser demonstrada uma forma, utilizando l�gica XOR.
;		
;		No debug, na simula��o e na pr�tica o programa e o circuito funcionaram como esperado.
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
	#define saida1	PORTB,1					; Cria um mnem�nico para saida1
	#define saida2	PORTB,4					; Cria um mnem�nico para saida2
	
;	--- Entradas ---

	#define botao1	PORTB,0					; Cria um mnem�nico para botao1
	
;	--- Constantes ---

	mascara_RB1		equ		B'00000010'		; Cria m�scara para inverter estado de RB1
	mascara_RB4		equ		B'00010000'		; Cria m�scara para inverter estado de RB4
	
;	--- Registradores de uso geral ---

	cblock		H'20'						; Inicio da mem�ria de usu�rio
	
	T0
	T1
	
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
	movlw	H'00'							; w = 00h
	movwf	TRISB							; TRISB = 00h, configura todos os pinos do portb como sa�da digital
	bank0									; Seleciona o banco 0 de mem�ria
	movlw	H'00'							; w = 00h
	movwf	PORTB							; PORTB = 00h, inicia todo portb em Low
	
loop:
	
	movlw	mascara_RB1						; w = mascara_RB1
	xorwf	PORTB,F							; Usa l�gica XOR e mascara para inverter o bit RB1
	call 	delay500ms						; Espera 500ms
	movlw	mascara_RB4						; w = mascara_RB4
	xorwf	PORTB,F							; Usa l�gica XOR e mascara para inverter o bit RB4
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
			nop ; Gasta 7 ciclo de m�quina = 7us
			
			decfsz	T1	 ; Decrementa o valor contido no T1 e pula uma linha se o valor for zero
			goto	aux2 ; Desvia para a label aux2
			
			decfsz	T0 ; Decrementa o valor contido no T0 e pula uma linha se o valor for zero
			goto 	aux1 ; Desvia o programa para a label aux1
			
			return ; Retorna para o loop infinito
			
			end