#include <assert.h>
#include <setjmp.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// include nul terminator when copying, no len check on dst, return dst
extern char *ft_strcpy(char *dst, const char *src);

static jmp_buf jump_buffer;

static void signal_handler_ill(int signum)
{
	if (signum == SIGILL)
	{
		longjmp(jump_buffer, 1);
	}
}
static void signal_handler_bus(int signum)
{
	if (signum == SIGBUS)
	{
		longjmp(jump_buffer, 1);
	}
}

int main()
{
	char *libc_sigbus = "\0";
	char libc_sigill[1];
	char libc_big_buf[254];
	char libc_small_buf[15];
	char libc_sufficient_buf[16];
	char *libc_bigger = strdup("somebiggerthing");

	memset(&libc_big_buf, '1', 254);
	strcpy(libc_big_buf, libc_bigger);
	printf("%s\n", libc_big_buf);
	// contents (and len other than termination match)
	assert(strncmp(libc_big_buf, libc_bigger, sizeof(libc_sufficient_buf)) == 0);
	assert(strlen(libc_big_buf) == sizeof(libc_sufficient_buf) - 1);
	strcpy(libc_sufficient_buf, libc_bigger);
	// strings have the same contents
	assert(strncmp(libc_sufficient_buf, libc_bigger, sizeof(libc_sufficient_buf)) == 0);
	signal(SIGILL, signal_handler_ill);
	if (setjmp(jump_buffer) == 0)
	{
		strcpy(libc_small_buf, libc_bigger);
		strcpy(libc_sigill, libc_bigger);
		fprintf(stderr, "strcpy did not sigill!\n");
		abort();
	}
	signal(SIGBUS, signal_handler_bus);
	if (setjmp(jump_buffer) == 0)
	{
		strcpy(libc_sigbus, libc_bigger);
		fprintf(stderr, "strcpy did not sigbus!\n");
		abort();
	}
	free(libc_bigger);
	char my_big_buf[254];
	char my_sufficient_buf[16];
	char *my_bigger = strdup("somebiggerthing");
	memset(&my_big_buf, '1', 254);
	ft_strcpy(my_big_buf, my_bigger);
	printf("%s\n", my_big_buf);
	// contents (and len other than termination match)
	assert(strncmp(my_big_buf, my_bigger, sizeof(my_sufficient_buf)) == 0);
	assert(strlen(my_big_buf) == sizeof(my_sufficient_buf) - 1);
	ft_strcpy(my_sufficient_buf, my_bigger);
	// strings have the same contents
	assert(strncmp(my_sufficient_buf, my_bigger, sizeof(my_sufficient_buf)) == 0);
	//	--- DANGER! ---
	// char *my_sigbus = "\0";
	// char my_sigill[1];
	// char my_small_buf[15];
	// 	ft_strcpy(my_small_buf, my_bigger);
	// 	ft_strcpy(my_sigill, my_bigger);
	// 	ft_strcpy(my_sigbus, my_bigger);
	free(my_bigger);
	return (0);
}