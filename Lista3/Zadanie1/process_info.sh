#!/bin/bash

# Print the header
printf "%-6s %-6s %-40s %-9s %-6s %-7s %-7s %-6s %-6s\n" "PPID" "PID" "COMM" "STATE" "TTY" "RSS" "PGID" "SID" "OPEN_FILES"

# Iterate over all numeric directories in /proc (representing process IDs)
for pid in /proc/[0-9]*; do
  # Extract PID from the directory name
  pid_number=$(basename "$pid")

  # Check if /proc/PID/status and /proc/PID/stat exist to avoid errors
  if [[ -f "$pid/status" && -f "$pid/stat" ]]; then
    # Read necessary fields from /proc/PID/status
    ppid=$(grep -m 1 '^PPid:' "$pid/status" | awk '{print $2}')
    comm=$(grep -m 1 '^Name:' "$pid/status" | awk '{print $2}')
    rss=$(grep -m 1 '^VmRSS:' "$pid/status" | awk '{print $2}')
    pgid=$(awk '{print $5}' "$pid/stat")
    sid=$(awk '{print $6}' "$pid/stat")

    # Read the state and tty from /proc/PID/stat
    state=$(awk '{print $3}' "$pid/stat")
    tty_nr=$(awk '{print $7  }' "$pid/stat")
    
    # Convert tty number to human-readable format
    tty=$(ps -p "$pid_number" -o tty=)
    if [ -z "$tty" ]; then
       tty="?"
    fi

    # Count the number of open files
    open_files=$(ls -1q /proc/$pid_number/fd 2>/dev/null | wc -l)

    # Print the formatted output
    printf "%-10s %-10s %-20s %-10s %-10s %-10s %-10s %-10s %-10s\n" "$ppid" "$pid_number" "$comm" "$state" "$tty" "${rss:-0}" "$pgid" "$sid" "$open_files"
  fi
done | column -t
