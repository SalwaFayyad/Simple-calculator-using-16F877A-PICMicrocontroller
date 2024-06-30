;**********************************************************************************************************************************************************************
;SALWA FAYYAD 1200430
;SAHAR FAYYAD 1190119
;MAJD ABUBAHA 1190069
;MAYSAM KHATEEB 1190207
		
;**********************************************************************************************************************************************************************
;                                                                	MASTER MULTIPLICATION
;**********************************************************************************************************************************************************************
	PROCESSOR 16F877A
	INCLUDE "P16F877A.INC"	
	__CONFIG 0x3731
;**************************************INITALIZE REGISTERS*****************************************

TENTH_NUM1 EQU 0x20 
ONES_NUM1 EQU 0x21
TENTH_NUM2 EQU 0x22
ONES_NUM2 EQU 0x23

COUNTER EQU 0x25         ;COUNTER FOR TIMER-0
COUNTER_BUTTON EQU 0x26  ;BUTTON COUNTERS
COUNTER_BUTTON2 EQU 0x27 ;BUTTON COUNTERS-2
COUNTER_FINISH EQU 0x28

NUM1 EQU 0x29 ; COMBINATION NUMBER 1 (TENTH-ONES)
MASTER_RESULT2  EQU 0x30 ; LOWEST RESULT FOR MASTER 
MASTER_RESULT1  EQU 0x31 ; HIGHEST RESULT FOR MASTER
COUNTER_MUL EQU 0X32     ; COUNTER FOR MULTIPLICATION

thousand EQU 0X33
hun EQU 0X34
tens EQU 0X35
ones  EQU 0X36

Msd	EQU	0x37	; Most significant digit of result
Lsd	EQU	0x38	; Least significant digit of result
Hsd	EQU	0x39	
Hhsd EQU 0x40	
	
CO_PROC_RESULT2  EQU 0x41 ; LOWEST RESULT FOR CO_PROCESSOR
CO_PROC_RESULT1  EQU 0x42 ; HIGHEST RESULT FOR CO_PROCESSOR
NUM2_TENS EQU 0x43

RESULT_HIGH      EQU 0x44  ; 
RESULT_LOW       EQU 0x45  ; Low byte of result

;**********************************START THE PROGRAM*******************************************
	ORG 0x00
	GOTO init

	ORG 0x04
	GOTO ISR
;********************************************************************************************
;                                        INTERRUPTS 
;********************************************************************************************
ISR:
    
    BANKSEL INTCON
    BTFSS INTCON, TMR0IF  ; Check for Timer0 overflow interrupt
    GOTO ButtonInterrupt  ; If Timer0 overflow interrupt flag is not set, check button interrupt

    CALL TimerOverflowInterrupt ; if timer 0 overflow flag is set go to TimerOverFlow
    GOTO ISR_Exit

TimerOverflowInterrupt:  ; Handle Timer0 overflow interrupt
    BANKSEL INTCON
    BCF INTCON, TMR0IF     ; Clear Timer0 overflow interrupt flag

    INCF COUNTER, F    ; Increment overflow counter

    ; Check if it has reached a specific count (e.g., 20 for approximately 2 seconds)
    MOVLW 20
    SUBWF COUNTER, W
    BTFSS STATUS, Z        ; Check if the result is zero , reach 2 second
    GOTO ISR_Exit          ; If not zero, exit ISR
    GOTO TimerReachedTwoSeconds
    RETURN                 ; Return if not zero

  
ISR_Exit:  ; Re-enable Timer0 interrupt
    BANKSEL INTCON
    BSF INTCON, TMR0IE     ; Enable Timer0 interrupt
    BSF INTCON, INTE       ; Enable external interrupts
    BSF INTCON, GIE        ; Global interrupt enable
    RETFIE

ButtonInterrupt:  ; Button interrupt handling
    
    BANKSEL INTCON
    BCF INTCON, INTF       ; Clear external interrupt flag for the button
	
    CALL Button1Pressed
    BSF INTCON, INTE       ; Enable external interrupts
    RETFIE

;**********************************************************************************************************************************************************************
;                                                                      MAIN CODE 
;**********************************************************************************************************************************************************************

INCLUDE "LCDIS.INC" ;; LCD LIBRARY 4 BIT
;***************************************************************************************

