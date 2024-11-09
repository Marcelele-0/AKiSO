## How?

The ANSI escape sequence \033[1;38;5;%dm is used to change the foreground color.

\033: This is the escape character, which starts the escape sequence.
    
[1;38;5;%dm: This part is the actual escape sequence for setting the color:
       -  1 sets the text style to bold.
       -  38 indicates setting the foreground color.
       -  5 tells the terminal that you are specifying a color from a 256-color palette.
       -  %d is where the color number (from color) will be substituted. In this case, it will range from 0 to 15, corresponding to the basic 16 colors.

	
\033[0m is the escape sequence to reset the color back to the default terminal color. After all the colors have been printed, this ensures that any text printed afterward will use the terminal's default settings.
