#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// @note for c only!
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
		printf("Node %d: Value = %d\n", i, *(int *)current->data);
		
		#ifdef DEBUG_ADDR
		// Also print memory addresses when debug flag is defined
		printf("Node addr: %p | Data addr: %p | Next addr: %p", 
			   (void*)current, current->data, (void*)current->next);
		#endif
		
		printf("\n");
		current = current->next;
		i++;
	}
	printf("\n");
}

void print_dbg_list(t_list *cur) {
	print_list(cur, "current");
	/*
	45321
	43521
	43251
	43215
	34215
	32415
	32145
	23145
	21345
	12345
	*/
}

extern t_list	*ft_create_elem(void *data);// @note testing only!
/*
dep: t_list *ft_create_elem(void *data);
	creates a new element of t_list.
	- It should assign data to the given argument and next to NULL.

adds a new element (t_list) to the beginning of the list
- It should assign data to the given argument.
- If necessary, it will update the pointer at the beginning of the list.
*/
extern void		ft_list_push_front(t_list **begin_list, void *data);
extern int		ft_list_size(t_list *begin_list);

/*
sorts the list elements in ascending order
by comparing two elements and their data using a comparison function

(*cmp)(list_ptr->data, list_other_ptr->data); (cmp such as strcmp)
*/
extern void		ft_list_sort(t_list** lst, int (*cmp)(void *, void *));

// #define CMP_INLINE_SORT
#ifdef CMP_INLINE_SORT
extern void		ft_list_sort_fn_calls(t_list** lst, int (*cmp)(void *, void *));
#endif

