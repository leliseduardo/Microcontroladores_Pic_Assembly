;
;		PIC16F84A		Clock = 4MHz
;
;		Neste programa foram demonstrados os bancos de mem�ria e como alterar para o banco 0 e para o banco 1. Para isso
;	fora utilizados a diretivo define para facilitar a troca de bancos atrav�s dos comandos bcf e bsf.
;  		Para trabalhar com registradores, temos que saber em qual banco de mem�ria ele est� e, por isso, � importante 
;	trocar os bancos de mem�ria durante o programa. O registrador s� pode ser manipulado caso estaja-se no banco de 
;	mem�ria ao qual ele pertence.
;
;	Ainda, foram apresentados os comandos b�sicos de Assembly:
;
;   bcf = bit clear file, que muda um registrador ou vari�vel para n�vel baixo
;   bsf = bit set file, que muda um registrador ou vari�vel para n�vel alto
;
;	O professor disponibilizou uma tabela que mostra o que significa cada uma das letras presentes nos comando em 
;	Assembly. Esta tabela est� na pasta do curso.
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