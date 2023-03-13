;
;		O objetivo deste programa é demonstrar no display a atualização de um registrador, que irá contar de 0 a 255 e
;	recomeçar a contagem. Esta demonstração visa criar um projeto base para a demonstração de registradores no LCD.
;		Este projeto foi copiado do código demonstrado na aula, mas foi completamente compreendido.
;
;		Na simulação e na prática o circuito e o programa funcionaram perfeitamente.
;


;========================================================================================
; --- Listagem do Processador Utilizado ---
		list	p=16f876a					;utilizado PIC16F876A
		
		
;========================================================================================
; --- Opção Geral ---
		radix	dec							;utilizar notação decimal, quando não dito o contrário
		
		
;========================================================================================
; --- Arquivos Inclusos no Projeto ---
		include <P16F876A.inc>
		
		
;========================================================================================
; --- FUSE Bits ---
; - Cristal de 4MHz
; - Desabilitamos o Watch Dog Timer
; - Habilita o Power Up Timer
; - Brown Out desabilitado
; - Sem programação em baixa tensão, sem proteção de código, sem proteção da memória EEPROM
	__config _XT_OSC & _WDT_OFF & _PWRTE_OFF & _CP_OFF & _LVP_OFF & _BODEN_OFF
	
	
;========================================================================================
; --- Paginação de Memória ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 0 de memória
	#define		bank1	bsf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 1 de memória
	

;========================================================================================
; --- Mapeamento de Hardware ---
	#define		LCD_DATA	PORTB			;dados LCD
	#define		RS			PORTA,1			;register select LCD
	#define		RW			PORTA,2			;read/write LCD
	#define		EN			PORTA,3			;enable LCD
	
	
	
;========================================================================================
; --- Registradores de Uso Geral ---
	cblock		H'20'						;Início da memória disponível para o usuário

	
	W_TEMP									;Registrador para armazenar o conteúdo temporário de work
	STATUS_TEMP								;Registrador para armazenar o conteúdo temporário de STATUS
	cmd										;Registrador para comandos do LCD
	T0										;Registrador auxiliar para temporização
	T1										;Registrador auxiliar para temporização	
	REG_AUX									;Registrador auxiliar para uso na conversão bin/dec
	UNI										;Armazena unidade
	DEZ										;Armazena dezena
	CEN										;Armazena centena
	DISP									;Registrador a ser exibido no display

 
	endc									;Final da memória do usuário
	
	
;========================================================================================
; --- Vetor de RESET ---
	org			H'0000'						;Origem no endereço 00h de memória
	goto		inicio						;Desvia para a label início
	
	
;========================================================================================
; --- Vetor de Interrupção ---
	org			H'0004'						;As interrupções deste processador apontam para este endereço
	
; -- Salva Contexto --
	movwf 		W_TEMP						;Copia o conteúdo de Work para W_TEMP
	swapf 		STATUS,W  					;Move o conteúdo de STATUS com os nibbles invertidos para Work
	bank0									;Seleciona o banco 0 de memória (padrão do RESET) 
	movwf 		STATUS_TEMP					;Copia o conteúdo de STATUS com os nibbles invertidos para STATUS_TEMP
; -- Final do Salvamento de Contexto --


 
; -- Recupera Contexto (Saída da Interrupção) --
exit_ISR:

	swapf 		STATUS_TEMP,W				;Copia em Work o conteúdo de STATUS_TEMP com os nibbles invertidos
	movwf 		STATUS 						;Recupera o conteúdo de STATUS
	swapf 		W_TEMP,F 					;W_TEMP = W_TEMP com os nibbles invertidos 
	swapf 		W_TEMP,W  					;Recupera o conteúdo de Work
	
	retfie									;Retorna da interrupção
	
	
;========================================================================================	
; --- Principal ---
inicio:
	
	bank1									;seleciona o banco1 de memória
	movlw		H'0E'						;move literal 0Eh para Work
	movwf		ADCON1						;apenas AN0 como analógico, justificado à esquerda
	movlw		H'31'						;move literal 31h para Work
	movwf		TRISA						;configura RA1, RA2 e RA3 como saída
	movlw		H'00'						;move literal 00h para Work
	movwf		TRISB						;configura PORTB como saída
		
	bank0									;seleciona o banco0 de memória
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

	movf		DISP,W						;move conteúdo de DISP para work
	call		conv_binToDec				;chama sub rotina para ajuste decimal
	movlw		H'C7' 						;posiciona cursor na linha 2, coluna 6
	call		lcd_command					;envia comando para LCD
	movf		CEN,W						;move conteúdo de CEN para work
	addlw		H'30'						;soma com 30h (ASCII)
	call		lcd_char					;envia para LCD
	movf		DEZ,W						;move conteúdo de DEZ para work
	addlw		H'30'						;soma com 30h (ASCII)
	call		lcd_char					;envia para LCD
	movf		UNI,W						;move conteúdo de UNI para work
	addlw		H'30'						;soma com 30h (ASCII)
	call		lcd_char					;envia para LCD
	incf		DISP,F						;incrementa conteúdo de DISP
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
;	movlw   	H'C0'						;instrução para mudar de linha
;	call    	lcd_command	        		;envia comando para o LCD

    retlw   	H'00'						;retorna limpando work
	      

;========================================================================================
; --- Sub Rotina para enviar um caractere para o LCD ---
lcd_char:
	movwf   	cmd           				;move conteúdo de work para cmd
    call    	BUSY_CHECK      			;aguarda LCD ficar pronto
    bcf     	RW    						;LCD em modo leitura
    bsf     	RS    						;LCD em modo comando
    bsf     	EN     						;habilita LCD
    movf    	cmd,W          				;move conteúdo de cmd para work
    movwf   	LCD_DATA        			;envia dado para o LCD
    bcf     	EN							;desabilita o LCD
    retlw   	H'00'						;retorna limpando work
    
    
