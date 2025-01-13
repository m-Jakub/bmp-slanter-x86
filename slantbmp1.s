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
    mov     esi, [ebp + 8]      ; esi = img (pointer to image data)
    mov     ebx, [ebp + 12]     ; ebx = height (image width in pixels)
    mov     edx, [ebp + 20]     ; edx = stride (image stride in bytes)

    ; Initialize Row Counter
    xor     eax, eax            ; eax = row_number = 0

    ; ----------------------------
    ; Perform Byte-Wise Shift (if applicable)
    ; ----------------------------

    ; 1. Calculate how many whole bytes to shift
    ; 2. Save the last 'bytes_shift' bytes for wrapping
    ; 3. Shift the remaining bytes to the right by 'bytes_shift'
    ; 4. Restore the saved bytes to the beginning of the row
row_loop:

    ; Loop Condition: Check if all rows are processed
    cmp     eax, ebx            ; Compare row_number with height
    jge     end                 ; If row_number >= height, exit loop

    ; Calculate Pointer to Current Row
    ; edi will point to the start of the current row
    mov     edi, eax            ; edi = row_number
    imul    edi, edx            ; edi = row_number * stride
    add     edi, esi            ; edi = img + (row_number * stride)

    ; Determine Shift Amount for Current Row
    ; The shift amount is equal to the row number
    mov     ecx, eax              ; ecx = shift_amount = row_number
    shr     ecx, 3               ; ecx = shift_amount / 8

    ; ----------------------------
    ; Perform Byte-wise Shift (if applicable)
    ; ----------------------------

    ; Check if 
    test    ecx, ecx            ; Check if shift_amount is zero
    je      bitwise_shift       ; If shift_amount is zero, skip byte-wise shift


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
    inc     eax                 ; row_number++

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