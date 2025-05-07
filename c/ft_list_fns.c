#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct s_list
{
	void			*data;
	struct s_list	*next;
}	t_list;

t_list  *ft_create_elem(void *data) {
	// clean direct field copy
	// const t_list template = (struct s_list){.data = data, .next = NULL};
	// t_list	*new = malloc(sizeof(t_list));
	// if (new == NULL) {
		// 	return NULL;
	// }
	// memcpy(new, &template, sizeof(t_list));
	// simple non-stack memory
	t_list	*new = malloc(sizeof(t_list));
	if (new != NULL) {
		new->data = data;
		new->next = NULL;
	}
	return new;
}

int	main() {
	// element creation
	char	*somedata = strdup("my_secret at 0x0");
	const t_list template = (struct s_list){.data = somedata, .next = NULL};
	t_list	*created = ft_create_elem(somedata);
	assert(created != NULL);
	assert(created->data == template.data);
	assert(created->next == template.next);
	fprintf((stderr), "data contained matches: %s\n", (char *)created->data);
	free(created);
	free(somedata);
	// push element
}
/*
dep: t_list *ft_create_elem(void *data);
	creates a new element of t_list.
	- It should assign data to the given argument and next to NULL.

adds a new element (t_list) to the beginning of the list
- It should assign data to the given argument.
- If necessary, it will update the pointer at the beginning of the list.
*/
void	ft_list_push_front(t_list **begin_list, void *data);
int		ft_list_size(t_list *begin_list);

/*
sorts the list elements in ascending order
by comparing two elements and their data using a comparison function

(*cmp)(list_ptr->data, list_other_ptr->data); (cmp such as strcmp)
*/
t_list	*ft_list_sort(t_list* lst, int (*cmp)());

/*
removes from the list all elements whose data,
when compared to data_ref using cmp, causes cmp to return 0
The data from an element to be erased should be freed using free_fct.

(*cmp)(list_ptr->data, data_ref);
(*free_fct)(list_ptr->data);
*/
void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(), void (*free_fct)(void *));
