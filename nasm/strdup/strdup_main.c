#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern char *ft_strdup(const char *src);

int main()
{
	char *libc_empty = strdup("");
	char *libc_data = strdup("some data string");

	assert(libc_empty != NULL);
	free(libc_empty);
	free(libc_data);

	char *my_empty = ft_strdup("");
	char *my_data = ft_strdup("some data string");

	assert(my_empty != NULL);
	free(my_empty);
	free(my_data);
	printf("\nfinal boss!\n");
	char	*dup = ft_strdup("1e262\0");
	assert(dup != NULL);
	printf("\nAll tests passed %s!\n", dup);
	free(dup);
	printf("\nAll tests passed! ✅\n");
	return (0);
}