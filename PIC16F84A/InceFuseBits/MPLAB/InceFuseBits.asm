;
;			
;		PIC16F84A	Clock = 4MHz
;
;		Neste programa ser� iniciado o estudo da linguagem Assembly para microcontroladores PIC. De in�cio ser�o mostrados
;   os comando include e a configura��o dos Fuse Bits, necess�rios para o correto funcionamento do microcontrolador.
;  
;   	Lembrando, do curso de linguagem C para microcontroladores Pic, que o oscilador externo � configurado para XT
;	para frequ�ncias pr�ximas � 4MHz, WatchDog Timer � o timer que reinicia o MCU caso haja algum problema de funciona-
;	mento, o Power Up Timer � a fun��o que espera 72ms para come�ar executar o programa, para que os registradores sejam
;	iniciados e estabilizados e o Code Protect serve para proteger o microcontrolador de c�pias.
;


	list p=16f84a	; Informa o microcontrolador usado
	
	; --- Arquivos inclu�dos no projeto ---
	#include <p16f84a.inc>	; Inclui o arquivo do microcontrolador usado
	
	; --- FUSE Bits ---
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF	; Configura o oscilador externa para XT, desliga o watchDog
														; timer, habilita o Power Up Timer e desliga a prote��o de c�digo
	
	
	