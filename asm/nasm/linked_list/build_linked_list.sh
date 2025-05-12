#!/bin/sh

nasm -Werror -f elf64 ft_linked_list.s -o ft_linked_list.o
clang -Wall -Wextra -Werror -g3 -c linked_list_main.c -o main.o
clang -Wall -Wextra -Werror -g3 main.o ft_linked_list.o -o test_linked_list.out