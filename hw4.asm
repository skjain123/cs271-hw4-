; hw2.asm
; Author: Sunil Jain
; Course/ Project ID: CS271 -Homework 3
; Date: 
; Description: 

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode : dword

; insert constant definitions here

     MAX_STR             = 80           ; maximum chars to read to name

     MIN_BOUND           = 10           ; minimum boundary
     MAX_BOUND           = 200          ; maximum boundary

     MIN_RANGE           = 1            ; minimum range for the numbers
     MAX_RANGE           = 999           ; maximum range for the numbers
     
     MAX_SIZE            = 200          ; max array length

.data

; insert variable definitions here

	intro_msg           Byte      0ah, 0Dh, "CS 271 HW 4 - Sorting Random Integers     Programmed by Sunil Jain", 0ah, 0Dh, 0
     desc_msg            Byte      0ah, 0Dh, "This program generates random numbers in the range [lo .. hi], displays the original list, sorts the", 0ah, 0Dh, "list, and calculates the median value. Finally, it displays the list sorted in descending order.", 0ah, 0Dh, 0
     unsorted_msg        Byte      0ah, 0Dh, "The unsorted random numbers: ", 0ah, 0Dh, 0
     sorted_msg          Byte      0ah, 0Dh, "The sorted list: ", 0ah, 0Dh, 0
     median_msg          Byte      0ah, 0Dh, "This is the median ", 0

     rand_num_request    Byte      0ah, 0Dh, "How many numbers should be generated? [10 .. 200]: ", 0
     lower_b_request     Byte      0ah, 0Dh, "Enter lower bound (lo)   [1 .. 999] : ", 0
     upper_b_request     Byte      0ah, 0Dh, "Enter upper bound (high) [1 .. 999] : ", 0
     repeat_request      Byte      0ah, 0Dh, "Would you like to go again (Yes=1/No=0): ", 0

     bound_error         Byte      "Invalid Input", 0ah, 0Dh,  0
     range_error         Byte      "The lower bound must be LESS the upper bound, Invalid Input.", 0ah, 0Dh,  0

     space               Byte      "     ", 0
     extra_space         Byte      " ", 0

     arr                 DWORD     MAX_SIZE DUP(?)
     arr_size            DWORD     MAX_STR+1 DUP(?)
     
     lower_bound         DWORD     10
     upper_bound         DWORD     200

     new_line_count      DWORD     0
     
.code

main proc

; insert executable instructions here
     
     Call                randomize

     Call                introduction
     
     again:

     ;         getData {parameters: array_size (reference), lo (reference), hi (reference)}
     push                OFFSET arr_size
     push                OFFSET lower_bound
     push                OFFSET upper_bound
     Call                get_data
     
     ;         fillArray {parameters: array_size (value), lo (value), hi (value), array (reference)}
     push                arr_size
     push                lower_bound
     push                upper_bound
     push                OFFSET arr
     Call                fill_arr
     
     ;         displayList {parameters: new_line_count (val) array (reference), array_size (value), title (reference)} 
     push                new_line_count
     push                OFFSET arr
     push                arr_size
     push                OFFSET unsorted_msg
     Call                print_arr

     ;         sortList {parameters: array (reference), array_size (value)}
     push                OFFSET arr
     push                arr_size
     Call                sort_arr

     ;         displayMedian {parameters: array (reference), array_size (value)} 
     push                OFFSET arr
     push                arr_size
     Call      display_median

     ;         displayList {parameters: new_line_count (val) array (reference), array_size (value), title (reference)} 
     push                new_line_count
     push                OFFSET arr
     push                arr_size
     push                OFFSET sorted_msg
     Call                print_arr

     Call                Crlf
     mov                 edx, OFFSET repeat_request    ;    does the player want to go again?
     Call                WriteString
     Call                ReadInt                       ;    take input
     cmp                 eax, 1
     je                  again                         ;    if the player chose 1, go again

     invoke ExitProcess,0

main                     endp

     ; insert additional procedures here


; Procedure: Prints the introduction and descriptions statements
; recieves: N/A
; returns: N/A
; preconditions: N/A
; registers changed: edx
introduction             PROC

               ; prints the start messages
     mov                 edx, OFFSET intro_msg
     Call                WriteString
     mov                 edx, OFFSET desc_msg
     Call                WriteString

     ret
introduction             ENDP

; Procedure: gets the data from the user 
; recieves: N/A
; returns: Modifies the global variables for user input
; preconditions: N/A
; registers changed: edp, edx, eax, ebx, esi
get_data                 PROC

     push                ebp
     mov                 ebp, esp