; The init for our program
init:

    BANKSEL INTCON
    BCF INTCON, GIE   ; Disable global interrupts during setup
    
    CLRF COUNTER ;Initialize overflow counter 
    CLRF COUNTER_BUTTON ; COUNTER FOR BUTTON PRESSED WITH POSITION IN THE LCD
    CLRF COUNTER_BUTTON2 ; COUNTER TO CHECK IF THE CURSOR REACHED THE "EQUAL" SIGN
    CLRF COUNTER_MUL

    CLRF NUM1
    CLRF MASTER_RESULT1 
    CLRF MASTER_RESULT2
	CLRF thousand
	CLRF hun 
	CLRF tens 
	CLRF ones  

    CLRF CO_PROC_RESULT2
    CLRF CO_PROC_RESULT1
    CLRF COUNTER_FINISH

    BANKSEL TRISD
    CLRF TRISD
   

	; INITIALIZE BUTTON FOR INTERRUPT ON PORT-B
	BANKSEL TRISB 
	BSF TRISB, 0 ;Sets TRISB0 as an input.
	
	MOVLW 0x30 ; NUMBERS INITIALIZE TO ZERO IN ASSCII
	MOVWF TENTH_NUM1
	MOVWF TENTH_NUM2 
	MOVWF ONES_NUM1 
	MOVWF ONES_NUM2      


;;;;;;;;;;;;;;;;;;;
;;; INITIALIZE USART PROTOCOL TO COMMUNICATE WITH A CO-PROCESSOR PIC
;;;;;;;;;;;;;;;;;;;
	    ; Set up baud rate

    BANKSEL PORTC
	BCF PORTC, 6  ; 
	BSF PORTC, 7  ; 

    BANKSEL SPBRG
    MOVLW 0x25            ; Load SPBRG for 9600 baud with Fosc = 4MHz
    MOVWF SPBRG

    BANKSEL RCSTA
    MOVLW 0x90            ; Enable serial port (SPEN=1), enable continuous receive (CREN=1 for async mode)
    MOVWF RCSTA

    BANKSEL TXSTA
    MOVLW 0x20            ; BRGH = 1
    MOVWF TXSTA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    BANKSEL PORTD
    CALL xms
    CALL inid
    BANKSEL PORTD
    CALL DisplayMessage ; If counter hasn't reached 3, display message
	CALL xms
	CALL xms
    CALL DisplayMessage ; If counter hasn't reached 3, display message	
	CALL xms
	CALL xms
    CALL DisplayMessage ; If counter hasn't reached 3, display message	
	CALL xms
	CALL xms
    GOTO start

;***********************************************************************************************

start:

   CLRF TENTH_NUM1
    CLRF ONES_NUM1
    CLRF TENTH_NUM2
    CLRF ONES_NUM2
    CLRF COUNTER
    CLRF COUNTER_BUTTON
    CLRF COUNTER_BUTTON2
    CLRF NUM1
    CLRF MASTER_RESULT2
    CLRF MASTER_RESULT1
    CLRF COUNTER_MUL
    CLRF thousand
    CLRF hun
    CLRF tens
    CLRF ones
    CLRF Msd
    CLRF Lsd
    CLRF Hsd
    CLRF Hhsd
    CLRF CO_PROC_RESULT2
    CLRF CO_PROC_RESULT1
    CLRF NUM2_TENS
    CLRF COUNTER_FINISH
    CLRF RESULT_HIGH
    CLRF RESULT_LOW

	CALL  DISPLAY_NUMBER_1 
   ; Configure Timer0: prescaler, mode, and enable overflow interrupt
    BANKSEL OPTION_REG
    MOVLW b'00000111' ; Prescaler 1:256 for Timer0
    MOVWF OPTION_REG

 	BANKSEL TMR0
    CLRF TMR0          ; Clear Timer0 register

    BANKSEL INTCON
    BSF INTCON, TMR0IE ; Enable Timer0 interrupt
	BSF INTCON, GIE
  


    GOTO loop

