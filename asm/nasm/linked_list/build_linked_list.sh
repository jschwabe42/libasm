#!/bin/sh

nasm -Werror -f macho64 ft_linked_list.s -o ft_linked_list.o
cc -Wall -Wextra -Werror -arch x86_64 -c linked_list_main.c -o main.o
cc -Wall -Wextra -Werror -arch x86_64 main.o ft_linked_list.o -o test_linked_list.out