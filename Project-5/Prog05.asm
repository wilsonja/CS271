TITLE Programming Assignment #5     (Prog05.asm)
 
; Author: Jacob Wilson
; Course / Project ID: CS271_400 Program #5             Date: 5/20/16
; Description: This program generates a user determined number of random
;  integers and enters them into an array. It then sorts the values in the
;  array and determines the median. Displayed are the median, and both
;  unsorted and sorted arrays.

INCLUDE Irvine32.inc

MIN_SIZE = 10										; minimum values allowed
MAX_SIZE = 200										; maximum values allowed
LO_RANGE = 100										; minimum random value
HI_RANGE = 999										; maximum random value

.data
progTitle		BYTE	"Sorting Random Integers              Programmed by Jacob Wilson", 0
instructions	BYTE	"This program generates random numbers in the range [100 .. 999],", 13, 10
				BYTE	"displays the original list, sorts the list, and calculates the", 13, 10
				BYTE	"median value. Finally, it displays the list sorted in descending", 13, 10
				BYTE	"order.", 0
numRequest		BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
unsortPrompt	BYTE	"The unsorted random numbers:", 0
medianPrompt	BYTE	"The median is ", 0
sortPrompt		BYTE	"The sorted list:", 0
invalPrompt		BYTE	"Invalid input", 0
spaces3			BYTE	32, 32, 32, 0

numInts			DWORD	?
myArray			DWORD	MAX_SIZE DUP(?)

.code
main PROC
	call	Randomize									; set up for random int
	call	introduction

	push	OFFSET numInts								; passed by reference
	call	getUserData

	push	OFFSET myArray								; passed by reference
	push	numInts										; passed by value
	call	fillArray

	push	OFFSET myArray								; passed by reference
	push	numInts										; passed by value
	push	OFFSET unsortPrompt							; passed by reference
	call	displayList

	push	OFFSET myArray								; passed by reference
	push	numInts										; passed by value
	call	sortList

	push	OFFSET myArray								; passed by reference
	push	numInts										; passed by value
	call	displayMedian

	push	OFFSET myArray								; passed by reference
	push	numInts										; passed by value
	push	OFFSET sortPrompt							; pased by reference
	call	displayList

	exit	; exit to operating system
main ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                    introduction
; Procedure to display both the program information and
; program instructions.
; 
; Receives: nothing
; Returns: nothing
; Preconditions: called from main
; Registers changed: edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
introduction PROC
	; display program title information
	mov		edx, OFFSET progTitle
	call	WriteString
	call	Crlf
	call	Crlf

	; display instructions
	mov		edx, OFFSET instructions
	call	WriteString
	call	Crlf
	call	Crlf
	ret
introduction ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                    getUserData
; Procedure to obtain from the user, number of values
; to generate.
; 
; Receives: numInts by reference
; Returns: nothing
; Preconditions: called from main, passed numInts
; Registers changed: ebp, ebx, edx, eax
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
getUserData PROC
	; set up the stack frame
	push	ebp
	mov		ebp, esp

getNum:	
	; prompt user to enter a number
	mov		edx, OFFSET numRequest
	call	WriteString
	call	ReadInt
	mov		ebx, [ebp + 8]
	mov		[ebx], eax

	; compare input to minimum value
	mov		eax, MIN_SIZE
	cmp		[ebx], eax
	jl		OutRange

	; compare input to maximum value
	mov		eax, MAX_SIZE
	cmp		[ebx], eax
	jg		OutRange
	jmp		Done

OutRange:
	; if number is out of range, display invalid and ask again
	mov		edx, OFFSET invalPrompt
	call	WriteString
	call	Crlf
	jmp		getNum

Done:
	call	Crlf
	pop		ebp
	ret		4
getUserData ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                     fillArray
; Procedure to fill an array with randomly generated
; integers. Method borrowed from CS271 lecture 20.
;
; Receives: array address, size of array
; Returns: nothing
; Preconditions: called from main
; Registers changed: eax, exc, ebp
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
fillArray PROC
	; set up the stack frame
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp + 12]								; point to the beginning of array
	mov		ecx, [ebp + 8]								; initialize counter to number of values

GenerateValue:
	; generate random value within range
	mov		eax, HI_RANGE
	sub		eax, LO_RANGE
	add		eax, 1
	call	RandomRange
	add		eax, LO_RANGE

	; add the value to the array
	mov		[esi], eax
	add		esi, 4
	loop	GenerateValue

	pop		ebp
	ret		8
