#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_read.s -o ft_read.o
	clang -Wall -Wextra -Werror -arch x86_64 -c read_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o ft_read.o -o test_read.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -Werror -f elf64 ft_read.s -o ft_read.o
	clang -Wall -Wextra -Werror -c read_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_read.o -o test_read.out
fi