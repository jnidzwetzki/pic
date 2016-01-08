# The PIC repository
Some code for pic micro controller. Most of the code is for the PIC16F628A controller.

## Ultrasonic sensor with seven segment led output ##
* Sourcefile: *sonic_sevensegment.asm*
* Description: This project uses the HCSR04 ultrasonic sensor to measure the distance of an object. The PIC 
triggeres the ultrasonic sensor several times per seconds and convert the result into centimeter. The result is displayed 
onto the seven-segment display. The shift registers are used to address the seven-segment displays.
* Hardware: 1x PIC16F628A, 3x TPIC 595N (shift register with open-drain), 3x seven-segment displays, 1x HCSR04 ultrasonic sensor
* Image: ![ultra sonic](/pics/ultrasonic_seven.jpg)
