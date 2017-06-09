.ORG 0000H
JMP MAIN

.ORG 0034H
JMP RST65

	 
DELAY: 	MVI B,0FFH; SUBROUTINE FOR SHORT DELAY of 1"point"8ms
LOOP:	DCR B
		JNZ LOOP
		RET	


MAIN:	
		LXI SP,0000H; INITIALIZING THE STACK POINTER
		PUSH PSW;SAVING ACCUMALATOR CONTENTS TO FFFFH
		MVI A,092H; CONTROL WORD FOR 8255 - P A&B=IP P C=OP
		OUT 03H; CONTROL REGISTER ADDRESS =03H
		MVI A,0C9H; CONTROL WORD FOR 1 O/P ON SOD & MASKING ALL INTERRUPTS OTHER THAN 6.5
		SIM
		CALL LCD_INIT
		CALL DELAY
		CALL DATA1
		CALL DELAY1
		CALL DELAY1
		CALL DELAY1
		EI
		JMP HEART
		POP PSW
		HLT


LCD_INIT: MVI D, 033H; SENDING INITIALISATION COMMAND
			 CALL COMMAND
			 MVI D,032H; SENDING INITIALISATION COMMAND
			 CALL COMMAND
			 MVI D,028H; SENDING COMMAND TO INITIALIZE 4 BIT
			 MVI D,006H; SENDING COMMAND TO INITIALIZE CURSOR
			 CALL COMMAND
			 MVI D,00FH; SEND COMMAND TO DISPLAY ON CURSOR BLINK
			 CALL COMMAND
			 MVI D,001H; SENDING COMMAND TO CLEAR DISPLAY
			 CALL COMMAND
			 CALL DELAY
			 CALL DELAY
			 RET

DATA1: MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA	
			MVI D,048H; SENDING DATA "H"
			CALL DATA
			MVI D,065H; SENDING DATA "e"
			CALL DATA
			MVI D,061H; SENDING DATA "a"
			CALL DATA
			MVI D,06CH; SENDING DATA "l"
			CALL DATA
			MVI D,074H; SENDING DATA "t"
			CALL DATA
			MVI D,068H; SENDING DATA "h"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,04BH; SENDING DATA "K"
			CALL DATA
			MVI D,069H; SENDING DATA "i"
			CALL DATA
			MVI D,074H; SENDING DATA "t"
			CALL DATA
			MVI D,0C0H; COMMAND TO FORCE CURSOR FROM 2nd LINE
			CALL COMMAND
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,020H; SENDING DATA "SPACE"
			CALL DATA
			MVI D,042H; SENDING DATA "B"
			CALL DATA
			MVI D,079H; SENDING DATA "y"
			CALL DATA
			CALL DELAY
			RET

COMMAND: MOV A,D
			ANI 0F0H;MASKING UPPER 4 BITS AND RS=0 FOR COMMAND
			OUT 02H; PORT C ADDRESS OF 8255
			CALL DELAY
			ORI 02H; ENABLE HIGH AND RS LOW
			CALL DELAY
			OUT 02H
			CALL DELAY
			ANI 0F0H
			OUT 02H
			CALL DELAY
			MOV A,D
			RLC; SHIFTING THE 4 BITS
			RLC
			RLC
			RLC
			ANI 0F0H; MASKING LOWER 4 BITS
			OUT 02H
			CALL DELAY
			ORI 02H; ENABLE HIGH
			CALL DELAY
			OUT 02H
			CALL DELAY
			ANI 0F0H
			OUT 02H
			CALL DELAY
			RET


DATA: 	MOV A,D
		ANI 0F1H; MAKING RS=1 FOR DATA REGISTER
		OUT 02H; PORT C ADDRESS OF 8255
		CALL DELAY
		ORI 03H; ENABLE HIGH AND RS HIGH
		CALL DELAY
		OUT 02H
		CALL DELAY
		ANI 0F1H
		OUT 02H
		CALL DELAY
		MOV A,D
		RLC; SHIFTING THE 4 BITS
		RLC
		RLC
		RLC
		ANI 0F1H
		OUT 02H
		CALL DELAY
		ORI 03H; ENABLE HIGH
		CALL DELAY
		OUT 02H
		CALL DELAY
		ANI 0F1H
		OUT 02H
		CALL DELAY
		RET


DELAY1:	LXI H, 0FFFFH
LOOP1:	DCX H
		MOV A,L
		ORA H
		JNZ LOOP1 
		RET

RST65: PUSH PSW
	   MVI A, 040H
	   SIM;  OUTPUTTING 0 ON SOD TO CLEAR D F/F
	   CALL DELAY

	   LDA 0A000H
	   INR A
	   STA 0A000H
	   
	   EI
	   MVI A,0CDH
	   SIM
	   POP PSW

	   RET

HEXTOBCD: PUSH PSW
			PUSH D
			MOV C,A              ; GET HEX DATA
			MVI D,00H          ;Clear D for Most significant Byte 
			XRA A             ;Clear Accumulator 

LOOP22:   ADI 01              ;Count the number one by one 
		 DAA               ;Adjust for BCD count 
		 JNC LOOP21 
		 INR D 
LOOP21:   DCR C 
		 JNZ LOOP22 
		 STA 0A001H          ;Store the Least Significant Byte 
		 MOV A,D 
		 STA 0A005H          ;Store the Most Significant Byte 
		 POP D
		 POP PSW
		 RET
