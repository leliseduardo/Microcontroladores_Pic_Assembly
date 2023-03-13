;
;		O objetivo deste programa é utilizar o display para visualizar a tensão lida no ADC. Agora, o display irá mostrar
;	a tensão lida de entrada no ADC, depois de todo equacionamento, utilizando as subrotinas de multiplicação de divisão
;	e a subrotina de conversão de binário para decimal. O display irá mostrar uma tensão de 0V a 25V.
;		Este projeto vem sendo desvenvolvido através das últimas aulas e, neste aqui, encerra-se o voltímetro ultilizando
;	os display de 7 segmentos.
;
;		Na prática o programa e o circuito funcionaram como esperado.
;

	list p=16f876a							; Informa o microcontrolador utilizado
	
	
; --- Documentação ---


	#include	<p16f876a.inc>				; Inclui o arquivo que contém os registradores do Pic
	
	
; --- Fuse bits ---

	
	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF  & _CP_OFF & _CPD_OFF
	
	; Configura clock  4MHz, liga o Power Up Timer e desliga o Master Clear
	
	
; --- Paginação de memória ---

	
	#define 	bank0	bcf	STATUS,RP0		; Cria mnemônico para selecionar o banco 0 de memória
	#define		bank1	bsf	STATUS,RP0		; Cria mnemônico para selecionar o banco 1 de memória
	
	
; --- Mapeamento de hardware ---

	#define		digit1	PORTB,3				;digito de controle da centena do display
	#define     digit2  PORTB,2				;digito de controle da dezena do display
	#define		digit3	PORTB,1				;digito de controle da unidade do display
	
	
; --- Registradores de uso geral ---


	cblock		H'20'						; Endereço de inicio para configuração de registradores de uso geral
	
	W_TEMP									; Armazena o conteúdo de w temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	adc										; Armazena a leitura de ADC
	
	REG1H									;byte alto registrador 1 de 16 bits utilizado na rotina de divisão
	REG1L									;byte baixo registrador 1 de 16 bits utilizado na rotina de divisão
	REG2H									;byte alto registrador 2 de 16 bits utilizado na rotina de divisão
	REG2L									;byte baixo registrador 2 de 16 bits utilizado na rotina de divisão
	REG3H									;byte alto registrador 3 de 16 bits utilizado na rotina de divisão
	REG3L									;byte baixo registrador 3 de 16 bits utilizado na rotina de divisão
	REG4H									;byte alto registrador 4 de 16 bits utilizado na rotina de divisão
	REG4L									;byte baixo registrador 4 de 16 bits utilizado na rotina de divisão
	AUX_H									;byte baixo de registrador de 16 bits para retornar valor da div
	AUX_L									;byte baixo de registrador de 16 bits para retornar valor da div
	AUX_TEMP								;contador temporário usado na rotina de divisão
	REG_MULT1								;registrador 1 para multiplicação
	REG_MULT2								;registrador 2 para multiplicação
	REG_AUX									;registrador auxiliar
	UNI										;armazena unidade
	DEZ_A									;armazena unidade da dezena
	DEZ_B									;armazena dezena
	
	counter									;Registrador auxiliar de contagem
	CEN_DISP								;Centena do número exibido no display
	DEZ_DISP								;Dezena do número exibido no display
	UNI_DISP								;Unidade do número exibido no display
	
	
	endc									; Fim da configuração de registradores de uso geral
	
	cont1		equ		H'23'				; Contador auxiliar no banco 0 de memória
	cont2		equ		H'A1'				; Contador auxiliar no banco 1 de memória
	
; --- Vetor de Reset ---

	
	org			H'0000'						; Endereço de origem do vetor de Reset
	
	goto 		inicio						; Desvia para o programa principal	
	
	
; --- Vetor de Interrupção ---

	
	org			H'0004'						; Endereço de origem do vetor de Interrupção
	
; -- Salvamento de contexto --

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona o banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)
	
