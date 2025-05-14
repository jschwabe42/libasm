#!/bin/sh

nasm -f elf64 ft_strcmp.s -o ft_strcmp.o
clang -Wall -Wextra -Werror -g3 -c strcmp_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_strcmp.o -o test_strcmp.out