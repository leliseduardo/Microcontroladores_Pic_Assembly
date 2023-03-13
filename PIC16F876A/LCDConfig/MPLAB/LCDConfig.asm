;
;		O objetivo deste programa � realizar a configura��o do display LCD, fazendo sua inicializa��o. Na linguagem C do
;	MikroC, no curso de Pic em C, foi utilizada uma biblioteca para usar o LCD. Aqui, � demonstrada a forma de se inicia-
;	liza-lo do zero.
;		O c�digo foi copiado da demonstra��o da aula, n�o fui eu que escrevi. Mas de qualquer forma, o c�digo foi intei-
;	ramente compreendido.
;
;		Na simula��o e na pr�tica o circuito e o programa funcionaram perfeitamente.	
;

; --- Listagem do Processador Utilizado ---
		list	p=16f876a					;utilizado PIC16F876A
		
		
;========================================================================================
; --- Op��o Geral ---
		radix	dec							;utilizar nota��o decimal, quando n�o dito o contr�rio
		
		
;========================================================================================
; --- Arquivos Inclusos no Projeto ---
		include <P16F876A.inc>
		
		
;========================================================================================
; --- FUSE Bits ---
; - Cristal de 4MHz
; - Desabilitamos o Watch Dog Timer
; - Habilita o Power Up Timer
; - Brown Out desabilitado
; - Sem programa��o em baixa tens�o, sem prote��o de c�digo, sem prote��o da mem�ria EEPROM
	__config _XT_OSC & _WDT_OFF & _PWRTE_OFF & _CP_OFF & _LVP_OFF & _BODEN_OFF
	
	
;========================================================================================
; --- Pagina��o de Mem�ria ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1	bsf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 1 de mem�ria
	

;========================================================================================
; --- Mapeamento de Hardware ---
	#define		LCD_DATA	PORTB			;dados LCD
	#define		RS			PORTA,1			;register select LCD
	#define		RW			PORTA,2			;read/write LCD
	#define		EN			PORTA,3			;enable LCD
	
	
	
;========================================================================================
; --- Registradores de Uso Geral ---
	cblock		H'20'						;In�cio da mem�ria dispon�vel para o usu�rio

	
	W_TEMP									;Registrador para armazenar o conte�do tempor�rio de work
	STATUS_TEMP								;Registrador para armazenar o conte�do tempor�rio de STATUS
	cmd										;Registrador para comandos do LCD
	T0										;Registrador auxiliar para temporiza��o
	T1										;Registrador auxiliar para temporiza��o	

 
	endc									;Final da mem�ria do usu�rio
	
	
;========================================================================================
; --- Vetor de RESET ---
	org			H'0000'						;Origem no endere�o 00h de mem�ria
	goto		inicio						;Desvia para a label in�cio
	
	
;========================================================================================
; --- Vetor de Interrup��o ---
	org			H'0004'						;As interrup��es deste processador apontam para este endere�o
	
; -- Salva Contexto --
	movwf 		W_TEMP						;Copia o conte�do de Work para W_TEMP
	swapf 		STATUS,W  					;Move o conte�do de STATUS com os nibbles invertidos para Work
	bank0									;Seleciona o banco 0 de mem�ria (padr�o do RESET) 
	movwf 		STATUS_TEMP					;Copia o conte�do de STATUS com os nibbles invertidos para STATUS_TEMP
; -- Final do Salvamento de Contexto --


 
; -- Recupera Contexto (Sa�da da Interrup��o) --
exit_ISR:

	swapf 		STATUS_TEMP,W				;Copia em Work o conte�do de STATUS_TEMP com os nibbles invertidos
	movwf 		STATUS 						;Recupera o conte�do de STATUS
	swapf 		W_TEMP,F 					;W_TEMP = W_TEMP com os nibbles invertidos 
	swapf 		W_TEMP,W  					;Recupera o conte�do de Work
	
	retfie									;Retorna da interrup��o
	
	
;========================================================================================	
; --- Principal ---
inicio:
	
	bank1									;seleciona o banco1 de mem�ria
	movlw		H'0E'						;move literal 0Eh para Work
	movwf		ADCON1						;apenas AN0 como anal�gico, justificado � esquerda
	movlw		H'31'						;move literal 31h para Work
	movwf		TRISA						;configura RA1, RA2 e RA3 como sa�da
	movlw		H'00'						;move literal 00h para Work
	movwf		TRISB						;configura PORTB como sa�da
		
	bank0									;seleciona o banco0 de mem�ria
	clrf		PORTA						;limpa PORTA
	clrf		PORTB						;limpa PORTB
	movlw		H'07'						;move literal 07h para work
	movwf		CMCON						;desabilita comparadores
	
	call		_500ms						;aguarda 500ms
	call		lcd_init					;inicializa LCD
	

	
 
	
	
