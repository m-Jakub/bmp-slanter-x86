        section .text
        global  countdigits
countdigits:
        push    ebp
        mov     ebp, esp

        mov     edx, [ebp+8]
        xor     eax, eax        ; eax = 0
nextchar:
        mov     cl, [edx]
        inc     edx
        test    cl, cl
        jz      fin
        cmp     cl, '0'         ;compare cl against digit 0
        jb      nextchar
        cmp     cl, '9'
        ja      nextchar
        ; it's a digit
        inc     eax
        jmp     nextchar

fin:
        pop     ebp
        ret

    ; check which extention for assembler is best to use in the pdf file

    ; nasm -f elf32 countdigits.s
    ; there are 2 .o files now
    ; cc -m32 -o cntdig cntdig.o countdigits.o
    ;