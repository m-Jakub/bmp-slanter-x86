; filepath: /mnt/c/Studies/Sem_5/COAR/Project_x86/slantbmp1.s
section .text
    global slantbmp1

; Function: void slantbmp1(void *img, int width, int height, int stride)
; Parameters (cdecl):
;   img:    [ebp + 8]    ; Pointer to image data
;   width:  [ebp + 12]   ; Image width in pixels
;   height: [ebp + 16]   ; Image height in rows
;   stride: [ebp + 20]   ; Image stride in bytes

slantbmp1:
    ; ----------------------------
    ; Function Prologue
    ; ----------------------------
    push    ebp                 ; Save base pointer
    mov     ebp, esp            ; Establish new base pointer

    push    ebx                 ; Preserve ebx
    push    esi                 ; Preserve esi
    push    edi                 ; Preserve edi

    ; ----------------------------
    ; Load Function Parameters
    ; ----------------------------

    ; Initialize Row Counter
    xor     ebx, ebx            ; ebx = row_number = 0

    ; ----------------------------
    ; Perform Byte-Wise Shift (if applicable)
    ; ----------------------------
row_loop:

    ; Loop Condition: Check if all rows are processed
    cmp     ebx, [ebp + 16]     ; Compare row_number with height
    jge     end                 ; If row_number >= height, exit loop

    ; Calculate Pointer to Current Row
    ; edi will point to the start of the current row
    mov     edi, ebx            ; edi = row_number
    imul    edi, [ebp + 20]            ; edi = row_number * stride
    add     edi, [ebp + 8]            ; edi = img + (row_number * stride)

    ; Determine Shift Amount for Current Row
    ; The shift amount is equal to the row number
    mov     ecx, ebx              ; ecx = shift_amount = row_number
    shr     ecx, 3               ; ecx = shift_amount / 8

    ; Check if shift_amount is non-zero
    test    ecx, ecx            ; Check if shift_amount is zero
    jz      bitwise_shift       ; If shift_amount is zero, skip byte-wise shift


    ; ----------------------------
    ; Byte-Wise Shift
    ; ----------------------------

    mov    esi, edi            ; esi = start of row
    add    esi, [ebp + 20]     ; esi = end of row (row_start + stride)
    dec    esi                ; esi = last byte of row
    mov    edx, ecx            ; edx = bytes_shift (counter for wrap-around bytes loop)

    ; ----------------------------
    ; Process Wrap-Around Bytes
    ; ----------------------------
wrap_loop:
    mov    al, [esi]            ; al = last byte of row

    ; Shift the whole row by one byte to the right
    mov    ecx, esi         ; ecx = current byte
    dec    ecx                ; move to previous byte
    
shift_row_loop:
    mov    ah, [ecx]            ; ah = load byte from previous position
    mov    [ecx + 1], ah    ; store byte to current position
    dec    ecx                ; move to previous byte
    cmp    ecx, edi            ; check if we reached the start of the row
    jae    shift_row_loop    ; repeat loop if not

    ; Restore the saved byte to the beginning of the row
    mov    [edi], al            ; restore the saved byte to the beginning of the row

    ; Update wrap_loop variables
    dec    edx                ; decrement bytes_shift
    jnz    wrap_loop            ; repeat loop if not zero

bitwise_shift:
    ; ----------------------------
    ; Perform Bit-wise Shift (if applicable)
    ; ----------------------------
    ; Calculate remaining bits to shift after byte-wise shift
    ; Example Steps:
    ; 1. Compute bits_shift = shift_amount % 8
    ; 2. Iterate through each byte in the row
    ; 3. Shift bits to the right by 'bits_shift'
    ; 4. Handle carry-over bits between bytes for wrapping
    ; 
    ; [Insert Bit-wise Shifting Logic Here]

    ; ----------------------------
    ; Increment Row Counter
    ; ----------------------------
    inc     ebx                 ; row_number++

    ; ----------------------------
    ; Continue to Next Row
    ; ----------------------------
    jmp     row_loop            ; Repeat loop for the next row

end:
    ; ----------------------------
    ; Function Epilogue
    ; ----------------------------
    pop     edi                 ; Restore edi
    pop     esi                 ; Restore esi
    pop     ebx                 ; Restore ebx

    mov     esp, ebp            ; Restore stack pointer
    pop     ebp                 ; Restore base pointer
    ret                         ; Return to caller

; ----------------------------
; End of slantbmp1 Function
; ----------------------------