fillArray ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      sortList
; Procedure uses a selection sort method to sort values
; in an array in descending order.
;
; Receives: array address, size of array
; Returns: nothing
; Preconditions: existing array, called from main
; Registers changed: eax, ebx, ecx, ebp
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
sortList PROC
	; set up the stack frame
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 8]								; initialize the counter to request - 1
	dec		ecx

IndexLoop:
	; ecx is used as counters in both loops
	push	ecx
	mov		esi, [ebp + 16]								; start at beginning of array

CompareLoop:
	; start by comparing neighboring values
	mov		eax, [esi]
	mov		ebx, [esi + 4]
	cmp		eax, ebx
	jge		NoSwap

Swap:
	; if values are to be swapped, pass both array addresses
	push	esi											; first array address
	add		esi, 4
	push	esi											; second array address
	push	ecx											; save loop counter
	call	exchange
	sub		esi, 4										; return esi to status before exchange call

NoSwap:
	; move on to the next value for comparison
	add		esi, 4
	loop	CompareLoop

NextIndex:
	; move to the next index to start new comparisons
	pop		ecx
	loop	IndexLoop

	pop		ebp
	ret		8
sortList ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                     exchange
; Procedure to swap to values in an array.
;
; Receives:	two array addresses
; Returns: nothing
; Preconditions: existing array
; Registers changed: eax, ebx, ecx, edx, ebp
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
exchange PROC
	; set up the stack frame
	push	ebp
	mov		ebp, esp
	pushad												; save all registers

	; store the address of each array location
	mov		eax, [ebp + 12]							
	mov		ebx, [ebp + 16]								

	; store the value present in each array location
	mov		ecx, [eax]									
	mov		edx, [ebx]									

	; move the second array value into the first array location
	mov		esi, eax									
	mov		[esi], edx									

	; determine the distance to the second array location
	sub		ebx, eax									

	; move the first array value into the second array location
	add		esi, ebx									
	mov		[esi], ecx									
	
	popad												; restore all registers
	pop		ebp
	ret		12
exchange ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                     displayMedian
; Procedure to determine and display the median value
; in an array.
;
; Receives:	array address and array size
; Returns: nothing
; Preconditions: existing array, called from main
; Registers changed: eax, ebx, edx
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
displayMedian PROC
	; set up the stack frame
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp + 12]								; point to beginning of array

	; display the mediam message
	mov		edx, OFFSET medianPrompt
	call	WriteString

	; check to see if there are an even or odd number of values in array
	mov		eax, [ebp + 8]								; the number of items in the array
	cdq
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		EvenNum
OddNum:
	; if odd, display the middle value of the array
	mov		eax, [esi + 4 * eax]						; size of DWORD times half the number of items
	jmp		Done
EvenNum:
	; if even, calculate the average of the two middle values
	mov		ebx, eax
	mov		eax, [esi + 4 * ebx]						; the middle value
	dec		ebx
	add		eax, [esi + 4 * ebx]						; the item preceding the middle value
	mov		ebx, 2
	cdq
	div		ebx											; divide for the average

Done:
	; display the median number
	call	WriteDec
	call	Crlf
	call	Crlf
	pop		ebp
	ret		8
displayMedian ENDP

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
;                      displayList
; Procedure to display an array. Method was borrowed
; from CS271 lecture 20
;
; Receives: array address, array size, prompt indicating
;  what type of array is displayed
; Returns: nothing
; Preconditions: existing array, called from main
; Registers changed: ebx, ecx, edx, ebp
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
displayList PROC
	; set up the stack fram
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp + 16]								; location of prompt
	mov		ecx, [ebp + 12]								; number of items
	mov		edx, [ebp + 8]								; location of array
	mov		ebx, 10										; counter for line break
	call	WriteString
	call	Crlf

MoreDisplay:
	; display each value
	mov		eax, [esi]
	call	WriteDec
	add		esi, 4										; move to next value
	dec		ebx											; decrease value counter
	cmp		ebx, 0										; determine if line break needed
	je		AddLine
	jmp		AddSpaces

AddLine:
	; if value count = 0, enter a line break
	call	Crlf
	mov		ebx, 10										; reset value counter
	jmp		Done
AddSpaces:
	; if <10 values on a line, add spaces
	mov		edx, OFFSET spaces3
	call	WriteString
Done:
	; continue looping through all values
	loop	MoreDisplay

	call	Crlf
	call	Crlf
	pop		ebp
	ret		8
displayList ENDP

END main
