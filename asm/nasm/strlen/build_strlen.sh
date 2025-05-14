#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_strlen.s -o ft_strlen.o
	clang -Wall -Wextra -Werror -arch x86_64 -c strlen_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o ft_strlen.o -o test_strlen.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -Werror -f elf64 ft_strlen.s -o ft_strlen.o
	clang -Wall -Wextra -Werror -c strlen_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_strlen.o -o test_strlen.out
fi