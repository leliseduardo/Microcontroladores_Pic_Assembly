;
;		O objetivo deste programa � demonstrar no display a atualiza��o de um registrador, que ir� contar de 0 a 255 e
;	recome�ar a contagem. Esta demonstra��o visa criar um projeto base para a demonstra��o de registradores no LCD.
;		Este projeto foi copiado do c�digo demonstrado na aula, mas foi completamente compreendido.
;
;		Na simula��o e na pr�tica o circuito e o programa funcionaram perfeitamente.
;


;========================================================================================
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
	REG_AUX									;Registrador auxiliar para uso na convers�o bin/dec
	UNI										;Armazena unidade
	DEZ										;Armazena dezena
	CEN										;Armazena centena
	DISP									;Registrador a ser exibido no display

 
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
	clrf		DISP						;limpa registrador DISP
	
	call		_500ms						;aguarda 500ms
	call		lcd_init					;inicializa LCD
	call		lcd_hello					;chama sub rotina para enviar mensagem para LCD	

	
 
	
	
;========================================================================================	
; --- Loop Infinito ---
loop:

	movf		DISP,W						;move conte�do de DISP para work
	call		conv_binToDec				;chama sub rotina para ajuste decimal
	movlw		H'C7' 						;posiciona cursor na linha 2, coluna 6
	call		lcd_command					;envia comando para LCD
	movf		CEN,W						;move conte�do de CEN para work
	addlw		H'30'						;soma com 30h (ASCII)
	call		lcd_char					;envia para LCD
	movf		DEZ,W						;move conte�do de DEZ para work
	addlw		H'30'						;soma com 30h (ASCII)
	call		lcd_char					;envia para LCD
	movf		UNI,W						;move conte�do de UNI para work
	addlw		H'30'						;soma com 30h (ASCII)
	call		lcd_char					;envia para LCD
	incf		DISP,F						;incrementa conte�do de DISP
	call		_500ms						;aguarda 500ms

	goto		loop						;desvia de volta para label loop
	
	
;========================================================================================	
; --- Desenvolvimento das Sub Rotinas ---


;========================================================================================
; --- Sub Rotina para enviar mensagem para o LCD ---
lcd_hello:
	movlw   	' '							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
	movlw   	'H'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
	movlw   	'e'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	'l'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	'l'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw  	 	'o'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	' '							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	'W'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	'o'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	'r'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	'l'							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
    movlw   	'd'							;move caractere para work
    call   		lcd_char					;envia caractere para o LCD
    movlw   	' '							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
	movlw   	' '							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
	movlw   	' '							;move caractere para work
    call    	lcd_char					;envia caractere para o LCD
;	movlw   	H'C0'						;instru��o para mudar de linha
;	call    	lcd_command	        		;envia comando para o LCD

    retlw   	H'00'						;retorna limpando work
	      

;========================================================================================
; --- Sub Rotina para enviar um caractere para o LCD ---
lcd_char:
	movwf   	cmd           				;move conte�do de work para cmd
    call    	BUSY_CHECK      			;aguarda LCD ficar pronto
    bcf     	RW    						;LCD em modo leitura
    bsf     	RS    						;LCD em modo comando
    bsf     	EN     						;habilita LCD
    movf    	cmd,W          				;move conte�do de cmd para work
    movwf   	LCD_DATA        			;envia dado para o LCD
    bcf     	EN							;desabilita o LCD
    retlw   	H'00'						;retorna limpando work
    
    
;========================================================================================
; --- Sub Rotina para Inicializar LCD ---
lcd_init:

	movlw   	H'38'           			;move literal 38h para work
    call    	lcd_command					;envia comando para LCD modo 8 bits
    										;LCD com 2 linhas
    										;Resolu��o dos caracteres: 5x7 pontos

    movlw   	H'0C'	    				;move literal 0Fh para work
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
; --- Sub rotina de convers�o Bin�rio para Decimal ---
;**********************************************************************
;* Ajuste decimal
;* W [HEX] =  dezena [DEC] ; unidade [DEC]
;* Conforme indicado no livro - "Conectando o PIC - Recursos avan�ados"
;* Autores Nicol�s C�sar Lavinia e David Jos� de Souza
;*
;* Alterada por M�rcio Jos� Soares para uso com n�meros com duas dezenas e uma unidade
;* Artigo dispon�vel em arnerobotics.com.br
;*
;* Adaptado por Wagner Rambo para aplica��o no projeto Volt�metro
;*
;* Recebe o valor atual de Work e retorna os registradores de usu�rio
;* CENTENA, DEZ e UNI o n�mero BCD correspondente.

conv_binToDec:

	movwf		REG_AUX						;salva valor a converter em REG_AUX
	clrf		UNI							;limpa unidade
	clrf		DEZ							;limpa dezena
	clrf		CEN							;limpa centena

	movf		REG_AUX,F					;REG_AUX = REG_AUX
	btfsc		STATUS,Z					;valor a converter resultou em zero?
	return									;Sim. Retorna

start_adj:
						
	incf		UNI,F						;N�o. Incrementa UNI
	movf		UNI,W						;move o conte�do de UNI para Work
	xorlw		H'0A'						;W = UNI XOR 10d
	btfss		STATUS,Z					;Resultou em 10d?
	goto		end_adj						;N�o. Desvia para end_adj
						 
	clrf		UNI							;Sim. Limpa registrador UNI
	movf		DEZ,W						;Move o conte�do de DEZ para Work
	xorlw		H'09'						;W = DEZ_A XOR 9d
	btfss		STATUS,Z					;Resultou em 9d?
	goto		incDezA						;N�o, valor menor que 9. Incrementa DEZ_A
	clrf		DEZ							;Sim. Limpa registrador DEZ
	incf		CEN,F						;Incrementa registrador CEN
	goto		end_adj						;Desvia para end_adj
	
incDezA:
	incf		DEZ,F						;Incrementa DEZ
	
end_adj:
	decfsz		REG_AUX,F					;Decrementa REG_AUX. Fim da convers�o ?
	goto		start_adj					;N�o. Continua
	return									;Sim. Retorna
 
	
;========================================================================================	
; --- Final do Programa ---	
	end