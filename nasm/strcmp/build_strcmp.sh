#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -f ${FORMAT} ft_strcmp.s -o ft_strcmp.o
cc -Wall -Wextra -Werror ${ARCH} -c strcmp_main.c -o main.o
cc -Wall -Wextra -Werror ${ARCH} main.o ft_strcmp.o -o test_strcmp.out  2>/dev/null #suppress warning