## Directory Handling:
        If no directory argument is provided, the script uses the current directory (.).
        If a directory argument is provided, it changes to that directory.

## File Iteration:
        The script iterates over all files in the directory using for file in *.
        It checks if the item is a file with [ -f "$file" ], ignoring directories.
## Renaming Logic:
        It converts the filename to lowercase using new_file=$(echo "$file" | tr '[:upper:]' '[:lower:]').
        If the original filename differs from the lowercase version, it renames the file with mv -- "$file" "$new_file".

### Key Commands

    tr '[:upper:]' '[:lower:]': Translates uppercase letters to lowercase.
    mv --: Renames files, with -- ensuring filenames with special characters are handled safely
