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

nasm -Werror -g -f ${FORMAT} ft_write.s -o ft_write.o
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} -c write_main.c -o main.o
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} main.o ft_write.o -o test_write.out