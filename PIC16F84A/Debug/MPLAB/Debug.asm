;
;		PIC16F84A			Clock = 4MHz
;
;		Este programa tem a fun��o de demonstrar como criar um novo projeto com o MPLAB, um projeto que poder� ser com-
;	pilado e ir� gerar os arquivos Hex, para gravar o Pic na pr�tica e Cof, para debugar o Pic. Ainda, este programa foi
;	usado para demonstrar o debug do MPLAB.
;
;		Na aula, o professor demonstrou, atrav�s do datasheer, que o registrador TRISA n�o apresenta os tr�s nibles mais
;	significativos e, mesmo configurando ele todo como entrada (H'FF'), por exemplo, os tr�s nibles mais significativos
; 	permancem em 0.
;		Os registradores de estado dos pinos, os PORTX, s� poder�o ser setados em High se o pino em quest�o foi configu-
;	rado como sa�da. Caso tenha sido configurado como entrada, mesmo que configuremos o PORTX como High, ele permanecer�
; 	em Low. Logo, s� se pode configurar em High as sa�das.
; 
;		O comando "goto $" mant�m o programa fixo nesta linha, pois o comando goto desvia o programa para algum lugar,
;	e o comando $ devolve o endere�o em que ele est�. Ou seja, o programa ser� desviado para a pr�pria linha em que est�.
;	Assim, o programa fica preso nesta linha.
;	
;		Como se pode ver na simula��o, ao passar o valor H'FF' para PORTB, ao inv�s de ficar com esse valor, ele fica com 
;	o valor H'80', pois o registrador PORTB s� ir� colocar em High os pinos que foram configurados como sa�da digital.
;

list p=16f84a	; Informa o microcontrolador usado
	
	; --- Arquivos inclu�dos no projeto ---
	#include <p16f84a.inc>	; Inclui o arquivo do microcontrolador usado
	
	; --- FUSE Bits ---
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF	; Configura o oscilador externa para XT, desliga o watchDog
														; timer, habilita o Power Up Timer e desliga a prote��o de c�digo
														
	; --- Pagina��o de mem�ria ---
	#define bank0 bcf STATUS,RP0 ; Basta utilizar o mnem�nico bank0 para mudar para o banco 0
	#define bank1 bsf STATUS,RP0 ; Basta utilizar o mnem�nico bank1 para mudar para o banco 1
								 ; Para mudar de banco de mem�ria � neces�rio configurar o bit RP0 do registrador STATUS
								
	; --- Entradas ---
	#define botao PORTB,RB0 ; Cria um mnem�nico para um bot�o, que estar� conectado ao RB0
	
	; --- Sa�das ---
	#define led PORTB,RB7 ; Cria um mnem�nico para um led, conectado no pino RB7				
								
	; --- Vetor de Reset ---
	org H'0000' ; Informa a origem do vetor Reset no banco de mem�ria
	
	goto inicio ; Desvia o programa para inicio
	
	; --- Vetor de Interrup��o --- 
	org H'0004' ; Informa a origem do vetor de interrup��o no banco de mem�ria
	
	retfie ; Desvia o programa para retomar de onde parou, quando houve a interrup��o
	
	
	; --- Programa principal ---
	inicio:
	
		bank1 ; Utiliza o mnem�nico bank1 para selecionar o banco 1 de mem�ria
		movlw	H'FF' ; Ou B'1111 1111', move este valor para o registrador de trabalho Work
		movwf	TRISA ; Transfere o valor de W para TRISA, configurando todas os pinos como entrada digital
		movlw 	H'7F' ; Ou B'0111 1111', move este valor para o registradore de trabalho Work
		movwf	TRISB ; Transfere o valor do resgistrador Work (w) para o registrador TRISB, configurando apenas RB0
					  ; como sa�da digital, e o resto dos pinos do PORTB como entrada digital.
		bank0 ; Utiliza o mnem�nico bank0 para selecionar o banco 0 de mem�ria
		movlw	H'FF' ; Move este valor para o resgistrador de trabalho Work (w)
		movwf	PORTB ; Transfere o valor de w para o portb, iniciando todas as sa�das em High
		
		goto	$ ; Mant�m a execu��o presa nesta linha 
		
		end 