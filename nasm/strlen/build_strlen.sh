#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -f ${FORMAT} ft_strlen.s -o ft_strlen.o
cc -Wall -Wextra -Werror ${ARCH} -c strlen_main.c -o main.o
cc -Wall -Wextra -Werror ${ARCH} main.o ft_strlen.o -o test_strlen.out