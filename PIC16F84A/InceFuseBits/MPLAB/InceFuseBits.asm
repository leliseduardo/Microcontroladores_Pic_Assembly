;
;			
;		PIC16F84A	Clock = 4MHz
;
;		Neste programa será iniciado o estudo da linguagem Assembly para microcontroladores PIC. De início serão mostrados
;   os comando include e a configuração dos Fuse Bits, necessários para o correto funcionamento do microcontrolador.
;  
;   	Lembrando, do curso de linguagem C para microcontroladores Pic, que o oscilador externo é configurado para XT
;	para frequências próximas à 4MHz, WatchDog Timer é o timer que reinicia o MCU caso haja algum problema de funciona-
;	mento, o Power Up Timer é a função que espera 72ms para começar executar o programa, para que os registradores sejam
;	iniciados e estabilizados e o Code Protect serve para proteger o microcontrolador de cópias.
;


	list p=16f84a	; Informa o microcontrolador usado
	
	; --- Arquivos incluídos no projeto ---
	#include <p16f84a.inc>	; Inclui o arquivo do microcontrolador usado
	
	; --- FUSE Bits ---
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF	; Configura o oscilador externa para XT, desliga o watchDog
														; timer, habilita o Power Up Timer e desliga a proteção de código
	
	
	