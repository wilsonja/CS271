TITLE Programming Assignment #3     (Prog03.asm)

; Author: Jacob Wilson
; Course / Project ID: CS271_400 Project #3         Date: 5/1/16
; Description: This program allows a user to enter integers in the range
;  of -100 to -1. It then calculates and displays the sum of all integers
;  entered, and calculates and displays the rounded average of the
;  integers. The standard prompts for accepting a user name, greeting the
;  user, and saying goodbye to the user are utilized.
;
; Special features: The program validates the user data to make sure that
;  it is within the expected range. The average of the numbers entered
;  is rounded according to the assignment guidlines. The lines are
;  numbered as the user enters numbers to fulfill extra credit 1 option.

INCLUDE Irvine32.inc

; define the lower limit as a constant
LOWERLIMIT = -100

.data
progTitle		BYTE	"Welcome to the Integer Accumulator ", 0
byName			BYTE	"Programmed by ", 0
myName			BYTE	"Jacob Wilson", 0
promptName		BYTE	"What is your name? ", 0
sayHello		BYTE	"Hello, ", 0
promptInstruct	BYTE	"Please enter numbers in [-100, -1].", 13,10
				BYTE	"Enter a non-negative number when you are finished to see results.", 0
promptNums		BYTE	"Enter a number:  ", 0
outRange		BYTE	"Out of range. Enter a number in [-100, -1].", 0
period			BYTE	46, 32, 0
excredit1		BYTE	"**EC: Program displays line number during user input.", 0

promptQuant1	BYTE	"You entered ", 0
promptQuant2	BYTE	" valid numbers.", 0
promptSum		BYTE	"The sum of your valid numbers is ", 0
promptAvg		BYTE	"The rounded average is ", 0
promptNoValid	BYTE	"You did not enter any valid numbers!", 0

promptBye		BYTE	"Thanks for playing Integer Accumulator! ", 0
promptBye2		BYTE	"I fare the well my dearest, ", 0

userName		BYTE	21 DUP(0)
nameSize		DWORD	?
nums			SDWORD	?
sum				SDWORD	?
avg				SDWORD	?
remain			SDWORD	?
numCount		DWORD	?

.code
main PROC
; introduction
	; display program title and programmer name
	mov		edx, OFFSET progTitle
	call	WriteString
	call	Crlf
	mov		edx, OFFSET byName
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	call	Crlf
	mov		edx, OFFSET excredit1
	call	WriteString
	call	Crlf
	call	Crlf

	; request user name
	mov		edx, OFFSET promptName
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF userName
	dec		ecx
	call	ReadString						; read in user name
	mov		nameSize, eax					; store size of inputted name

	; greet user by name
	mov		edx, OFFSET sayHello
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET period
	call	WriteString
	call	CrLf

; userInstructions
	; display instructions to user
	mov		edx, OFFSET promptInstruct
	call	WriteString
	call	Crlf
	call	Crlf

; getUserData
GetNums:	
	; request numbers from user
	push	numCount						; save numCount while using for extra credit option
	inc		numCount						; increase by one to reflect true line count
	mov		eax, numCount
	call	WriteDec						; display extra credit line count
	pop		numCount						; return numCount to actual value
	mov		edx, OFFSET period
	call	WriteString
	mov		edx, OFFSET promptNums
	call	WriteString
	call	ReadInt
	mov		nums, eax

	; input validation (if user enters value less than -100)
	mov		eax, LOWERLIMIT
	cmp		nums, eax
	jl		OutR

	; determine if user enters positive or negative number, if the number
	; is not negative, the user is done entering numbers
	mov		eax, nums
	cmp		eax, 0
	js		InR
	jns		CalcAndDisplay

OutR:	
	; for out of range numbers do not add to sum
	mov		edx, OFFSET outRange
	call	WriteString
	call	Crlf
	call	Crlf
	jmp		GetNums

InR:
	; for in range numbers continue in loop
	mov		eax, nums
	add		sum, eax						; keep adding new numbers to sum
	inc		numCount						; increase the number of values added
	loop	GetNums

CalcAndDisplay:
; display results
	; if no valid numbers entered
	mov		eax, sum
	cmp		eax, 0
	jz		NoValidNums						; skip past sum and average sections

	; result if valid numbers entered
	call	Crlf
	mov		edx, OFFSET promptQuant1
	call	WriteString
	mov		eax, numCount
	call	WriteDec						; displays number of values entered
	mov		edx, OFFSET promptQuant2
	call	WriteString
	call	Crlf

	; display sum
	mov		edx, OFFSET promptSum
	call	WriteString
	mov		eax, sum
	call	WriteInt						; displays sum of values added
	call	Crlf

	; calculate average
	cdq										; clear edx
	mov		ebx, numCount
	idiv	ebx
	mov		avg, eax
	mov		remain, edx

	; determine rounding
	mov		eax, numCount
	cdq										; clear edx
	mov		ebx, 2
	div		ebx
	neg		remain
	cmp		remain, eax						; round up if remainder is more than half of divisor
	jle		NoRounding

RoundUp:
	mov		eax, avg
	dec		eax								; decrease rounds up because using negative numbers
	mov		avg, eax						; store newly rounded number

NoRounding:
	mov		edx, OFFSET promptAvg
	call	WriteString
	mov		eax, avg
	call	WriteInt
	call	Crlf
	call	Crlf
	jmp		GoodBye

; if no valid numbers entered
NoValidNums:
	call	Crlf
	mov		edx, OFFSET promptNoValid
	call	WriteString
	call	Crlf
	call	Crlf

; display goodbye
GoodBye:
	mov		edx, OFFSET promptBye
	call	WriteString
	call	Crlf
	mov		edx, OFFSET promptBye2
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET period
	call	WriteString
	call	Crlf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
