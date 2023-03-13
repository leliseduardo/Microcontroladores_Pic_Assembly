;
;		O objetivo deste programa é utilizar a tensão de referência como saída analógica. A tensão de referência que 
;	antes foi usada em uma das entradas dos comparadores internos, internamente, agora será configurada para se conectar
;	ao pino RA2. Assim, a tensão de referência interna do Pic pode ser vista num de seus pinos, no caso RA2.
;		Para utilizar a tensão de referência como saída no pino RA2, deve-se configurar a flag VROE = 1, no registrador
;	VRCON. Ainda, o pino RA2 deve ser configurado como entrada digital, no registrador TRISA. Pode não fazer sentido, 
;	mas a tensão de referência é um periférico interno do Pic e é um circuito diferente do circuito dos ports e, logo,
;	para funcionar como saída no pino RA2, o registrador de direção (TRIS) deve configurar este pino como entrada.  
;		Para configurar a tensão de referência, deve-se definir se ela irá funcionar com "Low Range" ou "High Range". 
;	Para "Low Range", basta configurar a flag VRR = 1 no registrador VRCON. Neste caso, a tensão de referência responde
;	à equação abaixo:
;
;				VR<3:0>					|->			Sendo VR<3:0>: um valor de 0 a 15d 
;		Vref = --------- x VDD			|->			VDD: A tensão de alimentação do Pic
;				  24 					
;
;		Para variar a tensão de referência, basta variar o valor das flags VR<3:0>. Logo, como este registrador é de 
;	apenas 4 bits, pode-se ver que a tensão analógica não tem muita resolução, mas ainda sim varia de uma tensão mínima
;	até uma tensão máxima, em saltos que dependem da equação. Abaixo está a tensão mínima, a máxima e o salto de tensão:
;
;				 	  0				
;		Vref(min) = ----- x VDD	= 0V				Tensão mínima = 0V
;				  	  24 	
;
;				 	   	1d			
;		Vref(salto) = ----- x VDD = 0,2083V			Tensão de salto = 0,20833333V
;				  	    24 
;
;				      15d				
;		Vref(max) = ------- x VDD = 3,125V			Tensão máxima = 3,125V 
;				  	  24 
;
;		O datasheet recomenda, ainda, que seja conectado um buffer e um capacitor de estabilização de tensão no pino
;	RA2. O buffer permitirá que a saída forneça corrente suficiente para acionar pequenas cargas, como leds, ou acionar
;	cargas maiores através de transistores, MOSFET's e etc. No circuito dessa aula, no proteus, pode-se ver o buffer e o
;	capacitor conectador em RA2.
;		
;
;		Na simulação e na prática o circuito e o programa funcionaram perfeitamente. Com o multímetro, deu para medir
;	a tensão de referência no pino RA2 e a tensão de saída do buffer. As tensões estão abaixo:
;
;		Vref(RA2) = 3,16V 
;		Vbuffer(saida) = 3,21V 		
;

	list		p=16f628a					; Informa o microcontrolador utilizado
	

; --- Documentação ---

	#include	<p16f628a.inc>				; Inclui o documento que contém os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
; Configura clock em 4MHz, ativa o Power Up Timer e ativa o Master Clear

; --- Paginação de memória ---

	#define 	bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar banco 0 de memória
	#define 	bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar banco 1 de memória 
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTB,0				; Cria mnemônico para led1 em RA3
	#define 	led2 	PORTB,1				; Cria mnemônico para led2 em RA2
	#define		botao1	PORTB,7				; Cria mnemônico para botao1 em RB0
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Endereço de início para configuração de registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	
	endc									; Fim da configuração dos registradores de uso geral
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endereço de memória para o vetor de Reset
	
	goto 		inicio						; Desvia para label do programa principal
	
; --- Vetor de Interrupção ---

	org			H'0004'						; Origem do endereço de memória para o vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto --

	; Desenvolvimento da ISR...
	
	

; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; w = w (original)
	
	retfie									; Retorna para endereço que estava quando ocorreu a interrupção
	
; -- Fim da recuperação de contexto --


; --- Programa principal --- 

inicio:										; Cria label para programa principal

	bank1									; Seleciona o banco 1 de memória
	movlw		H'FF'						; w = FFh
	movwf		TRISA						; Configura todo PORTA como entrada, inclusive RA2, necessário para que a
											; a tensão de referência funcione neste pino
	movlw		H'FE'						; w = FEh 
	movwf		TRISB						; Configura apenas RB0 como saída digital, o resto como entrada
	movlw		H'EF'						; w = ACh
	movwf		VRCON						; Habilita a tensão de referência, conectada em RA2, Low Range, tensão máxima
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						; w = 07F
	movwf		CMCON						; Desliga os comparadores internos
	
	bcf			led1						; Inicia led1 em Low

; --- Loop infinito ---

loop:										; Cria label para loop infinito



	goto		loop						; Loop infinito
	

; --- Sub Rotinas --- 

	
	
	
; --- Fim do programa ---

	end										; Final do programa