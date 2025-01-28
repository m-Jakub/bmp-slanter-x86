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

    ; Allocate row buffer 
    mov     ecx, [ebp + 12]     ; ecx = width
    mov     edx, ecx	        ; edx = width
    shr     ecx, 3              ; ecx = width / 8 (number of full bytes)
    test    edx, 7              ; Check if there are remaining bits
    jz      no_extra_byte
    inc     ecx                 ; Add one more byte if there are remaining bits

no_extra_byte:
    ; Allocate buffer on the stack using the calculated number of bytes
    sub     esp, ecx            ; Allocate 'number of bytes' on the stack
    mov     edi, esp            ; edi = buffer pointer

    ; Initialize Row Counter
    mov     ebx, [ebp + 16]              ; ebx = row_number = height
    sub     ebx, 2

    ; Calculate Number to rotate the last byte of the current row to the left
    ; This is performed to store the last in of the current row on the first position of a byte
    ; To put this byte at the beggining of the row
    mov     edx, [ebp + 12]     ; edx = width
    and     dl, 0b00000111     ; edx = width % 8 = Number of bits in the last byte that are part of the image
    dec     dl                 ; edx = width % 8 - 1 = Number to rotate left the last byte of the current row
    cmp     dl, -1	     ; Check if the last byte is a full byte
    jne     main_loop

    mov     dl, 7	     ; If the last byte is a full byte, set the number to rotate to 7

    ; ----------------------------
    ; Perform Byte-Wise Shift (if applicable)
    ; ----------------------------
main_loop:
    ; Calculate number of single bits to shift (row number % 8)
    mov     ecx, [ebp + 16]
    sub     ecx, ebx            ; ecx = row_number
    dec     ecx                 ; ecx = row_number - 1
    and     ecx, 0b00000111     ; ecx = row_number % 8 = Number of bits to shift
    mov     dh, cl              ; dh = Number of bits to shift

    ; Calculate Pointer to Current Row (esi)
    mov     esi, ebx            ; esi = row_number
    imul    esi, [ebp + 20]     ; esi = row_number * stride
    add     esi, [ebp + 8]      ; esi = img + (row_number * stride) = Pointer to current row

    ; Fill the buffer with the current row
    mov     ecx, ebp	    ; ecx = base pointer
    sub     ecx, esp
    sub     ecx, 12	    ; ecx = buffer size
    mov     eax, ecx            ; eax = buffer size

    mov     edi, esp            ; edi = buffer pointer
    rep movsb                   ; Copy bytes from [esi] to [edi]
    ; ecx is being zeroed by rep movsb

    mov     esi, eax            ; esi = buffer size

row_loop:
    ; Calculate pointer to the last byte of the buffer
    mov     edi, esp            ; edi = buffer pointer
    add     edi, esi            ; edi = buffer pointer + number of bytes
    dec     edi                 ; edi = Pointer to the last byte of the buffer

    ; Save the last bit of the current row in al
    mov     al, [edi]           ; al = Last byte of the current row
    mov     cl, dl	     ; cl = Number of bits to shift
    rol     al, cl	     ; Rotate left the last byte of the current row by ecx bits
    and     al, 0b10000000      ; al = Last bit of the current row

    shr     byte [edi], 1              ; shift the last byte of the current row to the right
    cmp     edi, esp            ; Compare current byte with the first byte of the current row
    je      end_shift_loop      ; If current byte == first byte, skip shifting

shift_loop:

    dec     edi                 ; edi = Pointer to the byte before the last byte of the current row

    ; Use the carry flag to keep track of the last bit of the current row
    shr     byte [edi], 1       ; Shift the current byte to the right
    setc    ah                 ; ah = Carry flag
    ror     ah, 1              ; Rotate the register to put the carry flag in the first bit

    or      byte [edi+1], ah         ; Set the first bit of the next byte to the carry flag

    ; Loop Condition: Check if all bytes are processed
    cmp     edi, esp            ; Compare current byte with the first byte of the current row
    jg      shift_loop          ; If current byte > first byte, continue processing

    ; Set the first byte of the current row to the last bit of the current row

end_shift_loop:
    or      byte [esp], al      ; Set the first byte of the current row to the last bit of the current row

debug:
    dec     dh                 ; Decrement the number of bits to shift
    jnz     row_loop            ; If number of bits to shift > 0, continue processing

    ; Calculate Pointer to Current Row (edi)
    mov     edi, ebx            ; edi = row_number
    imul    edi, [ebp + 20]     ; edi = row_number * stride
    add     edi, [ebp + 8]      ; edi = img + (row_number * stride) = Pointer to current row
    ; Restore the row from the buffer to the image
    mov     ecx, ebp	    ; ecx = base pointer
    sub     ecx, esp
    sub     ecx, 12	    ; ecx = buffer size
    mov     esi, esp            ; esi = buffer pointer
    rep movsb                   ; Copy bytes from [esi] to [edi]

    ; Loop Condition: Check if all rows are processed
    dec     ebx                 ; row_number++
    test    ebx, ebx            ; Check if row_number == 0
    jnz     main_loop            ; If row_number < height, continue processing

end:
    ; ----------------------------
    ; Function Epilogue
    ; ----------------------------

    ; Deallocate row buffer
    mov     ecx, ebp	    ; ecx = base pointer
    sub     ecx, esp
    sub     ecx, 12	    ; ecx = buffer size
    add     esp, ecx            ; Deallocate 'number of bytes' from the stack

    pop     edi                 ; Restore edi
    pop     esi                 ; Restore esi
    pop     ebx                 ; Restore ebx

    mov     esp, ebp            ; Restore stack pointer
    pop     ebp                 ; Restore base pointer
    ret                         ; Return to caller

; ----------------------------
; End of slantbmp1 Function
; ----------------------------