#ifndef KERNEL_H
#define KERNEL_H

/* Built-in shell command prototypes. */

void f_help();
void f_quit();
// void f_exec();  // Comente ou remova esta linha

#define BUFF_SIZE 256
#define PROMPT "> "

/* Command struct. */
struct cmd_t
{
  const char *name;
  void (*funct)();
};

extern struct cmd_t cmds[];

void shell(); // Adicione a declaração da função shell

#endif /* KERNEL_H */
