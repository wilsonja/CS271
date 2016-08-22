TITLE Programming Assignment #2     (Prog02.asm)

; Author: Jacob Wilson
; Course / Project ID: CS271_400 / Project #2       Date: 4/15/16
; Description: This program displays a number of values from the
;  Fibonacci sequence. The user inputs the number of values
;  desired, as well as their own name. The program utilizes the
;  user name and also displays the Fibonacci values five per line.

INCLUDE Irvine32.inc

UPPERLIMIT = 46			; constant upper limit used for validation

.data
progTitle		BYTE	"Fibonacci Numbers", 0
byName			BYTE	"Programmed by ", 0
myName			BYTE	"Jacob Wilson", 0
promptName		BYTE	"What is your name? ", 0
sayHello		BYTE	"Hello, ", 0
promptInstruct	BYTE	"Enter the number of Fibonacci terms to be displayed,", 13,10
				BYTE	"give the number as an integer in the range [1 ... 46].", 0
promptFibs		BYTE	"How many Fibonacci terms do you want? ", 0
outRange		BYTE	"Out of range. Enter a number in [1 ... 46].", 0
promptBye		BYTE	"Results certified by ", 0
promptBye2		BYTE	"My sincerest farewell, ", 0
period			BYTE	46, 0
spaces			BYTE	32, 32, 32, 32, 32, 32, 0

userName		BYTE	21 DUP(0)
nameSize		DWORD	?
numFibs			DWORD	?
numTerms		DWORD	?
fibNow			DWORD	0
fibPrev			DWORD	1
fibNext			DWORD	1
lineCount		DWORD	0

.code
main PROC

; introduction
	; display program title and programmer name
	mov		edx, OFFSET progTitle
	call	WriteString
	call	CrLf
	mov		edx, OFFSET byName
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	call	CrLf
	call	CrLf

	; request user name
	mov		edx, OFFSET promptName
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF userName
	dec		ecx
	call	ReadString
	mov		nameSize, eax

	; greet the user by name
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
	call	CrLf
	call	CrLf

; getUserData
GetFibs:
	; request number of Fib terms from user
	mov		edx, OFFSET promptFibs
	call	WriteString
	call	ReadInt							; number of Fibs requested
	mov		numFibs, eax
	
	; input validation
	mov		eax, UPPERLIMIT					; check against upper limit
	cmp		numFibs, eax
	jb		InR								; jump if in range

	; for out of range numbers
	mov		edx, OFFSET outRange
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		GetFibs

; display Fibs
InR:										; for in range numbers
	mov		ecx, numFibs					; establish loop counter

FibLoop:
	; line feed after every 5 loops
	mov		eax, lineCount
	mov		ebx, 5
	xor		edx, edx
	div		ebx
	cmp		edx, 0
	jne		L1
	call	CrLf							; skip CrLf unless at fifth line
L1:
	; compute the Fib numbers
	mov		ebx, fibPrev
	add		ebx, fibNow
	mov		fibNext, ebx
	mov		eax, fibNext
	call	WriteDec
	mov		edx, OFFSET spaces
	call	WriteString
L2:
	; set up for the following Fib number
	mov		eax, fibNow
	mov		fibPrev, eax
	mov		eax, fibNext
	mov		fibNow, eax
	inc		lineCount
	loop FibLoop

; farewell
	; display goodbye message to user
	call	CrLf
	call	CrLf
	mov		edx, OFFSET promptBye
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	mov		edx, OFFSET period
	call	WriteString
	call	CrLf
	mov		edx, OFFSET promptBye2
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET period
	call	WriteString
	call	CrLf
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
