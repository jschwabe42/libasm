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

// #define DEBUG_ADDR

void print_list(t_list *head, const char *label) {
	printf("\n=== %s ===\n", label);
	if (!head) {
		printf("Empty list\n");
		return;
	}
	
	t_list *current = head;
	int i = 0;
	
	while (current) {
		// Print the integer value
		printf("Node %d: Value = %d", i, *(int *)current->data);
		
		#ifdef DEBUG_ADDR
		// Also print memory addresses when debug flag is defined
		printf(" | Node addr: %p | Data addr: %p | Next addr: %p", 
			   (void*)current, current->data, (void*)current->next);
		#endif
		
		printf("\n");
		current = current->next;
		i++;
	}
	printf("\n");
}

t_list  *ft_create_elem(void *data) {
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
		*begin_list = new_front;
	}
	// no way to set NULL on failed allocation without causing leaks
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
int	not_cmp(void *ptr_a, void *ptr_b) {
	return cmp_bubble(ptr_b, ptr_a);
}

int	is_modulo(void *ptr_a, void *ptr_b) {
	const int	a = *(int *)ptr_a;
	const int	b = *(int *)ptr_b;
	return a % b != 0;
}

void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(void *, void *), void (*free_fct)(void *));
void	free_nothing(void *sth) {
	(void)sth;
}

int	cmp_is_equal_or_data_null(void *data, void *cmp) {
	if (((data && cmp) && *(int *)data == *(int *)cmp) || !cmp) {
		return 0;
	}
	return 1;
}

void	test_list_sort_remove() {
	int	arr[5] = {5, 4, 3, 2, 1};
	int	arr_ordered[5] = {1, 2, 3, 4 ,5};
	t_list	**dbl_ptr = malloc(sizeof(t_list *));
	// @audit-info since prepended arr_ordered used
	t_list	*last = ft_create_elem(&arr_ordered[0]);
	*dbl_ptr = last;
	for (int i = 1; i < 5; i++) {
		// @audit-info since prepended arr_ordered used
		ft_list_push_front(dbl_ptr, &arr_ordered[i]);
	}
	// print and assert unordered correctly
	t_list	*print_assert = *dbl_ptr;
	for (int i = 0; i < 5; i++) {
		// fprintf(stderr, "%d\n", *(int *)print_assert->data);
		assert(arr[i] == *(int *)print_assert->data);
		print_assert = print_assert->next;
	}
	// validate comparison function
	// assert(cmp_bubble(&arr[0], &arr[1]) > 0);
	// fprintf((stderr), "DBL: **%p has - *%p\n", dbl_ptr, *dbl_ptr);
	// fprintf((stderr), "first elem: %d at %p in - *%p\n", *(int *)((*dbl_ptr)->data), ((*dbl_ptr)->data), *dbl_ptr);
	// fprintf((stderr), "second elem: %d at %p in %p - next: %p\n", *(int *)((*dbl_ptr)->next->data), ((*dbl_ptr)->next->data), ((*dbl_ptr)->next),(*dbl_ptr)->next->next);
	print_list(*dbl_ptr, "*dbl_ptr");
	ft_list_sort(dbl_ptr, cmp_bubble);
	assert(((*dbl_ptr)->next) != NULL);
	assert(((*dbl_ptr)->next->next) != NULL);
	// fprintf((stderr), "DBL: **%p\n", dbl_ptr);
	// fprintf((stderr), "first elem: %d at *%p in %p - next: %p\n", *(int *)((*dbl_ptr)->data),((*dbl_ptr)->data), *dbl_ptr, (*dbl_ptr)->next);
	// fprintf((stderr), "second elem: %d at %p in %p - next: %p\n", *(int *)((*dbl_ptr)->next->data), ((*dbl_ptr)->next->data), ((*dbl_ptr)->next),(*dbl_ptr)->next->next);
	// fprintf(stderr, "\n------\nre - ordered\n\n");
	t_list	*check_sorted = *dbl_ptr;
	for (int i = 0; i < 5; i++) {
		// fprintf(stderr, "%d\n", *(int *)check_sorted->data);
		assert(arr_ordered[i] == *(int *)check_sorted->data);
		check_sorted = check_sorted->next;
	}
	print_list(*dbl_ptr, "*dbl_ptr");
	assert(not_cmp(&arr[0], &arr[1]) < 0);
	ft_list_sort(dbl_ptr, not_cmp);
	t_list	*re_unordered = *dbl_ptr;
	for (int i = 0; i < 5; i++) {
		assert(arr[i] == *(int *)re_unordered->data);
		re_unordered = re_unordered->next;
	}
	#define A
	#ifdef A // A: should only remove even
	fprintf(stderr, "removing even numbers\n");
	ft_list_remove_if(dbl_ptr, &arr_ordered[1]/* 2 */, is_modulo, free_nothing);
	#elif defined (B) // B: remove last 2, become 543
	ft_list_remove_if(dbl_ptr, &arr_ordered[0], cmp_is_equal_or_data_null, free_nothing);
	ft_list_remove_if(dbl_ptr, &arr_ordered[1], cmp_is_equal_or_data_null, free_nothing);
	#elif defined(C) // remove all elements
	ft_list_remove_if(dbl_ptr, NULL, cmp_is_equal_or_data_null, free_nothing);
	#endif
	int max_val = ft_list_size(*dbl_ptr);
	t_list	*only_odd = *dbl_ptr;
	fprintf(stderr, "\n");
	for (int i = 0; i < max_val; i++) {
		fprintf(stderr, "%d\n", *(int *)only_odd->data);
		only_odd = only_odd->next;
	}
	#ifndef C// will abort if ran with C
	helper_free_list_data(*dbl_ptr, free_nothing);
	#endif
	free(dbl_ptr);
}

