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

    ; Reserve a slot for storing the pointer to the current row
    mov     eax, [ebp + 16]     ; eax = height
    dec     eax                 ; eax = height - 1
    imul    eax, [ebp + 20]     ; eax = (height - 1) * stride
    add     eax, [ebp + 8]      ; eax = img + ((height -1 ) * stride) = Pointer to the last row

    sub     esp, 4              ; Allocate 4 bytes on the stack
    mov     [ebp - 4], eax      ; Store the pointer to the last row

    ; Calculate the number of bytes that are fully padding
    mov     eax, [ebp + 12]   ; eax = width
    add     eax, 7            ; eax = width + 7
    shr     eax, 3            ; eax = (width + 7) >> 3 = bytes used for data
    mov     ecx, [ebp + 20]   ; ecx = stride
    sub     ecx, eax          ; ecx = padding_bytes = stride - ((width + 7) >> 3)

    sub     esp, 4              ; Allocate 4 bytes on the stack
    mov     [ebp - 8], ecx      ; Store the number of padding bytes
    

    ; Allocate buffer on the stack using the calculated number of bytes
    sub     esp, [ebp + 20]            ; Allocate 'number of bytes' on the stack

    ; ----------------------------
    ; Initialize Saved Registers
    ; ----------------------------
    push    ebx                 ; Preserve ebx
    push    esi                 ; Preserve esi
    push    edi                 ; Preserve edi

    ; Initialize Row Counter
    xor     ebx, ebx            ; ebx = row_number = 0

    ; Calculate Number to rotate the last byte of the current row to the left
    ; This is performed to store the last in of the current row on the first position of a byte
    ; To put this byte at the beggining of the row
    mov     edx, [ebp + 12]     ; edx = width
    and     dl, 0b00000111     ; edx = width % 8 = Number of bits in the last byte that are part of the image

    ; ----------------------------
    ; Perform Byte-Wise Shift (if applicable)
    ; ----------------------------
main_loop:
    ; Calculate number of single bits to shift (row number % 8)
    mov     ecx, ebx
    and     ecx, 0b00000111     ; ecx = row_number % 8 = Number of bits to shift
    jz      row_divisible_by_8  ; If row_number % 8 == 0, skip the bit-wise shift
    mov     dh, cl              ; dh = Number of bits to shift

    ; Store the current row in the buffer
    mov     esi, [ebp - 4]      ; esi = Pointer to the last row
    mov     ecx, [ebp + 20]      ; ecx = buffer size = stride
    mov     edi, esp            ; edi = buffer pointer
    rep movsb                   ; Copy bytes from [esi] to [edi]

row_loop:

    ; Calculate the number of bytes to process
    mov     esi, [ebp + 20]      ; esi = buffer size = stride
    sub     esi, [ebp - 8]       ; esi = stride - padding_bytes

    ; Store pointer to the current row in edi
    mov     edi, esp            ; edi = buffer pointer

    clc		     ; Clear the carry flag before shifting

shift_loop:

    ; Use the carry flag to keep track of the last bit of the current row
    rcr     byte [edi], 1       ; Rotate right the current byte and set the last bit to the carry flag

    inc     edi                 ; Move to the next byte
    dec     esi                 ; edi = Pointer to the byte before the last byte of the current row
    jnz     shift_loop          ; If current byte > first byte, continue processing

debug:
    ; Set the first byte of the current row to the last bit of the current row (that was stored in the carry flag)
    dec     edi                 ; edi = Pointer to the first byte of the current row
    mov     al, [edi]           ; al = Last byte of the current row
    mov     cl, dl              ; cl = Number of bits to shift
    shl     al, cl	      ; Shift the last bit to the first position

    ; Store the first byte of the current row
    or      byte [esp], al      ; Store the first byte of the current row

    dec     dh                 ; Decrement the number of bits to shift
    jnz     row_loop            ; If number of bits to shift > 0, continue processing

    ; Calculate Pointer to Current Row (edi)
    mov     edi, [ebp - 4]      ; edi = Pointer to current row
    ; Restore the row from the buffer to the image
    mov     ecx, [ebp + 20]      ; ecx = buffer size
    mov     esi, esp            ; esi = buffer pointer
    rep movsb                   ; Copy bytes from [esi] to [edi]

row_divisible_by_8:

    mov     edi, [ebp - 4]      ; esi = Pointer to the current row
    sub     edi, [ebp + 20]     ; edi = Pointer to the previous row
    mov     [ebp - 4], edi      ; Store the pointer to the current row

    ; Loop Condition: Check if all rows are processed
    inc     ebx                 ; row_number++
    cmp     ebx, [ebp + 16]     ; Compare row_number with height
    jnz     main_loop            ; If row_number < height, continue processing

end:
    ; ----------------------------
    ; Function Epilogue
    ; ----------------------------

    pop     edi                 ; Restore edi
    pop     esi                 ; Restore esi
    pop     ebx                 ; Restore ebx

    ; Deallocate the buffer
    mov     esp, ebp            ; Restore stack pointer

    pop     ebp                 ; Restore base pointer
    ret                         ; Return to caller

; ----------------------------
; End of slantbmp1 Function
; ----------------------------