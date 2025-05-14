#!/bin/sh

nasm -f elf64 ft_strdup.s -o ft_strdup.o
nasm -f elf64 ../strcpy/ft_strcpy.s -o ft_strcpy.o
nasm -f elf64 ../strlen/ft_strlen.s -o ft_strlen.o
clang -Wall -Wextra -Werror -g3 -c strdup_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_strdup.o ft_strcpy.o ft_strlen.o -o test_strdup.out