; --------------------------------------------------------------------------------------
;              gets the array size from the user
     get_arr_size:
     mov                 edx, OFFSET rand_num_request
     Call                WriteString
     Call                ReadInt

     cmp                 eax, MIN_BOUND
     jl                  arr_size_error
     
     cmp                 eax, MAX_BOUND
     jg                  arr_size_error

     jmp                 arr_size_good

;              if the user input is out of the bounds given by the assignment repeat the get_arr_size
     arr_size_error:

     mov                 edx, OFFSET bound_error
     Call                WriteString
     jmp                 get_arr_size

;              if the arr size is good, change its value
     arr_size_good:
     mov                 esi, [ebp+16]            ;mov                 arr_size, eax
     dec                 eax                      ; to account for 1 to arr_size -> 0 to arr_size - 1
     mov                 [esi], eax
; --------------------------------------------------------------------------------------

; --------------------------------------------------------------------------------------
;              this section gets the lower bound
     get_lower_b:
     mov                 edx, OFFSET lower_b_request
     Call                WriteString
     Call                ReadInt

     cmp                 eax, MIN_RANGE
     jl                  lower_b_error
     
     cmp                 eax, MAX_RANGE
     jg                  lower_b_error

     jmp                 lower_b_good

     lower_b_error:

;              prints the error msg and then runs get_lower_b again
     mov                 edx, OFFSET bound_error
     Call                WriteString
     jmp                 get_lower_b

     lower_b_good:
     mov                 esi, [ebp+12]            ;mov                 lower_bound, eax
     mov                 [esi], eax
; --------------------------------------------------------------------------------------

; --------------------------------------------------------------------------------------
     get_upper_b:
     mov                 edx, OFFSET upper_b_request
     Call                WriteString
     Call                ReadInt

     cmp                 eax, MIN_RANGE
     jl                  upper_b_error
     
     cmp                 eax, MAX_RANGE
     jg                  upper_b_error

     jmp                 upper_b_good

     upper_b_error:
     
;              prints the error msg and then runs get_upper_b again
     mov                 edx, OFFSET bound_error
     Call                WriteString
     jmp                 get_upper_b

     upper_b_good:
     mov                 esi, [ebp+8]            ;mov                 upper_bound, eax
     mov                 [esi], eax
; --------------------------------------------------------------------------------------

     mov                 esi, [ebp+12]
     mov                 eax, [esi]
     mov                 esi, [ebp+8]
     cmp                 eax, [esi]
     jl                  good_range

     mov                 edx, OFFSET range_error
     Call                WriteString
     jmp                 get_lower_b

     good_range:

;              clears register
     pop                 ebp
     ret                 16
get_data                 ENDP

; Procedure: fills the array with random numbers
; recieves: [ebp+20] arr_size, [ebp+16] lower_bound, [ebp+12] upper_bound, [ebp+8] arr, 
; returns: a filled array
; preconditions: must have already created array
; registers changed: edx, ebp, eax, edi, ecx,
fill_arr                 PROC

;              sets up the parameters
     push                ebp
     mov                 ebp, esp

     mov                 ecx, 0
     mov                 edi, [ebp+8]

     rand_num:

     mov                 eax, [ebp+12]
     sub                 eax, [ebp+16]
     inc                 eax
     Call                RandomRange
     add                 eax, [ebp+16]
     
     mov                 [edi + 4*ecx], eax

     inc                 ecx
     cmp                 ecx, [ebp+20]
     jle                 rand_num

     pop                 ebp

     ret                 20
fill_arr                 ENDP


; Procedure: Prints all elements of the array
; recieves: [ebp+20] new_line_count [ebp+16] array, [ebp+12] array_size, [ebp+8] title
; returns: N/A
; preconditions: must have a filled array
; registers changed: edx, ebp, eax, esp, edi, 
print_arr                PROC
;              sets up parameters
     push                ebp
     mov                 ebp, esp

     mov                 ecx, 0
     mov                 edi, [ebp+16]
     mov                 eax, 0
     mov                 [ebp+20], eax

;              adds extra lines for formatting
     Call                Crlf
     Call                Crlf

     mov                 edx, [ebp+8]
     Call                WriteString

     Call                Crlf

;              loop for printing all values of the array
     print_loop:

;              put array element into eax to print
     mov                 eax, [edi]

;              offset number spacing for single digits and double digits to match with triple digit numbers
     cmp                 eax, 100
     jge                 over_100

     mov                 edx, OFFSET extra_space
     Call                WriteString

;              if the value is 3 digits, add less spaces
     over_100:

     cmp                 eax, 10
     jge                 over_10

     mov                 edx, OFFSET extra_space
     Call                WriteString

