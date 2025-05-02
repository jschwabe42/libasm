#!/bin/sh

nasm -f macho64 ft_atoi_base.s -o ft_atoi_base.o
nasm -f macho64 ../strlen/ft_strlen.s -o ft_strlen.o
cc -Wall -Wextra -Werror -arch x86_64 -c atoi_base_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_atoi_base.o ft_strlen.o -o test_atoi_base.out