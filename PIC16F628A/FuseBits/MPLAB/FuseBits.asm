;
;			PIC16F628A			Clock = 4MHz		Ciclo de m�quina = 1us
;
;		O objetivo deste programa � configurar e demonstrar os fuse bits do PIC16F628A.
;
;		A configura��o dos fuse bits ser� a seguinte:
;
;	- Cristal Oscilador externo de 4MHz	
;	- Watch Dog Timer desabilitado
;	- Power Up Timer habilitado
;	- Master Clear habilitado
;	- Browm Out desabilitado
;	- Sem programa��o em baixa tens�o
;	- Sem prote��o de mem�ria de dados
;	- Sem prote��o de c�digo
;

	list p=16f628a ; Informa o microcontrolador utilizado
	
	#include <p16f628a.inc> ; Inclui o arquivo que cont�m os registradores do pic16f628a	
	
; --- Fuse Bits ---
	
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF  
	
	
	end	
	