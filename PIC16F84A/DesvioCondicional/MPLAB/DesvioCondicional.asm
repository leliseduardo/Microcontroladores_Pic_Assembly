;
;		PIC16F84A			Clock = 4MHz		Ciclo de m�quina = 1us	
;
;		O objetivo desta aula � apresentar os quatro comando existentes em Assembly para Pic que realizam um desvio con-
;	dicional, isto �, desviam o programa a partir de certa condi��o, ou certo acontecimento.
;		Em Assembly, qualquer desvio condicional apenas faz com que o programa pule uma linha e, ainda sim, � um tipo de
;	execu��o de extrema import�ncia em v�rias aplica��es e situa��es.
;		Vale ressaltar que um desvio incondicional � aquele que n�o depende de nenhuma condi��o ou acontecimento para 
;	desviar o programa. Um exemplo � o comando "goto label" que, dado o comando e a label para qual deve desviar, ele 
;	desvia a execu��o na hora. 
;		Os quatro comandos de desvio condicional est�o em uma tabela ao fim do programa.
;
;		O debug do programa funcionou como esperado.
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
		
			movlw	D'10' 		; w = 10 decimal
			movwf	register1	; register1 = w
			
			movlw	B'00000100' ; w = 00000100
			movwf	register2	; register2 = w
			
			aux:
			
				btfss register2,2				; Decrementa 1 de register1 e salva no proprio register1. register1 = 0 ?
				goto aux						; N�o. Desvia para label aux
				goto loop						; Sim. Desvia para label loop
			
		goto loop		; Desvia o programa para a label loop
		
			
			
		end
		
		
; 		INSTRU��ES	
; ------------------------------
;
;	DECFSZ	=> decrement file skip zero
;
;	DECFSZ	f,d
;
;	Decrementa f (d = f - 1) e desvia* se f = 0
;
;	d = (w) ou d = 1 (f)
;
; -------------------------------
; ------------------------------
;
;	INCFSZ	=> increment file skip zero
;
;	INCFSZ	f,d
;
;	Incrementa f (d = f + 1) e desvia* se f = 0
;
;	d = (w) ou d = 1 (f)
;
; -------------------------------
; ------------------------------
;
;	BTFSC	=>	bit test file skip clear 
;
;	BTFSC	f,b
;
;	Testa bit (b) do registrador (f), desvia* se igual a zero
;
;	
;
; -------------------------------
; ------------------------------
;
;	BTFSS	=> bit test file skip set
;
;	BTFSS	f,b
;
;	Testa bit (b) do registrador (f), desvia* se igual a um
;
;	
;
; -------------------------------
;
;	
;	* O mesmo que saltar a pr�xima linha
;
;
;
