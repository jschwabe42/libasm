#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -f ${FORMAT} ft_linked_list.s -o ft_linked_list.o
# nasm -Werror -f ${FORMAT} sort_fn_calls.s -o sort_fn_calls.o
cc -Wall -Wextra -Werror ${ARCH} -c linked_list_main.c -o main.o
cc -Wall -Wextra -Werror ${ARCH} main.o ft_linked_list.o -o test_linked_list.out  2>/dev/null #suppress warning
# clang -Wall -Wextra -Werror ${ARCH} main.o sort_fn_calls.o ft_linked_list.o -o test_linked_list.out