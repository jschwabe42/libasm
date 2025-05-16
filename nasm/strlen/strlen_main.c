#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <stdio.h>
#include <signal.h>

extern size_t ft_strlen(const char *str);

static jmp_buf jump_buffer;

static void signal_handler(int signum)
{
	if (signum == 11)
	{
		longjmp(jump_buffer, 1);
	}
}

int main()
{
	const char *src = "Hello, world!";
	const size_t len = ft_strlen(src);
	assert(strlen(src) == len);
	assert(strlen("") == ft_strlen(""));

	// will result in valgrind: Address 0x0 is not stack'd, malloc'd or (recently) free'd
	signal(11, signal_handler);

	if (setjmp(jump_buffer) == 0)
	{
		ft_strlen(NULL);
		fprintf(stderr, "ft_strlen(NULL) did not segfault!\n");
		abort();
	}
	return (0);
}