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

nasm -Werror -g -f ${FORMAT} ft_strlen.s -o ft_strlen.o
gcc -Wall -Wextra -Werror -g ${ARCH} -c strlen_main.c -o main.o
gcc -Wall -Wextra -Werror -g ${ARCH} main.o ft_strlen.o -o test_strlen.out