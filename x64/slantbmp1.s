; filepath: /mnt/c/Studies/Sem_5/COAR/Project_x86/slantbmp1.s
section .text
    global slantbmp1

; Function: void slantbmp1(void *img, int width, int height, int stride)
; Parameters (cdecl):
;   img: rdi
;   width: rsi
;   height: rdx
;   stride: rcx

slantbmp1:
    ; ----------------------------
    ; Function Prologue
    ; ----------------------------
    push    rbp                 ; Save base pointer
    mov     rbp, rsp            ; Establish new base pointer

    push    rbx                 ; Preserve rbx
    push    rsi                 ; Preserve rsi
    push    rdi                 ; Preserve rdi

    mov     r8, rdi             ; Save img in r8
    mov     r9, rsi             ; Save width in r9
    mov     r10, rdx            ; Save height in r10
    mov     r11, rcx            ; Save stride in r11

    xor     rdi, rdi            ; Clear rdi
    xor     rsi, rsi            ; Clear rsi
    xor     rdx, rdx            ; Clear rdx
    xor     rcx, rcx            ; Clear rcx

    ; ----------------------------
    ; Load Function Parameters
    ; ----------------------------

    ; Initialize Row Counter
    mov     rbx, r10              ; rbx = row_number = 1 (starting from row 1)
    sub     rbx, 2                ; rbx = height - 2

    ; Calculate Number to rotate the last byte of the current row to the left
    ; This is performed to store the last in of the current row on the first position of a byte
    ; To put this byte at the beggining of the row
    mov     rcx, r9     ; rcx = width
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
    mov     rdx, r10            ; rdx = row_number
    sub     rdx, rbx
    dec     rdx                 ; Decrement the number of bits to shift

    ; Calculate Pointer to Current Row (rdi)
    mov     rdi, rbx            ; rdi = row_number
    dec     rbx                 ; row_number++
    imul    rdi, r11            ; rdi = row_number * stride
    add     rdi, r8            ; rdi = img + (row_number * stride) = Pointer to current row

row_loop:
    ; Calculate pointer to the last byte of the current row (rsi)
    mov     rsi, r9      ; rsi = width
    shr     rsi, 3               ; rsi = width / 8
    add     rsi, rdi             ; rsi = rdi + (width / 8) = Pointer to the last byte of the current row

    ; Save the last bit of the current row in al
    mov     al, [rsi]           ; r12 = Last byte of the current row
    rol     al, cl	     ; Rotate left the last byte of the current row by ecx bits
    and     al, 0b10000000      ; al = Last bit of the current row

    shr     byte [rsi], 1              ; shift the last byte of the current row to the right

shift_loop:

    dec     rsi                 ; rsi = Pointer to the byte before the last byte of the current row

    ; Use the carry flag to keep track of the last bit of the current row
    shr     byte [rsi], 1       ; Shift the current byte to the right
    setc    ah                 ; ah = Carry flag
    ror     ah, 1              ; Rotate the register to put the carry flag in the first bit

;     inc     rsi                 ; rsi = Pointer to the current byte
    or      byte [rsi+1], ah         ; Set the first bit of the next byte to the carry flag

    ; Loop Condition: Check if all bytes are processed
    cmp     rsi, rdi            ; Compare current byte with the first byte of the current row
    jg      shift_loop          ; If current byte > first byte, continue processing

    ; Set the first byte of the current row to the last bit of the current row
    or      byte [rdi], al      ; Set the first byte of the current row to the last bit of the current row

    dec     rdx                 ; Decrement the number of bits to shift
    jg      row_loop            ; If number of bits to shift > 0, continue processing

    ; Loop Condition: Check if all rows are processed
    test    ebx, ebx            ; Check if row_number == 0
    jg      main_loop            ; If row_number < height, continue processing

end:
    ; ----------------------------
    ; Function Epilogue
    ; ----------------------------
    pop     rdi                 ; Restore rdi
    pop     rsi                 ; Restore rsi
    pop     rbx                 ; Restore rbx

    mov     rsp, rbp            ; Restore stack pointer
    pop     rbp                 ; Restore base pointer
    ret                         ; Return to caller

; ----------------------------
; End of slantbmp1 Function
; ----------------------------