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

nasm -Werror -g -f ${FORMAT} ft_atoi_base.s -o ft_atoi_base.o
nasm -Werror -g -f ${FORMAT} ../strdup/ft_strdup.s -o ft_strdup.o
nasm -Werror -g -f ${FORMAT} ../strcpy/ft_strcpy.s -o ft_strcpy.o
nasm -Werror -g -f ${FORMAT} ../strlen/ft_strlen.s -o ft_strlen.o
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} -c atoi_base_main.c -o main.o
clang -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer ${ARCH} main.o ft_atoi_base.o ft_strcpy.o ft_strdup.o ft_strlen.o -o test_atoi_base.out