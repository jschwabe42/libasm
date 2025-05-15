#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -f ${FORMAT} ft_write.s -o ft_write.o
cc -Wall -Wextra -Werror ${ARCH} -c write_main.c -o main.o
cc -Wall -Wextra -Werror ${ARCH} main.o ft_write.o -o test_write.out