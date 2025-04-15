#include <_strings.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>

// return -1 on error, otherwise bytes_read
extern ssize_t ft_read(int fildes, const void *buf, size_t nbyte);

int main()
{
	char write_buf[153];
	char	*wptr = &write_buf[0];
	memset(&write_buf[16], '\n', 153 - 16);
	write(1, write_buf, 153);
	char linechars[8] = "FUCK OFF";
	for (int i = 0; i < 8; i++) {
		memset(wptr, linechars[i], 16);
		wptr += 17;
	}
	write(1, write_buf, 153);
	int fildes = open("./testout.txt", O_RDWR | O_CREAT, 0644);
	write(fildes, write_buf, 153);
	char	read_buf[1024];
	bzero(read_buf, 1024);

	// Reset file position to beginning before reading
	lseek(fildes, 0, SEEK_SET);

	assert(ft_read(fildes, read_buf, sizeof(read_buf)) > 0);
	close(fildes);
	int fildes_copy = open("./test_copy.txt", O_WRONLY | O_CREAT, 0644);
	write(fildes_copy, read_buf, 153);
	close(fildes_copy);
	// file contents match
	assert(system("diff ./testout.txt ./test_copy.txt") == 0);
	// nbyte <= INT_MAX
	assert(ft_read(0, read_buf, LONG_MAX + 1) == -1);
	return (0);
}