int	strcmp_adapter(void *a, void *b) {
	return strcmp((const char *)a, (const char *)b);
}
int	main() {
	// element creation
	// char	*somedata = strdup("HAS_TO_BE_END");
	// const t_list template = (struct s_list){.data = somedata, .next = NULL};
	// t_list	*created_first = ft_create_elem(somedata);
	// assert(ft_list_size(NULL) == 0);
	// assert(ft_list_size(created_first) == 1);
	// assert(created_first != NULL);
	// assert(created_first->data == template.data);
	// assert(created_first->next == template.next);
	// fprintf((stderr), "created: %s\n", (char *)created_first->data);
	// // push element
	// t_list	**dbl_ptr = malloc(sizeof(t_list *));
	// *dbl_ptr = created_first;
	// assert(dbl_ptr != NULL);
	// char	*nowfirstdata = strdup("START");
	// fprintf((stderr), "DBL: **%p has - *%p\n", dbl_ptr, *dbl_ptr);
	// fprintf((stderr), "created_first: %s at %p in - *%p\n", (char *)((*dbl_ptr)->data), ((*dbl_ptr)->data), *dbl_ptr);
	// fprintf((stderr), "pushing...:\n");
	// ft_list_push_front(dbl_ptr, nowfirstdata);
	// assert(*dbl_ptr != NULL);
	// assert(((*dbl_ptr)->next) != NULL);
	// assert(((*dbl_ptr)->next->next) == NULL);
	// assert(ft_list_size(*dbl_ptr) == 2);
	// fprintf((stderr), "DBL: **%p\n", dbl_ptr);
	// fprintf((stderr), "first: %s at *%p in %p - next: %p\n", (char *)((*dbl_ptr)->data),((*dbl_ptr)->data), *dbl_ptr, (*dbl_ptr)->next);
	// fprintf((stderr), "second: %s at %p in %p - next: %p\n", (char *)((*dbl_ptr)->next->data), ((*dbl_ptr)->next->data), ((*dbl_ptr)->next),(*dbl_ptr)->next->next);
	// assert(created_first->next == NULL);

	// helper_free_list_data(*dbl_ptr, free);
	// free(dbl_ptr);
	test_list_sort_remove();
}


bool	swap(t_list *cur, t_list *next, int (*cmp)(void *, void *)) {
	bool ret = true;
	if ((*cmp)(cur->data, next->data) > 0) {
		ret = false;
		void	*tmp_cur = cur->data;
		cur->data = next->data;
		next->data = tmp_cur;
		print_list(cur, "swap");
	} else {
		print_list(cur, "NO-swap");
	}
	return ret;
}


void	advance(t_list **cur, t_list **next) {
	*cur = *next;
		print_list(*cur, "advance");
	*next = (*next)->next;
}
void	reset_to_head(t_list **lst, t_list **cur, t_list **next) {
	*cur = *lst;
	*next = (*lst)->next;
	print_list(*lst, "reset-head");
}

/*
sorts the list elements in ascending order
by comparing two elements and their data using a comparison function

(*cmp)(list_ptr->data, list_other_ptr->data); (cmp such as strcmp)
*/
void	ft_list_sort(t_list** lst, int (*cmp)(void *, void *)) {
	t_list	*cur = *lst;
	t_list	*next = (*lst)->next;
	bool	sorted = false;
	while (sorted == false) {
		sorted = true;
		while (cur && next) {
			if (swap(cur, next, cmp) != sorted) {
				sorted = false;
			}
			advance(&cur, &next);
			// print_list(cur, "*inner advance");
			// advance
			// cur = next;
			// next = next->next;
		}
		reset_to_head(lst, &cur, &next);
		// print_list(*lst, "*outer reset");
		// reset to head @audit-info
		// cur = *lst;
		// next = (*lst)->next;

	}
}

/*
removes from the list all elements whose data,
when compared to data_ref using cmp, causes cmp to return 0
The data from an element to be erased should be freed using free_fct.

(*cmp)(list_ptr->data, data_ref);
(*free_fct)(list_ptr->data);
*/
void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(void *, void *), void (*free_fct)(void *)) {
	t_list	*cur = *begin_list;
	t_list	*prev = NULL;
	while (cur) {
		if ((*cmp)(cur->data, data_ref) == 0) {
			// remove
			(*free_fct)(cur->data);
			// update previous element to point to cur->next
			t_list	*next = cur->next;
			free(cur);
			if (!prev) { // removed first element - reset to beginning (next)
				*begin_list = next;
				cur = *begin_list;
			} else { // removed non-first - update self on previous and set self
				prev->next = next;
				cur = next;
			}
		} else {
			prev = cur;
			cur = cur->next;
		}
	}
}
