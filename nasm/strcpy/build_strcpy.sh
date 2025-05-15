#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -f ${FORMAT} ft_strcpy.s -o ft_strcpy.o
cc -Wall -Wextra -Werror ${ARCH} -c strcpy_main.c -o main.o
cc -Wall -Wextra -Werror ${ARCH} main.o ft_strcpy.o -o test_strcpy.out  2>/dev/null #suppress warning