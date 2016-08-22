TITLE Programming Assignment #6a     (Prog06a.asm)

; Author: Jacob Wilson
; Course / Project ID: CS271_400 Program #6a          Date: 6/3/16
; Description: This program utilizes low-level I/O and macros to process a user inputted
;  string. Each character of the string is validated to be a legal integer, then the
;  string is converted to an integer. The sum and average is calculated and displayed.

INCLUDE Irvine32.inc

ARRAY_SIZE = 10							; constant max size of the array

.data
progTitle	BYTE	"Programming Assignment 6a: Designing low-level I/O procedures", 0
progBy		BYTE	"Written by: Jacob Wilson", 0
progInstruct	BYTE	"Please provide 10 unsigned decimal integers.", 13, 10
		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 13, 10
		BYTE	"After you have finished inputting the raw numbers, I will display a list", 13, 10
		BYTE	"of the integers, their sum, and their average value.", 0
enterPrompt	BYTE	"Please enter an unsigned integer: ", 0
errorPrompt	BYTE	"ERROR: You did not enter an unsigned integer, or your number was too large.", 0
numsPrompt	BYTE	"You entered the following numbers: ", 0
sumPrompt	BYTE	"The sum of these numbers is: ", 0
avgPrompt	BYTE	"The average is: ", 0
byePrompt	BYTE	"Goodbye! Thanks for playing!", 0
space		BYTE	32, 0

numArray	DWORD	ARRAY_SIZE DUP(?)			; array holding the 10 integers
inputString	BYTE	255	DUP(?)			 	;the inputted string
inputSize	DWORD	?					; size of the inputted string
sum		DWORD	?					; calculated sum
avg		DWORD	?					; calculated average
numDigits	DWORD	0					; track the number of inputs

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Macros ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
; method for getString macro followed from CS271 Lecture 26
getString	MACRO	stringVar, stringPrompt	
	push	ecx						; save registers
	push	edx
	displayString	stringPrompt						
	mov	edx, OFFSET	stringVar			; save the string in variable
	mov	ecx, (SIZEOF stringVar) - 1			; save the size minus the end of line character
	call	ReadString					; accept user input
	pop	edx
	pop	ecx
ENDM

; method for displayString macro followed from CS271 Lecture 26
displayString	MACRO	inputString
	push	edx						; save register
	mov	edx, OFFSET inputString				; to go string location
	call	WriteString					; display string
	pop	edx
ENDM
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

.code
main PROC
; introduce the program
	call	introduction

; start a loop to obtain the 10 integers
	mov	ecx, ARRAY_SIZE					; loop limited to 10 integers
GetNums:
	push	OFFSET	inputSize
	push	OFFSET	inputString
	push	OFFSET numArray
	push	OFFSET	numDigits
	call	readVal
	inc	numDigits					; tracks the number of values entered
	loop	GetNums
	call	Crlf

; display the entered values
	displayString	numsPrompt
	push	OFFSET numArray
	push	ARRAY_SIZE
	call	writeVal
	call	Crlf

; calculate the sum and display
	displayString	sumPrompt
	push	OFFSET numArray
	push	OFFSET sum
	push	ARRAY_SIZE
	call	calcSum

; calculate the average and display
	displayString avgPrompt
	push	OFFSET avg
	push	sum
	push	ARRAY_SIZE
	call	calcAvg
	call	Crlf

; display a departing message
	push	OFFSET byePrompt
	call	farewell

	exit	; exit to operating system
main ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                    introduction
; Procedure to display both the program information and
; program instructions.
; 
; Receives: nothing
; Returns: message with introduction
; Preconditions: called from main
; Registers changed: edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
introduction PROC
	; display program title information
	displayString	progTitle
	call	Crlf
	displayString	progBy
	call	Crlf
	call	Crlf

	; display instructions
	displayString	 progInstruct
	call	Crlf
	call	Crlf
	ret
