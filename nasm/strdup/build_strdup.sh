#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
FORMAT="macho64"
ARCH="-arch x86_64"
elif [ "$(uname)" = "Linux" ]; then
FORMAT="elf64"
ARCH=""
fi

nasm -Werror -f ${FORMAT} ft_strdup.s -o ft_strdup.o
nasm -Werror -f ${FORMAT} ../strcpy/ft_strcpy.s -o ft_strcpy.o
nasm -Werror -f ${FORMAT} ../strlen/ft_strlen.s -o ft_strlen.o
cc -Wall -Wextra -Werror ${ARCH} -c strdup_main.c -o main.o
cc -Wall -Wextra -Werror ${ARCH} main.o ft_strdup.o ft_strcpy.o ft_strlen.o -o test_strdup.out  2>/dev/null #suppress warning