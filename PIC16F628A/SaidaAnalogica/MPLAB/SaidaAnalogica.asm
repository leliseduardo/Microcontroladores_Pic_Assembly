;
;		O objetivo deste programa � utilizar a tens�o de refer�ncia como sa�da anal�gica. A tens�o de refer�ncia que 
;	antes foi usada em uma das entradas dos comparadores internos, internamente, agora ser� configurada para se conectar
;	ao pino RA2. Assim, a tens�o de refer�ncia interna do Pic pode ser vista num de seus pinos, no caso RA2.
;		Para utilizar a tens�o de refer�ncia como sa�da no pino RA2, deve-se configurar a flag VROE = 1, no registrador
;	VRCON. Ainda, o pino RA2 deve ser configurado como entrada digital, no registrador TRISA. Pode n�o fazer sentido, 
;	mas a tens�o de refer�ncia � um perif�rico interno do Pic e � um circuito diferente do circuito dos ports e, logo,
;	para funcionar como sa�da no pino RA2, o registrador de dire��o (TRIS) deve configurar este pino como entrada.  
;		Para configurar a tens�o de refer�ncia, deve-se definir se ela ir� funcionar com "Low Range" ou "High Range". 
;	Para "Low Range", basta configurar a flag VRR = 1 no registrador VRCON. Neste caso, a tens�o de refer�ncia responde
;	� equa��o abaixo:
;
;				VR<3:0>					|->			Sendo VR<3:0>: um valor de 0 a 15d 
;		Vref = --------- x VDD			|->			VDD: A tens�o de alimenta��o do Pic
;				  24 					
;
;		Para variar a tens�o de refer�ncia, basta variar o valor das flags VR<3:0>. Logo, como este registrador � de 
;	apenas 4 bits, pode-se ver que a tens�o anal�gica n�o tem muita resolu��o, mas ainda sim varia de uma tens�o m�nima
;	at� uma tens�o m�xima, em saltos que dependem da equa��o. Abaixo est� a tens�o m�nima, a m�xima e o salto de tens�o:
;
;				 	  0				
;		Vref(min) = ----- x VDD	= 0V				Tens�o m�nima = 0V
;				  	  24 	
;
;				 	   	1d			
;		Vref(salto) = ----- x VDD = 0,2083V			Tens�o de salto = 0,20833333V
;				  	    24 
;
;				      15d				
;		Vref(max) = ------- x VDD = 3,125V			Tens�o m�xima = 3,125V 
;				  	  24 
;
;		O datasheet recomenda, ainda, que seja conectado um buffer e um capacitor de estabiliza��o de tens�o no pino
;	RA2. O buffer permitir� que a sa�da forne�a corrente suficiente para acionar pequenas cargas, como leds, ou acionar
;	cargas maiores atrav�s de transistores, MOSFET's e etc. No circuito dessa aula, no proteus, pode-se ver o buffer e o
;	capacitor conectador em RA2.
;		
;
;		Na simula��o e na pr�tica o circuito e o programa funcionaram perfeitamente. Com o mult�metro, deu para medir
;	a tens�o de refer�ncia no pino RA2 e a tens�o de sa�da do buffer. As tens�es est�o abaixo:
;
;		Vref(RA2) = 3,16V 
;		Vbuffer(saida) = 3,21V 		
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	

; --- Documenta��o ---

	#include	<p16f628a.inc>				; Inclui o documento que cont�m os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura clock em 4MHz, ativa o Power Up Timer e ativa o Master Clear

; --- Pagina��o de mem�ria ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnem�nico para selecionar banco 0 de mem�ria
	#define 	bank1	bsf	STATUS,RP0		; Cria mnem�nico para selecionar banco 1 de mem�ria 
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTB,0				; Cria mnem�nico para led1 em RA3
	#define 	led2 	PORTB,1				; Cria mnem�nico para led2 em RA2
	#define		botao1	PORTB,7				; Cria mnem�nico para botao1 em RB0
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endere�o de in�cio para configura��o de registradores de uso geral
	
	W_TEMP									; Armazena o conte�do de w temporariamente
	STATUS_TEMP								; Armazena o conte�do de STATUS temporariamente
	
	endc									; Fim da configura��o dos registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endere�o de mem�ria para o vetor de Reset
	
	goto 		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrup��o ---

	org			H'0004'						; Origem do endere�o de mem�ria para o vetor de Interrup��o
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de mem�ria
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	

; -- Recupera��o de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Retorna para endere�o que estava quando ocorreu a interrup��o
	
; -- Fim da recupera��o de contexto --


; --- Programa principal --- 

inicio:										; Cria label para programa principal

	bank1									; Seleciona o banco 1 de mem�ria
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada, inclusive RA2, necess�rio para que a
											; a tens�o de refer�ncia funcione neste pino
	movlw		H'FE'						; w = FEh 
	movwf		TRISB						; Configura apenas RB0 como sa�da digital, o resto como entrada
	movlw		H'EF'						; w = ACh
	movwf		VRCON						; Habilita a tens�o de refer�ncia, conectada em RA2, Low Range, tens�o m�xima
	bank0									; Seleciona banco 0 de mem�ria
	movlw		H'07'						; w = 07F
	movwf		CMCON						; Desliga os comparadores internos
	
	bcf			led1						; Inicia led1 em Low

; --- Loop infinito ---

loop:										; Cria label para loop infinito



	goto		loop						; Loop infinito
	

; --- Sub Rotinas --- 

	
	
	
; --- Fim do programa ---

	end										; Final do programa