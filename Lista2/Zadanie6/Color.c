#include <stdio.h>
#include <unistd.h> 
 
int main() {
	for (int color = 0; color<16; color ++) {
		printf("\033[1;38;5;%dmHello, World!\n", color);
	} 

	 for (int color = 16; color<256; color ++) {
                printf("\033[1;38;5;%dmHello, World!\n", color);
		usleep(10000);
        }
	printf("\033[0m");
} 
