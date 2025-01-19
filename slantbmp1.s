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

    ; Calculate Number to rotate the last byte of the current row to the left
    ; This is performed to store the last in of the current row on the first position of a byte
    ; To put this byte at the beggining of the row
    mov     cl, [ebp + 12]     ; ecx = width
    and     cl, 0b00000111     ; ecx = width % 8 = Number of bits in the last byte that are part of the image
    dec     cl                 ; ecx = width % 8 - 1 = Number to rotate left the last byte of the current row
    cmp     cl, -1	     ; Check if the last byte is a full byte
    jne     main_loop

    mov     cl, 7	     ; If the last byte is a full byte, set the number to rotate to 7
    

    ; ----------------------------
    ; Perform Byte-Wise Shift (if applicable)
    ; ----------------------------
main_loop:

    ; Store number of bits to shift (row number) (shift counter)
    mov     edx, ebx            ; edx = row_number
    inc     edx                 ; row_number++
    
    ; Calculate Pointer to Current Row (edi)
    mov     edi, ebx            ; edi = row_number
    inc     ebx                 ; row_number++
    imul    edi, [ebp + 20]            ; edi = row_number * stride
    add     edi, [ebp + 8]            ; edi = img + (row_number * stride) = Pointer to current row

row_loop:
    ; Calculate pointer to the last byte of the current row (esi)
    mov     esi, [ebp + 12]      ; esi = width
    shr     esi, 3               ; esi = width / 8
    add     esi, edi             ; esi = edi + (width / 8) = Pointer to the last byte of the current row

    ; Save the last bit of the current row in ah
    mov     al, [esi]           ; al = Last byte of the current row
    rol     al, cl	     ; Rotate left the last byte of the current row by ecx bits
    and     al, 0b10000000      ; al = Last bit of the current row

    shr     byte [esi], 1              ; shift the last byte of the current row to the right

shift_loop:

    dec     esi                 ; esi = Pointer to the byte before the last byte of the current row

    ; Use the carry flag to keep track of the last bit of the current row
    shr     byte [esi], 1       ; Shift the current byte to the right
    setc    ah                 ; ah = Carry flag
    ror     ah, 1              ; Rotate the register to put the carry flag in the first bit

    or      byte [esi+1], ah         ; Set the first bit of the next byte to the carry flag

    ; Loop Condition: Check if all bytes are processed
    cmp     esi, edi            ; Compare current byte with the first byte of the current row
    jg      shift_loop          ; If current byte > first byte, continue processing

    ; Set the first byte of the current row to the last bit of the current row
    or      byte [edi], al      ; Set the first byte of the current row to the last bit of the current row

    dec     edx                 ; Decrement the number of bits to shift
    jg     row_loop            ; If number of bits to shift > 0, continue processing

    ; Loop Condition: Check if all rows are processed
    cmp     ebx, [ebp + 16]     ; Compare row_number with height
    jl     main_loop            ; If row_number < height, continue processing

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