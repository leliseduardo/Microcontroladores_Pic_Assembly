;
;		PIC16F84A			Clock = 4MHz
;
;		Este programa tem a fun��o de demonstrar o funcionamento das subrotinas. As subrotinas s�o rotinas de programa que se dese-
;	ja que sejam executadas em v�rios momentos do programa e, para economizar mem�ria, criamos uma subrotina que ser� chamada sempre
;	que se quiser executar tal rotina, ao inv�s de escrever v�rias vezes a mesma rotina.
;		Pode-se dizer que as subrotinas s�o equivalente �s fun��es da linguagem C.
;
;		Neste codigo ser�o usadas duas novas diretivas:
;	call -> Usada para chamar a subrotina em quest�o
;	return -> Retorna da subrotina para executar o resto do programa do loop infinito
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
	#define botao1 PORTB,RB0 ; Cria um mnem�nico para um bot�o, que estar� conectado ao RB0
	#define botao2 PORTB,RB1 ; Cria um mnem�nico para um bot�o, que estar� conectado ao RB1 
	
	; --- Sa�das ---
	#define led1 PORTB,RB7 ; Cria um mnem�nico para um led, conectado no pino RB7
	#define led2 PORTB,RB6 ; Cria um mnem�nico para um led, conectado ao pino RB6				
								
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
		movlw 	H'3F' ; Ou B'0011 1111', move este valor para o registradore de trabalho Work
		movwf	TRISB ; Transfere o valor do resgistrador Work (w) para o registrador TRISB, configurando apenas RB0
					  ; como sa�da digital, e o resto dos pinos do PORTB como entrada digital.
		bank0 ; Utiliza o mnem�nico bank0 para selecionar o banco 0 de mem�ria
		movlw	H'3F' ; Move este valor para o resgistrador de trabalho Work (w)
		movwf	PORTB ; Transfere o valor de w para o portb, iniciando todas as sa�das em High
		
	loop:
	
		call	leitura_botao1 ; Chama a sub-rotina leitura_botao1
		call	leitura_botao2 ; Chama a sub-rotina leitura_botao2
	
	goto	loop ; Retorna para label loop
	
	
	; --- Sub-rotinas ---
	
	leitura_botao1	; Sub-rotina leitura_botao1
	
		btfsc	botao1 ; Testa se o botao foi pressionado, se foi, pula uma linha
		goto	apaga_led1 ; Se n�o for, desvia para a label apaga_led1
		bsf		led1 ; Se o botao foi pressionado, seta o led2 (RB7) em High (liga o led)
		return ; Retorna para loop infinito
		
	apaga_led1:
	
		bcf		led1 ; Se o botao n�o foi pressionado, coloca led1 (RB7) em Low (apaga led)
		return ; Retorna para loop infinito
		
	leitura_botao2	; Sub-rotina leitura_botao2
	
		btfsc	botao2 ; Testa se o botao foi pressionado, se foi, pula uma linha
		goto	apaga_led2 ; Se n�o for, desvia para a label apaga_led2
		bsf		led2 ; Se o bot�o foi pressionado, seta o led2 (RB6) em High
		return ; Retorna para loop infinito
		
	apaga_led2
	
		bcf		led2 ; Se o bot�o n�o foi pressionado, coloca led2 (RB6) em Low
		return ; Retorna para loop infinito
		
		end 