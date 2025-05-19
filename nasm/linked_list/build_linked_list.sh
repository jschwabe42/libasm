#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
if [ "$(arch)" = "i386" ]; then
ARCH=""
fi
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -g -f ${FORMAT} ft_linked_list.s -o ft_linked_list.o
# nasm -Werror -f ${FORMAT} sort_fn_calls.s -o sort_fn_calls.o
gcc -Wall -Wextra -Werror -g ${ARCH} -c linked_list_main.c -o main.o
gcc -Wall -Wextra -Werror -g ${ARCH} main.o ft_linked_list.o -o test_linked_list.out
# gcc -Wall -Wextra -Werror ${ARCH} main.o sort_fn_calls.o ft_linked_list.o -o test_linked_list.out