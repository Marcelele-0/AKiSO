#!/bin/bash

############################################### WIFI ################################################
# Funkcja do konwersji rozmiaru na przyjazną jednostkę
convert_size() {
    local size=$1
    if [ $size -ge 1073741824 ]; then
        echo "$(echo "$size / 1073741824" | bc) GB"
    elif [ $size -ge 1048576 ]; then
        echo "$(echo "$size / 1048576" | bc) MB"
    elif [ $size -ge 1024 ]; then
        echo "$(echo "$size / 1024" | bc) KB"
    else
        echo "$size B"
    fi
}

# Funkcja do rysowania wykresu słupkowego
draw_bar() {
    local value=$1
    local max_value=$2
    local bar_length=50  # Długość wykresu
    local bar="#"

    # Obliczenie proporcji dla wykresu
    local scale=$(echo "scale=2; $value / $max_value" | bc)
    local num_hashes=$(echo "$scale * $bar_length" | bc | awk '{print int($1)}')

    # Rysowanie wykresu
    for ((i = 0; i < $num_hashes; i++)); do
        echo -n "$bar"
    done
    echo ""
}

# Inicjalizacja zmiennych
rx_prev=0
tx_prev=0
rx_total=0
tx_total=0
count=0
skip_initial=3  # Liczba początkowych pomiarów do pominięcia

max_speed=10000000  # Zmienna max_speed do rysowania wykresów (maksymalna prędkość w B/s)


########################################################## CPU ########################################################


# Funkcja do pobierania użycia CPU
get_cpu_usage() {
    local cpu=$1
    local stat_file="/proc/stat"
    local prev_idle prev_total curr_idle curr_total

    # Wczytanie statystyk CPU
    read -r _ user nice system idle iowait irq softirq steal guest < <(awk "NR==$((cpu+1))" $stat_file)

    curr_idle=$((idle + iowait))
    curr_total=$((user + nice + system + idle + iowait + irq + softirq + steal))

    if [[ -n "$prev_idle" && -n "$prev_total" ]]; then
        # Obliczanie różnicy w czasie między kolejnymi pomiarami
        idle_diff=$((curr_idle - prev_idle))
        total_diff=$((curr_total - prev_total))
        usage=$((100 * (total_diff - idle_diff) / total_diff))
        echo $usage
    fi

    # Aktualizacja poprzednich wartości
    prev_idle=$curr_idle
    prev_total=$curr_total
}

# Funkcja do pobierania częstotliwości CPU
get_cpu_frequency() {
    local cpu=$1
    local freq_file="/sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_cur_freq"
    
    if [ -f "$freq_file" ]; then
        cat "$freq_file"
    else
        echo "N/A"
    fi
}

###########################################################    ###########################################################





# Pętla pomiarów
while true; do
    # Odczyt danych z /proc/net/dev
    net_data=$(cat /proc/net/dev | grep "wlp4s0")
    
    # Odczytanie wartości bytes dla odbioru i wysyłania
    rx_current=$(echo $net_data | awk '{print $2}')
    tx_current=$(echo $net_data | awk '{print $10}')
    
    # Obliczenie różnicy w bajtach od poprzedniego pomiaru
    rx_diff=$((rx_current - rx_prev))
    tx_diff=$((tx_current - tx_prev))
    
    # Pomijanie początkowych kilku pomiarów (na przykład 3 pierwsze)
    if ((count < skip_initial)); then
        rx_prev=$rx_current
        tx_prev=$tx_current
        count=$((count + 1))
        sleep 1
        continue
    fi
    
    # Zaktualizowanie łącznych danych
    rx_total=$((rx_total + rx_diff))
    tx_total=$((tx_total + tx_diff))
    
    # Zwiększenie liczby pomiarów
    count=$((count + 1))
    
    # Obliczenie prędkości w B/s
    rx_speed=$rx_diff
    tx_speed=$tx_diff
    
    # Obliczenie średniej prędkości
    avg_rx_speed=$((rx_total / count))
    avg_tx_speed=$((tx_total / count))
    
    # Wyświetlanie wyników
    echo "--------------------------------------Wi-fi stats------------------------------------------"
    echo "WiFi - Odbiór: $(convert_size $rx_speed), Wysłanie: $(convert_size $tx_speed)"
    echo -n "Prędkość Odbioru: "
    draw_bar $rx_speed $max_speed
    echo -n "Prędkość Wysłania: "
    draw_bar $tx_speed $max_speed
    echo -n "Średnia prędkość Odbioru: "
    draw_bar $avg_rx_speed $max_speed
    echo -n "Średnia prędkość Wysłania: "
    draw_bar $avg_tx_speed $max_speed

    # Zaktualizowanie wartości dla kolejnego pomiaru
    rx_prev=$rx_current
    tx_prev=$tx_current
    

    echo "--------------------------------------CPU Stats------------------------------------------"
    
    # Liczba rdzeni
    num_cores=$(nproc)

    # Dla każdego rdzenia CPU
    for ((i=0; i<num_cores; i++)); do
        cpu_usage=$(get_cpu_usage $i)
        cpu_freq=$(get_cpu_frequency $i)

        echo -n "CPU$i - Wykorzystanie: $cpu_usage%, Częstotliwość: $cpu_freq kHz"
        echo
    done
   
    # Poczekanie 1 sekundę przed kolejnym pomiarem
    sleep 1
done
