# Программирование на языке ассемблера. Микропроект

Микропроект на FASM для 64 bit Linux (ELF64)

## Вариант 10. Коптев Олег Станиславович
Разработать программу вычисления корня кубического из заданного числа согласно быстросходящемуся итерационному алгоритму определения корня n-ной степени с точностью не хуже 0,05% (использовать FPU)

### Алгоритм
Для нахождения кубического корня используется [алгоритм нахождения корня n-ной степени](https://ru.wikipedia.org/wiki/Алгоритм_нахождения_корня_n-ной_степени).

Для определения точности вычисления используется такая проверка: <img src="https://render.githubusercontent.com/render/math?math=\frac{100 \cdot |x_k - x_{k-1}|}{x_k} < 0.05">

#### Суть алгоритма
1) Сделать предположение <img src="https://render.githubusercontent.com/render/math?math=x_0">;
2) Задать <img src="https://render.githubusercontent.com/render/math?math=x_{k%2B1}=\frac{1}{n}%20\left(%20(n-1)x_k%20%2B%20\frac{A}{x_k^{n-1}}%20\right)">, где в нашем случае <img src="https://render.githubusercontent.com/render/math?math=n = 3">;
3) Повторять шаг 2, пока не будет достигнута необходимая точность.

### Компиляция и сборка
Компилируется при помощи вызова `fasm app.asm`, сборка -  `gcc app.o -o app -lm` (флаг `-lm` нужен, чтобы использовать библиотеку `math.h`)

### Пример работы
Ниже представлены несколько вариантов входных данных и соответствующие результаты исполнения:

Исходное число: 8, результат: 2.000000
![picture 1](https://raw.githubusercontent.com/OlegStanKoptev/CubeRoot/master/images/1.png)
Исходное число: 970299, результат: 99.000000
![picture 2](https://raw.githubusercontent.com/OlegStanKoptev/CubeRoot/master/images/2.png)
Исходное число: -27, результат: -3.000000
![picture 3](https://raw.githubusercontent.com/OlegStanKoptev/CubeRoot/master/images/3.png)
Исходное число: 0, результат: 0
![picture 4](https://raw.githubusercontent.com/OlegStanKoptev/CubeRoot/master/images/4.png)
Исходное число: 99999999999999, результат: 46415.888340
![picture 5](https://raw.githubusercontent.com/OlegStanKoptev/CubeRoot/master/images/5.png)

Во всех случаях вычисленное значение лежит в области допустимой погрешности

### Исходный код с комментариями
```Assembly
format ELF64
public main

; Koptev Oleg
; Variant 10

extrn printf
extrn scanf
extrn cbrt

section '.data' writable
    strStart        db  'Program for counting cube root with the precision of %.2f%', 10, 0
    strInFloat      db  'Please enter the number: ', 0
    strScanFloat    db  '%lf', 0
    strCalcRes      db  'Calculated result: %f', 10, 0
    strTrueRes      db  'True result using cbrt(): %f', 10, 0
    strFiller       db  'Listing approximations...', 10, 0

    strIterPhrase   db  9, '%d: %f', 10, 0

    A               dq  ?
    tempA           dq  ?
    epsilon         dq  0.05
    x               dq  ?
    tempX           dq  ?
    input_A         dq  ?
    next_x          dq  ?
    true_val        dq  ?
    counter         dd  0

    zero            dd  0
    two             dd  2
    three           dd  3
    hundred         dd  100

section '.code' writable 
main:
    ; printf("Program for counting cube root with the precision of %.2f\n", epsilon);
    sub rsp, 40
    mov rdi, strStart
    movsd xmm0, [epsilon]
    mov eax, 1
    call printf

    ; printf("Please enter the number: ");
    mov rdi, strInFloat
    xor rax, rax
    call printf

    ; scanf("%lf", &A);
    mov rdi, strScanFloat
    mov rsi, A
    call scanf

    ; input_A = A;
    mov rdx, [A]
    mov [input_A], rdx

    ; start();
    call start

    ; printf("Calculated result: %.3f\n", next_x);
    mov rdi, strCalcRes
    movsd xmm0, [next_x]
    mov eax, 1
    call printf

    ; cbrt(input_A);
    movsd xmm0, [input_A]
    mov eax, 1
    call cbrt

    ; printf("True result using cbrt(): %.3f\n");
    mov rdi, strTrueRes
    mov eax, 1
    call printf

    add rsp, 40
    ; return 0;
    xor rax, rax
    ret

; void start()
;   input: user number is A variable
;   output: cube root in x variable
start:
    ; printf("Listing approximations...\n");
    mov rdi, strFiller
    xor rax, rax
    call printf

    ; next_x = A / 3;
    fld qword [A]
    fild dword [three]
    fdivp st1, st0
    fstp qword [next_x]

    ; counter = 1;
    mov ebx, 1
    mov [counter], ebx

    xor rcx, rcx

    ; do
    .iter:
        ; printf("%d: %f", counter, next_x)
        sub rsp, 40
        mov rdi, strIterPhrase
        mov esi, [counter]
        movsd xmm0, [next_x]
        mov eax, 1
        call printf
        add rsp, 40

        ; x = next_x;
        fld qword [next_x]
        fstp qword [x]

        ; next_x = getNext()
        call getNext
        movsd qword [next_x], xmm0

        ; if (next_x == null) goto reset_x;
        fld qword [next_x]
        fcomi st1
        jp reset_x
        fstp st0

        ; while (abs(next_x - x) * 100 / next_x > epsilon)
        fld qword [epsilon]
        fld qword [next_x]
        fld qword [x]
        fsubp st1, st0
        fild dword [hundred]
        fmulp st1, st0
        fld qword [next_x]
        fdivp st1, st0
        fabs

        fcomi st1
        jb exit

        ; empty the fpu stack to avoid stack overflow
        fstp st0
        fstp st0
        fstp st0

        ; counter++;
        mov edx, [counter]
        inc edx
        mov [counter], edx

        jmp .iter
reset_x:
    fild dword [zero]
    fstp qword [next_x]
exit:
    ret

; double getNext(double A, double x)
;   input: user number, current approximation
;   output: (2 * x + A / (x * x)) / 3
getNext:
    ; tempA = A / (x * x);
    fld qword [A]
    fld qword [x]
    fmul st0, st0
    fdivp st1, st0
    fstp qword [tempA]

    ; tempX = 2 * x;
    fld qword [x]
    fild dword [two]
    fmulp st1, st0
    fstp qword [tempX]

    ; tempA = tempA + tempX;
    fld qword [tempA]
    fld qword [tempX]
    fadd st0, st1

    ; tempA = tempA / 3;
    fild dword [three]
    fdivp st1, st0
    fstp qword [tempA]

    movsd xmm0, qword [tempA]
    ret

```
