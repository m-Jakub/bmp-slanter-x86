#include <stdio.h>

// prototype of the function:
unsigned int countdigits(const char *str);

// we pass the argumnets through the command line, not ask the user during execution
int main(int argc, char *argv[])
{
    for (int i = 1; i < argc; i++)
    {
        printf("%s: %u\n", argv[i], countdigits(argv[i]));
    }
}

// cc -m32 -c cntdig.c
// -c tells to create only .o (semi compiled file), no exxecutable

// check which extention for assembler is best to use in the pdf file

//