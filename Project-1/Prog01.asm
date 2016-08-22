TITLE Programming Assignment #1     (Prog01.asm)

; Author: Jacob Wilson
; Course / Project ID: CS271_400 / Project #1       Date: 4/8/16
; Description: This program accepts two integers inputted by the user. It
;  then calculates and displays the sum, product, quotient, and remainder.
;  The program also verifies whether the second number is greater, less
;  than, or equal to the first.

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

myName		BYTE	"by Jacob Wilson", 0
intro		  BYTE	9,"Elementary Arithmetic", 9, 9, 0
prompt_1	BYTE	"Enter two numbers and I'll show you the sum, difference,", 13,10
			    BYTE	"product, quotient, and remainder.", 0
ec2Prompt	BYTE	"**EC: Program verfies that second number is less than first.",0
firstNum	BYTE	"First number: ", 0
secondNum	BYTE	"Second number: ", 0
plusSign	BYTE	32,43,32, 0
minusSign	BYTE	32,45,32, 0
multSign	BYTE	32,120,32, 0
divSign		BYTE	32,246,32, 0
eqSign		BYTE	32,61,32, 0
remSign		BYTE	" remainder  ", 0
isGreater	BYTE	"The second number is less.", 0
isLess		BYTE	"The second number is greater.", 0
areEqual	BYTE	"The two numbers are equal!", 0
goodbye		BYTE	"Hope you had fun! Goodbye!", 0
enter_1		DWORD	?
enter_2		DWORD	?
sum			  DWORD	?
diff		  DWORD	?
product		DWORD	?
quot	  	DWORD	?
remain		DWORD	?

.code
main PROC

; introduction
	mov	  	edx, OFFSET intro
	call  	WriteString
	mov		  edx, OFFSET	myName
	call	  WriteString
	call  	CrLf
	call  	CrLf
	mov		  edx, OFFSET ec2Prompt
	call	  WriteString
	call	  CrLf
	call	  CrLf

; get the data
	mov	  	edx, OFFSET prompt_1
	call  	WriteString
	call	  CrLf
	call	  CrLf
	mov	  	edx, OFFSET firstNum
	call	  WriteString
	call	  ReadInt				            ; read in first number
	mov	  	enter_1, eax		          ; store first number
	mov	  	edx, OFFSET secondNum
	call	  WriteString
	call	  ReadInt				            ; read in second number
	mov		  enter_2, eax		          ; store second number
	call	  CrLf

; calculate the required values
	; addition
	mov	  	eax, enter_1
	add		  eax, enter_2
	mov		  sum, eax

	; subtraction
	mov		  eax, enter_1
	sub	  	eax, enter_2
	mov		  diff, eax

	; mutliplication
	mov		  eax, enter_1
	mov	  	ebx, enter_2
	mul	  	ebx
	mov		  product, eax

	; division
	mov	  	eax, enter_1
	mov	  	ebx, enter_2
	div	  	ebx
	mov		  quot, eax
	mov		  remain, edx

; display the results
	; display addition
	mov	  	eax, enter_1
	call	  WriteDec
	mov		  edx, OFFSET plusSign
	call  	WriteString
	mov	  	eax, enter_2
	call  	WriteDec
	mov		  edx, OFFSET eqSign
	call  	WriteString
	mov	  	eax, sum
	call	  WriteDec
	call	  CrLf

	; display subtraction
	mov		  eax, enter_1
	call	  WriteDec
	mov		  edx, OFFSET minusSign
	call	  WriteString
	mov		  eax, enter_2
	call  	WriteDec
	mov		  edx, OFFSET eqSign
	call  	WriteString
	mov		  eax, diff
	call	  WriteInt
	call	  CrLf

	; display multiplication
	mov		  eax, enter_1
	call  	WriteDec
	mov	  	edx, OFFSET multSign
	call  	WriteString
	mov	  	eax, enter_2
	call  	WriteDec
	mov		  edx, OFFSET eqSign
	call  	WriteString
	mov		  eax, product
	call  	WriteDec
	call	  CrLf

	; display division with remainder
	mov		  eax, enter_1
	call  	WriteDec
	mov		  edx, OFFSET divSign
	call	  WriteString
	mov	  	eax, enter_2
	call  	WriteDec
	mov		  edx, OFFSET eqSign
	call	  WriteString
	mov	  	eax, quot				          ; for the quotient
	call  	WriteDec
	mov		  edx, OFFSET remSign
	call	  WriteString
	mov	  	eax, remain			        	; for the remainder
	call  	WriteDec
	call  	CrLf
	call	  CrLf

; determine if second number is greater of less
	mov		  eax, enter_1
	cmp	  	eax, enter_2
	jg		  L1
	jl		  L2
	je		  L3
L1:
	; if second number is greater
	mov		  edx, OFFSET isGreater
	call	  WriteString
	call	  CrLf
	jmp		  Bottom
L2:
	; if second number is less than
	mov		  edx, OFFSET isLess
	call  	WriteString
	call	  CrLf
	jmp		  Bottom
L3:
	; if both numbers are equal
	mov	  	edx, OFFSET areEqual
	call	  WriteString
	call	  CrLf

; say goodbye
Bottom:
	call  	CrLf
	mov	  	edx, OFFSET goodbye
	call  	WriteString
	call	  CrLf
	call	  CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