;*********************************************************************************************************************************************************************
;                                                                                SENDING DATA 
;********************************************************************************************************************************************************************
SendData: ; send Number 1 in one shot

    BANKSEL TXREG       ; Select Bank for TXREG
	MOVF NUM1,W
    MOVWF TXREG         ; Move the data in W to TXREG for transmission

	CALL xms
	CALL xms

    BANKSEL TXREG   
	MOVF ONES_NUM2,W
	MOVWF TXREG

    MOVFW TENTH_NUM2
    BTFSC STATUS,Z
    GOTO  receive1
    
    MOVFW NUM1
    BTFSC STATUS,Z
    GOTO  receive1

	GOTO mul2

   
	;GOTO receive1



;*******************************************************************************************************************************************************************
;                                                                                      RECIVE DATA 
;********************************************************************************************************************************************************************
	
receive1:
    CLRF CO_PROC_RESULT1

	BANKSEL PIR1 ; Switch to Bank 0
    BTFSS PIR1, RCIF       ; Check if data is received
    GOTO receive1            ; If not, loop

    BANKSEL RCREG          ; Select bank containing RCREG
    MOVF RCREG, W          ; Read the received data
    MOVWF CO_PROC_RESULT1

    ;MOVF CO_PROC_RESULT1, W
	;ADDWF ones
    
	GOTO receive2

receive2:
    CLRF CO_PROC_RESULT2

	BANKSEL PIR1 ; Switch to Bank 0
    BTFSS PIR1, RCIF       ; Check if data is received
    GOTO receive2           ; If not, loop

    BANKSEL RCREG          ; Select bank containing RCREG
    MOVF RCREG, W          ; Read the received data
    MOVWF CO_PROC_RESULT2

    ;CLRF CO_PROC_RESULT2
    ;CLRF CO_PROC_RESULT1

    ;CLRF MASTER_RESULT2
    ;CLRF MASTER_RESULT1

	GOTO addition
 
;**********************************************************************************************


;********************************************************************************************
	
Button1Pressed:
    CLRF COUNTER      
    CLRF COUNTER_BUTTON2

    MOVLW 1
    SUBWF COUNTER_FINISH,W
    BTFSS STATUS, Z
	GOTO  check_first
    GOTO  start ; If COUNTER_BUTTON is 0, increment tenth number

check_first:
    MOVLW 0
    SUBWF COUNTER_BUTTON,W
    BTFSS STATUS, Z
	GOTO  onescheck
    GOTO  TENTH_NUM_1_INCREMENT ; If COUNTER_BUTTON is 0, increment tenth number

onescheck:
	MOVLW 1
    SUBWF COUNTER_BUTTON,W
    BTFSS STATUS, Z
    GOTO twoscheck
    GOTO ONES_NUM_1_INCREMENT ; If COUNTER_BUTTON is 1, increment ones number

twoscheck:
  	MOVLW 3   ;; reach the x index
    SUBWF COUNTER_BUTTON,W
    BTFSS STATUS, Z
    GOTO THIRDCHECK
    GOTO TENTH_NUM_2_INCREMENT ; If COUNTER_BUTTON is 1, increment ones number

EQUALCHECK: 
    ;INCF COUNTER_BUTTON,F
    BCF Select, RS
 	MOVLW 0xC5 ; for second line
	CALL send
	BSF Select, RS
    MOVLW   '='
    CALL    send
    INCF COUNTER_BUTTON2,F
	;CALL SendData
    ;CALL mul_ones_num1
    CALL DISP
    GOTO mul
    RETURN
  
THIRDCHECK:
 	MOVLW 4   ;; reach the x index
    SUBWF COUNTER_BUTTON,W
    BTFSS STATUS, Z
    GOTO final
    GOTO ONES_NUM_2_INCREMENT ; If COUNTER_BUTTON is 1, increment ones number

final:    

; The main code for our program
TimerReachedTwoSeconds: 
    CLRF COUNTER  
    CALL MoveCursor
    INCF COUNTER_BUTTON,F

	MOVLW 2    ;; reach the x index
    SUBWF COUNTER_BUTTON,W
    BTFSS STATUS, Z
    GOTO checkequal
    GOTO DISPLAY_NUMBER_2 ; If COUNTER_BUTTON is 1, increment ones number

    GOTO  ISR_Exit

checkequal:
    MOVLW 5    ;; reach the x index     
    SUBWF COUNTER_BUTTON,W
    BTFSS STATUS, Z
    GOTO  ISR_Exit
    GOTO EQUALCHECK ; If COUNTER_BUTTON is 1, increment ones number
  
