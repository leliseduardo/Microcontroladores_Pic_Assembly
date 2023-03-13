;
;		PIC16F84A			Clock = 	4MHz		Ciclo de m�quina = 1us
;
;		O objetivos deste programa � demonstrar os comando de opera��es aritm�ticas simples, como soma, subtra��o, shift-
;	left e shift-right. Essas duas �ltimas servem como uma multiplica��o por multiplos de 2. 
;		Em Assembly para Pic n�o existem comando de multiplica��o e estes ser�o constru�dos ao longo do curso.
;
;		Foram mostrados alguns comandos novos:
;	clrf	=> Utilizado para zerar um registrador de uso geral, ou qualquer outro registrador
;
;		Os comandos de opera��o aritim�tica estar�o em uma tabela ao final do programa
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
		
			movlw	D'10' ; Move 10 decimal para w
			addlw	D'5'  ; Soma 5 ao valor contido em w
			
			movlw	D'50'	; Move 50 decimal para w
			movwf	register1	; Move o valor contido em w para register1
			movlw	D'100'	; Move 100 decimal para w
			addwf	register1,w
			
		goto loop		; Desvia o programa para a label loop
		
			
			
		end
		
		
		
	; --- Intru��es aritm�ticas ---
	;
	; -------------------------------
	;
	;	ADDLW 	k
	;	
	;	Opera��o: W = W + k
	;
	; -------------------------------
	;
	;	ADDWF	f,d
	;
	;	Opera��o: d = W + f
	;
	;	d = 0 (w) ou d = 1 (f) 
	;
	; -------------------------------
	;
	;	RLF		f,d
	;
	;	Opera��o: d = << 1 (rotaciona o operador f 1 bit para esquerda, "multiplica por 2")
	;
	;	d = 0 (w) ou d = 1 (f)
	;
	; -------------------------------
	;
	;	RRF		f,d
	;
	;	Opera��o:	d = f >> 1 (rotaciona o  registrador f um bit para a direita, "divide por 2")
	;
	;	d = 0 (w) ou d = 1 (f)
	;
	; -------------------------------
	;
	;	SUBLW	k
	;
	;	Opera��o:	W = k - W
	;
	; -------------------------------
	;
	;	SUBWF	f,d
	;
	;	Opera��o:	d = f - W
	;
	;	d = 0 (w) ou d = 1 (f)
	;
	; -------------------------------
	; 
	;	O comando shift-left (rlf = rotate left file) multiplica um n�mero bin�rio por 2. Por exemplo:
	;
	;	Decimal 4 = Bin�rio 00000100
	;
	;					00000100 = 4 decimal
	;	shift-left:		00001000 = 8 decimal (4 x 2)
	;	shift-left:		00010000 = 16decimal (8 x 2)	
	;
	;	Da mesma forma, shift-right (rrf = rotate right file) divide um n�mero bin�rio por 2. Por exemplo:
	;
	;	Decimal 4 = Bin�rio 00000100
	;
	;					00000100 = 4 decimal
	;	shift-right		00000010 = 2 decimal (4 / 2)
	;	shift-right		00000001 = 1 decimal (2 / 2)
	
	
	
			