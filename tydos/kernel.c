/*
 *    SPDX-Copyright: 2021 Monaco F. J. <monaco@usp.br>
 *   
 *    SPDX-License-Identifier: GPL-3.0-or-later
 *
 *    This file is part of SYSeg, available at https://gitlab.com/monaco/syseg.
 */

/* This source file implements the kernel entry function 'kmain' called
   by the bootloader, and the command-line interpreter. Other kernel functions
   were implemented separately in another source file for legibility. */

#include "bios1.h"       /* For kwrite() etc.            */
#include "bios2.h"       /* For kread() etc.             */
#include "kernel.h"      /* Essential kernel functions.  */
#include "kaux.h"        /* Auxiliary kernel functions.  */

/* Kernel's entry function. */

void kmain(void)
{
  int i, j;
  
  register_syscall_handler();  /* Register syscall handler at int 0x21.*/

  splash();          /* Unnecessary splash screen.              */

  shell();           /* Invoke the command-line interpreter. */
  
  halt();            /* On exit, halt.                       */
  
}

/* Tiny Shell (command-line interpreter). */

char buffer[BUFF_SIZE];
int go_on = 1;

void shell()
{
  int i;
  clear();
  kwrite ("TinyDOS 1.0\n");

  while (go_on)
    {

      /* Read the user input. 
     Commands are single-word ASCII tokens with no blanks. */
      do
  {
    kwrite(PROMPT);
    kread (buffer);
  }
      while (!buffer[0]);

      /* Check for matching built-in commands */
      
      i=0;
      while (cmds[i].funct)
  {
    if (!strcmp(buffer, cmds[i].name))
      {
        cmds[i].funct();
        break;
      }
    i++;
  }

      /* If the user input does not match any built-in command name, just
     ignore and read the next command. If we were to execute external
     programs, on the other hand, this is where we would search for a 
     corresponding file with a matching name in the storage device, 
     load it and transfer it the execution. Left as exercise. */
      
      if (!cmds[i].funct)
  kwrite ("Command not found\n");
    }
}


/* Array with built-in command names and respective function pointers. 
   Function prototypes are in kernel.h. */

struct cmd_t cmds[] =
  {
    {"help",    f_help},     /* Print a help message.       */
    {"quit",    f_quit},     /* Exit TyDOS.                 */
    // {"exec",    f_exec},     /* Execute an example program. */
    {0, 0}
  };


/* Built-in shell command: help. */

void f_help()
{
  kwrite ("...me, Obi-Wan, you're my only hope!\n\n");
  kwrite ("   But we can try also some commands:\n");
  kwrite ("      exec    (to execute an user program example\n");
  kwrite ("      quit    (to exit TyDOS)\n");
}

void f_quit()
{
  kwrite ("Program halted. Bye.");
  go_on = 0;
}