; -- Fim do salvamento de contexto

	; Desenvolvimento da ISR...
	
	btfss		INTCON,T0IF					;Houve overflow do Timer0?
	goto		exit_ISR					;Não, desvia para saída da interrupção
	bcf			INTCON,T0IF					;Sim, limpa flag
	
	
	btfsc		digit1						;Digito da centena ativado?
	goto		copy_dez					;Sim, desvia para atualizar dez
	btfsc		digit2						;Não. Digito da dez ativado?
	goto		copy_uni					;Sim, desvia para atualizar unidade
	btfsc		digit3						;Não. Digito da unidade ativado?
 											;Sim, atualiza centena
 	
copy_cen:

	bcf			digit2						;Desliga digito da dezena
	bcf			digit3						;Desliga digito da unidade
	clrf		PORTC						;limpa PORTC
	bsf			digit1						;Liga digito da centena
	movf		CEN_DISP,W					;move conteúdo de centena para work
	call		send_disp					;chama sub rotina para atualizar display
	movwf		PORTC						;PORTC recebe o dado convertido
	goto		exit_ISR					;desvia para saída da interrupção
	
	
copy_dez:

	bcf			digit3						;Desliga digito da unidade
	bcf			digit1						;Desliga digito da centena
	clrf		PORTC						;limpa PORTC
	bsf			digit2						;Liga digito mais significativo
	movf		DEZ_DISP,W					;move conteúdo de dezena para work
	call		send_disp					;chama sub rotina para atualizar display
	movwf		PORTC						;PORTC recebe o dado convertido
	goto		exit_ISR					;desvia para saída da interrupção
	
copy_uni:

	bcf			digit1						;Limpa digito da centena
	bcf			digit2						;Limpa digito da dezena
	clrf		PORTC						;Limpa PORTC
	bsf			digit3						;Liga digito da unidade
	movf		UNI_DISP,W					;move conteúdo de unidade para work
	call		send_disp					;chama sub rotina para atualizar display
	movwf		PORTC						;PORTC recebe o dado convertido
	;goto		exit_ISR					;desvia para saída da interrupção
	
; -- Recuperação de contexto --

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS (original)
	movwf		STATUS						; STATUS = STATUS (original)
	swapf		W_TEMP,F					; W_TEMP = w (com nibbles invertidos)
	swapf		W_TEMP,w					; W_TEMP = w (original)
	
	retfie									; Retorna para o endereço que estava quando ocorreu a interrupção
	
; -- Fim da recuperação de contexto --


; --- Programa principal ---

inicio:										; Cria label do programa principal

	movlw		H'A0'						;move literal 00h para Work
	movwf		INTCON						;habilita interrupção global e do Timer0

	bank1									; Seleciona banco 1 de memória
	movlw		H'FF'						; w = FF
	movwf		TRISA						; Configura todo PORTA como entrada
	movlw		H'F1'						; w = 00
	movwf		TRISB						; Configura RB1, RB2 e RB3 como saída digital
	movlw		H'80'						; w = 00
	movwf		TRISC						; Configura apenas RB7 como entrada digital, o resto como saída
	movlw		H'D3'						;move literal D3h para Work
	movwf		OPTION_REG					;Timer0 incrementa com ciclo de máquina, ps 1:32
	call 		configura_ADC				; Chama subrotina configura_ADC
	bank0									; Seleciona banco 0 de memória
	movlw		H'07'						;move literal 07h para work
	movwf		CMCON						;desabilita comparadores
	
	bcf			digit1						;desativa digito da centena
	clrf		UNI_DISP					;limpa unidade do display
	clrf		DEZ_DISP					;limpa dezena do display
	clrf		CEN_DISP					;limpa centena do display

; -- Loop infinito --

loop:										; Cria label para loop infinito

	bsf			ADCON0,GO_DONE				; Inicia leitura do ADC
	