;              if the value is 2 digits, add less spaces
     over_10:

     Call                WriteDec                 ; print the number after the spaces

     mov                 edx, OFFSET space
     Call                WriteString

;              every 10 numbers create a New line
     mov                 eax, [ebp+20]
     inc                 eax
     mov                 [ebp+20], eax
     mov                 ebx, [ebp+20]
     cmp                 ebx, 10
     jl                  no_new_line

     Call                Crlf
     mov                 eax, 0
     mov                 [ebp+20], eax

;              if there is not a new line, go to the next number in the array
     no_new_line:

;              go down the array (DWORD size is 4)
     add                 edi, 4
     
     inc                 ecx
     cmp                 ecx, [ebp+12]
     jle                 print_loop

     pop                 ebp

     ret                 16
print_arr                ENDP

; Procedure: Prints the introduction and descriptions statements
; recieves: arr = [ebp+12], arr_size = [ebp+8]
; returns: modifies the array and sorts it
; preconditions: must have a filled array
; registers changed: edx, ebp, eax, esi, ecx          
sort_arr                 PROC
     ;sets up parameters
     push                ebp
     mov                 ebp, esp

     ;int i, j; 
     ;for (i = 0; i < n - 1; i++) 
  
      ;  // Last i elements are already 
      ;  // in place 
      ;  for (j = 0; j < n - i - 1; j++) 
      ;      if (arr[j] > arr[j + 1]) 
      ;          swap(arr[j], arr[j + 1]);
     
     mov                 ebx, 0
     
     outer_loop:

     mov                 ecx, 0

     inner_loop:

     mov                 esi, [ebp+12]
     mov                 eax, [esi + ecx*4]
     mov                 edx, [esi + 4 + ecx*4]
     cmp                 eax, edx
     jg                  skip_swap

     push                ebx            ; save outer_loop counter
     push                [ebp+12]
     push                ecx
     inc                 ecx
     push                ecx
     dec                 ecx
     Call swap
     pop                 ebx            ; load outer_loop counter

     skip_swap:

     inc                 ecx
     cmp                 ecx, [ebp+8]
     jl                  inner_loop

     inc                 ebx
     cmp                 ebx, [ebp+8]
     jl                  outer_loop


     pop                 ebp

     ret                 12
sort_arr                 ENDP

; Procedure: Prints the introduction and descriptions statements
; recieves: array (reference), index_1 (value), index_2 (value)
; returns: the swapped elements
; preconditions: must have a filled array with two items to swap
; registers changed: edx, ebp, esi, eax, ebx, ecx
;[ebp+16] array, [ebp+12] index_1, [ebp+8] index_2,
swap                     PROC
     
     push                ebp
     mov                 ebp, esp

     ;moves the parameters into the registers
     mov                 esi, [ebp+16]            ; address of arr
     mov                 ebx, [ebp+12]            ; index_1
     mov                 ecx, [ebp+8]             ; index_2
    
     ;swaps the registers
     mov                 edx, [esi + ebx*4]
     mov                 eax, [esi + ecx*4]
     mov                 [esi + ecx*4], edx
     mov                 [esi + ebx*4], eax

     ;clears the stack
     pop                 ebp
     ret                 12
swap                     ENDP

; displayMedian {parameters: array (reference), array_size (value)} 

; Procedure: Displays the median
; recieves: {parameters: array (reference), array_size (value)}
; returns: nothing it prints to the median to the console
; preconditions: must have a filled And SORTED array
; registers changed: edx, ebp, esi, eax, ebx
;              [ebp+12] arr                  [ebp+8] arr_size
display_median           PROC

     push                ebp
     mov                 ebp, esp

;              get user input
     Call                Crlf
     mov                 edx, OFFSET median_msg
     Call                WriteString

;              move the array pointer to esi
     mov                 esi, [ebp+12]

;              divide the array size by two and use the edx remainder to determine if it is even or odd
     mov                 eax, [ebp+8]
     inc                 eax
     cdq
     mov                 ebx, 2
     div                 ebx

     cmp                 edx, 0
     jne                 odd_size
     
;              if it is even, take the average of the two medians and print it
     mov                 ebx, eax
     mov                 eax, [esi+ ebx*4 - 4]
     add                 eax, [esi+ ebx*4]
     inc                 eax
     cdq
     mov                 ebx, 2
     div                 ebx

     Call                WriteDec
          
     jmp                 after_med

     odd_size:

;              if it is odd, print the middle number
     mov                 ebx, eax
     mov                 eax, [esi+ ebx*4]
     Call                WriteDec

     after_med:

     pop                 ebp

     ret 12
display_median           ENDP

End main