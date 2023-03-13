;
;		PIC16F628A		Clock = 4MHz		Ciclo de máquina = 1us		
;
;		O objetivo deste programa é testar o timer2 na prática, ligando e desligando o timer2 e observando seu tempo de
;	latência. Como não tenho osciloscópio, irei fazer o teste na simulação do proteus. 
;
;		Timer 2
;
;		Overflow = PR2 * Prescaler * Postscaler * ciclo de máquina
;		Overflow = 51 * 4 * 5 * 1us
;		Overflow = 1,02ms
;
;		Na simulação o programa funcionou como esperado, com o tempo de interrupção igual ao programado mais o tempo de
;	latência.
;


	list		p=16f628a					; Informa o microcontrolador utilizado
	
; --- Inclusão de arquivos ---

	#include 	<p16f628a.inc>				; Inclui o arquivo que contém os registradores do Pic
	
; --- Fuse bits ---

	__config	_XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF
	
;	Clock em 4MHz, Power Up Timer habilitado e Master Clear Habilitado

; --- Paginação de memória ---

	#define 	bank0		bcf	STATUS,RP0	; Cria um mnemônico para selecionar o banco 0 de memória
	#define		bank1		bsf	STATUS,RP0	; Cria um mnemônico para selecionar o banco 1 de memória
	
; --- Mapeamento de hardware ---

	#define 	led1	PORTA,3				; Cria mnemônico para led1 em RA3
	#define 	led2 	PORTA,2				; Cria mnemônico para led2 em RA2
	
; --- Registradores de uso geral ---

	cblock		H'20'						; Cria registradores de uso geral a partir do endereço 20h de memória
	
	W_TEMP									; Armazena o conteúdo de W temporariamente
	STATUS_TEMP								; Armazena o conteúdo de STATUS temporariamente
	tempo1									; Auxilia a contagem do delay
	tempo2									; Auxilia a contagem do delay
	
	endc
	
; --- Vetor de Reset ---

	org			H'0000'						; Origem do endereço para o vetor de Reset
	
	goto 		inicio						; Desvia programa para label inicio
	
	
; --- Vetor de Interrupção

	org 		H'0004'						; Origem do endereço para o vetor de Interrupção
	
; --- Salvamento de contexto ---

	movwf		W_TEMP						; W_TEMP = w
	swapf		STATUS,w					; w = STATUS (com nibbles invertidos)
	bank0									; Seleciona banco 0 de memória
	movwf		STATUS_TEMP					; STATUS_TEMP = STATUS (com nibbles invertidos)

; --- Fim do salvamento de contexto ---

	; Desenvolvimento da ISR
	
	btfss		PIR1,TMR2IF					; Testa se flag TMR2IF setou, se sim, pula uma linha
	goto		exit_ISR					; Se não, sai da interrupção
	bcf			PIR1,TMR2IF					; Limpa flag TMR2IF
	
	comf		PORTB						; Complementa portb, somente as saídas
	
; --- Recuperação de contexto ---

exit_ISR:

	swapf		STATUS_TEMP,w				; w = STATUS_TEMP (status original)
	movwf		STATUS						; STATUS = w (status original)
	swapf		W_TEMP,F					; W_TEMP = W_TEMP (nibbles invertidos)
	swapf		W_TEMP,w					; w = W_TEMP (w original)	

	retfie
	
; --- Fim da recuperação de contexto ---


; --- Programa principal ---

inicio:										; Inicia label programa principal


	bank1									; Seleciona o banco 1 de memória
	bsf			PIE1,TMR2IE					; Habilita a interrupção por oveflow do timer2
	movlw		H'33'						; w = 101d
	movwf		PR2							; Inicia o PR2 = 101d, isto é, TMR2 conta ate 101d e zera quando estoura
	movlw		H'F3'						; w = F3h
	movwf		TRISA						; TRISA = F3h, configura apenas RA3 e RA2 como saídas digitais
	movlw		H'FD'						; w = FDh
	movwf		TRISB						; TRISB = FDh, configura apenas RB1 como saída digital
	bank0									; Seleciona o banco 0 de memória
	bsf			INTCON,GIE					; Habilita a interrupção global
	bsf			INTCON,PEIE					; Habilita a interrupção por periféricos
	movlw		B'00100001'					; w = B'00100101'
	movwf		T2CON						; Postscaler = 1:5, prescaler = 1:4 e timer2 habilitado
	

loop:										; Inicia loop infinito

	bsf			led1						; Liga led1
	bsf			T2CON,TMR2ON				; Liga timer2
	call 		delay500ms					; Delay 500ms
	bcf			led1						; Desliga led1
	bcf			T2CON,TMR2ON				; Desliga timer2
	call		delay500ms					; Delay 500ms


	goto loop								; Desvia para loop infinito
	
	
; --- Sub-rotinas ---
	
	delay500ms:	; Cria a sub-rotina
	
		movlw	D'200' ; Move o valor 200 decimal para W
		movwf	tempo1 ; Move o valor de W para o registrador de uso geral no endereço 0C
		
		aux1: ; Cria uma label auxiliar
		
			movlw	D'250' ; Move o valor decimal 250 para W
			movwf	tempo2 ; Move o valor de W para o registrado de uso geral no endereço 0D
			
		aux2: ; Cria outra label auxiliar
		
			nop
			nop
			nop
			nop
			nop
			nop
			nop ; Gasta 7 ciclo de máquina = 7us
			
			decfsz	tempo2 ; Decrementa o valor contido no endereço 0D e pula uma linha se o valor for zero
			goto	aux2 ; Desvia para a label aux2
			
			decfsz	tempo1 ; Decrementa o valor contido no endereço 0C e pula uma linha se o valor for zero
			goto 	aux1 ; Desvia o programa para a label aux1
			
			return ; Retorna para o loop infinito
			
	
	
end
	
end 