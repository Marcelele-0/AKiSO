section .data
    hex_format db "%08x", 0    ; Format do wyświetlania liczby w formacie szesnastkowym
    newline db 10, 0           ; Nowa linia

section .bss
    buffer resb 9              ; Bufor na tekst (8 cyfr + '\0')

section .text
    global _start

_start:
    ; Liczba, którą chcemy wyświetlić
    mov eax, 123456            ; Wstawienie liczby do rejestru EAX

    ; Zamiana liczby na ciąg szesnastkowy
    mov ebx, 16                ; Podstawa 16 (szesnastkowa)
    mov ecx, buffer + 8        ; Wskaźnik na koniec bufora (mieszcząc znak null na końcu)

convert_loop:
    dec ecx                    ; Przesuwamy wskaźnik na lewo
    xor edx, edx               ; Zerowanie rejestru EDX
    div ebx                    ; Dzielimy EAX przez 16, wynik w EAX, reszta w EDX
    add dl, '0'                ; Zamiana cyfry na znak ASCII
    cmp dl, '9'                ; Sprawdzamy, czy to jest cyfra
    jbe skip_to_next
    add dl, 7                  ; Jeśli większe niż '9', dodaj 7 ('A' - '0' = 7)
skip_to_next:
    mov [ecx], dl              ; Zapisanie cyfry do bufora

    test eax, eax              ; Sprawdzamy, czy dzielnik jest zerowy
    jnz convert_loop           ; Jeśli nie, kontynuujemy

    ; Zapisanie bufora na standardowe wyjście
    mov eax, 4                 ; Numer wywołania systemowego 'write'
    mov ebx, 1                 ; Deskryptor pliku (stdout)
    mov edx, 8                 ; Długość tekstu (8 cyfr)
    lea ecx, [buffer]          ; Wskaźnik na bufor
    int 0x80                   ; Wywołanie systemowe

    ; Nowa linia
    mov eax, 4                 ; Wywołanie systemowe 'write'
    mov ebx, 1                 ; Deskryptor pliku (stdout)
    lea ecx, [newline]         ; Wskaźnik na ciąg nowej linii
    mov edx, 1                 ; Długość (1 znak)
    int 0x80                   ; Wywołanie systemowe

    ; Zakończenie programu
    mov eax, 1                 ; Numer wywołania systemowego 'exit'
    xor ebx, ebx               ; Kod wyjścia (0)
    int 0x80                   ; Wywołanie systemowe
