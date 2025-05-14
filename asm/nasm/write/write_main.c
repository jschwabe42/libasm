#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>

// extern const char *const sys_errlist[];

// return -1 on error, otherwise bytes_written
extern ssize_t ft_write(int fildes, const void *buf, size_t nbyte);

int main()
{
	char write_buf[153];
	char *wptr = &write_buf[0];
	memset(&write_buf, 0, sizeof(write_buf));
	memset(&write_buf[16], '\n', 153 - 16);
	assert(ft_write(1, write_buf, 153) == 153);
	char linechars[8] = "FUCK OFF";
	for (int i = 0; i < 8; i++)
	{
		memset(wptr, linechars[i], 16);
		wptr += 17;
	}
	ft_write(1, write_buf, 153);
	int fildes = open("./testout", O_WRONLY | O_CREAT, 0644);
	assert(ft_write(fildes, write_buf, 153) != -1);
	assert(close(fildes) != -1);
	// assert(ft_write(1, write_buf, LONG_MAX + 1) == -1);
	// assert(write(1, write_buf, LONG_MAX + 1) == -1);
	fprintf(stderr, "Error: %s (errno: %d)\n", strerror(errno), errno);
	printf("EINVAL = %d\n", EINVAL);
	// fprintf(stderr, "System error message: %s\n", sys_errlist[errno]);
	perror("");
	return (0);
}