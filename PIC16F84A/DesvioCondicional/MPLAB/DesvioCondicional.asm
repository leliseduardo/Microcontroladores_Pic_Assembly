;
;		PIC16F84A			Clock = 4MHz		Ciclo de máquina = 1us	
;
;		O objetivo desta aula é apresentar os quatro comando existentes em Assembly para Pic que realizam um desvio con-
;	dicional, isto é, desviam o programa a partir de certa condição, ou certo acontecimento.
;		Em Assembly, qualquer desvio condicional apenas faz com que o programa pule uma linha e, ainda sim, é um tipo de
;	execução de extrema importância em várias aplicações e situações.
;		Vale ressaltar que um desvio incondicional é aquele que não depende de nenhuma condição ou acontecimento para 
;	desviar o programa. Um exemplo é o comando "goto label" que, dado o comando e a label para qual deve desviar, ele 
;	desvia a execução na hora. 
;		Os quatro comandos de desvio condicional estão em uma tabela ao fim do programa.
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
		
			movlw	D'10' 		; w = 10 decimal
			movwf	register1	; register1 = w
			
			movlw	B'00000100' ; w = 00000100
			movwf	register2	; register2 = w
			
			aux:
			
				btfss register2,2				; Decrementa 1 de register1 e salva no proprio register1. register1 = 0 ?
				goto aux						; Não. Desvia para label aux
				goto loop						; Sim. Desvia para label loop
			
		goto loop		; Desvia o programa para a label loop
		
			
			
		end
		
		
; 		INSTRUÇÕES	
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
;	* O mesmo que saltar a próxima linha
;
;
;
