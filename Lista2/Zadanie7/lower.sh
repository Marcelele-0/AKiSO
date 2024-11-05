#!/bin/bash

# Set the directory to current if no argument is provided
if [ -z "$1" ]; then
    directory="."
else
    directory="$1"
fi

# Change to the specified directory
cd "$directory" || exit

# Loop through all files in the directory
for file in *; do
    # Check if it is a file (skip directories)
    if [ -f "$file" ]; then
        # Create a new file name by converting to lowercase
        new_file=$(echo "$file" | tr '[:upper:]' '[:lower:]')
        
        # Rename the file if the name is different
        if [ "$file" != "$new_file" ]; then
            mv -- "$file" "$new_file"
        fi
    fi
done
