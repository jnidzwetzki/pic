; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"

; CONFIG
; __config 0x3F70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

; 0 Output
#define segment_0A b'11111110'
#define segment_0B b'11001000'

; 1 Output
#define segment_1A b'11111111'
#define segment_1B b'11101011'
 
; 2 Output
#define segment_2A b'11111101'
#define segment_2B b'11001100'
 
; 3 Output
#define segment_3A b'11111101'
#define segment_3B b'11001001'
 
; 4 Output
#define segment_4A b'11111100'
#define segment_4B b'11101011'

; 5 Output
#define segment_5A b'11111100'
#define segment_5B b'11011001'
 
; 6 Output
#define segment_6A b'11111100'
#define segment_6B b'11011000'
 
; 7 Output
#define segment_7A b'11111111'
#define segment_7B b'11001011'
 
; 8 Output
#define segment_8A b'11111100'
#define segment_8B b'11001000'
 
; 9 Output
#define segment_9A b'11111100'
#define segment_9B b'11001001'
 
 
    cblock 0x20
        w_temp			;0x20
        status_temp		;0x21
	output_state		;0x22
	work			;0x23
    endc
  
    org 0x000 
    goto prepare
     
    ; Interrupt handler
    org 0x004
    goto interrupt_handler
    
write_0:
    movlw segment_0A
    movwf PORTA
    movlw segment_0B
    movwf PORTB
    goto toggle_led_end
    
write_1:
    movlw segment_1A
    movwf PORTA
    movlw segment_1B
    movwf PORTB
    goto toggle_led_end

write_2:
    movlw segment_2A
    movwf PORTA
    movlw segment_2B
    movwf PORTB
    goto toggle_led_end

write_3:
    movlw segment_3A
    movwf PORTA
    movlw segment_3B
    movwf PORTB
    goto toggle_led_end

write_4:
    movlw segment_4A
    movwf PORTA
    movlw segment_4B
    movwf PORTB
    goto toggle_led_end

write_5:
    movlw segment_5A
    movwf PORTA
    movlw segment_5B
    movwf PORTB
    goto toggle_led_end

write_6:
    movlw segment_6A
    movwf PORTA
    movlw segment_6B
    movwf PORTB
    goto toggle_led_end

write_7:
    movlw segment_7A
    movwf PORTA
    movlw segment_7B
    movwf PORTB
    goto toggle_led_end

write_8:
    movlw segment_8A
    movwf PORTA
    movlw segment_8B
    movwf PORTB
    goto toggle_led_end

write_9:
    movlw segment_9A
    movwf PORTA
    movlw segment_9B
    movwf PORTB
    
    ; Reset counter
    movlw b'11111111'
    movwf output_state
    
    goto toggle_led_end   
    
toggle_led:
    incf output_state,F
    movfw output_state
    movwf work
    
    btfsc STATUS,Z
    goto write_0
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_1
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_2
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_3
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_4
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_5
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_6
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_7
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_8
    
    decf work,W
    movwf work
    btfsc STATUS,Z
    goto write_9

toggle_led_end:
    return
    
prepare:
    movlw b'00000000'  
    movwf PORTB        ; Reset all pins on PORTB
    movwf PORTA        ; Reset all pins on PORTA
    movwf output_state
    
    banksel TRISB
    movlw b'11000000'
    movwf TRISB      

    banksel TRISA
    movlw b'11111100'
    movwf TRISA       

    
    banksel T1CON      ; Prepare Timer1
    movlw b'00000000'
    movwf TMR1L
    movwf TMR1H   
    bcf PIR1,TMR1IF
    movlw b'00110001'  ; Prescale 8, internal clock, timer active
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
