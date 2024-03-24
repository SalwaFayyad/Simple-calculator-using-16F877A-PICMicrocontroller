;SALWA FAYYAD 1200430
;SAHAR FAYYAD 1190119
;MAJD ABUBAHA 1190069
;MAYSAM KHATEEB 1190207

;**************************************************************************************************
;									CO-PROCESSOR MULTIPLICATION									
;**************************************************************************************************

	PROCESSOR 16F877A
	INCLUDE "P16F877A.INC"	

	__CONFIG 0x3731
;**************************************************************************************************
;REGISTORS DECLARATIONS 

ONES_NUM2 EQU 0x23
NUMBER_1_REGISTER EQU 0x24
COUNTER_MUL EQU 0x25     ; COUNTER FOR MULTIPLICATION
CO_PROC_RESULT2 EQU 0x26 ; FOR LEAST SIGNIFICANT DIGIT
CO_PROC_RESULT1 EQU 0x27 ; FOR THE MOST SIGNIFICANT DIGIT

;**************************************************************************************************
; The instructions should start from here
	ORG 0x00
	GOTO init
;***************************************************************************************************
	INCLUDE "LCDIS.INC" 
;***************************************************************************************************

; The init for our program
init:
	CLRF CO_PROC_RESULT2
    CLRF CO_PROC_RESULT1
	CLRF NUMBER_1_REGISTER
	CLRF ONES_NUM2

;**************************************************************************************************
;	PROTOCOL USART INITIALIZATION
;**************************************************************************************************

	BANKSEL PORTC
	BCF PORTC, 6  ; Clear bit 0 of PORTC, TX
	BSF PORTC, 7  ; Clear bit 1 of PORTC, RX

    BANKSEL SPBRG
    MOVLW 0x25            ;Baud rate
    MOVWF SPBRG

    BANKSEL RCSTA
    MOVLW 0x90            ; Enable serial port (SPEN=1), enable continuous receive (CREN=1 for async mode) 10010000
    MOVWF RCSTA

    BANKSEL TXSTA
    MOVLW 0x20           ; 8_bit transmission , transmit enabled 00100000
    MOVWF TXSTA

	; we add the led to check for sending and receiving
    bcf STATUS, RP0        ; Return to Bank 0
	BANKSEL TRISD
	BCF TRISD, 2   ; Set RD2 as output for the LED
	BANKSEL PORTD  ; Return to bank containing PORTD for subsequent operations

	CALL receive1
	CALL receive2

    MOVFW ONES_NUM2 
    BTFSC STATUS,Z
    GOTO  SendData
    
    MOVFW NUMBER_1_REGISTER
    BTFSC STATUS,Z
    GOTO  SendData    

	CALL mul_ones_num1

;***************************************************************************************************
; Revised receive routine for PIC2
receive1:
    BTFSS PIR1, RCIF       ; Check if data is received
    GOTO receive1          ; If not, loop

    BANKSEL RCREG          ; Select bank containing RCREG
    MOVF RCREG, W          ; Read the received data
	MOVWF NUMBER_1_REGISTER

    BANKSEL PORTD
    BCF PORTD, 2           ; Turn LED off

    RETURN
    
receive2:
    BTFSS PIR1, RCIF       ; Check if data is received
    GOTO receive2           ; If not, loop again

    BANKSEL RCREG          
    MOVF RCREG, W          ; Read the received data
	MOVWF ONES_NUM2        ; Store the unit digit of the second number

    BANKSEL PORTD
    BSF PORTD, 2           ; Turn LED on
	RETURN


SendData:
	BANKSEL TXREG   
	MOVF CO_PROC_RESULT1 ,W
	MOVWF TXREG

	CALL xms 
    CALL xms 

	BANKSEL TXREG   
	MOVF CO_PROC_RESULT2 ,W
	MOVWF TXREG

    BANKSEL PORTD
    BCF PORTD, 2           ; Turn LED off
    GOTO clear

;*****************************************************************************************************
;START MULTIPLICATION

mul_ones_num1:
   	MOVF	NUMBER_1_REGISTER ,W		
	CLRF	CO_PROC_RESULT2		
    CLRF	CO_PROC_RESULT1		
    GOTO    add1_tenth_num1

add1_tenth_num1:
	ADDWF	CO_PROC_RESULT2	; add to total
    BTFSC   STATUS, C  
    INCF    CO_PROC_RESULT1, F
	DECFSZ	ONES_NUM2	
	GOTO	add1_tenth_num1		; repeat if not done
    MOVF    CO_PROC_RESULT1, W
	GOTO    SendData		; done, display result

; CLEAR REGISTERS 
clear:
  	CLRF CO_PROC_RESULT2
    CLRF CO_PROC_RESULT1
	CLRF NUMBER_1_REGISTER
	CLRF ONES_NUM2
END