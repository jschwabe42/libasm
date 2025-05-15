#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_strdup.s -o ft_strdup.o
	nasm -Werror -f macho64 ../strcpy/ft_strcpy.s -o ft_strcpy.o
	nasm -Werror -f macho64 ../strlen/ft_strlen.s -o ft_strlen.o
	clang -Wall -Wextra -Werror -arch x86_64 -c strdup_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o ft_strdup.o ft_strcpy.o ft_strlen.o -o test_strdup.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -f elf64 ft_strdup.s -o ft_strdup.o
	nasm -f elf64 ../strcpy/ft_strcpy.s -o ft_strcpy.o
	nasm -f elf64 ../strlen/ft_strlen.s -o ft_strlen.o
	clang -Wall -Wextra -Werror -c strdup_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_strdup.o ft_strcpy.o ft_strlen.o -o test_strdup.out
fi