TENTH_NUM_1_INCREMENT:
    BANKSEL TENTH_NUM1 ; Increment the TENTH_NUM1 value
    INCF TENTH_NUM1, F ; Increment TENTH_NUM1 and check for overflow
    MOVF TENTH_NUM1, W   ; Move TENTH_NUM1 to W
    XORLW D'10'           ; XOR with 9    ; Subtract 9 from W
    BTFSC STATUS, Z      ; If the result is zero, TENTH_NUM1 was greater than 9
    GOTO ResetTenthNum1 ; If TENTH_NUM1 is greater than 9, reset it to 0
    
    ; If TENTH_NUM1 is not greater than 9, continue to display the incremented value
    MOVLW 0xC0 ; for second line
    CALL send
    BSF Select, RS
    MOVF TENTH_NUM1, W ; Get the value of TENTH_NUM1
    ADDLW D'48' ; Convert to ASCII
    CALL send ; Send the updated value to the LCD
   	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_FIRST_POSITION
    RETURN

ResetTenthNum1:
    CLRF TENTH_NUM1 ; Reset TENTH_NUM1 to 0
    MOVLW 0xC0 ;for second line
    CALL send
    BSF Select, RS
    MOVLW D'48' ; Load ASCII value for '0'
    CALL send ; Send '0' to the LCD
	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_FIRST_POSITION
    RETURN

ONES_NUM_1_INCREMENT:
    BANKSEL ONES_NUM1 ; Increment the TENTH_NUM1 value
    INCF ONES_NUM1, F ; Increment TENTH_NUM1 and check for overflow
    MOVF ONES_NUM1, W   ; Move TENTH_NUM1 to W
    XORLW D'10'           ; XOR with 9    ; Subtract 9 from W
    BTFSC STATUS, Z      ; If the result is zero, TENTH_NUM1 was greater than 9
    GOTO ResetOnesNum1 ; If TENTH_NUM1 is greater than 9, reset it to 0
; If TENTH_NUM1 is not greater than 9, continue to display the incremented value
    MOVLW  0xC1 ;FOR second line
    CALL send
    BSF Select, RS
    MOVF ONES_NUM1, W ; Get the value of TENTH_NUM1
    ADDLW D'48' ; Convert to ASCII
    CALL send ; Send the updated value to the LCD
   	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_SECOND_POSITION
    RETURN

    
ResetOnesNum1:
    CLRF ONES_NUM1 ; Reset TENTH_NUM1 to 0
    MOVLW 0xC1 ;for second line
    CALL send
    BSF Select, RS
    MOVLW D'48' ; Load ASCII value for '0'
    CALL send ; Send '0' to the LCD
	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_SECOND_POSITION
    RETURN

TENTH_NUM_2_INCREMENT:
    BANKSEL TENTH_NUM2 ; Increment the TENTH_NUM1 value
    INCF TENTH_NUM2, F ; Increment TENTH_NUM1 and check for overflow
    MOVF TENTH_NUM2, W   ; Move TENTH_NUM1 to W
    XORLW D'10'           ; XOR with 9    ; Subtract 9 from W
    BTFSC STATUS, Z      ; If the result is zero, TENTH_NUM1 was greater than 9
    GOTO ResetTenthNum2 ; If TENTH_NUM1 is greater than 9, reset it to 0
    
    ; If TENTH_NUM1 is not greater than 9, continue to display the incremented value
    MOVLW 0xC3 ; for second line
    CALL send
    BSF Select, RS
    MOVF TENTH_NUM2, W ; Get the value of TENTH_NUM1
    ADDLW D'48' ; Convert to ASCII
    CALL send ; Send the updated value to the LCD
   	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_THIRD_POSITION
    RETURN

ResetTenthNum2:
    CLRF TENTH_NUM2 ; Reset TENTH_NUM1 to 0
    MOVLW 0xC3 ;for second line
    CALL send
    BSF Select, RS
    MOVLW D'48' ; Load ASCII value for '0'
    CALL send ; Send '0' to the LCD
	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_THIRD_POSITION
    RETURN