espera_leitura:

	btfsc		ADCON0,GO_DONE				;GO_DONE limpo?
	goto		espera_leitura				;Não. Aguarda
	
	movf		ADRESH,W					;Sim. Move conteúdo de ADRESH em Work
	
	
	movwf		REG_MULT1					;move conteúdo de Work para REG_MULT1
	movlw		D'250'						;move literal 250 para Work
	movwf		REG_MULT2					;carrega 250 em REG_MULT2
	call		multip						;chama sub rotina para multiplicação
	movf		AUX_H,W						;move conteúdo de AUX_H para Work
	movwf		REG2H						;armazena resultado da multiplicação
	movf		AUX_L,W						;move conteúdo de AUX_L para Work
	movwf		REG2L						;armazena resultado da multiplicação
	clrf		REG1H						;limpa REG1H
	movlw		D'255'						;move 255 para WOrk
	movwf		REG1L						;armazena 255 em REG1L
	call		divid						;chama sub rotina para divisão
	movf		REG2L,W						;move conteúdo de REG2L para Work
	
	
	call		conv_binToDec				;chama sub rotina para conversão binária em decimal
	
	movf		UNI,W						;move conteúdo de UNI para Work
	movwf		UNI_DISP					;atualiza unidade do display
	movf		DEZ_A,W						;move conteúdo de DEZ_A para Work
	movwf		DEZ_DISP					;atualiza dezena do display
	movf		DEZ_B,W						;move conteúdo de DEZ_B para Work
	movwf		CEN_DISP					;atualiza centena do display


	goto		loop						; Desvia para loop infinito
	
	
	
; --- SubRotinas ---

configura_ADC:

	bank1									; Seleciona o banco 1 de memória
	movlw		H'0E'						; w = OEh
	movwf		ADCON1						; Justificado a esquerda, Fosc/2, apenas AN0 habilitado
	bank0									; Seleciona o banco 0 de memória
	movlw		H'41'						; w = 41h
	movwf		ADCON0						; Fosc/8, canal 0 de conversão e liga o conversor AD
	
	return									; Retorna para endereço onde a subrotina foi chamada

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
;* DEZ_A, DEZ_B e UNI o número BCD correspondente.

conv_binToDec:

	movwf		REG_AUX						;salva valor a converter em REG_AUX
	clrf		UNI							;limpa unidade
	clrf		DEZ_A						;limpa dezena A
	clrf		DEZ_B						;limpa dezena B

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
	movf		DEZ_A,W						;Move o conteúdo de DEZ_A para Work
	xorlw		H'09'						;W = DEZ_A XOR 9d
	btfss		STATUS,Z					;Resultou em 9d?
	goto		incDezA						;Não, valor menor que 9. Incrementa DEZ_A
	clrf		DEZ_A						;Sim. Limpa registrador DEZ_A
	incf		DEZ_B,F						;Incrementa registrador DEZ_B
	goto		end_adj						;Desvia para end_adj
	
incDezA:
	incf		DEZ_A,F						;Incrementa DEZ_A
	
end_adj:
	decfsz		REG_AUX,F					;Decrementa REG_AUX. Fim da conversão ?
	goto		start_adj					;Não. Continua
	return									;Sim. Retorna


;========================================================================================
; --- Sub rotina de multiplicação (baseada na nota de aplicação AN544 da Microchip) ---
mult    MACRO   bit							;Inicio da macro de multiplicação

	btfsc		REG_MULT1,bit				;bit atual de REG_MULT1 limpo?
	addwf		AUX_H,F						;Não. Acumula soma de AUX_H
	rrf			AUX_H,F						;rotaciona AUX_H para direita e armazena o resultado nele próprio
	rrf			AUX_L,F						;rotaciona AUX_L para direita e armazena o resultado nele próprio

	endm									;fim da macro


multip:

	clrf		AUX_H						;limpa AUX_H
	clrf		AUX_L						;limpa AUX_L
	movf		REG_MULT2,W					;move o conteúdo de REG_MULT2 para Work
	bcf			STATUS,C					;limpa o bit de carry

	mult    	0							;chama macro para cada um dos 7 bits
	mult    	1							;de REG_MULT1
	mult    	2							;
	mult    	3							;
	mult    	4							;
	mult    	5							;
	mult    	6							;
	mult    	7							;

	return									;retorna


