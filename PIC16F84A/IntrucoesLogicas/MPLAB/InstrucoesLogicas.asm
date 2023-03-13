;
;		PIC16F84A			Clock = 4MHz		Ciclo de m�quina = 1us	
;
;		Este programa tem o objetivo de demonstrar as intru��es l�gicas em Assembly. As intru��es l�gicas tem a fun��o
;	de, bit a bit, fazer as opera��es l�gicas entre os registradores. A tabela com cada intru��o estar� no fim do pro-
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
														
	; --- Pagina��o de mem�ria ---
	#define		bank0	bcf		STATUS,RP0		; Cria um mnem�nico para o banco 0 de mem�ria
	#define 	bank1	bsf		STATUS,RP0		; Cria um mnem�nico para o banco 1 de mem�ria
	
	; --- Sa�das ---
	#define 	led1	PORTB,RB7	; Cria um mnem�nico para a sa�da RB7
	#define 	led2	PORTB,RB6	; Cria um menm�nico para a sa�da RB6
	
	; --- Registradores de uso geral ---
	cblock		H'0C'		; Inicio da mem�ria dos registradores de uso geral
	
	register1		;	Endere�o H'0C'
	register2		;	Endere�o H'0D'
	
	endc
	
	;
	;	register1	equ		H'0C'
	;	register2	equ		H'0D'
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
		clrf	register1 	; Inicia o registrador de uso geral register1 todo em Low
		clrf	register2	; Inicia o registrador de uso geral register2 todo em Low
		
		loop:			; Cria a label loop, que � a label do loop infinito
		
			movlw	B'00111110'	; Move o valor bin�rio para W
			andlw	B'11101010'	; W and B'11101010'
			
			iorwf	register1,f ; register1 = W or register1
			
		goto loop		; Desvia o programa para a label loop
		
			
			
		end
		
		
;		Instru��es
; ------------------------------
;
;	ANDLW		k
;
;	Opera��o:	W = W AND k
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	ANDWF		f,d
;
;	Opera��o:	d = W AND f
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
;	Opera��o:	d = NOT f
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
;	Opera��o:	W = W OR k
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	IORWF		f,d
;
;	Opera��o:	d = W OR f
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
;	Opera��o:	W = W XOR k
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
; ------------------------------
;
;	XORWF		f,d
;
;	Opera��o:	d = W XOR f
;
;	d = 0 (W) ou d = 1 (f)
;
;	Afeta a flag Z do STATUS;
;
; ------------------------------
