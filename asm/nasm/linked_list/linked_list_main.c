#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// @note for c only!
// @todo define in asm
typedef struct s_list
{
	void			*data;
	struct s_list	*next;
}	t_list;

extern t_list	*ft_create_elem(void *data);// @note testing only!
extern void		*ft_list_push_front(t_list **begin_list, void *data);
extern int		ft_list_size(t_list *begin_list);
extern void		ft_list_sort(t_list** lst, int (*cmp)(void *, void *));
// extern void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(void *, void *), void (*free_fct)(void *));

// @audit-info testing utils
// integer
int	cmp_bubble(void *ptr_a, void *ptr_b) {
	const int	a = *(int *)ptr_a;
	const int	b = *(int *)ptr_b;
	return a - b;
}
int	not_cmp(void *ptr_a, void *ptr_b) {
	return cmp_bubble(ptr_b, ptr_a);
}
int	strcmp_adapter(void *a, void *b) {
	return strcmp((const char *)a, (const char *)b);
}
// boolean
int	cmp_is_equal_or_data_null(void *data, void *cmp) {
	if (((data && cmp) && *(int *)data == *(int *)cmp) || !cmp) {
		return 0;
	}
	return 1;
}
int	is_modulo(void *ptr_a, void *ptr_b) {
	const int	a = *(int *)ptr_a;
	const int	b = *(int *)ptr_b;
	return a % b != 0;
}
void	free_nothing(void *sth) {
	(void)sth;
}
void	helper_free_list_data(t_list *begin_list, void (*free_fct)(void *)) {
	assert(begin_list != NULL);
	t_list	*cur = begin_list;
	while (cur) {
		t_list	*next = cur->next;
		free_fct(cur->data);
		free(cur);
		if (!next) {
			break;
		}
		cur = next;
	}
}
int		c_list_size(t_list *begin_list) {
	t_list	*cur = begin_list; // local: could just use begin_list
	int	len = 0;
	while (cur && ++len) {
		cur = cur->next;
	}
	return len;
}

int	main() {
	// element creation
	char	*somedata = strdup("HAS_TO_BE_END");
	const t_list template = (struct s_list){.data = somedata, .next = NULL};
	t_list	*created_first = ft_create_elem(somedata);
	assert(ft_list_size(NULL) == c_list_size(NULL));
	assert(ft_list_size(created_first) == c_list_size(created_first));
	assert(created_first != NULL);
	assert(created_first->data == template.data);
	assert(created_first->next == template.next);
	// push element
	t_list	**dbl_ptr = calloc(sizeof(t_list *), 1);
	*dbl_ptr = created_first;
	assert((dbl_ptr) != NULL);
	char	*nowfirstdata = strdup("START");
	fprintf((stderr), "DBL: **%p has - *%p\n", dbl_ptr, *dbl_ptr);
	fprintf((stderr), "created_first: %s at %p in - *%p\n", (char *)((*dbl_ptr)->data), ((*dbl_ptr)->data), *dbl_ptr);
	fprintf((stderr), "pushing...:\n");
	ft_list_push_front(dbl_ptr, nowfirstdata);
	assert(*dbl_ptr != NULL);
	assert(((*dbl_ptr)->next) != NULL);
	assert(((*dbl_ptr)->next->next) == NULL);
	assert(ft_list_size(*dbl_ptr) == c_list_size(*dbl_ptr));
	fprintf((stderr), "DBL: **%p\n", dbl_ptr);
	fprintf((stderr), "first: %s at *%p in %p - next: %p\n", (char *)((*dbl_ptr)->data),((*dbl_ptr)->data), *dbl_ptr, (*dbl_ptr)->next);
	fprintf((stderr), "second: %s at %p in %p - next: %p\n", (char *)((*dbl_ptr)->next->data), ((*dbl_ptr)->next->data), ((*dbl_ptr)->next),(*dbl_ptr)->next->next);
	assert(created_first->next == NULL);

	helper_free_list_data(*dbl_ptr, free);
	free(dbl_ptr);
}