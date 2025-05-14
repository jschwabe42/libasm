#!/bin/sh

nasm -f elf64 ft_strcpy.s -o ft_strcpy.o 
clang -Wall -Wextra -Werror -g3 -c strcpy_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_strcpy.o -o test_strcpy.out