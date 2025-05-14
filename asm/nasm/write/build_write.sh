#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_write.s -o ft_write.o
	clang -Wall -Wextra -Werror -arch x86_64 -c write_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o ft_write.o -o test_write.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -Werror -f elf64 ft_write.s -o ft_write.o
	clang -Wall -Wextra -Werror -c write_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_write.o -o test_write.out
fi