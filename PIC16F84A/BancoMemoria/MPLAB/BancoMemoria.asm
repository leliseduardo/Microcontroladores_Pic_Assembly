;
;		PIC16F84A		Clock = 4MHz
;
;		Neste programa foram demonstrados os bancos de memória e como alterar para o banco 0 e para o banco 1. Para isso
;	fora utilizados a diretivo define para facilitar a troca de bancos através dos comandos bcf e bsf.
;  		Para trabalhar com registradores, temos que saber em qual banco de memória ele está e, por isso, é importante 
;	trocar os bancos de memória durante o programa. O registrador só pode ser manipulado caso estaja-se no banco de 
;	memória ao qual ele pertence.
;
;	Ainda, foram apresentados os comandos básicos de Assembly:
;
;   bcf = bit clear file, que muda um registrador ou variável para nível baixo
;   bsf = bit set file, que muda um registrador ou variável para nível alto
;
;	O professor disponibilizou uma tabela que mostra o que significa cada uma das letras presentes nos comando em 
;	Assembly. Esta tabela está na pasta do curso.
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