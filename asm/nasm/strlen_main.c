#include <assert.h>
#include <stdlib.h>
#include <string.h>

extern size_t	ft_strlen(const char *str);

int main() {
	const char	*src = "Hello, world!";
	const size_t		len = ft_strlen(src);
	assert(strlen(src) == len);
	return (0);
}