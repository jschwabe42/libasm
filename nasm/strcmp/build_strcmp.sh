#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_strcmp.s -o ft_strcmp.o
	clang -Wall -Wextra -Werror -arch x86_64 -c strcmp_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o ft_strcmp.o -o test_strcmp.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -Werror -f elf64 ft_strcmp.s -o ft_strcmp.o
	clang -Wall -Wextra -Werror -c strcmp_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_strcmp.o -o test_strcmp.out
fi