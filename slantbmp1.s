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

    ; 1. Calculate how many whole bytes to shift
    ; 2. Save the last 'bytes_shift' bytes for wrapping
    ; 3. Shift the remaining bytes to the right by 'bytes_shift'
    ; 4. Restore the saved bytes to the beginning of the row
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

    ; ----------------------------
    ; Perform Byte-wise Shift (if applicable)
    ; ----------------------------

    ; Check if shift_amount is non-zero
    test    ecx, ecx            ; Check if shift_amount is zero
    je      bitwise_shift       ; If shift_amount is zero, skip byte-wise shift


; 1. Save the last 'bytes_shift' bytes to a temporary buffer
    push    ecx                   ; Save bytes_shift count on stack
    ; mov     edx, ecx            ; Move bytes_shift to EDX for preservation
    ; add     edi, [ebp + 20]     ; edi = edi + [ebp + 20] (end of the row)
    ; sub     edi, ecx            ; edi = edi - ecx (start of last 'bytes_shift' bytes)
    ; mov     esi, edi            ; esi = address of last 'bytes_shift' bytes
    ; sub     esp, ecx            ; Allocate 'bytes_shift' bytes on stack for temporary buffer
    ; mov     edi, esp            ; EDI points to temporary buffer
    ; mov     ecx, edx            ; ECX = bytes_shift
    ; rep     movsb               ; Copy 'bytes_shift' bytes from ESI to EDI

    pop     ecx                 ; Restore bytes_shift count

    ; ; 2. Shift the first (stride - bytes_shift) bytes to the right by 'bytes_shift' bytes
    ; mov     esi, edi            ; ESI = start of temporary buffer
    ; sub     esi, ecx            ; ESI = start of temporary buffer
    ; lea     edi, [esi + edx]    ; EDI = start of row + bytes_shift
    ; mov     ecx, [ebp + 20]            ; ECX = stride (bytes per row)
    ; sub     ecx, edx            ; ECX = stride - bytes_shift
    ; rep     movsb                ; Shift (stride - bytes_shift) bytes right by 'bytes_shift' bytes

    ; ; 3. Restore the saved bytes to the beginning of the row
    ; mov     esi, esp            ; ESI = temporary buffer
    ; mov     esi, edi            ; ESI = start of temporary buffer
    ; sub     esi, ecx            ; ESI = start of temporary buffer
    ; mov     ecx, edx            ; ECX = bytes_shift
    ; rep     movsb                ; Restore 'bytes_shift' bytes to start

    ; ; 4. Cleanup temporary buffer
    ; add     esp, edx            ; Deallocate temporary buffer
    ; pop     ecx                 ; Restore bytes_shift count


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