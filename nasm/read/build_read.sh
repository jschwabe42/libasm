#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -f ${FORMAT} ft_read.s -o ft_read.o
cc -Wall -Wextra -Werror ${ARCH} -c read_main.c -o main.o
cc -Wall -Wextra -Werror ${ARCH} main.o ft_read.o -o test_read.out  2>/dev/null #suppress warning