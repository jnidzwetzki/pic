; PIC16F628A Configuration Bit Settings

; ASM source line config statements

#include "p16F628A.inc"

; CONFIG
; __config 0x3F70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

#define NUMBER_0 b'01110111'
#define NUMBER_1 b'00010100'
#define NUMBER_2 b'10110011'
#define NUMBER_3 b'10110110'
#define NUMBER_4 b'11010100'
#define NUMBER_5 b'11100110'
#define NUMBER_6 b'11100111'
#define NUMBER_7 b'00110100'
#define NUMBER_8 b'11110111'
#define NUMBER_9 b'11110110'

; RB0 is data
; RB1 is shift register commit
; RB2 is data clock shift register 1
; RB3 is data clock shift register 2
; RB4 is data clock shift register 3

    cblock 0x20
        w_temp			;0x20
        status_temp		;0x21
	
	led1_value		;0x22
	led2_value		;0x23
	led3_value		;0x24
	´
	parameter		;0x25
	segment_tmp             ;0x26
	position_tmp		;0x27
	current_led             ;0x28
	led_value_tmp           ;0x29
    endc
  
    org 0x000 
    goto prepare
     
    ; Interrupt handler
    org 0x004
    goto interrupt_handler
    

write_sevensegment:
    movlw 8
    movwf segment_tmp
    
write_sevensegment_start:
    bcf PORTB,0
    rlf parameter,F
    btfsc STATUS,C
    bsf PORTB,0
    
    ; Clock shift register commit
    btfsc current_led,0
    goto write_sevensegment_led1
    
    btfsc current_led,1
    goto write_sevensegment_led2
    
    btfsc current_led,2
    goto write_sevensegment_led3

write_sevensegment_led1:
    bsf PORTB,3
    nop
    nop
    nop	
    bcf PORTB,3
    goto write_sevensegment_continue
    
write_sevensegment_led2:
    bsf PORTB,2
    nop
    nop
    nop	
    bcf PORTB,2
    goto write_sevensegment_continue
    
write_sevensegment_led3:
    bsf PORTB,4
    nop
    nop
    nop	
    bcf PORTB,4
    goto write_sevensegment_continue
    
write_sevensegment_continue:  
    decfsz segment_tmp, F
    goto write_sevensegment_start
    
    bsf PORTB,1
    nop
    nop
    nop
    bcf PORTB,1
    
    bcf PORTB,0
    return
    
write_0:
    movlw NUMBER_0
    movwf parameter
    call write_sevensegment
    return
    
write_1:
    movlw NUMBER_1
    movwf parameter
    call write_sevensegment
    return

write_2:
    movlw NUMBER_2
    movwf parameter
    call write_sevensegment
    return

write_3:
    movlw NUMBER_3
    movwf parameter
    call write_sevensegment
    return

write_4:
    movlw NUMBER_4
    movwf parameter
    call write_sevensegment
    return

write_5:
    movlw NUMBER_5
    movwf parameter
    call write_sevensegment
    return

write_6:
    movlw NUMBER_6
    movwf parameter
    call write_sevensegment
    return

write_7:
    movlw NUMBER_7
    movwf parameter
    call write_sevensegment
    return

write_8:
    movlw NUMBER_8
    movwf parameter
    call write_sevensegment
    return

write_9:    
    movlw NUMBER_9
    movwf parameter
    call write_sevensegment
    return   
    
update_led:
    btfsc STATUS,Z
    goto write_0
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_1
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_2
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_3
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_4
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_5
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_6
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_7
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_8
    
    decf position_tmp,W
    movwf position_tmp
    btfsc STATUS,Z
    goto write_9
    

increment_led_value3:
    ; Reset segment_tmp
    movlw b'00000000'
    movwf led2_value
    
    ; Handle overflow
    incf led3_value,F
    movfw led3_value
    movwf led_value_tmp
    movlw d'10'
    subwf led_value_tmp,W
    btfsc STATUS,Z
    call reset_led_counters
    return
    
increment_led_value2:
    
    movlw b'00000000'
    movwf led1_value

    incf led2_value,F
    movfw led2_value
    
    movwf led_value_tmp
    movlw d'10'
    subwf led_value_tmp,W
    
    ; Handle overflow
    btfsc STATUS,Z
    call increment_led_value3
    
    return  
    
increment_led_value1:
    
    incf led1_value,F
    movfw led1_value
    
    movwf led_value_tmp
    movlw d'10'
    subwf led_value_tmp,W
    
    ; Handle overflow
    btfsc STATUS,Z
    call increment_led_value2
    
    return
    
reset_led_counters:
    movlw b'00000000'  
    movwf led1_value
    movwf led2_value
    movwf led3_value
    return
    
prepare:
    movlw b'00000000'  
    movwf PORTB        ; Reset all pins on PORTB
    call reset_led_counters
    
    banksel TRISB
    movlw b'11100000'
    movwf TRISB      
    
    banksel T1CON      ; Prepare Timer1
    movlw b'00000000'
    movwf TMR1L
    movwf TMR1H   
    bcf PIR1,TMR1IF
    movlw b'00100001'  ; Prescale 4, internal clock, timer active
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
    bcf     STATUS,RP0  ; Switch to bank0
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
    ; Increment LED value
    call increment_led_value1
    
    ; Update led1 to new value
    movlw b'00000001'
    movwf current_led
    movfw led1_value
    movwf position_tmp
    call update_led
    
    ; Update led2 to new value
    movlw b'00000010'
    movwf current_led
    movfw led2_value
    movwf position_tmp
    call update_led
    
    ; Update led to new value
    movlw b'00000100'
    movwf current_led
    movfw led3_value
    movwf position_tmp
    call update_led
    
    bcf PIR1,TMR1IF
    return
    
;--------End of All Code Sections ---------------------------------------------

    end                     ;End of program code in this file
