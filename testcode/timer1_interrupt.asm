
; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"

; CONFIG
; __config 0x3F70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF


    cblock 0x20
        w_temp			;0x20
        status_temp		;0x21
	output_state		;0x22
    endc
  
    org 0x000 
    goto prepare
     
    ; Interrupt handler
    org 0x004
    goto interrupt_handler
     
toggle_led:
    incf output_state,f
    movfw output_state
    
    bcf PORTB,0
    bcf PORTB,1
    bcf PORTB,2
    bcf PORTB,3
    
    btfsc output_state,0      
    bsf PORTB,0
    
    btfsc output_state,1     
    bsf PORTB,1
    
    btfsc output_state,2     
    bsf PORTB,2
    
    btfsc output_state,3   
    bsf PORTB,3

    return
    
prepare:
    movlw b'00000000'  
    movwf PORTB        ; Reset all pins on PORTB
    movwf output_state
    banksel TRISB
    movlw b'11110000'
    movwf TRISB        ; 4 Pins on PORTB are outputs

    banksel T1CON      ; Prepare Timer1
    movlw b'00000000'
    movwf TMR1L
    movwf TMR1H   
    bcf PIR1,TMR1IF
    movlw b'00100001'  ; Prescale 8, internal clock, timer active
    movwf T1CON 
    
    ; Enable interrupts
    banksel PIE1
    bsf	PIE1,TMR1IE
    bsf INTCON,PEIE
    bsf INTCON,GIE
 
    banksel RA0

    goto main
    
main:
    goto main    

interrupt_handler:
    movwf   w_temp      ; Save w register
    swapf   STATUS,w    ; STATUS -> w
    bcf     STATUS,RP0   ; Switch to bank0
    movwf   status_temp ; w -> status_temp
    
    ; Handle TMR1 Interrupt
    btfsc PIR1,TMR1IF
    call tmr1_int
    
    ; return from interrupt
    bcf     INTCON, INTF
    swapf   status_temp,w  ; Restore status
    movwf   STATUS
    swapf   w_temp,f
    swapf   w_temp,w
    retfie

tmr1_int:
    call toggle_led
    bcf PIR1,TMR1IF
    return
    
;--------End of All Code Sections ---------------------------------------------

    end                     ;End of program code in this file