introduction ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      readVal
; Procedure accepts user inputted string, validates it
; to be legal integer 0-9, converts from string to
; integer using the Irvine ParseDecimal32 procedure (see
; Irvine text pg 163), then stores into array.
; 
; Receives: addresses of variable to store number, string
;  inputted by user, storage array, and count of entries
; Returns: stores inputted values in array
; Preconditions: called from main
; Registers changed: eax, ebx, ecx, esi
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
readVal	PROC
	; set up stack
	push	ebp
	mov	ebp, esp
	push	ecx						; save ecx for main loop

StartString:
	; initialized with string input
	getString	inputString, enterPrompt		; get string input
	mov	ebx, [ebp + 20]					; get location for string size variable
	mov	[ebx], eax					; store the string size
	mov	ecx, [ebx]					; set parse counter to size
	mov	esi, [ebp + 16]					; setup string location for lodsb

ParseString:
	; load each string byte and validate to be integer 0-9
	lodsb
	cmp	ax, 48
	jl	OutRange
	cmp	ax, 57
	jg	OutRange
	loop	ParseString					; continue looping through entire string

InRange:
	; when valid, setup ParseDecimal32
	mov	edx, [ebp + 16]					; inputted string location
	mov	ecx, [ebx]					; inputted string size
	call	ParseDecimal32					; easy conversion from string to int
	jmp	Done

OutRange:
	; if out of range, display error and try again
	displayString	errorPrompt
	call	Crlf
	jmp	StartString

Done:
	; store the integer in the array
	mov	edx, [ebp + 12]					; array location
	mov	ebx, [ebp + 8]								
	mov	ebx, [ebx]					; number of entries
	imul	ebx, 4						; move appropriate number of bytes in array
	mov	[ebx + edx], eax				; store at next open location

	pop	ecx
	pop	ebp
	ret	16
readVal	ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      writeVal
; Procedure to display values in an array.
; 
; Receives: array location and size
; Returns: displays array values
; Preconditions: array filled with 10 integers
; Registers changed: eax, ecx, esi
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
writeVal PROC
	; set up stack
	push	ebp
	mov	ebp, esp
	mov	esi, [ebp + 12]					; location of array
	mov	ecx, [ebp + 8]					; size of array used for counter

DisplayLoop:
	; loop through the array display each value
	mov	eax, [esi]
	call	WriteDec
	displayString	space
	add	esi, 4						; move to next array location
	loop	DisplayLoop

	pop	ebp
	ret	8
writeVal ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      calcSum
; Procedure to calculate and display the sum of values
; in an array.
; 
; Receives: array location and size, sum variable
; Returns: displays calculated sum
; Preconditions: array filled with 10 integers
; Registers changed: eax, ebx, ecx, esi
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
calcSum PROC
	; set up stack
	push	ebp
	mov	ebp, esp
	mov	esi, [ebp + 16]					; location of array
	mov	ebx, [ebp + 12]					; location of sum variable
	mov	ecx, [ebp + 8]					; location of array size

SumLoop:
	; loop through array summing values
	mov	eax, [esi]
	add	[ebx], eax					; accumulate in sum variable
	add	esi, 4						; move to next array position
	loop	SumLoop

	; display the final sum
	mov	eax, [ebx]
	call	WriteDec
	call	Crlf

	pop	ebp
	ret	12
calcSum ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      calcAvg
; Procedure to calculate the average of array values.
; 
; Receives: location of array and average variable, sum
;  variable containing calculated sum
; Returns: calculate average
; Preconditions: array and its sum
; Registers changed: eax, ebx, ecx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
calcAvg PROC
	; set up stack
	push	ebp
	mov	ebp, esp
	mov	ecx, [ebp + 16]					; location of average variable
	mov	eax, [ebp + 12]					; sum variable
	mov	ebx, [ebp + 8]					; location of array size

	; perform the division
	cdq	
	idiv	ebx
	mov	[ecx], eax					; store calculated average

	; display the calculated average
	mov	eax, [ecx]
	call	WriteDec
	call	Crlf

	pop	ebp
	ret	12
calcAvg ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      farewell
; Procedure to display a goodbye message to the user.
; 
; Receives: address of a string
; Returns: goodbye message
; Preconditions: called from main
; Registers changed: edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
farewell	PROC
	; display the goodbye message
	displayString	 byePrompt
	call	Crlf
	ret
farewell	ENDP

END main
