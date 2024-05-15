#include "bios.h"
#include "utils.h"

#define PROMPT "$ "        /* Prompt sign.      */
#define SIZE 20           /* Read buffer size. */

char buffer[SIZE];        /* Read buffer.      */

void hello() {
    println("Hello! Welcome to the system.");
}

int main() {
    clear();
    
    println("Boot Command 1.0");

    while (1) {
        print(PROMPT);        /* Show prompt.               */
        readln(buffer);        /* Read user input.            */

        if (buffer[0]) {        /* Execute built-in command.  */
            if (!strcmp(buffer,"help"))
                println("A Beatles's song.");
            else if (!strcmp(buffer, "hello"))
                hello();
            else 
                println("Unknown command.");
        }
    }
    
    return 0;
}

