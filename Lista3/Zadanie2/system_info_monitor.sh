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

    local scale=$(echo "scale=2; $value / $max_value" | bc)
    local num_hashes=$(echo "$scale * $bar_length" | bc | awk '{print int($1)}')

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
skip_initial=3
max_speed=10000000

############################################ GENERAL INFO #########################################
# Funkcja do wyświetlania czasu działania systemu
get_uptime() {
    local uptime=$(cat /proc/uptime | awk '{print $1}')
    
    # Zmiennoprzecinkowe operacje przy pomocy bc
    local days=$(echo "$uptime / 86400" | bc)
    local hours=$(echo "($uptime % 86400) / 3600" | bc)
    local minutes=$(echo "($uptime % 3600) / 60" | bc)
    local seconds=$(echo "$uptime % 60" | bc)
    
    echo "System uptime: ${days}d ${hours}h ${minutes}m ${seconds}s"
}

# Funkcja do wyświetlania stanu baterii
get_battery_status() {
    if [ -f "/sys/class/power_supply/BAT0/uevent" ]; then
        local battery_percent=$(grep "POWER_SUPPLY_CAPACITY=" /sys/class/power_supply/BAT0/uevent | cut -d= -f2)
        echo "Battery status: ${battery_percent}%"
    else
        echo "Battery status: N/A"
    fi
}

# Funkcja do wyświetlania obciążenia systemu
get_load_avg() {
    local load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo "System load average (1, 5, 15 min): $load_avg"
}

# Funkcja do wyświetlania aktualnego wykorzystania pamięci
get_memory_usage() {
    local mem_total=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    local mem_free=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
    
    echo "Memory usage:"
    echo "  Total memory: $(convert_size ${mem_total}000)"
    echo "  Free memory: $(convert_size ${mem_free}000)"
    echo "  Available memory: $(convert_size ${mem_available}000)"
}

################################################# CPU #################################################
# Funkcja do pobierania użycia CPU
get_cpu_usage() {
    local cpu=$1
    local stat_file="/proc/stat"
    local prev_idle prev_total curr_idle curr_total

    # Wczytanie statystyk CPU
    read -r _ user nice system idle iowait irq softirq steal guest < <(awk "NR==$((cpu+1))" $stat_file)

    curr_idle=$((idle + iowait))
    curr_total=$((user + nice + system + idle + iowait + irq + softirq + steal))

    # Sprawdzamy, czy to jest pierwszy pomiar
    if [[ -n "$prev_idle" && -n "$prev_total" ]]; then
        # Obliczanie różnicy w czasie między kolejnymi pomiarami
        idle_diff=$((curr_idle - prev_idle))
        total_diff=$((curr_total - prev_total))
        usage=$((100 * (total_diff - idle_diff) / total_diff))
        echo $usage
    else
        # Jeśli to pierwszy pomiar, nie obliczamy użycia (tylko ustawiamy wartości początkowe)
        echo "0"
    fi

    # Aktualizacja poprzednich wartości
    prev_idle=$curr_idle
    prev_total=$curr_total
}

get_cpu_frequency() {
    # Funkcja do pobierania częstotliwości CPU
    local cpu=$1
    local freq_file="/sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_cur_freq"
    
    if [ -f "$freq_file" ]; then
        cat "$freq_file"
    else
        echo "N/A"
    fi
}



while true; do
    echo ""
    echo ""
    echo "-------------------------------------- General Info --------------------------------------"
    get_uptime
    get_battery_status
    get_load_avg
    get_memory_usage

    echo""        # Wyświetlanie wyników
    echo "--------------------------------------Wi-fi stats------------------------------------------"
    
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
    

    echo "WiFi - Odbiór: $(convert_size $rx_speed), Wysłanie: $(convert_size $tx_speed)"
    echo -n "Prędkość Odbioru           |"
    draw_bar $rx_speed $max_speed
    echo -n "Prędkość Wysłania          |"
    draw_bar $tx_speed $max_speed
    echo -n "Średnia prędkość Odbioru   |"
    draw_bar $avg_rx_speed $max_speed
    echo -n "Średnia prędkość Wysłania  |"
    draw_bar $avg_tx_speed $max_speed

    # Zaktualizowanie wartości dla kolejnego pomiaru
    rx_prev=$rx_current
    tx_prev=$tx_current
    
    echo ""
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
