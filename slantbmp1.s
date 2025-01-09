; filepath: /mnt/c/Studies/Sem_5/COAR/Project_x86/slantbmp1.s
section .text
global slantbmp1

; Function: void slantbmp1(void *img, int width, int height)
; Parameters (cdecl):
;   img:    [ebp + 8]     ; Pointer to image data
;   width:  [ebp + 12]    ; Image width in pixels
;   height: [ebp + 16]    ; Image height in rows

slantbmp1:
    push    ebp
    mov     ebp, esp
    push    ebx             ; Save ebx (stride)
    push    esi             ; Save esi (img pointer)
    push    edi             ; Save edi (row index)

    ; Load parameters
    mov     esi, [ebp + 8]   ; esi = img pointer
    mov     ecx, [ebp + 12]  ; ecx = width (pixels)
    mov     edx, [ebp + 16]  ; edx = height (rows)

    ; Calculate stride: stride = ((width + 31) / 32) * 4
    mov     eax, ecx         ; eax = width
    add     eax, 31          ; eax = width + 31
    mov     ebx, 32          ; ebx = 32
    xor     edx, edx         ; Clear edx before division
    div     ebx              ; eax = (width + 31) / 32, edx = remainder
    imul    eax, 4           ; eax = stride
    mov     ebx, eax         ; ebx = stride

    ; Initialize row index to 0
    xor     edi, edi         ; edi = row index (0)

process_row:
    cmp     edi, edx
    jge     end_function     ; Exit loop if row >= height

    ; Calculate row pointer: img + (row * stride)
    mov     eax, edi         ; eax = row index
    imul    eax, ebx         ; eax = row index * stride
    add     eax, esi         ; eax = img + (row * stride)
    mov     edi, eax         ; edi = current row pointer

    ; === Begin Integration of Slanting Logic ===

    ; TODO: Implement your slanting logic here.
    ; Example Placeholder: Shift each byte in the row left by 1 bit

    mov     ecx, ebx         ; ecx = stride (bytes per row)
    mov     esi, edi         ; esi = current row pointer

shift_bits:
    cmp     ecx, 0
    je      next_row
    mov     al, [esi]
    shl     al, 1             ; Shift left by 1 bit (example operation)
    mov     [esi], al
    inc     esi
    dec     ecx
    jmp     shift_bits

next_row:
    ; === End Integration of Slanting Logic ===

    ; Move to the next row
    inc     edi               ; Increment row index
    jmp     process_row

end_function:
    pop     edi               ; Restore edi (row index)
    pop     esi               ; Restore esi (img pointer)
    pop     ebx               ; Restore ebx (stride)
    pop     ebp
    ret