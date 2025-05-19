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

nasm -Werror -g -f ${FORMAT} ft_strdup.s -o ft_strdup.o
nasm -Werror -g -f ${FORMAT} ../strcpy/ft_strcpy.s -o ft_strcpy.o
nasm -Werror -g -f ${FORMAT} ../strlen/ft_strlen.s -o ft_strlen.o
gcc -Wall -Wextra -Werror -g ${ARCH} -c strdup_main.c -o main.o
gcc -Wall -Wextra -Werror -g ${ARCH} main.o ft_strdup.o ft_strcpy.o ft_strlen.o -o test_strdup.out