ONES_NUM_2_INCREMENT:
    BANKSEL ONES_NUM2 ; Increment the TENTH_NUM1 value
    INCF ONES_NUM2, F ; Increment TENTH_NUM1 and check for overflow
    MOVF ONES_NUM2, W   ; Move TENTH_NUM1 to W
    XORLW D'10'           ; XOR with 9    ; Subtract 9 from W
    BTFSC STATUS, Z      ; If the result is zero, TENTH_NUM1 was greater than 9
    GOTO ResetOnesNum2 ; If TENTH_NUM1 is greater than 9, reset it to 0
; If TENTH_NUM1 is not greater than 9, continue to display the incremented value
    MOVLW  0xC4 ;FOR second line
    CALL send
    BSF Select, RS
    MOVF ONES_NUM2, W ; Get the value of TENTH_NUM1
    ADDLW D'48' ; Convert to ASCII
    CALL send ; Send the updated value to the LCD
   	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_FORTH_POSITION
    RETURN

    
ResetOnesNum2:
    CLRF ONES_NUM2 ; Reset TENTH_NUM1 to 0
    MOVLW 0xC4 ;for second line
    CALL send
    BSF Select, RS
    MOVLW D'48' ; Load ASCII value for '0'
    CALL send ; Send '0' to the LCD
	BSF Select, RS ; Set RS to data mode
	call RETURN_CURSOR_TO_FORTH_POSITION
    RETURN

RETURN_CURSOR_TO_FIRST_POSITION:
    BCF Select, RS ; Command mode
    MOVLW 0xC0 ; Set cursor to the first position of the second row
    CALL send ; Send the command
    RETURN

RETURN_CURSOR_TO_SECOND_POSITION:
    BCF Select, RS ; Command mode
    MOVLW 0xC1 ; Set cursor to the first position of the second row
    CALL send ; Send the command
    RETURN

RETURN_CURSOR_TO_MUL_POSITION:
    BCF Select, RS ; Command mode
    MOVLW 0xC2 ; Set cursor to the first position of the second row
    CALL send ; Send the command
    RETURN

RETURN_CURSOR_TO_THIRD_POSITION:
    BCF Select, RS ; Command mode
    MOVLW 0xC3 ; Set cursor to the first position of the second row
    CALL send ; Send the command
    RETURN

RETURN_CURSOR_TO_FORTH_POSITION:
    BCF Select, RS ; Command mode
    MOVLW 0xC4 ; Set cursor to the first position of the second row
    CALL send ; Send the command
    RETURN

MoveCursorRight:
   BCF Select, RS ; Command mode
    MOVLW   0x14      ; Command to move the cursor to the right
    CALL    send        ; Use the send subroutine to transmit the command
    RETURN
   
stopcursor:
    BCF Select, RS ; Command mode
    MOVLW 0xC6 ; Set cursor to the first position of the second row
    CALL send ; Send the command
    RETURN

MoveCursor:
    MOVLW 1
    SUBWF COUNTER_BUTTON2,W
    BTFSS STATUS, Z
    GOTO  MoveCursorRight
    GOTO stopcursor ; If COUNTER_BUTTON is 1, increment ones number
  

mul:
   MOVLW   .10
   MOVWF   COUNTER_MUL         ; Initialize loop counter
   MOVF   TENTH_NUM1 ,W       ; Store MASTER_RESULT_tens in TEMP_REG
   CLRF    NUM1  ; Clear MASTER_RESULT	
   GOTO    MUL_LOOP

MUL_LOOP:
    ADDWF   NUM1 ; Add TEMP_REG to MASTER_RESULT
    DECFSZ  COUNTER_MUL   ; Decrement loop counter and skip if zero
    GOTO    MUL_LOOP         ; Repeat loop if counter is not zero
    MOVF   ONES_NUM1,W
    ADDWF  NUM1
    CLRF   COUNTER_MUL 
    GOTO   SendData

mul2:
   MOVLW   .10
   MOVWF   COUNTER_MUL         ; Initialize loop counter
   MOVF    TENTH_NUM2 ,W       ; Store MASTER_RESULT_tens in TEMP_REG  ==> 39
   CLRF    NUM2_TENS
   GOTO    MUL_LOOP2
   