;========================================================================================
; --- Sub Rotina para Inicializar LCD ---
lcd_init:

	movlw   	H'38'           			;move literal 38h para work
    call    	lcd_command					;envia comando para LCD modo 8 bits
    										;LCD com 2 linhas
    										;Resolução dos caracteres: 5x7 pontos

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
    movwf   	cmd            				;move o conteúdo de work para cmd
    call    	BUSY_CHECK      			;aguarda LCD ficar pronto
  	bcf     	RW    						;LCD em modo leitura
    bcf     	RS    						;LCD em modo comando
	bsf     	EN     						;habilita LCD
    movf    	cmd,W          				;move conteúdo de cmd para work
    movwf   	LCD_DATA        			;envia dado para o LCD
    bcf     	EN							;desabilita LCD
    retlw   	H'00'						;retorna limpando work


;========================================================================================
; --- Sub Rotina para checar a Busy Flag ---
BUSY_CHECK:
	bank1				    				;Seleciona banco 1 de memória
    movlw   	H'FF'            			;move literal FFh para work
    movwf   	TRISB						;configura todo PORTB como entrada
    bank0				    				;Seleciona banco 0 de memória
    bcf     	RS    						;LCD em modo comando
    bsf     	RW    						;LCD em modo escrita
    bsf     	EN    						;habilita LCD
    movf    	LCD_DATA,W     				;le o busy flag, endereco DDram 
    bcf     	EN    						;desabilita LCD
    andlw   	H'80'						;Limpa bits não utilizados
	btfss   	STATUS, Z					;chegou em zero?
    goto    	BUSY_CHECK					;não, continua teste
    
lcdnobusy:									;sim
    bcf     	RW  						;LCD em modo leitura     
    bank1				    				;Seleciona banco 1 de memória
    movlw   	H'00'						;move literal 00h para work
    movwf   	TRISB						;configura todo PORTB como saída
    bank0				    				;Seleciona banco 0 de memória
    retlw   	H'00'						;retorna limpando work


;========================================================================================
; --- Sub Rotina para atraso de 500ms ---
_500ms:										;Rotina para atraso de 500ms

	movlw		D'200'						;Move o valor para W
	movwf		T0							;Inicializa tempo0 

											; 4 ciclos de máquina

aux1:
	movlw		D'250'						;Move o valor para W
	movwf		T1							;Inicializa tempo1
	
											; 2 ciclos de máquina

aux2:
	nop										;no operation | 1 ciclo de máquina
	nop										;no operation | 1 ciclo de máquina
	nop										;no operation | 1 ciclo de máquina
	nop										;no operation | 1 ciclo de máquina
	nop										;no operation | 1 ciclo de máquina
	nop										;no operation | 1 ciclo de máquina
	nop										;no operation | 1 ciclo de máquina

	decfsz		T1							;Decrementa tempo1 até que seja igual a zero
	goto		aux2						;Vai para a label aux2 

											; 250 x 10 ciclos de máquina = 2500 ciclos

	decfsz		T0							;Decrementa tempo0 até que seja igual a zero
	goto		aux1						;Vai para a label aux1

											; 3 ciclos de máquina

											; 2500 x 200 = 500000

	return									;Retorna após a chamada da sub rotina
	

;========================================================================================
; --- Sub rotina de conversão Binário para Decimal ---
;**********************************************************************
;* Ajuste decimal
;* W [HEX] =  dezena [DEC] ; unidade [DEC]
;* Conforme indicado no livro - "Conectando o PIC - Recursos avançados"
;* Autores Nicolás César Lavinia e David José de Souza
;*
;* Alterada por Márcio José Soares para uso com números com duas dezenas e uma unidade
;* Artigo disponível em arnerobotics.com.br
;*
;* Adaptado por Wagner Rambo para aplicação no projeto Voltímetro
;*
;* Recebe o valor atual de Work e retorna os registradores de usuário
;* CENTENA, DEZ e UNI o número BCD correspondente.

conv_binToDec:

	movwf		REG_AUX						;salva valor a converter em REG_AUX
	clrf		UNI							;limpa unidade
	clrf		DEZ							;limpa dezena
	clrf		CEN							;limpa centena

	movf		REG_AUX,F					;REG_AUX = REG_AUX
	btfsc		STATUS,Z					;valor a converter resultou em zero?
	return									;Sim. Retorna

start_adj:
						
	incf		UNI,F						;Não. Incrementa UNI
	movf		UNI,W						;move o conteúdo de UNI para Work
	xorlw		H'0A'						;W = UNI XOR 10d
	btfss		STATUS,Z					;Resultou em 10d?
	goto		end_adj						;Não. Desvia para end_adj
						 
	clrf		UNI							;Sim. Limpa registrador UNI
	movf		DEZ,W						;Move o conteúdo de DEZ para Work
	xorlw		H'09'						;W = DEZ_A XOR 9d
	btfss		STATUS,Z					;Resultou em 9d?
	goto		incDezA						;Não, valor menor que 9. Incrementa DEZ_A
	clrf		DEZ							;Sim. Limpa registrador DEZ
	incf		CEN,F						;Incrementa registrador CEN
	goto		end_adj						;Desvia para end_adj
	
incDezA:
	incf		DEZ,F						;Incrementa DEZ
	
end_adj:
	decfsz		REG_AUX,F					;Decrementa REG_AUX. Fim da conversão ?
	goto		start_adj					;Não. Continua
	return									;Sim. Retorna
 
	
;========================================================================================	
; --- Final do Programa ---	
	end