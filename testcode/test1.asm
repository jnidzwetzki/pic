
; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"

; CONFIG
; __config 0x3F70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

    cblock
    d1
    endc

    org 0  
    goto prepare
    


prepare: 
    movlw b'00000000'  
    movwf d1

delay:
    incf d1,f
    MOVF d1,w
    BTFSC STATUS,Z
    goto delay
    
    
    
    movlw b'00000000'  
    movwf PORTB        ; Reset all pins on PORTB
    banksel TRISB
    movlw b'11000000'
    movwf TRISB      ; All Pins on PORTB are output
    banksel RA0
    goto main
    
main:
    bsf PORTB,0
    bsf PORTB,1
   
    
loop:
    goto loop
    
;--------End of All Code Sections ---------------------------------------------

    end                     ;End of program code in this file



