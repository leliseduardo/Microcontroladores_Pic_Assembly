;
; 		PIC16F84A			Clock = 4MHz		Ciclo de m�quina = 1us
;
;		Neste programa o objetivo � demonstrar as formas que se tem para declarar registradores de uso geral, que nada
;	mais s�o do que as vari�veis do programa. Em Assembly, o uso do termo registrador de uso geral � mais correto e uma
;	boa pr�tica.
;
;		Neste programa, dois novos comandos foram vistos:
;	equ => Utilizado para declarar uma vari�vel, apontando um nome qualquer como um endere�o de mem�ria
;	cblock => Utilizado para indicar um endere�o de mem�ria, que ser� o endere�o inicial da grava��o de v�rias vari�veis.
;


	list p=16f84a ; Informa o microcontrolador utilizado
	
	; --- Arquivos utilizados no projeto
	#include <p16f84a.inc>	; Inclui o microcontrolador utilizado
	
	; --- Fuse bits ---
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF	; Configura os fuses do microcontrolador. Clock de 4MHz,
														; Watchdog timer desligado, PowerUp Timer ligado e Code Protect
														; desligado
														
	; --- Pagina��o de mem�ria ---
	#define		bank0	bcf		STATUS,RP0		; Cria um mnem�nico para o banco 0 de mem�ria
	#define 	bank1	bsf		STATUS,RP0		; Cria um mnem�nico para o banco 1 de mem�ria
	
	; --- Sa�das ---
	#define 	led1	PORTB,RB7	; Cria um mnem�nico para a sa�da RB7
	#define 	led2	PORTB,RB6	; Cria um menm�nico para a sa�da RB6
	
	; --- Registradores de uso geral ---
	cblock		H'0C'		; Inicio da mem�ria dos registradores de uso geral
	
	tempo1		;	Endere�o H'0C'
	tempo2		;	Endere�o H'0D'
	
	endc
	
	;
	;	tempo1	equ		H'0C'
	;	tempo2	equ		H'0D'
	;
	;	Esta � uma das formas de se declarar os registradores de uso geral
	;
	
	
	
	
	; --- Vetor de Reset ---
	org 		H'0000'		; Informa o endere�o do vetor Reset no banco de mem�ria
	
	goto inicio	; Desvia o programa para a label inicio
	
	; --- Vetor de interrup��o
	org			H'0004'		; Informa o endere�o do vetor de interrup��o no banco de mem�ria
	
	retfie		; Retorna a execu��o para o local onde o programa foi interrompido
	
	
	; --- Programa principal ---
	inicio:
	
		bank1			; Seleciona o banco 1 de mem�ria
		movlw	H'3F'	; Move o valor 3F para o registrador w
		movwf	TRISB	; Move o valor de w para o registrador TRISB e configura RB7 e RB6 como sa�das digitais
		bank0			; Seleciona o banco 0 de mem�ria	
		movlw	H'3F'	; Move o valor 3F para w
		movwf	PORTB	; Move o valor de w para PORTB e inicia as portas RB7 e RB6 em Low
		
		loop:			; Cria a label loop, que � a label do loop infinito
		
			bsf	led1 			; Acende led1
			bcf led2			; Apaga led2
			call delay500ms		; Chama a subrotina delay500ms
			bcf	led1			; Apaga led1
			bsf	led2			; Acende led2
			call delay500ms		; Chama a subrotina delay500ms
			
		goto loop		; Desvia o programa para a label loop
		
		
	; --- Subrotinas ---
	delay500ms:				; Cria subrotina delay500ms
	
		movlw	D'200' 		; Move 200 decimal para w
		movwf	tempo1		; Move o valor de w para tempo1
		
		aux1:				; Cria label auxiliar
		
			movlw	D'250'	; Move 250 decimal para w
			movwf	tempo2	; Move o valor de w para tempo2
			
		aux2:				; Cria outra label auxiliar
		
			nop
			nop
			nop
			nop
			nop
			nop
			nop 			; Gasta 7 ciclos de m�quina
			
			decfsz	tempo2	; Decrementa 1 de tempo2 e pula uma linha se chegar a zero
			goto 	aux2	; Desvia o programa para a label aux2
			
			decfsz	tempo1	; Se tempo2 igual a zero, decrementa 1 de tempo1 e pula uma linha se chegar a zero
			goto 	aux1	; Desvia programa para a label aux1
			
			return 			; Se tempo1 igual a zero, sai da subrotina
			
			
			
			end