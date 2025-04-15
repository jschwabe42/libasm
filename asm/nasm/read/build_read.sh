#!/bin/sh

nasm -f macho64 ft_read.s -o ft_read.o 
cc -Wall -Wextra -Werror -arch x86_64 -c read_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_read.o -o test_read.out