MUL_LOOP2:
    ADDWF   NUM2_TENS ; Add TEMP_REG to MASTER_RESUL
    DECFSZ  COUNTER_MUL   ; Decrement loop counter and skip if zero
    GOTO    MUL_LOOP2         ; Repeat loop if counter is not zero
    GOTO   mul_ones_num1

mul_ones_num1:
   	MOVF	NUM1 ,W		; get first number
	CLRF	MASTER_RESULT2		; total to Z
    CLRF	MASTER_RESULT1		; total to Z
    GOTO    add1_tenth_num1

add1_tenth_num1:
	ADDWF	MASTER_RESULT2	; add to total
    BTFSC   STATUS, C  
    INCF    MASTER_RESULT1, F
	DECFSZ	NUM2_TENS	; num2 times and
	GOTO	add1_tenth_num1		; repeat if not done
	GOTO     receive1


Display_Result:

    BCF Select,RS
  	MOVLW 0xC6
    CALL send
    BSF Select, RS
    MOVF  thousand  , W ; Get the value of TENTH_NUM1
    ADDLW D'48'
    CALL send 

    BCF Select,RS
  	MOVLW 0xC7
    CALL send
    BSF Select, RS
    MOVF  hun   , W ; Get the value of TENTH_NUM1
    ADDLW D'48'
    CALL send 

    BCF Select,RS
  	MOVLW 0xC8
    CALL send
    BSF Select, RS
    MOVF  tens   , W ; Get the value of TENTH_NUM1
    ADDLW D'48'
    CALL send 
   
    
    BCF Select,RS
  	MOVLW 0xC9
    CALL send
    BSF Select, RS
    MOVF  ones   , W ; Get the value of TENTH_NUM1
    ADDLW D'48'
    CALL send 

    INCF COUNTER_FINISH,F
    RETURN 
;; 12 x 21 --> 12 x 20 + 12 x 1 
;;0810
addition:
    MOVF MASTER_RESULT1, W
    ADDWF CO_PROC_RESULT1, W
    ADDWF RESULT_HIGH
    
    ; Add low bytes
    MOVF MASTER_RESULT2, W
    ADDWF CO_PROC_RESULT2, W
    MOVWF RESULT_LOW

    BTFSC STATUS, C
    INCF RESULT_HIGH, F
 
    CALL split
    GOTO Display_Result


split:
	CLRF ones
	CLRF tens
	CLRF hun
	CLRF thousand
next:
	MOVFW RESULT_LOW
	BTFSC STATUS, Z
	GOTO loop_High
	DECF RESULT_LOW
next2:
	INCF ones
	CALL check_ones
	GOTO next

finish_split:
	RETURN

check_ones:
	MOVLW d'10'
	SUBWF ones,W
	BTFSS STATUS, Z
	RETURN
	CLRF ones
	INCF tens
	CALL check_tens
	RETURN

check_tens:
	MOVLW d'10'
	SUBWF tens,W
	BTFSS STATUS, Z
	RETURN
	CLRF tens
	INCF hun
	CALL check_huns
	RETURN

check_huns:
	MOVLW d'10'
	SUBWF hun,W
	BTFSS STATUS, Z
	RETURN
	CLRF hun
	INCF thousand
	RETURN

loop_High:
	MOVFW RESULT_HIGH
	BTFSC STATUS, Z
	GOTO finish_split
	MOVLW 0xff
	MOVWF RESULT_LOW
	DECF RESULT_HIGH
	GOTO next2


;**********************************************************************************************************************************************************
;                                                                         DISPLAY NUMBERS 
;**********************************************************************************************************************************************************


DisplayMessage:
	BCF Select, RS
	MOVLW 0x0F
	CALL send	
	BSF Select,RS
    MOVLW   'W'
    CALL    send
    MOVLW   'e'
    CALL    send
    MOVLW   'l'
    CALL    send
    MOVLW   'c'
    CALL    send
    MOVLW   'o'
    CALL    send
    MOVLW   'm'
    CALL    send
    MOVLW   'e'
    CALL    send
    MOVLW   ' '
    CALL    send
    MOVLW   't'
    CALL    send
    MOVLW   'o'
    CALL    send
	BCF Select,RS

	MOVLW 0xC0 ; for second line
	CALL send
	BSF Select, RS
    MOVLW   'm'
    CALL    send
    MOVLW   'u'
    CALL    send
    MOVLW   'l'
    CALL    send
    MOVLW   't'
    CALL    send
    MOVLW   'i'
    CALL    send
    MOVLW   'p'
    CALL    send
    MOVLW   'l'
    CALL    send
    MOVLW   'i'
    CALL    send
    MOVLW   'c'
    CALL    send
    MOVLW   'a'
    CALL    send
    MOVLW   't'
    CALL    send
    MOVLW   'i'
    CALL    send
    MOVLW   'o'
    CALL    send
    MOVLW   'n'
    CALL    send
	BSF Select,RS
	call xms 
	call xms
	call xms
	call ClearLCD
    RETURN