;========================================================================================	
; --- Loop Infinito ---
loop:


	
	
	goto		loop						;desvia de volta para label loop
	
	
;========================================================================================	
; --- Desenvolvimento das Sub Rotinas ---



;========================================================================================
; --- Sub Rotina para Inicializar LCD ---
lcd_init:

	movlw   	H'38'           			;move literal 38h para work
    call    	lcd_command					;envia comando para LCD modo 8 bits
    										;LCD com 2 linhas
    										;Resolu��o dos caracteres: 5x7 pontos

    movlw   	H'0F'	    				;move literal 0Fh para work
    call    	lcd_command        			;liga Display
    										;liga Cursor
    										;habilita modo Blink

    movlw   	H'06'          				;move literal 06h para work
    call    	lcd_command        			;incremento do display/deslocamento do cursor

    movlw   	H'01'          				;move literal 01h para work
    call    	lcd_command        			;limpa display
    
    retlw   	H'00'	    				;retorna limpando work
    
    
;========================================================================================
; --- Sub Rotina para envio de Comandos LCD ---
lcd_command:
    movwf   	cmd            				;move o conte�do de work para cmd
    call    	BUSY_CHECK      			;aguarda LCD ficar pronto
  	bcf     	RW    						;LCD em modo leitura
    bcf     	RS    						;LCD em modo comando
	bsf     	EN     						;habilita LCD
    movf    	cmd,W          				;move conte�do de cmd para work
    movwf   	LCD_DATA        			;envia dado para o LCD
    bcf     	EN							;desabilita LCD
    retlw   	H'00'						;retorna limpando work


;========================================================================================
; --- Sub Rotina para checar a Busy Flag ---
BUSY_CHECK:
	bank1				    				;Seleciona banco 1 de mem�ria
    movlw   	H'FF'            			;move literal FFh para work
    movwf   	TRISB						;configura todo PORTB como entrada
    bank0				    				;Seleciona banco 0 de mem�ria
    bcf     	RS    						;LCD em modo comando
    bsf     	RW    						;LCD em modo escrita
    bsf     	EN    						;habilita LCD
    movf    	LCD_DATA,W     				;le o busy flag, endereco DDram 
    bcf     	EN    						;desabilita LCD
    andlw   	H'80'						;Limpa bits n�o utilizados
	btfss   	STATUS, Z					;chegou em zero?
    goto    	BUSY_CHECK					;n�o, continua teste
    
lcdnobusy:									;sim
    bcf     	RW  						;LCD em modo leitura     
    bank1				    				;Seleciona banco 1 de mem�ria
    movlw   	H'00'						;move literal 00h para work
    movwf   	TRISB						;configura todo PORTB como sa�da
    bank0				    				;Seleciona banco 0 de mem�ria
    retlw   	H'00'						;retorna limpando work


;========================================================================================
; --- Sub Rotina para atraso de 500ms ---
_500ms:										;Rotina para atraso de 500ms

	movlw		D'200'						;Move o valor para W
	movwf		T0							;Inicializa tempo0 

											; 4 ciclos de m�quina

aux1:
	movlw		D'250'						;Move o valor para W
	movwf		T1							;Inicializa tempo1
	
											; 2 ciclos de m�quina

aux2:
	nop										;no operation | 1 ciclo de m�quina
	nop										;no operation | 1 ciclo de m�quina
	nop										;no operation | 1 ciclo de m�quina
	nop										;no operation | 1 ciclo de m�quina
	nop										;no operation | 1 ciclo de m�quina
	nop										;no operation | 1 ciclo de m�quina
	nop										;no operation | 1 ciclo de m�quina

	decfsz		T1							;Decrementa tempo1 at� que seja igual a zero
	goto		aux2						;Vai para a label aux2 

											; 250 x 10 ciclos de m�quina = 2500 ciclos

	decfsz		T0							;Decrementa tempo0 at� que seja igual a zero
	goto		aux1						;Vai para a label aux1

											; 3 ciclos de m�quina

											; 2500 x 200 = 500000

	return									;Retorna ap�s a chamada da sub rotina
 
	
;========================================================================================	
; --- Final do Programa ---	
	end