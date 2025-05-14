#!/bin/sh

nasm -f elf64 ft_strlen.s -o ft_strlen.o
clang -Wall -Wextra -Werror -g3 -c strlen_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_strlen.o -o test_strlen.out