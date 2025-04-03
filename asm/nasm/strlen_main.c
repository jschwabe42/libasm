#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <stdio.h>

extern size_t	ft_strlen(const char *str);

static jmp_buf jump_buffer;

static void signal_handler(int signum) {
    if (signum == SIGSEGV) {
        longjmp(jump_buffer, 1);
    }
}

int main() {
	const char	*src = "Hello, world!";
	const size_t		len = ft_strlen(src);
	assert(strlen(src) == len);
	assert(strlen("") == ft_strlen(""));

    signal(SIGSEGV, signal_handler);

    if (setjmp(jump_buffer) == 0) {
        ft_strlen(NULL);
        fprintf(stderr, "ft_strlen(NULL) did not segfault!\n");
        abort();
    }
	return (0);
}