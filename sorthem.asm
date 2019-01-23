%include "asm_io.inc"
extern rconf

SECTION .data
  msg1: db "Initial configuration:",10,0
  msg2: db "Final configuration:",10,0 
  tow1: db "          o|o",10,0
  tow2: db "         oo|oo",10,0
  tow3: db "        ooo|ooo",10,0
  tow4: db "       oooo|oooo",10,0
  tow5: db "      ooooo|ooooo",10,0
  tow6: db "     oooooo|oooooo",10,0
  tow7: db "    ooooooo|ooooooo",10,0
  tow8: db "   oooooooo|oooooooo",10,0
  tow9: db "  ooooooooo|ooooooooo",10,0
  base: db "XXXXXXXXXXXXXXXXXXXXXXX",10,0
  err1: db "Incorrect number of arguments. Expected single digit between 2 & 9.",10,0
  err2: db "Argument must be a number between 2 and 9",10,0

SECTION .bss
  count: resd 1
  peg: resd 9
  val: resd 1
  i: resd 1
  change: resd 1

SECTION .text
  global asm_main

;------SHOWP-------
showp:
  enter 0,0
  pusha
  mov ebx, dword [ebp+8]			;array
  mov ecx, dword [ebp+12]			;size (top of stack is second parameter)
  mov [count], dword 36

;------main loop-----
  LOOP:
  sub [count], dword 4
  cmp [count], dword 0
  jl FINAL

;---iterate through loop----
  mov eax, [count]
  mov edx, [ebx+eax]
  cmp edx, 0
  je LOOP

;---jmp statements for possible values of array----
  cmp edx, dword 1
  je PRINT1
  cmp edx, dword 2
  je PRINT2
  cmp edx, dword 3
  je PRINT3
  cmp edx, dword 4
  je PRINT4
  cmp edx, dword 5
  je PRINT5
  cmp edx, dword 6
  je PRINT6
  cmp edx, dword 7
  je PRINT7
  cmp edx, dword 8
  je PRINT8
  cmp edx, dword 9
  je PRINT9

;---print statements for the pyramid---
  PRINTEND:
  call print_string
  jmp LOOP

  PRINT1:
  mov eax, tow1
  jmp PRINTEND
  
  PRINT2:
  mov eax, tow2
  jmp PRINTEND
  
  PRINT3:
  mov eax, tow3
  jmp PRINTEND
  
  PRINT4:
  mov eax, tow4
  jmp PRINTEND
 
  PRINT5:
  mov eax, tow5
  jmp PRINTEND

  PRINT6:
  mov eax, tow6
  jmp PRINTEND

  PRINT7:
  mov eax, tow7
  jmp PRINTEND

  PRINT8:
  mov eax, tow8
  jmp PRINTEND

  PRINT9:
  mov eax, tow9
  jmp PRINTEND

;----- Print final line----
  FINAL:
  mov eax, base
  call print_string
  call read_char
  popa
  leave
  ret

;-----SORTHEM------
sorthem:
  enter 0,0
  pusha
  
  mov ebx, dword [ebp+8]		;array
  mov ecx, dword [ebp+12]		;size
  
;---check if n is 1----
  cmp ecx, 1
  je SORTHEM_END

  add ebx, 4
  sub ecx, 1
  push ecx
  push ebx
  call sorthem
  sub ebx, 4
  add esp, 8
  add ecx, 1		;return ecx to n (no longer n-1)

;---setup the loop-----
  mov [i], dword 0
  mov [change], dword 0
 
  SORT_LOOP:
  mov edx, ecx
  sub edx, 1
  cmp [i], edx
  je LOOP_END

;---edx is A[i], eax is A[i+1]---
  mov edx, [ebx]
  mov eax, [ebx + 4]
  cmp edx, eax
  ja LOOP_END

  cmp edx, eax
  jb SWAP

  SWAP:
  mov [ebx], eax
  mov [ebx+4], edx
  add [i], dword 1
  mov [change], dword 1
  add ebx, 4
  jmp SORT_LOOP

  LOOP_END:
  cmp [change], dword 1			;showp only if value has been changed
  je SHOW_FINAL
  jmp SORTHEM_END

  SHOW_FINAL:
  push val
  push peg
  call showp
  add esp, 8

  SORTHEM_END:
  popa
  leave
  ret

;-----MAIN------
asm_main:
  enter 0,0
  pusha
  
  mov eax, dword [ebp+8]		;check for single input argument (argc = 2)
  cmp eax, dword 2
  jne ERR1

  mov ebx, [ebp+12]
  mov ecx, [ebx+4]
  
;-----ensure input is single digit----
  cmp byte [ecx+1], byte 0
  jne ERR2
  
;----check range of input----
  mov bl, byte[ecx]
  cmp byte [ecx], '2'
  jb ERR2
  cmp byte [ecx], '9'
  ja ERR2
  
  mov edx, dword 0
  mov dl, byte [ecx]
  sub dl,'0'
  mov [val], edx			;store size (max num) in [val]

;----calling rconf---------
  mov eax, [val] 
  push eax
  push peg
  call rconf 
  pop eax
  add esp, 4				;generate random array based on input  

;----print initial string/intial configuration---
  mov eax, msg1
  call print_string
  call print_nl

  mov eax, [val]
  push eax
  push peg
  call showp				;print initial pyramid
  pop eax
  add esp, 4

;----call sorthem----
  mov eax, 0
  mov eax, [val]
  push eax
  push peg
  call sorthem
  pop eax
  add esp, 4

;----print final string/final configuration
  mov eax, msg2
  call print_string
  call print_nl

  mov eax, [val]
  push eax
  push peg
  call showp				;print final pyramid
  pop eax
  add esp, 4
  jmp CLOSE

;------error statements and closing routine------
  ERR1:
  mov eax,0
  mov eax, err1
  call print_string
  jmp CLOSE
  
  ERR2:
  mov eax,0
  mov eax, err2
  call print_string
  jmp CLOSE

  CLOSE:
  mov eax,0
  popa
  leave
  ret
