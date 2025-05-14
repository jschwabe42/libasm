#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
	nasm -Werror -f macho64 ft_linked_list.s -o ft_linked_list.o
	clang -Wall -Wextra -Werror -arch x86_64 -c linked_list_main.c -o main.o
	clang -Wall -Wextra -Werror -arch x86_64 main.o sort_fn_calls.o ft_linked_list.o -o test_linked_list.out
elif [ "$(uname)" = "Linux" ]; then
	nasm -Werror -f elf64 ft_linked_list.s -o ft_linked_list.o
	clang -Wall -Wextra -Werror -c linked_list_main.c -o main.o
	clang -Wall -Wextra -Werror main.o ft_linked_list.o -o test_linked_list.out
fi