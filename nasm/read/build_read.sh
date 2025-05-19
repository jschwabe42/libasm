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

nasm -Werror -g -f ${FORMAT} ft_read.s -o ft_read.o
gcc -Wall -Wextra -Werror -g ${ARCH} -c read_main.c -o main.o
gcc -Wall -Wextra -Werror -g ${ARCH} main.o ft_read.o -o test_read.out