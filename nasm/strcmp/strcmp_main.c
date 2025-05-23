#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern int	ft_strcmp(const char *s1, const char *s2);

int main() {
	assert(strcmp("hello, world", "hello, my precious") > 0 && ft_strcmp("hello, world", "hello, my precious") > 0);
	assert(strcmp("hello, world", "hello, zlord") < 0 && ft_strcmp("hello, world", "hello, zlord") < 0);
	assert(strcmp("hello, world", "hello, world") == 0 && ft_strcmp("hello, world", "hello, world") == 0);
	// weird if ran with valgrind or sanitizer: value of original changes
	const char	*src = "Hello, world!";
	const char	*src2 = "Hello world!";
	assert(strcmp(src, src2) && ft_strcmp(src, src2) > 0);
	assert(strcmp("", src) && ft_strcmp("", src) < 0);
	assert(strcmp(src, "") && ft_strcmp(src, "") > 0);
	assert(strcmp(src, "H") && ft_strcmp(src, "H") > 0);
	return (0);
}