;
;		PIC16F84A			Clock = 4MHz	Ciclo de máquina = 1/(4MHz/4) = 1us
;
;		Neste programa o objetivo é criar uma sub-rotina de delay, para que seja possível fazer programas com temporiza- 
;	ções. Para isso, é preciso que o programa fique preso dentro da sub-rotina de delay pelo tempo desejado que, no caso
;	será 500ms. Este delay será usado para piscar dois leds alternadamente.
;
;		Nesta aula utiliza-se dois comands novos:
;
;		decfsz = Decrementa file skip zero, que decrementa um registrador de uso geral e pula uma linha caso ele seja 
;	zero.
;		nop = não realiza nada, apenas gasta um ciclo de máquina
;
;		Para criar o delay de 500ms, a subrotina utiliza duas labels auxiliares e dois registradores de uso geral (ou
;	variáveis). A subrotina grava no primeiro registrador de uso geral o valor 200 decimal, e no segundo, através de uma
;	label auxiliar, 250 decimal. Na segunda label auxiliar são gastos 7 ciclos de máquina com o comando "nop", que não
;	realiza nada. Gasta mais um ciclo de máquina com o comando "decfsz" no registrador que contém o valor 250. Depois,
;	gasta dois ciclos de máquina com o comando "goto aux2", para retornar para a mesma label auxiliar (a segunda). Com 
;	isso, a segunda label auxiliar gasta 10 ciclos de máquina por execução, e a cada execução decrementa 1 do registrador
; 	que contém 250, totalizando em 2500 ciclos de máquina.
;		Após o registrador de 250 chegar a zero, ele decrementa 1 do registrador que contém 200. Logo após, recarrega o
;	registrador de 250 novamente com 250. Esse processo se repete até que o registrado com 200 chegue a zero e, daí, 
;	retorne ao loop infinito. 
;		Todo esse processo gasta 2500 x 200 = 500000 ciclo de máquina. Fazendo 500000 x ciclo de máquina, fica
;	500000 x 1us = 0,5s, que é o tempo que se queria. Assim, basta chamar a subrotina quando se quiser que o programa 
;	temporize 0,5s.
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
								
	; --- Saídas ---
	#define led1 PORTB,RB7 ; Cria um mnemônico para um led, conectado no pino RB7
	#define led2 PORTB,RB6 ; Cria um mnemônico para um led, conectado ao pino RB6				
								
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
		movlw 	H'3F' ; Ou B'0011 1111', move este valor para o registradore de trabalho Work
		movwf	TRISB ; Transfere o valor do resgistrador Work (w) para o registrador TRISB, configurando apenas RB0
					  ; como saída digital, e o resto dos pinos do PORTB como entrada digital.
		bank0 ; Utiliza o mnemônico bank0 para selecionar o banco 0 de memória
		movlw	H'3F' ; Move este valor para o resgistrador de trabalho Work (w)
		movwf	PORTB ; Transfere o valor de w para o portb, iniciando todas as saídas em High
		
	loop:
	
		bsf		led1 ; Acende led1
		bcf		led2 ; Apaga led2 
		call	delay500ms ; Desvia para a sub-rotina delay500ms
		bcf 	led1 ; Apaga led1 
		bsf		led2 ; Acende led2
		call 	delay500ms ; Desvia para a sub-rotina delay500ms
	
	goto	loop ; Retorna para label loop
	
	
	; --- Sub-rotinas ---
	
	delay500ms:	; Cria a sub-rotina
	
		movlw	D'200' ; Move o valor 200 decimal para W
		movwf	H'0C' ; Move o valor de W para o registrador de uso geral no endereço 0C
		
		aux1: ; Cria uma label auxiliar
		
			movlw	D'250' ; Move o valor decimal 250 para W
			movwf	H'0D' ; Move o valor de W para o registrado de uso geral no endereço 0D
			
		aux2: ; Cria outra label auxiliar
		
			nop
			nop
			nop
			nop
			nop
			nop
			nop ; Gasta 7 ciclo de máquina = 7us
			
			decfsz	H'0D' ; Decrementa o valor contido no endereço 0D e pula uma linha se o valor for zero
			goto	aux2 ; Desvia para a label aux2
			
			decfsz	H'0C' ; Decrementa o valor contido no endereço 0C e pula uma linha se o valor for zero
			goto 	aux1 ; Desvia o programa para a label aux1
			
			return ; Retorna para o loop infinito
			
			end
			