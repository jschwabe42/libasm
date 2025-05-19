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
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} -c read_main.c -o main.o
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} main.o ft_read.o -o test_read.out