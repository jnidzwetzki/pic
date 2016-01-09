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
#define NUMBER_ERR b'11110000'

; RB0 is data
; RB1 is shift register commit
; RB2 is data clock shift register 1
; RB4 is data clock shift register 3
; RB5 is data clock shift register 2

    cblock 0x20
        w_temp			    ;0x20
        status_temp		    ;0x21
	
	led1_value		    ;0x22
	led2_value		    ;0x23
	led3_value		    ;0x24
	
	write_sevensegment_parameter ;0x25
	segment_tmp		    ;0x26
	update_led_parameter	    ;0x27
	current_led		    ;0x28
	led_value_tmp		    ;0x29
	tmr1_h_tmp		    ;0x2A
	tmr1_l_tmp		    ;0x2B
	tmr1_decr_tmp               ;0x2C
	
	tmr0_int_ignore             ;0x2D
    endc
  
    org 0x000 
    goto prepare
     
    ; Interrupt handler
    org 0x004
    goto interrupt_handler
    
; *** Write a number to a shift register ***
; 1. Parameter: current_led - Select the shiftregister
; 2. Parameter: write_sevensegment_parameter - The value
write_sevensegment:
    movlw 8
    movwf segment_tmp
    
write_sevensegment_start:
    bcf PORTB,0
    rlf write_sevensegment_parameter,F
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
    bsf PORTB,5
    nop
    nop
    nop	
    bcf PORTB,5
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
    decfsz segment_tmp, f
    goto write_sevensegment_start
    bcf PORTB,0

    ; Make the changes in the shift register visible
    bsf PORTB,1
    nop
    nop
    nop
    bcf PORTB,1
    
    return
; *** Increment the number of led3 ***
increment_led_value3:
    clrf led2_value
    incf led3_value,F
    movfw led3_value
    
    movwf led_value_tmp
    movlw d'10'
    subwf led_value_tmp,W
    
    ; Handle overflow
    btfsc STATUS,Z
    call reset_led_counters
    return

; *** Increment the number of led2 ***
increment_led_value2:
    clrf led1_value
    incf led2_value,F
    movfw led2_value
    
    movwf led_value_tmp
    movlw d'10'
    subwf led_value_tmp,W
    
    ; Handle overflow
    btfsc STATUS,Z
    call increment_led_value3
    return  

; *** Increment the number of led1 *** 
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

; *** Update the value of one led ***
; 1. Parameter update_led_parameter - the new value 
; 2. Parameter: current_led - Select the shiftregister
update_led:
    movfw update_led_parameter
    xorlw d'0'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_0
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'1'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_1
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'2'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_2
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'3'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_3
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'4'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_4
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'5'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_5
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'6'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_6
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'7'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_7
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'8'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_8
    goto write_led_end
    
    movfw update_led_parameter
    xorlw d'9'
    btfss STATUS,Z
    goto $+3
    movlw NUMBER_9
    goto write_led_end
    
    ; Not a known number
    movlw NUMBER_ERR 
    
write_led_end:
    movwf write_sevensegment_parameter
    call write_sevensegment
    return

; *** Set all led counters to 0 ***
reset_led_counters:
    clrf led1_value
    clrf led2_value
    clrf led3_value
    return

; *** Prepare the application ***
prepare:
    clrf PORTB        ; Reset all pins on PORTB
    clrf PORTA        ; Reset all pins on PORTA
    
    call reset_led_counters
    
    banksel TRISB
    movlw b'11001000'
    movwf TRISB      
    
    banksel TRISA
    bcf TRISA,0       ; RA0 is output
    
    banksel TMR0      ; Prepare Timer0
    clrf TMR0
    bcf INTCON,T0IF
    
    ; Prescaler
    banksel OPTION_REG 
    bsf OPTION_REG,0
    bsf OPTION_REG,1
    bsf OPTION_REG,2

    ; Options
    bcf OPTION_REG,3
    bcf OPTION_REG,4
    bcf OPTION_REG,5
    
    banksel T1CON      ; Prepare Timer1 
    bcf PIR1,TMR1IF
    movlw b'00100001'  ; Prescale 4, internal clock, timer active
    movwf T1CON 
    
    ; Handle TMR0 interrupt again
    movlw d'0'
    movwf tmr0_int_ignore
    
    ; Enable interrupts
    banksel INTCON
    bsf	INTCON,T0IE
    bsf INTCON,PEIE
    bsf INTCON,GIE
 
    ; Enable CCP interupts
    banksel PIE1
    bsf	PIE1,CCP1IE
 
    banksel RA0

    goto main
    
; *** Main - Loop forever ***    
main:
    goto main    
 
