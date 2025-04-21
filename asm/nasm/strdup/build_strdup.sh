#!/bin/sh

nasm -f macho64 ft_strdup.s -o ft_strdup.o
nasm -f macho64 ../strcpy/ft_strcpy.s -o ft_strcpy.o
nasm -f macho64 ../strlen/ft_strlen.s -o ft_strlen.o
cc -Wall -Wextra -Werror -arch x86_64 -c strdup_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_strdup.o ft_strcpy.o ft_strlen.o -o test_strdup.out