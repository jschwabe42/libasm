#!/bin/sh

nasm -f elf64 ft_write.s -o ft_write.o 
clang -Wall -Wextra -Werror -g3 -c write_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_write.o -o test_write.out