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
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} -c linked_list_main.c -o main.o
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} main.o ft_linked_list.o -o test_linked_list.out
# clang -Wall -Wextra -Werror ${ARCH} main.o sort_fn_calls.o ft_linked_list.o -o test_linked_list.out