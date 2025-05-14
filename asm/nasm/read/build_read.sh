#!/bin/sh

nasm -f elf64 ft_read.s -o ft_read.o 
clang -Wall -Wextra -Werror -g3 -c read_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_read.o -o test_read.out