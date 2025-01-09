section .text
global slantbmp1

; Function: void slantbmp1(void *img, size_t stride, int height)
; Parameters (cdecl):
;   img:    [ebp + 8]    ; Pointer to image data
;   stride: [ebp + 12]   ; Stride (padded row size) in bytes
;   height: [ebp + 16]   ; Image height in rows

slantbmp1:
    push    ebp
    mov     ebp, esp
    push    ebx             ; Save ebx
    push    esi             ; Save esi
    push    edi             ; Save edi

    ; Load parameters
    mov     esi, [ebp + 8]    ; img pointer
    mov     ecx, [ebp + 12]   ; stride
    mov     edx, [ebp + 16]   ; height

    ; Initialize row index to 0
    xor     ebx, ebx          ; ebx = row index (0)

process_row:
    cmp     ebx, edx
    jge     end_function      ; Exit loop if row >= height

    ; Calculate row pointer: img + (row * stride)
    mov     eax, ebx          ; Move row index to eax
    imul    eax, ecx          ; eax = row * stride
    add     eax, esi          ; eax = img + (row * stride)

    ; === Begin Integration of New Instructions ===

    ; No operations performed. The image data is copied as-is.

    ; === End Integration of New Instructions ===

    ; Move to the next row
    inc     ebx
    jmp     process_row

end_function:
    pop     edi               ; Restore edi
    pop     esi               ; Restore esi
    pop     ebx               ; Restore ebx
    pop     ebp
    ret