;
;		PIC16F84A			Clock = 4MHz		Ciclo de máquina = 1us	
;
;		Este programa tem o objetivo de demonstrar as intruções lógicas em Assembly. As intruções lógicas tem a função
;	de, bit a bit, fazer as operações lógicas entre os registradores. A tabela com cada intrução estará no fim do pro-
;	grama.
;
;


list p=16f84a ; Informa o microcontrolador utilizado
	
	; --- Arquivos utilizados no projeto
	#include <p16f84a.inc>	; Inclui o microcontrolador utilizado
	
	; --- Fuse bits ---
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF	; Configura os fuses do microcontrolador. Clock de 4MHz,
														; Watchdog timer desligado, PowerUp Timer ligado e Code Protect
														; desligado
														
	; --- Paginação de memória ---
	#define		bank0	bcf		STATUS,RP0		; Cria um mnemônico para o banco 0 de memória
	#define 	bank1	bsf		STATUS,RP0		; Cria um mnemônico para o banco 1 de memória
	
	; --- Saídas ---
	#define 	led1	PORTB,RB7	; Cria um mnemônico para a saída RB7
	#define 	led2	PORTB,RB6	; Cria um menmônico para a saída RB6
	
	; --- Registradores de uso geral ---
	cblock		H'0C'		; Inicio da memória dos registradores de uso geral
	
	register1		;	Endereço H'0C'
	register2		;	Endereço H'0D'
	
	endc
	
	;
	;	register1	equ		H'0C'
	;	register2	equ		H'0D'
	;
	;	Esta é uma das formas de se declarar os registradores de uso geral
	;
	
	
	
	
	; --- Vetor de Reset ---
	org 		H'0000'		; Informa o endereço do vetor Reset no banco de memória
	
	goto inicio	; Desvia o programa para a label inicio
	
	; --- Vetor de interrupção
	org			H'0004'		; Informa o endereço do vetor de interrupção no banco de memória
	
	retfie		; Retorna a execução para o local onde o programa foi interrompido
	
	
	; --- Programa principal ---
	inicio:
	
		bank1			; Seleciona o banco 1 de memória
		movlw	H'3F'	; Move o valor 3F para o registrador w
		movwf	TRISB	; Move o valor de w para o registrador TRISB e configura RB7 e RB6 como saídas digitais
		bank0			; Seleciona o banco 0 de memória	
		movlw	H'3F'	; Move o valor 3F para w
		movwf	PORTB	; Move o valor de w para PORTB e inicia as portas RB7 e RB6 em Low
		clrf	register1 	; Inicia o registrador de uso geral register1 todo em Low
		clrf	register2	; Inicia o registrador de uso geral register2 todo em Low
		
		loop:			; Cria a label loop, que é a label do loop infinito
		
			movlw	B'00111110'	; Move o valor binário para W
			andlw	B'11101010'	; W and B'11101010'
			
			iorwf	register1,f ; register1 = W or register1
			
		goto loop		; Desvia o programa para a label loop
		
			
			
		end
		
		
;		Instruções
; ------------------------------
;
;	ANDLW		k
;
;	Operação:	W = W AND k
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	ANDWF		f,d
;
;	Operação:	d = W AND f
;
;	d = 0 (W) ou d = 1 (f)
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	COMF		f,d
;
;	Operação:	d = NOT f
;
;	d = 0 (W) ou d = 1 (f)
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	IORLW		k
;
;	Operação:	W = W OR k
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	IORWF		f,d
;
;	Operação:	d = W OR f
;
;	d = 0 (W) ou d = 1 (f)
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	XORLW		k
;
;	Operação:	W = W XOR k
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	XORWF		f,d
;
;	Operação:	d = W XOR f
;
;	d = 0 (W) ou d = 1 (f)
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
