section .bss
    buffer resb 12             ; Bufor na liczby (max 10 cyfr + '\n' + null)

section .data
    ten: dd 10                 ; Stała używana do dzielenia przez 10

section .text
    global _start              ; Punkt wejścia dla linkera

_start:
    mov ebx, 2                ; Rozpoczynamy od 2 (pierwsza liczba pierwsza)

main_loop:
    cmp ebx, 100000           ; Sprawdzamy, czy osiągnięto 100000
    ja end_program            ; Jeśli przekroczono 100000, zakończ program

    ; Sprawdzanie czy liczba jest pierwsza
    push ebx                  ; Zachowujemy liczbę na stosie
    call is_prime
    pop ebx                   ; Przywracamy liczbę
    cmp eax, 1                ; Jeśli eax == 1, liczba jest pierwsza
    jne not_prime             ; Jeśli nie, przejdź do następnej liczby

    ; Wypisywanie liczby
    push ebx                  ; Zachowujemy liczbę
    mov eax, ebx              ; Przekazujemy liczbę do konwersji
    call int_to_string        ; Konwersja liczby w eax na tekst w buforze
    mov eax, 4                ; Wywołanie systemowe write
    mov ebx, 1                ; Standardowe wyjście
    mov ecx, buffer           ; Adres bufora z liczbą
    mov edx, 12               ; Maksymalna liczba bajtów do wypisania
    int 0x80                  ; Wykonaj wywołanie systemowe
    pop ebx                   ; Przywróć liczbę

not_prime:
    inc ebx                   ; Przejdź do następnej liczby
    jmp main_loop             ; Powrót do głównej pętli

end_program:
    mov eax, 1                ; Kod systemowy zakończenia programu
    int 0x80                  ; Wywołanie systemowe

; Procedura sprawdzania liczby pierwszej
; Wejście: ebx - liczba do sprawdzenia
; Wyjście: eax - 1 jeśli liczba jest pierwsza, 0 w przeciwnym razie
is_prime:
    push ecx                  ; Zachowujemy rejestry
    push edx
    mov eax, ebx              ; Kopiujemy liczbę
    cmp ebx, 2                ; Jeśli liczba <= 2, jest pierwsza
    je is_prime_yes
    mov ecx, 2                ; Zaczynamy od dzielnika 2

prime_check_loop:
    mov edx, 0                ; Zerujemy edx przed dzieleniem
    div ecx                   ; eax / ecx, reszta w edx
    cmp edx, 0                ; Sprawdzamy, czy reszta == 0
    je is_prime_no            ; Jeśli tak, liczba nie jest pierwsza

    inc ecx                   ; Zwiększ dzielnik
    mov eax, ecx
    mul ecx                   ; Oblicz: eax = ecx * ecx
    cmp eax, ebx              ; Jeśli dzielnik^2 > liczba, liczba jest pierwsza
    ja is_prime_yes
    mov eax, ebx              ; Przywracamy liczbę
    jmp prime_check_loop

is_prime_yes:
    mov eax, 1                ; Liczba jest pierwsza
    pop edx
    pop ecx
    ret

is_prime_no:
    mov eax, 0                ; Liczba nie jest pierwsza
    pop edx
    pop ecx
    ret

; Procedura konwersji liczby na tekst
; Wejście: eax - liczba
; Wyjście: bufor wypełniony tekstem liczby zakończonym '\n'
int_to_string:
    push ebx
    push ecx
    push edx
    mov ecx, buffer + 11      ; Ustaw wskaźnik na koniec bufora
    mov byte [ecx], 10        ; Dodaj '\n' na końcu
    dec ecx                   ; Przesuń wskaźnik w lewo

.convert_loop:
    xor edx, edx              ; Zerujemy edx przed dzieleniem
    div dword [ten]           ; eax / 10, reszta w edx
    add dl, '0'               ; Zamień cyfrę na ASCII
    mov [ecx], dl             ; Zapisz cyfrę w buforze
    dec ecx                   ; Przesuń wskaźnik w lewo
    test eax, eax             ; Sprawdź, czy zostało coś do podzielenia
    jnz .convert_loop         ; Jeśli tak, kontynuuj

    inc ecx                   ; Wskaźnik na pierwszy znak liczby
    pop edx
    pop ecx
    pop ebx
    ret