/*
removes from the list all elements whose data,
when compared to data_ref using cmp, causes cmp to return 0
The data from an element to be erased should be freed using free_fct.

(*cmp)(list_ptr->data, data_ref);
(*free_fct)(list_ptr->data);
*/
extern void		ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(void *, void *), void (*free_fct)(void *));

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
int	is_odd(void *ptr_a, void *ptr_b) {
	(void)ptr_b;
	return (*(int *)ptr_a % 2 == 0);
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

bool	swap(t_list *cur, t_list *next, int (*cmp)(void *, void *)) {
	bool ret = true;
	if (cmp(cur->data, next->data) > 0) {
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



void	test_list_sort() {
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
		fprintf(stderr, "%d\n", *(int *)print_assert->data);
		// assert(arr[i] == *(int *)print_assert->data);
		print_assert = print_assert->next;
	}
	// validate comparison function
	assert(cmp_bubble(&arr[0], &arr[1]) > 0);
	fprintf((stderr), "DBL: **%p has - *%p\n", dbl_ptr, *dbl_ptr);
	fprintf((stderr), "first elem: %d at %p in - *%p\n", *(int *)((*dbl_ptr)->data), ((*dbl_ptr)->data), *dbl_ptr);
	fprintf((stderr), "second elem: %d at %p in %p - next: %p\n", *(int *)((*dbl_ptr)->next->data), ((*dbl_ptr)->next->data), ((*dbl_ptr)->next),(*dbl_ptr)->next->next);
	#ifdef CMP_INLINE_SORT
	ft_list_sort_fn_calls(dbl_ptr, cmp_bubble);
	print_list(*dbl_ptr, "fn_calls");
	ft_list_sort(dbl_ptr, not_cmp);
	print_list(*dbl_ptr, "rev non-fn_calls");
	ft_list_sort(dbl_ptr, cmp_bubble);
	print_list(*dbl_ptr, "sort non-fn_calls");
	#else
	ft_list_sort(dbl_ptr, cmp_bubble);
	#endif
	assert(((*dbl_ptr)->next) != NULL);
	assert(((*dbl_ptr)->next->next) != NULL);
	fprintf((stderr), "DBL: **%p\n", dbl_ptr);
	fprintf((stderr), "first elem: %d at *%p in %p - next: %p\n", *(int *)((*dbl_ptr)->data),((*dbl_ptr)->data), *dbl_ptr, (*dbl_ptr)->next);
	fprintf((stderr), "second elem: %d at %p in %p - next: %p\n", *(int *)((*dbl_ptr)->next->data), ((*dbl_ptr)->next->data), ((*dbl_ptr)->next),(*dbl_ptr)->next->next);
	fprintf(stderr, "\n------\nre - ordered\n\n");
	t_list	*check_sorted = *dbl_ptr;
	for (int i = 0; i < 5; i++) {
		fprintf(stderr, "%d\n", *(int *)check_sorted->data);
		check_sorted = check_sorted->next;
	}
	check_sorted = *dbl_ptr;
	for (int i = 0; i < 5; i++) {
		assert(arr_ordered[i] == *(int *)check_sorted->data);
		check_sorted = check_sorted->next;
	}
	assert(not_cmp(&arr[0], &arr[1]) < 0);
	#ifdef CMP_INLINE_SORT
	ft_list_sort_fn_calls(dbl_ptr, not_cmp);
	print_list(*dbl_ptr, "fn_calls: unsort");
	#else
	ft_list_sort(dbl_ptr, not_cmp);
	#endif
	t_list	*re_unordered = *dbl_ptr;
	for (int i = 0; i < 5; i++) {
		assert(arr[i] == *(int *)re_unordered->data);
		re_unordered = re_unordered->next;
	}
	#define D
	#ifdef A // A: should only remove even
	fprintf(stderr, "removing even numbers\n");
	ft_list_remove_if(dbl_ptr, &arr_ordered[1]/* 2 */, is_modulo, free_nothing);
	assert(*(int *)(*dbl_ptr)->data == 5);
	assert(*(int *)(*dbl_ptr)->next->data == 3);
	assert(*(int *)(*dbl_ptr)->next->next->data == 1);
	assert((*dbl_ptr)->next->next->next == NULL);
	#elif defined(D) // D: should only remove odd
	ft_list_remove_if(dbl_ptr, &arr_ordered[1]/* 2 */, is_odd, free_nothing);
	fprintf(stderr, "removing odd numbers\n");
	assert(*(int *)(*dbl_ptr)->data == 4);
	assert(*(int *)(*dbl_ptr)->next->data == 2);
	assert((*dbl_ptr)->next->next == NULL);
	#elif defined (B) // B: remove last 2, become 543
	ft_list_remove_if(dbl_ptr, &arr_ordered[0], cmp_is_equal_or_data_null, free_nothing);
	ft_list_remove_if(dbl_ptr, &arr_ordered[1], cmp_is_equal_or_data_null, free_nothing);
	assert(*(int *)(*dbl_ptr)->data == 5);
	assert(*(int *)(*dbl_ptr)->next->data == 4);
	assert(*(int *)(*dbl_ptr)->next->next->data == 3);
	assert((*dbl_ptr)->next->next->next == NULL);
	#elif defined(C) // remove all elements
	ft_list_remove_if(dbl_ptr, NULL, cmp_is_equal_or_data_null, free_nothing);
	assert(dbl_ptr != NULL);
	assert((*dbl_ptr) == NULL);
	#endif
	int max_val = ft_list_size(*dbl_ptr);
	t_list	*only_odd = *dbl_ptr;
	fprintf(stderr, "\n");
	for (int i = 0; i < max_val; i++) {
		fprintf(stderr, "%d\n", *(int *)only_odd->data);
		only_odd = only_odd->next;
	}
	print_list(*dbl_ptr, "*dbl_ptr");
	#ifndef C// will abort if ran with C
	helper_free_list_data(*dbl_ptr, free_nothing);
	#endif
	free(dbl_ptr);
}

int	main() {
	// #define T_PUSH
	#ifdef T_PUSH // element creation
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
	#endif
	// test sorting
	test_list_sort();
}