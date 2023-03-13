;
;		PIC16F84A			Clock = 4MHZ		
;
;		Neste programa será demonstrado como são configuradas alguma variáveis de entrada, como botões, saídas, como 
;	leds, como configurar o vetor de Reset e como configurar o vetor de interrupção. A configuração destes vetores 
;	consiste em setar o endereço de memória onde estão ester vetores, de acordo com o datasheet. 
;
;	Alguns comandos novos serão usados:
;
;	org = informa a origem na posição de memória
;	movlw = move uma literal para o registradow Work, que guarta o valor da literal
;	movwf = move o valor contido no registradow Work para algum outro registrador, seja especial ou de uso geral
; 
;		Registradores de uso geral são aquele que se usa para variáveis, constantes, mnemônicos. Os registradores espe-
;	ciais são aqueles próprios do microcontrolador, usados para configurar alguma operação do mcu.
;
;	H'XXXX' representa número hexadecimais
;	D'XXXX' representa número decimais
;	B'XXXX' representa número binários
;	A'XXXX' representa caracteres da tabela ASCII
;
;	Por padrão, o banco 0 de memória já inicia selecionado.
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
		movlw 	H'7F' ; Ou B'0111 1111', move este valor para o registradore de trabalho Work
		movwf	TRISB ; Transfere o valor do resgistrador Work (w) para o registrador TRISB, configurando apenas RB0
					  ; como saída digital, e o resto dos pinos do PORTB como entrada digital.
		bank0 ; Utiliza o mnemônico bank0 para selecionar o banco 0 de memória
		
		end 