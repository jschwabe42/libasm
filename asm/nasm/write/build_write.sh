#!/bin/sh

nasm -f macho64 ft_write.s -o ft_write.o 
cc -Wall -Wextra -Werror -arch x86_64 -c write_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_write.o -o test_write.out