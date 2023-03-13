;
;			PIC16F628A			Clock = 4MHz		Ciclo de máquina = 1us
;
;		O objetivo deste programa é configurar e demonstrar os fuse bits do PIC16F628A.
;
;		A configuração dos fuse bits será a seguinte:
;
;	- Cristal Oscilador externo de 4MHz	
;	- Watch Dog Timer desabilitado
;	- Power Up Timer habilitado
;	- Master Clear habilitado
;	- Browm Out desabilitado
;	- Sem programação em baixa tensão
;	- Sem proteção de memória de dados
;	- Sem proteção de código
;

	list p=16f628a ; Informa o microcontrolador utilizado
	
	#include <p16f628a.inc> ; Inclui o arquivo que contém os registradores do pic16f628a	
	
; --- Fuse Bits ---
	
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF  
	
	
	end	
	