#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

extern size_t ft_strlen(const char *str);

int main()
{
	assert(ft_strlen("hello, world") == strlen("hello, world"));
	printf("linkable binary (from c) works!\n");
}