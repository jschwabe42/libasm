#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_strcpy.s -o ft_strcpy.o
	clang -Wall -Wextra -Werror -arch x86_64 -c strcpy_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o ft_strcpy.o -o test_strcpy.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -Werror -f elf64 ft_strcpy.s -o ft_strcpy.o
	clang -Wall -Wextra -Werror -c strcpy_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_strcpy.o -o test_strcpy.out
fi