DISPLAY_NUMBER_1:

	call ClearLCD
	BCF Select, RS
	MOVLW 0x80
	CALL send	
	BSF Select,RS
    MOVLW   'N'
    CALL    send
    MOVLW   'u'
    CALL    send
    MOVLW   'm'
    CALL    send
    MOVLW   'b'
    CALL    send
    MOVLW   'e'
    CALL    send
    MOVLW   'r'
    CALL    send
    MOVLW   ' '
    CALL    send
    MOVLW   '1'
    CALL    send
	BCF Select,RS

	MOVLW 0xC0 ; for second line
	CALL send
	BSF Select, RS
    MOVF TENTH_NUM1, W ; Get the value of TENTH_NUM1
    SUBWF TENTH_NUM1, W ; Convert from ASCII to numerical value
    ADDLW D'48' ; Convert to ASCII
    CALL send ; Send the tens digit to the LCD
    BSF Select, RS
    MOVF ONES_NUM1, W ; Get the value of TENTH_NUM1
    SUBWF ONES_NUM1, W ; Convert from ASCII to numerical value
    ADDLW D'48' ; Convert to ASCII
    CALL send ;
	BSF Select, RS ; Set RS to data mode
    CALL RETURN_CURSOR_TO_FIRST_POSITION
	RETURN

DISPLAY_NUMBER_2:
    BCF Select, RS
 	MOVLW 0xC2 ; for second line
	CALL send
	BSF Select, RS
    MOVLW   'X'
    CALL    send

	BCF Select, RS
	MOVLW 0x80
	CALL send	
	BSF Select,RS
    MOVLW   'N'
    CALL    send
    MOVLW   'u'
    CALL    send
    MOVLW   'm'
    CALL    send
    MOVLW   'b'
    CALL    send
    MOVLW   'e'
    CALL    send
    MOVLW   'r'
    CALL    send
    MOVLW   ' '
    CALL    send
    MOVLW   '2'
    CALL    send
	BCF Select,RS

	
	MOVLW 0xC3
    CALL send
    BSF Select, RS
    MOVF TENTH_NUM2, W ; Get the value of TENTH_NUM1
    SUBWF TENTH_NUM2, W ; Convert from ASCII to numerical value
    ADDLW D'48' ; Convert to ASCII
    CALL send ; Send the tens digit to the LCD
    BSF Select, RS
    MOVF ONES_NUM2, W ; Get the value of TENTH_NUM1
    SUBWF ONES_NUM2, W ; Convert from ASCII to numerical value
    ADDLW D'48' ; Convert to ASCII
    CALL send ;
	BSF Select, RS ; Set RS to data mode
	CALL RETURN_CURSOR_TO_MUL_POSITION
    GOTO twoscheck
	RETURN


DISP:
	BCF Select, RS
	MOVLW 0x80
	CALL send	
	BSF Select,RS
    MOVLW   'R'
    CALL    send
    MOVLW   'E'
    CALL    send
    MOVLW   'S'
    CALL    send
    MOVLW   'U'
    CALL    send
    MOVLW   'L'
    CALL    send
    MOVLW   'T'
    CALL    send
    MOVLW   ' '
    CALL    send
    MOVLW   ' '
    CALL    send
	BSF Select, RS ; Set RS to data mode
	RETURN	

ClearLCD:
    BANKSEL PORTD
    BCF Select, RS ; Command mode
    MOVLW 0x01 ; Clear display command
    CALL send ; Send the command
    MOVLW 0x02 ; Return home command
    CALL send ; Send the command
    RETURN


loop:
    BANKSEL PORTD
	CALL xms

    GOTO loop 

    END
