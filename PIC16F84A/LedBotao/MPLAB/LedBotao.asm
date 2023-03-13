;
;		PIC16F84A			Clock = 4MHz
;
;		Neste programa, será feito um led acender quando um botão for pressionado. O botão está conectado no pino RB0 e
;	o led no pino RB7.
;
;		Alguns novos comandos serão usados
;
;		btfsc = bit test file skip clear, que testa se o bit de um registrador é zero e, se for, pula uma linha
;
;		Pela debug do programa deu para ver que o programa funcionou como esperado. Na simulação do proteus o programa
;	funcionou como esperado.
;		Na prática, o programa e o circuito funcionaram perfeitamente.
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
		
	loop:
	
		btfsc	botao ; Testa se o botao foi pressionado, se foi, pula uma linha
		goto	apaga_led ; Se não for, desvia para a label apaga_led
		bsf		led ; Se o botao foi pressionado, seta o led (RB7) em High (liga o led)
		goto	loop ; Retorna para label loop
		
	apaga_led:
	
		bcf		led ; Se o botao não foi pressionado, coloca led (RB7) em Low (apaga led)
		goto	loop ; Retorna para label loop
		
		end 
