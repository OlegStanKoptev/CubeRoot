# Программирование на языке ассемблера. Микропроект

Микропроект на FASM для 64bit Linux (ELF64)

## Вариант 10. Коптев Олег Станиславович
Разработать программу вычисления корня кубического из заданного числа согласно быстросходящемуся итерационному алгоритму определения корня n-ной степени с точностью не хуже 0,05% (использовать FPU)
```Assembly
format ELF64
public main

extrn printf
extrn scanf
extrn cbrt

section '.data' writable
    strFloatOutput    db    '%.5f', 10, 0

    strStart        db     'Program for counting cube root with the precision of %.2f', 10, 0
    strInFloat        db    'Please enter the number: ', 0
    strScanFloat    db    '%lf', 0
    strCalcRes        db     'Calculated result: %.3f', 10, 0
    strTrueRes        db    'True result using cbrt(): %.3f', 10, 0
    strFiller        db    'Starting the algorithm...', 10, 0

    strIterPhrase   db  '%d: %f', 10, 0

    A                 dq  ?
    tempA            dq  ?
    delta             dq  0.05
    x                 dq  ?
    temp_x            dq  ?
    input_A            dq  ?
    next_x             dq  ?
    true_val        dq  ?
    counter            dd     0

    two             dd  2
    three           dd  3

    value            dq  1.6

section '.code' writable 
main:
    sub rsp, 40
    mov rdi, strStart
    movsd xmm0, [delta]
    mov eax, 1
    call printf


    mov rdi, strInFloat
    xor rax, rax
    call printf

    mov rdi, strScanFloat
    mov rsi, A
    call scanf

    mov rdx, [A]
    mov [input_A], rdx
    call start

    mov rdi, strCalcRes
    movsd xmm0, [x]
    mov eax, 1
    call printf

    movsd xmm0, [input_A]
    mov eax, 1
    call cbrt

    mov rdi, strTrueRes
    mov eax, 1
    call printf

    add rsp, 40
    xor rax, rax
    ret

start:
    mov rdi, strFiller
    xor rax, rax
    call printf

    fld qword [A]
    fild dword [three]
    fdivp st1, st0
    fstp qword [next_x]

    mov ebx, 1
    mov [counter], ebx

    xor rcx, rcx

    .iter:
        push rsp
        mov rdi, strIterPhrase
        mov esi, [counter]
        movsd xmm0, [next_x]
        mov eax, 1
        call printf
        pop rsp

        fld qword [next_x]
        fstp qword [x]

        call getNext
        mov [next_x], rax

        fld qword [delta]
        fld qword [next_x]
        fld qword [x]
        fsubp st1, st0
        fabs
        fcomi st1
        jb exit

        fstp st0
        fstp st0
        fstp st0

        mov edx, [counter]
        inc edx
        mov [counter], edx

        jmp .iter
exit:
    ret


getNext:
    fld qword [A]

    fld qword [x]
    fmul st0, st0

    fdivp st1, st0
    fstp qword [tempA]

    fld qword [x]
    fild dword [two]
    fmulp st1, st0
    fstp qword [temp_x]

    fld qword [tempA]
    fld qword [temp_x]
    fadd st0, st1

    fild dword [three]
    fdivp st1, st0
    fstp qword [tempA]

    mov rax, [tempA]
    ret
```
