;
;		PIC16F84A			Clock = 	4MHz		Ciclo de máquina = 1us
;
;		O objetivos deste programa é demonstrar os comando de operações aritméticas simples, como soma, subtração, shift-
;	left e shift-right. Essas duas últimas servem como uma multiplicação por multiplos de 2. 
;		Em Assembly para Pic não existem comando de multiplicação e estes serão construídos ao longo do curso.
;
;		Foram mostrados alguns comandos novos:
;	clrf	=> Utilizado para zerar um registrador de uso geral, ou qualquer outro registrador
;
;		Os comandos de operação aritimética estarão em uma tabela ao final do programa
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
		
			movlw	D'10' ; Move 10 decimal para w
			addlw	D'5'  ; Soma 5 ao valor contido em w
			
			movlw	D'50'	; Move 50 decimal para w
			movwf	register1	; Move o valor contido em w para register1
			movlw	D'100'	; Move 100 decimal para w
			addwf	register1,w
			
		goto loop		; Desvia o programa para a label loop
		
			
			
		end
		
		
		
	; --- Intruções aritméticas ---
	;
	; -------------------------------
	;
	;	ADDLW 	k
	;	
	;	Operação: W = W + k
	;
	; -------------------------------
	;
	;	ADDWF	f,d
	;
	;	Operação: d = W + f
	;
	;	d = 0 (w) ou d = 1 (f) 
	;
	; -------------------------------
	;
	;	RLF		f,d
	;
	;	Operação: d = << 1 (rotaciona o operador f 1 bit para esquerda, "multiplica por 2")
	;
	;	d = 0 (w) ou d = 1 (f)
	;
	; -------------------------------
	;
	;	RRF		f,d
	;
	;	Operação:	d = f >> 1 (rotaciona o  registrador f um bit para a direita, "divide por 2")
	;
	;	d = 0 (w) ou d = 1 (f)
	;
	; -------------------------------
	;
	;	SUBLW	k
	;
	;	Operação:	W = k - W
	;
	; -------------------------------
	;
	;	SUBWF	f,d
	;
	;	Operação:	d = f - W
	;
	;	d = 0 (w) ou d = 1 (f)
	;
	; -------------------------------
	; 
	;	O comando shift-left (rlf = rotate left file) multiplica um número binário por 2. Por exemplo:
	;
	;	Decimal 4 = Binário 00000100
	;
	;					00000100 = 4 decimal
	;	shift-left:		00001000 = 8 decimal (4 x 2)
	;	shift-left:		00010000 = 16decimal (8 x 2)	
	;
	;	Da mesma forma, shift-right (rrf = rotate right file) divide um número binário por 2. Por exemplo:
	;
	;	Decimal 4 = Binário 00000100
	;
	;					00000100 = 4 decimal
	;	shift-right		00000010 = 2 decimal (4 / 2)
	;	shift-right		00000001 = 1 decimal (2 / 2)
	
	
	
			