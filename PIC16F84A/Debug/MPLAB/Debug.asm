;
;		PIC16F84A			Clock = 4MHz
;
;		Este programa tem a função de demonstrar como criar um novo projeto com o MPLAB, um projeto que poderá ser com-
;	pilado e irá gerar os arquivos Hex, para gravar o Pic na prática e Cof, para debugar o Pic. Ainda, este programa foi
;	usado para demonstrar o debug do MPLAB.
;
;		Na aula, o professor demonstrou, através do datasheer, que o registrador TRISA não apresenta os três nibles mais
;	significativos e, mesmo configurando ele todo como entrada (H'FF'), por exemplo, os três nibles mais significativos
; 	permancem em 0.
;		Os registradores de estado dos pinos, os PORTX, só poderão ser setados em High se o pino em questão foi configu-
;	rado como saída. Caso tenha sido configurado como entrada, mesmo que configuremos o PORTX como High, ele permanecerá
; 	em Low. Logo, só se pode configurar em High as saídas.
; 
;		O comando "goto $" mantém o programa fixo nesta linha, pois o comando goto desvia o programa para algum lugar,
;	e o comando $ devolve o endereço em que ele está. Ou seja, o programa será desviado para a própria linha em que está.
;	Assim, o programa fica preso nesta linha.
;	
;		Como se pode ver na simulação, ao passar o valor H'FF' para PORTB, ao invés de ficar com esse valor, ele fica com 
;	o valor H'80', pois o registrador PORTB só irá colocar em High os pinos que foram configurados como saída digital.
;

list p=16f84a	; Informa o microcontrolador usado
	
	; --- Arquivos incluídos no projeto ---
	#include <p16f84a.inc>	; Inclui o arquivo do microcontrolador usado
	
	; --- FUSE Bits ---
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF	; Configura o oscilador externa para XT, desliga o watchDog
														; timer, habilita o Power Up Timer e desliga a proteção de código
														
	; --- Paginação de memória ---
	#define bank0 bcf STATUS,RP0 ; Basta utilizar o mnemônico bank0 para mudar para o banco 0
	#define bank1 bsf STATUS,RP0 ; Basta utilizar o mnemônico bank1 para mudar para o banco 1
								 ; Para mudar de banco de memória é necesário configurar o bit RP0 do registrador STATUS
								
	; --- Entradas ---
	#define botao PORTB,RB0 ; Cria um mnemônico para um botão, que estará conectado ao RB0
	
	; --- Saídas ---
	#define led PORTB,RB7 ; Cria um mnemônico para um led, conectado no pino RB7				
								
	; --- Vetor de Reset ---
	org H'0000' ; Informa a origem do vetor Reset no banco de memória
	
	goto inicio ; Desvia o programa para inicio
	
	; --- Vetor de Interrupção --- 
	org H'0004' ; Informa a origem do vetor de interrupção no banco de memória
	
	retfie ; Desvia o programa para retomar de onde parou, quando houve a interrupção
	
	
	; --- Programa principal ---
	inicio:
	
		bank1 ; Utiliza o mnemônico bank1 para selecionar o banco 1 de memória
		movlw	H'FF' ; Ou B'1111 1111', move este valor para o registrador de trabalho Work
		movwf	TRISA ; Transfere o valor de W para TRISA, configurando todas os pinos como entrada digital
		movlw 	H'7F' ; Ou B'0111 1111', move este valor para o registradore de trabalho Work
		movwf	TRISB ; Transfere o valor do resgistrador Work (w) para o registrador TRISB, configurando apenas RB0
					  ; como saída digital, e o resto dos pinos do PORTB como entrada digital.
		bank0 ; Utiliza o mnemônico bank0 para selecionar o banco 0 de memória
		movlw	H'FF' ; Move este valor para o resgistrador de trabalho Work (w)
		movwf	PORTB ; Transfere o valor de w para o portb, iniciando todas as saídas em High
		
		goto	$ ; Mantém a execução presa nesta linha 
		
		end 