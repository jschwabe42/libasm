#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// mandatory
extern size_t	ft_strlen(const char *str);
extern int		ft_strcmp(const char *s1, const char *s2);
extern char		*ft_strdup(const char *src);
extern char		*ft_strcpy(char *dst, const char *src);
extern ssize_t	ft_read(int fildes, const void *buf, size_t nbyte);
extern ssize_t	ft_write(int fildes, const void *buf, size_t nbyte);
// bonus
extern int		ft_atoi_base(char *str, char *base);
typedef struct s_list
{
	void			*data;
	struct s_list	*next;
}	t_list;
extern void		ft_list_push_front(t_list **begin_list, void *data);
extern int		ft_list_size(t_list *begin_list);
extern void		ft_list_sort(t_list** lst, int (*cmp)(void *, void *));
extern void		ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(void *, void *), void (*free_fct)(void *));


int main()
{
	// function from mandatory
	assert(ft_strlen("hello, world") == strlen("hello, world"));
	// something that does a syscall
	ft_write(1, "\ngreetings from: write\n\n", 25);
	// something that calls malloc
	char	*dup = ft_strdup("1e262");
	assert(dup != NULL);
	// function from bonus (compile with...)
	assert(ft_atoi_base(dup, "0123456789abcdef") == 123490);
	free(dup);
	printf("linkable binary (from c) works!\n");
}