; *** Prepare the CCP module ***
prepare_ccp:
    banksel CCP1CON    ; Prepare CCP
    bcf CCP1CON,3
    bsf CCP1CON,2
    bcf CCP1CON,1
    bsf CCP1CON,0
    
    ; Ignore TMR0 interrupts 25 times
    ; This ensures, that no new sonic measurements are prepared during
    ; the next moments.
    ; 
    ; In normal operation, the interrupts will made available 
    ; at the end of the mesasurement cycle. When the sensor
    ; does not capture a result, the timer deceases to '0'
    ; and the next TMR0 interrupt will trigger a new mesasurement cycle.
    movlw d'25'
    movwf tmr0_int_ignore

    return
    
ccp_int_waiting:    
    banksel CCP1CON    ; Prepare CCP
    bcf CCP1CON,0
    bcf PIR1,CCP1IF

    ; Reset TMR1 counter
    banksel T1CON      ; Prepare Timer1
    clrf TMR1L
    clrf TMR1H 
    
    return

increment_low_tmr:
    movlw b'11111111'
    movwf tmr1_l_tmp
    decf tmr1_h_tmp,f
    goto ccp_int_received_decrement_low

; *** Convert and display the ultrasoic measurement ***
ccp_int_received:
    
    ; Store a copy of tmr1 value at CCP capture.
    movfw CCPR1L
    movwf tmr1_l_tmp
    
    movfw CCPR1H
    movwf tmr1_h_tmp
    
    call reset_led_counters
    
    ; Convert timer into cm
    ; Object: 100 cm 
    ; Sonic 2x100cm = 200cm
    ; speed of sound 330 m/s
    ; 2/330 = 0,0060 seconds
    ; 250.000 Timer values per sec
    ; TMR0 will capture a value of 1515
    ; 100 * 15 = 1500 (we need to devide the result by 15)
    

ccp_int_received_decrement_low:
    movlw d'15'
    movwf tmr1_decr_tmp
    
ccp_int_received_decrement_low2:
    movfw tmr1_l_tmp
    btfsc STATUS,Z
    goto ccp_int_received_low_end
    decf tmr1_l_tmp,f

    decfsz tmr1_decr_tmp,f
    goto ccp_int_received_decrement_low2
    
    call increment_led_value1
    goto ccp_int_received_decrement_low
    
ccp_int_received_low_end:  
    
    ; Check high bit (if not empty, decrement and set low to 255)
    movfw tmr1_h_tmp
    btfss STATUS,Z
    goto increment_low_tmr
    
    ; Enable TMR0 interrupts
    movlw d'0'
    movwf tmr0_int_ignore
    
    return

; *** Start a new ultrasonic measurement ***
send_sonic:
    bsf PORTA,0
    ; >= 10 nops to set PORTA,0 for 10 micro seconds to high
    nop
    nop 
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    bcf PORTA,0
    return

; *** The interrupt handler *** 
interrupt_handler:
    movwf   w_temp      ; Save w register
    swapf   STATUS,w    ; STATUS -> w
    bcf     STATUS,RP0  ; Switch to bank0
    movwf   status_temp ; w -> status_temp
    
    ; Handle TMR0 Interrupt
    banksel INTCON
    btfsc INTCON,TMR0IF
    call tmr0_int
    
    ; Handle CCP Interrupt
    banksel PIR1
    btfsc PIR1,CCP1IF
    call ccp1_int
    
    ; return from interrupt
    banksel INTCON
    bcf     INTCON, INTF
    swapf   status_temp,w  ; Restore status
    movwf   STATUS
    swapf   w_temp,f
    swapf   w_temp,w
    retfie

; *** Handle CCP interrupts *** 
ccp1_int:
    banksel PIR1
    bcf PIR1,CCP1IF
    
    btfss CCP1CON,0
    call ccp_int_received
    
    btfsc CCP1CON,0
    call ccp_int_waiting
    
    return
    
; *** Handle TMR0 interrupts ***   
tmr0_int:
    banksel INTCON
    bcf INTCON,TMR0IF
    
    ; Decrease tmr0_int_ignore if > 0
    ; if > 0 = We are inside a measurement cycle
    ; Skip LED update and preparement of a
    ; new measurement cycle
    movfw tmr0_int_ignore
    btfsc STATUS,Z
    goto $+3
    decf tmr0_int_ignore, f ; $+1
    return                  ; $+2
    
    ; Update led1 to new value
    movlw b'00000001'
    movwf current_led
    movfw led1_value
    movwf update_led_parameter
    call update_led
    
    ; Update led2 to new value
    movlw b'00000010'
    movwf current_led
    movfw led2_value
    movwf update_led_parameter
    call update_led
    
    ; Update led3 to new value
    movlw b'00000100'
    movwf current_led
    movfw led3_value
    movwf update_led_parameter
    call update_led
    
    ; Start new ultrasonic measurement
    call send_sonic
    
    ; Prepare ccp module to capture rising edge of the echo port
    call prepare_ccp
    
    return
    
;--------End of All Code Sections ---------------------------------------------

    end                     ;End of program code in this file