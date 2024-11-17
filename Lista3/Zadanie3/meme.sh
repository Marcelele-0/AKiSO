#!/bin/bash

# Sprawdzanie, czy wymagane narzędzia są zainstalowane
if ! command -v curl &> /dev/null; then
    echo "curl nie jest zainstalowany. Zainstaluj go komendą: sudo pacman -S curl"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq nie jest zainstalowany. Zainstaluj go komendą: sudo pacman -S jq"
    exit 1
fi

if ! command -v img2txt &> /dev/null && ! command -v catimg &> /dev/null; then
    echo "img2txt ani catimg nie są zainstalowane. Zainstaluj jeden z nich komendą: sudo pacman -S libcaca lub catimg"
    exit 1
fi

# Pobieranie losowego obrazka z The Cat API
cat_image_url=$(curl -s https://api.thecatapi.com/v1/images/search | jq -r '.[0].url')

# Pobieranie losowego cytatu z Chuck Norris API
chuck_joke=$(curl -s https://api.chucknorris.io/jokes/random | jq -r '.value')

# Pobieranie i wyświetlanie obrazka
echo "Pobieranie obrazka z The Cat API..."
if command -v img2txt &> /dev/null; then
    curl -s "$cat_image_url" | img2txt -W 80
elif command -v catimg &> /dev/null; then
    curl -s "$cat_image_url" -o cat_image.jpg
    catimg cat_image.jpg
    rm cat_image.jpg
fi

# Wyświetlanie cytatu
echo -e "\n--------------------------------------"
echo "Losowy cytat z Chuck Norris API:"
echo "$chuck_joke"
echo "--------------------------------------"
