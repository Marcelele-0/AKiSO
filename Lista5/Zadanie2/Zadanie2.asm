section .data
    ; Macierz 3x3 (9 liczb całkowitych)
    matrix dd 1, 2, 3
           dd 4, 5, 6
           dd 7, 8, 9

    msg_total db "Suma elementów: ", 0
    msg_diag db "Suma przekątnej: ", 0
    newline db 0xA, 0

section .bss
    total resd 1         ; Suma wszystkich elementów
    diagonal resd 1      ; Suma elementów na przekątnej
    buffer resb 12       ; Bufor na wynik w postaci tekstowej

section .text
    global _start

_start:
    ; Inicjalizacja sum
    xor eax, eax         ; eax = 0
    mov [total], eax     ; total = 0
    mov [diagonal], eax  ; diagonal = 0

    ; Oblicz sumę wszystkich elementów i przekątnej
    mov ecx, 0           ; Indeks elementu

sum_loop:
    cmp ecx, 9           ; Czy przetworzono wszystkie elementy?
    je print_results     ; Jeśli tak, zakończ pętlę

    mov eax, [matrix + ecx * 4] ; Pobierz element macierzy
    add [total], eax     ; Dodaj element do sumy całkowitej

    ; Sprawdź, czy element jest na przekątnej
    cmp ecx, 0
    je add_to_diagonal
    cmp ecx, 4
    je add_to_diagonal
    cmp ecx, 8
    je add_to_diagonal
    jmp next_element

add_to_diagonal:
    add [diagonal], eax  ; Dodaj element do sumy przekątnej

next_element:
    inc ecx              ; Przejdź do następnego elementu
    jmp sum_loop

print_results:
    ; Wyświetl sumę wszystkich elementów
    mov eax, 4           ; write syscall
    mov ebx, 1           ; file descriptor (stdout)
    mov ecx, msg_total   ; Tekst "Suma elementów: "
    mov edx, 17          ; Długość tekstu
    int 0x80

    mov eax, [total]     ; Pobierz sumę całkowitą
    call int_to_ascii    ; Konwertuj na ASCII
    mov eax, 4           ; write syscall
    mov ebx, 1           ; file descriptor (stdout)
    mov ecx, buffer      ; Bufor z wynikiem
    mov edx, 12          ; Maksymalna długość wyniku
    int 0x80

    ; Dodaj nową linię
    mov eax, 4           ; write syscall
    mov ebx, 1           ; file descriptor (stdout)
    mov ecx, newline     ; Nowa linia
    mov edx, 1           ; Długość
    int 0x80

    ; Wyświetl sumę przekątnej
    mov eax, 4           ; write syscall
    mov ebx, 1           ; file descriptor (stdout)
    mov ecx, msg_diag    ; Tekst "Suma przekątnej: "
    mov edx, 20          ; Długość tekstu
    int 0x80

    mov eax, [diagonal]  ; Pobierz sumę przekątnej
    call int_to_ascii    ; Konwertuj na ASCII
    mov eax, 4           ; write syscall
    mov ebx, 1           ; file descriptor (stdout)
    mov ecx, buffer      ; Bufor z wynikiem
    mov edx, 12          ; Maksymalna długość wyniku
    int 0x80

    ; Dodaj nową linię
    mov eax, 4           ; write syscall
    mov ebx, 1           ; file descriptor (stdout)
    mov ecx, newline     ; Nowa linia
    mov edx, 1           ; Długość
    int 0x80

    ; Wyjście z programu
    mov eax, 1           ; exit syscall
    xor ebx, ebx         ; Kod wyjścia 0
    int 0x80

; Funkcja konwertująca liczbę na ASCII
; Argument: eax - liczba
; Wynik: buffer - tekst reprezentujący liczbę
int_to_ascii:
    mov ecx, 10          ; Baza dziesiętna
    lea esi, [buffer + 11] ; Wskaźnik na koniec bufora
    mov byte [esi], 0    ; Zakończ string null-terminatorem

convert_loop:
    xor edx, edx         ; Zeruj edx przed div
    div ecx              ; eax / 10, reszta w edx
    add dl, '0'          ; Konwertuj resztę na ASCII
    dec esi              ; Przesuwaj wskaźnik w lewo
    mov [esi], dl        ; Zapisz znak
    test eax, eax        ; Czy liczba się skończyła?
    jnz convert_loop     ; Jeśli nie, kontynuuj

    lea eax, [esi]       ; Ustaw eax na początek wyniku
    ret

