#!/bin/sh

nasm -Werror -f macho64 ft_linked_list.s -o ft_linked_list.o
nasm -Werror -f macho64 sort_fn_calls.s -o sort_fn_calls.o
cc -Wall -Wextra -Werror -arch x86_64 -c linked_list_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o sort_fn_calls.o ft_linked_list.o -o test_linked_list.out