;========================================================================================
; --- Sub rotina de divisão (baseada na nota de aplicação AN544 da Microchip) ---	
	
;========================================================================================
;                       Double Precision Division
;========================================================================================
;   Division : ACCb(16 bits) / ACCa(16 bits) -> ACCb(16 bits) with
;                                               Remainder in ACCc (16 bits)
;      (a) Load the Denominator in location ACCaHI & ACCaLO ( 16 bits )
;      (b) Load the Numerator in location ACCbHI & ACCbLO ( 16 bits )
;      (c) CALL D_divF
;      (d) The 16 bit result is in location ACCbHI & ACCbLO
;      (e) The 16 bit Remainder is in locations ACCcHI & ACCcLO
;****************************************************************************
divid:

	movlw		H'10'						;move 16d para Work
	movwf		AUX_TEMP					;carrega contador para divisão

	movf		REG2H,W						;move conteúdo de REG2H para Work
	movwf		REG4H						;armazena em REG4H
	movf		REG2L,W						;move conteúdo de REG2L para Work
	movwf		REG4L						;armazena em REG4L
	clrf		REG2H						;limpa REG2H
	clrf		REG2L						;limpa REG2L
	clrf		REG3H						;limpa REG3H
	clrf		REG3L						;limpa REG3L

DIV
	bcf			STATUS,C					;limpa bit de carry
	rlf			REG4L,F						;rotaciona REG4L para esquerda e armazena nele próprio
	rlf			REG4H,F						;rotaciona REG4H para esquerda e armazena nele próprio
	rlf			REG3L,F						;rotaciona REG3L para esquerda e armazena nele próprio 
	rlf			REG3H,F						;rotaciona REG3H para esquerda e armazena nele próprio 
	movf		REG1H,W						;move conteúdo de REG1H para Work
	subwf		REG3H,W						;Work = REG3H - REG1H
	btfss		STATUS,Z					;Resultado igual a zero?
	goto		NOCHK						;Não. Desvia para NOCHK
	movf		REG1L,W						;Sim. Move conteúdo de REG1L para Work
	subwf		REG3L,W						;Work = REG3L - REG1L
	 
NOCHK
	btfss		STATUS,C					;Carry setado?
	goto		NOGO						;Não. Desvia para NOGO
	movf		REG1L,W						;Sim. Move conteúdo de REG1L para Work
	subwf		REG3L,F						;Work = REG3L - REG1L
	btfss		STATUS,C					;Carry setado?
	decf		REG3H,F						;decrementa REG3H 
	movf		REG1H,W						;move conteúdo de REG1H para Work
	subwf		REG3H,F						;Work = REG3H - REG1H
	bsf			STATUS,C					;seta carry
	 
NOGO
	rlf			REG2L,F						;rotaciona REG2L para esquerda e salva nele próprio
	rlf			REG2H,F						;rotaciona REG2H para esquerda e salva nele próprio
	decfsz		AUX_TEMP,F					;decrementa AUX_TEMP. Chegou em zero?
	goto		DIV							;Não. Continua processo de divisão
	return									;Sim. Retorna
	
	
	
;========================================================================================	

;========================================================================================
send_disp:									;Sub rotina para conversão binário -> display 7 seg

			addwf		PCL,F				;PCL = PCL + W
						;' gfedcba'			;Posição correta dos segmentos
			retlw		B'00111111'			;Retorna símbolo '0'
			retlw		B'00000110'			;Retorna símbolo '1' 
		 	retlw		B'01011011'			;Retorna símbolo '2'
		 	retlw		B'01001111'			;Retorna símbolo '3'
		 	retlw		B'01100110'			;Retorna símbolo '4'
			retlw		B'01101101'			;Retorna símbolo '5' 
			retlw		B'01111101'			;Retorna símbolo '6' 
			retlw		B'00000111'			;Retorna símbolo '7' 
		 	retlw		B'01111111'			;Retorna símbolo '8'
			retlw		B'01101111'			;Retorna símbolo '9' 
 
	
;========================================================================================	


; --- Fim do programa ---

end