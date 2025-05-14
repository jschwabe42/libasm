#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <stdio.h>
#include <signal.h>

extern size_t _ft_strlen(const char *str);

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
	const size_t len = _ft_strlen(src);
	assert(strlen(src) == len);
	assert(strlen("") == _ft_strlen(""));

	signal(11, signal_handler);

	if (setjmp(jump_buffer) == 0)
	{
		_ft_strlen(NULL);
		fprintf(stderr, "ft_strlen(NULL) did not segfault!\n");
		abort();
	}
	return (0);
}