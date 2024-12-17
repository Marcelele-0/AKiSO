section .bss
    input resb 12       ; Bufor na wczytaną liczbę (max 11 znaków + \0)
    sum   resd 1        ; Przechowywana suma cyfr

section .data
    prompt db "Podaj liczbę: ", 0
    result_msg1 db "Suma cyfr w: ", 0
    newline db 0xA, 0

section .text
    global _start

_start:
    ; Wyświetl komunikat
    mov eax, 4          ; write syscall
    mov ebx, 1          ; file descriptor (stdout)
    mov ecx, prompt     ; adres tekstu
    mov edx, 14         ; długość tekstu
    int 0x80

    ; Wczytaj liczbę
    mov eax, 3          ; read syscall
    mov ebx, 0          ; file descriptor (stdin)
    mov ecx, input      ; bufor
    mov edx, 12         ; max liczba bajtów
    int 0x80

    ; Oblicz sumę cyfr
    xor ebx, ebx        ; suma = 0
    xor ecx, ecx        ; indeks = 0

sum_loop:
    mov al, [input + ecx] ; wczytaj znak
    cmp al, 0xA          ; czy nowa linia?
    je print_result      ; jeśli tak, zakończ pętlę
    sub al, '0'          ; konwertuj znak na cyfrę
    add ebx, eax         ; dodaj cyfrę do sumy
    inc ecx              ; przejdź do następnego znaku
    jmp sum_loop

print_result:
    mov [sum], ebx      ; zapisz sumę

    ; Wyświetl komunikat wyniku
    mov eax, 4          ; write syscall
    mov ebx, 1          ; file descriptor (stdout)
    mov ecx, result_msg ; adres tekstu
    mov edx, 12         ; długość tekstu
    int 0x80

    ; Konwersja sumy na tekst i wyświetlenie
    mov eax, [sum]      ; wczytaj sumę
    call int_to_ascii   ; konwertuj na ASCII
    mov eax, 4          ; write syscall
    mov ebx, 1          ; file descriptor (stdout)
    mov ecx, input      ; wynikowa liczba w buforze
    mov edx, 12         ; długość (maksymalnie 12 znaków)
    int 0x80

    ; Dodaj nową linię
    mov eax, 4          ; write syscall
    mov ebx, 1          ; file descriptor (stdout)
    mov ecx, newline    ; tekst nowej linii
    mov edx, 1          ; długość 1 bajt
    int 0x80

    ; Wyjdź z programu
    mov eax, 1          ; exit syscall
    xor ebx, ebx        ; kod wyjścia = 0
    int 0x80

; Funkcja konwertująca liczbę na ASCII
; Argument: eax - liczba
; Wynik: input - tekst reprezentujący liczbę
int_to_ascii:
    mov ecx, 10         ; baza dziesiętna
    lea esi, [input + 11] ; wskaźnik na koniec bufora
    mov byte [esi], 0   ; zakończ string null-terminatorem

convert_loop:
    xor edx, edx        ; zeruj edx przed div
    div ecx             ; eax / 10, reszta w edx
    add dl, '0'         ; konwertuj resztę na ASCII
    dec esi             ; przesuwaj wskaźnik w lewo
    mov [esi], dl       ; zapisz znak
    test eax, eax       ; czy liczba się skończyła?
    jnz convert_loop    ; jeśli nie, kontynuuj

    ret
