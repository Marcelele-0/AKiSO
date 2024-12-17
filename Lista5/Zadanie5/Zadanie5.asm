BITS 16
ORG 0x7C00

start:
    cli                     ; wyłącz przerwania
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00         ; ustaw stos

    mov ax, 0x0013          ; ustaw tryb graficzny 320x200x256 kolorów
    int 0x10

    call draw_mandelbrot    ; narysuj zbiór Mandelbrota

halt:
    hlt                     ; zawieś system
    jmp halt

; Rysowanie zbioru Mandelbrota
draw_mandelbrot:
    mov cx, 200             ; wysokość ekranu (Y)
    xor di, di              ; di = indeks w pamięci wideo

y_loop:
    push cx                 ; zachowaj CX
    mov cx, 320             ; szerokość ekranu (X)

x_loop:
    push cx                 ; zachowaj CX

    ; Oblicz współrzędne punktu w przestrzeni zespolonej
    mov ax, di              ; di = indeks pikselu
    xor dx, dx              ; wyzeruj dx dla dzielenia
    mov bx, 160             ; przesunięcie X na [-160, 160]
    cwd                     ; konwersja do podwójnego słowa
    idiv bx                 ; podział przez 320 (skalowanie X)
    mov [real_part], ax     ; rzeczywista część Z

    mov ax, di              ; di = indeks pikselu
    xor dx, dx              ; wyzeruj dx dla dzielenia
    mov bx, 100             ; przesunięcie Y na [-100, 100]
    cwd                     ; konwersja do podwójnego słowa
    idiv bx                 ; podział przez 200 (skalowanie Y)
    mov [imaginary_part], ax ; urojona część Z

    ; Obliczanie iteracji zbioru Mandelbrota
    call mandelbrot_iter

    ; Rysowanie na ekranie
    mov al, byte [iteration] ; liczba iteracji (kolor)
    mov es:[di], al          ; ustaw kolor piksela
    pop cx                  ; przywróć CX dla X
    loop x_loop             ; iteruj po szerokości

    pop cx                  ; przywróć CX dla Y
    add di, 320             ; przejdź do następnej linii (kolejny wiersz pikseli)
    loop y_loop             ; iteruj po wysokości

    ret

; Funkcja obliczająca liczbę iteracji w zbiorze Mandelbrota
mandelbrot_iter:
    mov ax, [real_part]     ; rzeczywista część
    mov bx, [imaginary_part] ; urojona część
    mov cx, 0               ; licznik iteracji
    mov dx, 2               ; promień dla sprawdzania (|Z| > 2)
    mov di, 0               ; współczynniki pomocnicze Z

mandelbrot_calc:
    ; Oblicz Z = Z^2 + C, gdzie Z = a + bi, C = x + yi
    ; Z^2 = (a + bi)^2 = a^2 - b^2 + 2abi
    mov ax, [real_part]
    imul ax, ax             ; a^2
    mov di, [imaginary_part]
    imul di, di             ; b^2
    sub ax, di              ; a^2 - b^2
    mov di, ax              ; rzeczywista część Z
    mov ax, [real_part]
    mov di, [imaginary_part]
    imul ax, di             ; 2ab
    mov bx, ax              ; urojona część Z
    ; Sprawdź, czy |Z| > 2 (czyli a^2 + b^2 > 4)
    ; (a^2 + b^2)
    mov ax, [real_part]
    imul ax, ax             ; a^2
    mov bx, [imaginary_part]
    imul bx, bx             ; b^2
    add ax, bx              ; a^2 + b^2
    cmp ax, 4               ; porównaj z 4
    jae mandelbrot_done     ; jeśli |Z| > 2, zakończ iterację

    inc cx                  ; zwiększ licznik iteracji
    ; Powtarzaj proces, aktualizując Z
    ; Z = Z^2 + C (już zaimplementowane powyżej)
    mov [real_part], di
    mov [imaginary_part], bx
    jmp mandelbrot_calc

mandelbrot_done:
    mov [iteration], cx      ; zapisz liczbę iteracji

    ret

; Sekcja danych
real_part dw 0               ; rzeczywista część liczby zespolonej
imaginary_part dw 0          ; urojona część liczby zespolonej
iteration db 0               ; licznik iteracji

times 510-($-$$) db 0  ; wypełnienie zerami do 510 bajtów
dw 0xAA55              ; sygnatura bootloadera
