#!/bin/sh

nasm -f macho64 ft_strlen.s -o ft_strlen.o
cc -Wall -Wextra -Werror -arch x86_64 -c strlen_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_strlen.o -o test_strlen