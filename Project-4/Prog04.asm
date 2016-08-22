TITLE Programming Assignment #4: Composite Numbers     (Prog04.asm)

; Author: Jacob Wilson
; Course / Project ID: CS271_400 Program #4          Date: 5/8/16
; Description: This program displays a number of composite numbers as determined by
;  the user. A composite number is one that can be evenly divided by numbers other
;  than 1 or itself. The program utilizes two loops; the first tracks the number of
;  composite numbers displayed and increments the number for testing, the second
;  loop tests if the number is composite by performing multiple divisions.

INCLUDE Irvine32.inc

LOWERLIMIT = 1
UPPERLIMIT = 400

.data
progTitle	BYTE	"Composite Numbers            Programmed by Jacob Wilson", 0
showInstruct	BYTE	"Enter the number of composite numbers you would like to see.",13, 10
		BYTE	"I can display up to 400 composites.", 0
askNums		BYTE	"Enter the number of composites to display [1 ... 400]: ", 0
showOutRange	BYTE	"Out of range. Try again.", 0
sayGoodBye	BYTE	"Results certified by Jacob W.   Goodbye!", 0
ecPrompt	BYTE	"**EC: Align the output columns.", 0
spaces3		BYTE	32, 32, 32, 0
spaces4		BYTE	32, 32, 32, 32, 0
spaces5		BYTE	32, 32, 32, 32, 32, 0

numComps	DWORD	?					; number of composites requested by user
currentComp	DWORD	?					; current number being tested
lineCount	DWORD	10					; decrements, line break needed when equal 0
inRange		DWORD	0					; acts as a bool variable, 1 when true
compFound	DWORD	0					; acts as a bool variable, 1 when true

.code
main PROC
	call	introduction
	call	getUserData
	call	showComposites
	call	farewell
	exit	; exit to operating system
main ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                    Introduction
; Procedure to display opening information and program
; instructions to the user.
; 
; Receives: nothing
; Returns: nothing
; Preconditions: called from main
; Registers changed: edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
introduction PROC
	; display program title information
	mov	edx, OFFSET progTitle
	call	WriteString
	call	Crlf
	mov	edx, OFFSET ecPrompt
	call	WriteString
	call	Crlf
	call	Crlf

	; display user instructions
	mov	edx, OFFSET showInstruct
	call	WriteString
	call	Crlf
	call	Crlf
	ret
introduction ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                    getUserData
; Procedure to get the number of composite numbers
; requested from the user.
; 
; Receives: nothing
; Returns: nothing
; Preconditions: called from main
; Registers changed: eax, edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
getUserData PROC
getNums:
	; prompt the user to enter a number
	mov	edx, OFFSET askNums
	call	WriteString
	call	ReadInt
	mov	numComps, eax					; store the user inputted number
	call	validate					; validate the number
	mov	eax, 0
	cmp	eax, inRange					; inRange = 1 (true) when valid
	je	getNums						; request a new number if invalid
	ret
getUserData ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      Validate
; Procedure to validate the number entered by the user.
; Valid numbers are 1-400 inclusive.
;
; Receives: nothing
; Returns: nothing
; Preconditions: user inputs integer in getUserData
; Registers changed: eax, edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
validate PROC
	; check the number against the lower limit
	mov	eax, LOWERLIMIT
	cmp	numComps, eax
	jl	OutRange

	; check the number against the upper limit
	mov	eax, UPPERLIMIT
	cmp	numComps, eax
	jg	OutRange

	; when number is in range
	mov	inRange, 1					; inRange = 1 (true) when valid
	jmp	ValDone

OutRange:
	; display message if the number is out of range
	mov	edx, OFFSET showOutRange
	call	WriteString
	call	Crlf

ValDone:
	ret
validate ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                    showComposites
; Procedure to loop ("outer loop") according to user
; requested number of composites. The loop calls the
; isComposite function to determine if the current
; number is a composite number. When a composite number
; is found, showComposites displays the value.
; 
; Receives: nothing
; Returns: nothing
; Preconditions: called from main with valid values
; Registers changed: eax, ebx, ecx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
showComposites PROC
	; initialize values for isComposite call
	call	Crlf
	mov	eax, 4						; set to lowest composite number
	mov	currentComp, eax				; begin with lowest possible composite
	mov	ecx, numComps					; outer loop set to user requested numbers

CompDisplay:
	; reset eax and ebx to prepare for isComposite call
	mov	eax, currentComp	
	mov	ebx, 2						; lowest divisor for composite numbers
	call	isComposite
	cmp	compFound, 0					; compFound = 1 (true) when composite number found
	je	CompNotFound					; restart loop with new value if not composite

	; display value after finding a composite number
	mov	eax, currentComp
	call	WriteDec
	inc	currentComp

	; check to see if a line break is necessary
	dec	lineCount
	mov	eax, 0
	cmp	lineCount, eax
	je	AddLine
	call	addSpaces					; additional procedure to align output columns
	jmp	ShowDone

AddLine:
	; add line, reset lineCount to 10
	call	Crlf
	mov	lineCount, 10
	jmp	ShowDone

CompNotFound:
	; check additional numbers as composites
	inc		currentComp				; move on to next number for testing
	jmp		CompDisplay				; loop count not incremented if composite not found

ShowDone:
	; reset compFound to false and resume loop
	mov	compFound, 0
	loop	CompDisplay					; loop count only increments when composite is found
showComposites ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                     isComposite
; Procedure to loop ("inner loop") to determine if the
; current value is a composite number. The loop tests the
; current number against all possible divisors up to the
; current number. If the number is divisible, it is
; composite.
; 
; Receives: nothing
; Returns: nothing
; Preconditions: called by showComposites
; Registers changed: eax, ebx, edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
isComposite PROC
FindComp:
	; compare the current number with divisor, if equal move on to next number
	cmp	ebx, eax
	je	CompDone

	; check divisibility, if remainder = 0, the number is composite
	cdq
	div	ebx
	cmp	edx, 0
	je	IsComp						; composite found

CheckComp:
	; check current number against additional divisors
	mov	eax, currentComp
	inc	ebx
	jmp	FindComp

IsComp:
	; once a composite number has been found
	mov	compFound, 1

CompDone:
	ret
isComposite ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      farewell
; Procedure to display a goodbye message to the user.
; 
; Receives: nothing
; Returns: nothing
; Preconditions: called from main
; Registers changed: eax, ebx, edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
farewell PROC
	; skip additional line break if number of composites is factor of 10
	mov	eax, numComps
	mov	ebx, 10
	cdq
	div	ebx
	cmp	edx, 0
	je	SkipLine
	call	Crlf

SkipLine:
	call	Crlf
	mov	edx, OFFSET sayGoodBye
	call	WriteString
	call	Crlf
	ret
farewell ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      addSpaces
; Procedure to align output columns based on the size
; of the value.
; 
; Receives: nothing
; Returns: nothing
; Preconditions: called from showComposites
; Registers changed: eax, edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
addSpaces PROC
	mov	eax, currentComp
	cmp	eax, 10
	jle	Space5
	cmp	eax, 100
	jle	Space4
	mov	edx, OFFSET spaces3
	call	WriteString
	ret
Space5:
	mov	edx, OFFSET spaces5
	call	WriteString
	ret
Space4:
	mov	edx, OFFSET spaces4
	call	WriteString
	ret
addSpaces ENDP

END main
