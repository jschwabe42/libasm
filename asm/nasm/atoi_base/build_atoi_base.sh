#!/bin/sh

nasm -Werror -f elf64 ft_atoi_base.s -o ft_atoi_base.o
nasm -f elf64 ../strlen/ft_strlen.s -o ft_strlen.o
clang -Wall -Wextra -Werror -g3 -c atoi_base_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_atoi_base.o ft_strlen.o -o test_atoi_base.out