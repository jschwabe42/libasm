#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

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
/*
dep: t_list *ft_create_elem(void *data);
creates a new element of t_list.
- It should assign data to the given argument and next to NULL.

adds a new element (t_list) to the beginning of the list
- It should assign data to the given argument.
- If necessary, it will update the pointer at the beginning of the list.
*/
void	ft_list_push_front(t_list **begin_list, void *data) {
	t_list	*new_front = ft_create_elem(data);
	if (new_front) {
		new_front->next = *begin_list;
	}
	// @audit-info sets NULL on failed allocation
	*begin_list = new_front;
}

void	helper_free_list_data(t_list *begin_list) {
	assert(begin_list != NULL);
	t_list	*cur = begin_list;
	while (cur) {
		t_list	*next = cur->next;
		free(cur->data);
		free(cur);
		if (!next) {
			break;
		}
		cur = next;
	}
}

int		ft_list_size(t_list *begin_list) {
	t_list	*cur = begin_list; // local: could just use begin_list
	int	len = 0;
	while (cur && ++len) {
		cur = cur->next;
	}
	return len;
}

void	ft_list_sort(t_list** lst, int (*cmp)(void *, void *));
int	cmp_bubble(void *ptr_a, void *ptr_b) {
	const int	a = *(int *)ptr_a;
	const int	b = *(int *)ptr_b;
	return a - b;
}

void	test_list_sort() {
	int	arr[5] = {5, 4, 3, 2, 1};
	int	arr_ordered[5] = {1, 2, 3, 4 ,5};
	t_list	**dbl_ptr = malloc(sizeof(t_list));
	// @audit-info since prepended arr_ordered used
	t_list	*last = ft_create_elem(&arr_ordered[0]);
	*dbl_ptr = last;
	for (int i = 1; i < 5; i++) {
		// @audit-info since prepended arr_ordered used
		ft_list_push_front(dbl_ptr, &arr_ordered[i]);
	}
	t_list	*print = *dbl_ptr;
	for (int i = 0; i < 5; i++) {
		fprintf(stderr, "%d\n", *(int *)print->data);
		print = print->next;
	}
}

int	main() {
	// element creation
	char	*somedata = strdup("my_secret at 0x0");
	const t_list template = (struct s_list){.data = somedata, .next = NULL};
	t_list	*created = ft_create_elem(somedata);
	assert(ft_list_size(NULL) == 0);
	assert(ft_list_size(created) == 1);
	assert(created != NULL);
	assert(created->data == template.data);
	assert(created->next == template.next);
	fprintf((stderr), "data contained matches: %s\n", (char *)created->data);
	// push element
	t_list	**dbl_ptr = malloc(sizeof(t_list));
	assert((dbl_ptr) != NULL);
	*dbl_ptr = created;
	char	*nowfirstdata = strdup("should be the first elem: lemme tell you about my friend!");
	ft_list_push_front(dbl_ptr, nowfirstdata);
	fprintf((stderr), "first elem: %s\n", (char *)((*dbl_ptr)->data));
	fprintf((stderr), "second elem: %s\n", (char *)((*dbl_ptr)->next->data));
	assert(((*dbl_ptr)->next) != NULL);
	assert(((*dbl_ptr)->next->next) == NULL);
	assert(ft_list_size(*dbl_ptr) == 2);
	// free((*dbl_ptr)->next);
	// free(*dbl_ptr);
	// free(somedata);
	// free(nowfirstdata);
	helper_free_list_data(*dbl_ptr);
	free(dbl_ptr);
	test_list_sort();
}

/*
sorts the list elements in ascending order
by comparing two elements and their data using a comparison function

(*cmp)(list_ptr->data, list_other_ptr->data); (cmp such as strcmp)
*/
void	ft_list_sort(t_list** lst, int (*cmp)(void *, void *)) {
	// @audit check head movement!
	// basically bubble sort
	t_list	*cur = *lst;
	t_list	*next = (*lst)->next;
	// int should_do = (*cmp)(list_ptr->data, list_other_ptr->data)
	// if (should_do > 0) -> strcmp has negative values, != is not sufficient!
	bool	sorted = false;
	while (!sorted) {
		sorted = true;
		while (cur && next) {
			if (cmp(cur->data, next->data) > 0) {
				sorted = false;
				// @audit check if head is being swapped:
				// obsolete by only swapping data assignments
				// if (cur == *lst) {
				// 	*lst = next;
				// }
				// swap data only: ptr invalidation to data
				void	*tmp_cur = cur->data;
				cur->data = next->data;
				next->data = tmp_cur;
			}
			// advance
			cur = cur->next;
			next = next->next;
		}
		// reset to head @audit-info
		cur = *lst;
		next = (*lst)->next;
	}
	// make sure new head is correctly set! @audit
}

/*
removes from the list all elements whose data,
when compared to data_ref using cmp, causes cmp to return 0
The data from an element to be erased should be freed using free_fct.

(*cmp)(list_ptr->data, data_ref);
(*free_fct)(list_ptr->data);
*/
void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(), void (*free_fct)(void *));
