#!/bin/sh

nasm -f macho64 ft_strcmp.s -o ft_strcmp.o
cc -Wall -Wextra -Werror -arch x86_64 -c strcmp_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_strcmp.o -o test_strcmp.out