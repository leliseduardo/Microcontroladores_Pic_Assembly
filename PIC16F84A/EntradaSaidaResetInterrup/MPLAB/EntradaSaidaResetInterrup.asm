;
;		PIC16F84A			Clock = 4MHZ		
;
;		Neste programa ser� demonstrado como s�o configuradas alguma vari�veis de entrada, como bot�es, sa�das, como 
;	leds, como configurar o vetor de Reset e como configurar o vetor de interrup��o. A configura��o destes vetores 
;	consiste em setar o endere�o de mem�ria onde est�o ester vetores, de acordo com o datasheet. 
;
;	Alguns comandos novos ser�o usados:
;
;	org = informa a origem na posi��o de mem�ria
;	movlw = move uma literal para o registradow Work, que guarta o valor da literal
;	movwf = move o valor contido no registradow Work para algum outro registrador, seja especial ou de uso geral
; 
;		Registradores de uso geral s�o aquele que se usa para vari�veis, constantes, mnem�nicos. Os registradores espe-
;	ciais s�o aqueles pr�prios do microcontrolador, usados para configurar alguma opera��o do mcu.
;
;	H'XXXX' representa n�mero hexadecimais
;	D'XXXX' representa n�mero decimais
;	B'XXXX' representa n�mero bin�rios
;	A'XXXX' representa caracteres da tabela ASCII
;
;	Por padr�o, o banco 0 de mem�ria j� inicia selecionado.
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
		movlw 	H'7F' ; Ou B'0111 1111', move este valor para o registradore de trabalho Work
		movwf	TRISB ; Transfere o valor do resgistrador Work (w) para o registrador TRISB, configurando apenas RB0
					  ; como sa�da digital, e o resto dos pinos do PORTB como entrada digital.
		bank0 ; Utiliza o mnem�nico bank0 para selecionar o banco 0 de mem�ria
		
		end 