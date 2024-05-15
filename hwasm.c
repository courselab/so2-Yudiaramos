#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h> 

#define BUFFER_SIZE 512

/* Structure for an assembly instruction */
typedef struct
{
    char *instr;
    char *operand1;
    char *operand2;
} AssemblyInstruction;

/* Function prototypes */
int find_start(char *str);
int find_end(char *str);
void trim_string(char *str);
void assemble(FILE *input, FILE *output);
void write_instruction(FILE *output, AssemblyInstruction *instruction);
void finalize_binary(FILE *output);

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        printf("Usage: %s <input.S> <output.bin>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input)
    {
        perror("Error opening input file");
        return 1;
    }

    FILE *output = fopen(argv[2], "wb");
    if (!output)
    {
        perror("Error opening output file");
        fclose(input);
        return 1;
    }

    assemble(input, output);

    fclose(input);
    fclose(output);
    return 0;
}

int find_start(char *str)
{
    int start = 0;
    while (str[start] != '\0' && isspace((unsigned char)str[start]))
    {
        start++;
    }
    return start;
}

int find_end(char *str)
{
    int end = strlen(str) - 1;
    while (end >= 0)
    {
        if (str[end]=='#'){
            end--;
            break;
        }
        end--;
    }
    if (end < 0)
    {
        end = strlen(str) - 1;
    }
    while (end >= 0 && isspace((unsigned char)str[end]))
    {
        end--;
    }
    return end;
}

void trim_string(char *str)
{
    int start, end, i;

    start = find_start(str);
    end = find_end(str);

    if (start > end)
    {
        str[0] = '\0';
    }
    else
    {
        for (i = 0; start <= end; start++, i++)
        {
            str[i] = str[start];
        }
        str[i] = '\0';
    }
}

void assemble(FILE *input, FILE *output)
{
    char line[256];
    while (fgets(line, sizeof(line), input))
    {
        AssemblyInstruction inst;
        char *token = strtok(line, " ,\t\n");
        
        if (!token)
            continue;

        inst.instr = token;
        inst.operand1 = strtok(NULL, ",");
        inst.operand2 = strtok(NULL, " \t");

        trim_string(inst.instr);
        if (inst.operand1)
            trim_string(inst.operand1);
        if (inst.operand2)
            trim_string(inst.operand2);

        write_instruction(output, &inst);
    }

    finalize_binary(output);
}

void write_instruction(FILE *output, AssemblyInstruction *instruction)
{
    if (strcmp(instruction->instr, "movb") == 0)
    {
        if (strcmp(instruction->operand2, "\%ah") == 0){
            fputc(0xB4, output);
        } else{
            fputc(0xB0, output);
        }
        if (instruction->operand1[2] == 'x')
        {
            fputc((unsigned char)strtol(instruction->operand1 + 1, NULL, 0), output);
        }
        else
        {
            fputc(atoi(instruction->operand1), output);
        }
    }
    else if (strcmp(instruction->instr, "int") == 0)
    {
        fputc(0xCD, output);
        if (instruction->operand1[2] == 'x')
        {
            fputc((unsigned char)strtol(instruction->operand1 + 1, NULL, 0), output);
        }
        else
        {
            fputc(atoi(instruction->operand1), output);
        }
    }
    else if (strcmp(instruction->instr, "hlt") == 0)
    {
        fputc(0xF4, output);
    }
    else if (strcmp(instruction->instr, "jmp") == 0)
    {
        fputc(0xEB, output);
        int offset = strtol(instruction->operand1, NULL, 16) - 3;
        fputc(offset, output);
    }
}

void finalize_binary(FILE *output)
{
    long size = ftell(output);
    int i;
    for (i = size; i < 510; i++)
    {
        fputc(0, output);
    }
    fputc(0x55, output);
    fputc(0xAA, output);
}