BCDTOASCII:   MOV B,A   ; Address already stored in HL
				ANI 0F           ;Mask Upper Nibble 
				CALL SUB1        ;Get ASCII code for upper nibble 
				MOV D,A 
				MOV A,B 
				ANI F0           ;Mask Lower Nibble 
				RLC 
				RLC 
				RLC 
				RLC 
				CALL SUB1        ;Get ASCII code for lower nibble 
				MOV C,A
				RET              ;Return from subroutine

SUB1:   CPI 0A
		JC SKIP 
		ADI 07 
SKIP:   ADI 30
		RET              ;Return Subroutine



		DATA3: 
		CALL HEXTOBCD; LSB-A001H, MSB-A005H
			LDA 0A001H; LOAD HL WITH ADDRESS OF LSB OF HEART RATE
			CALL BCDTOASCII ; LSB - C, MSB - D
			MOV A,C
			STA A002H; STORING MSB 
			MOV A,D
			STA A003H ; STORING LSB

			LDA 0A005H ; LOAD A WITH ADDRESS OF MSB OF HEART RATE
			CALL BCDTOASCII ; LSB - C, MSB - D
			MOV A,C
			STA A006H ; STORING MSB - THIS WILL ALWAYS BE 0 
			MOV A,D
			STA A007H ; STORING LSB

		MVI D,001H; SENDING COMMAND TO CLEAR DISPLAY
		CALL COMMAND
		MVI D,080H; COMMAND TO FORCE CURSOR FROM 1st LINE
		CALL COMMAND
		CALL DELAY
		CALL DELAY

		MVI D,048H; SENDING DATA "H"
		CALL DATA
		MVI D,065H; SENDING DATA "e"
		CALL DATA
		MVI D,061H; SENDING DATA "a"
		CALL DATA
		MVI D,072H; SENDING DATA "r"
		CALL DATA
		MVI D,074H; SENDING DATA "t"
		CALL DATA
		MVI D,020H; SENDING DATA "SPACE"
		CALL DATA
		MVI D,052H; SENDING DATA "R"
		CALL DATA
		MVI D,061H; SENDING DATA "a"
		CALL DATA
		MVI D,074H; SENDING DATA "t"
		CALL DATA
		MVI D,065H; SENDING DATA "e"
		CALL DATA
		MVI D,03EH; SENDING DATA "colon"

		MVI D,0C0H; COMMAND TO FORCE CURSOR FROM 2nd LINE
		CALL COMMAND

		LDA 0A007H ; LSB OF MSB OF HEART RATE (MSB IS ALWAYS 0)
		MOV D,A
		CALL DATA
		LDA 0A002H ; MSB OF LSB OF HEART RATE
		MOV D,A
		CALL DATA
		LDA 0A003H ; LSB OF LSB OF HEART RATE
		MOV D,A
		CALL DATA

		MVI D,020H; SENDING DATA "SPACE"
		CALL DATA
		MVI D,042H; SENDING DATA "B"
		CALL DATA
		MVI D,050H; SENDING DATA "P"
		CALL DATA
		MVI D,04DH; SENDING DATA "M"
		CALL DATA
		RET
HEART: 	
			MVI A,000H
			STA 0A000H
			MVI A,01DH
			CALL DELAYNSEC
			CALL DELAY
			CALL DELAY
			DI
			LDA 0A000H
			RLC
			STA 0A000H
			CALL DATA3;
			CALL DELAY
			CALL DELAY
			EI

		JMP HEART

DELAYNSEC: MVI H, 050H
			LOOP3: MVI B,096H
			LOOP4: MVI C, 0FAH
			LOOP5: INR H
			INR H
			INR H
			INR H
			INR H
			INR H
			INR H
			INR H
			INR H
			INR H
			DCR C
			JNZ LOOP5
			DCR B
			JNZ LOOP4
			DCR A
			MOV H,A
			CPI 00FH
			JNC LOOP3
			CZ DATA4
			MVI D,02AH; SENDING DATA "*"
			CALL DATA
			MOV A,H
			ADI 00H
			JNZ LOOP3
			RET


DATA4:		MVI D,001H; SENDING COMMAND TO CLEAR DISPLAY
			CALL COMMAND
			MVI D,080H; COMMAND TO FORCE CURSOR FROM 1st LINE
			CALL COMMAND
			CALL DELAY
			CALL DELAY

			MVI D,043H; SENDING DATA "C"
			CALL DATA
			MVI D,061H; SENDING DATA "a"
			CALL DATA
			MVI D,06CH; SENDING DATA "l"
			CALL DATA
			MVI D,063H; SENDING DATA "c"
			CALL DATA
			MVI D,075H; SENDING DATA "u"
			CALL DATA
			MVI D,06CH; SENDING DATA "l"
			CALL DATA
			MVI D,061H; SENDING DATA "a"
			CALL DATA
			MVI D,074H; SENDING DATA "t"
			CALL DATA
			MVI D,069H; SENDING DATA "i"
			CALL DATA
			MVI D,06EH; SENDING DATA "n"
			CALL DATA
			MVI D,067H; SENDING DATA "g"
			CALL DATA
			MVI D,02EH; SENDING DATA "."
			CALL DATA
			MVI D,02EH; SENDING DATA "."
			CALL DATA
			MVI D,02EH; SENDING DATA "."
			CALL DATA

			MVI D,0C0H; COMMAND TO FORCE CURSOR FROM 2nd LINE
			CALL COMMAND

			RET