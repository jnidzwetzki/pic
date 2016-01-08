
; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"

; CONFIG
; __config 0x3F70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

     org 0  

prepare: 
    
    movlw b'00000000'  
    movwf PORTB        ; Reset all pins on PORTB
    banksel TRISB
    movlw b'11000000'
    movwf TRISB      ; All Pins on PORTB are outputs

    banksel T1CON      ; Prepare Timer1
    movlw b'00000000'
    movwf TMR1L
    movwf TMR1H   
    bcf PIR1,TMR1IF
    movlw b'00110001'  ; Prescale 8, internal clock, timer active
    movwf T1CON 
    banksel RA0
    goto main
    
toggle_r1:
    btfsc PORTB,0  ; skip next if clear
    goto toggle_r1_off
    
toggle_r1_on:
    bsf PORTB,0
    bsf PORTB,1
    return
    
toggle_r1_off:
    bcf PORTB,0
    bcf PORTB,1
    return
    
main:
    btfss PIR1,TMR1IF
    goto main
    call toggle_r1
    bcf PIR1,TMR1IF
    goto main
   
    
loop:
    goto loop
    
;--------End of All Code Sections ---------------------------------------------

    end                     ;End of program code in this file
