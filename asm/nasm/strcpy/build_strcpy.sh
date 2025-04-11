#!/bin/sh

nasm -f macho64 ft_strcpy.s -o ft_strcpy.o 
cc -Wall -Wextra -Werror -arch x86_64 -c strcpy_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_strcpy.o -o test_strcpy.out