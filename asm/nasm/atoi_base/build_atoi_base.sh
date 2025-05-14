#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_atoi_base.s -o ft_atoi_base.o
	nasm -f macho64 ../strlen/ft_strlen.s -o ft_strlen.o
	clang -Wall -Wextra -Werror -arch x86_64 -c atoi_base_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o ft_atoi_base.o ft_strlen.o -o test_atoi_base.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -Werror -f elf64 ft_atoi_base.s -o ft_atoi_base.o
	nasm -f elf64 ../strlen/ft_strlen.s -o ft_strlen.o
	clang -Wall -Wextra -Werror -c atoi_base_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_atoi_base.o ft_strlen.o -o test_atoi_base.out
fi