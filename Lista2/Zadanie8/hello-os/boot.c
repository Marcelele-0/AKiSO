// boot.c

void main() {
    char *video_memory = (char*) 0xB8000; // Pointer to video memory
    char *message = "Hello, World!"; // Message to display
    
    // Length of the message (including the null terminator)
    int message_length = 14;

    // Loop through all possible background colors (0 to 15)
    for (unsigned char bg = 0; bg < 16; bg++) {
        // Loop through all possible foreground colors (0 to 15)
        for (unsigned char fg = 0; fg < 16; fg++) {
            unsigned char color = (bg << 4) | fg; // Combine background and foreground colors
            
            // Calculate the starting position in video memory for the current color combination
            int offset = (bg * 16 + fg) * 160; // 160 bytes per line for text mode

            // Write the message to video memory with the current color
            for (int i = 0; i < message_length; i++) {
                video_memory[offset + i * 2] = message[i]; // Character
                video_memory[offset + i * 2 + 1] = color; // Color attribute
            }
        }
    }

    while(1); // Infinite loop to keep the program running
}
