// boot.c

void main() {
    char *video_memory = (char*) 0xB8000; // Pointer to video memory
    char *message = "Hello, World!"; // Message to display
    
    unsigned char colors[] = {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // Background colors with black text
        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, // Background colors with bright text
        0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, // Additional colors (depends on mode)
        0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F  // Even more colors
    };

    int color_count = sizeof(colors) / sizeof(colors[0]); // Number of available colors
    int message_length = 14; // Length of the message (including the null terminator)
    
    // Loop through all background and foreground color combinations
    for (int bg = 0; bg < color_count; bg++) {
        for (int fg = 0; fg < color_count; fg++) {
            unsigned char color = (bg << 4) | fg; // Combine background and foreground colors
            
            // Calculate the starting position in video memory for the current color combination
            int offset = (bg * color_count + fg) * 160; // 160 bytes per line for text mode

            // Write the message to video memory with the current color
            for (int i = 0; i < message_length; i++) {
                video_memory[offset + i * 2] = message[i]; // Character
                video_memory[offset + i * 2 + 1] = color; // Color attribute
            }
        }
    }

    while(1); // Infinite loop to keep the program running
}
