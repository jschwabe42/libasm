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
extern void		*ft_list_push_front(t_list **begin_list, void *data);
extern int		ft_list_size(t_list *begin_list);
extern int		ft_list_sort(t_list** lst, int (*cmp)(void *, void *));
// extern void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(void *, void *), void (*free_fct)(void *));

// @audit-info testing utils
// integer
int	cmp_bubble(void *ptr_a, void *ptr_b) {
	const int	a = *(int *)ptr_a;
	const int	b = *(int *)ptr_b;
	if (a > b) {
		fprintf(stderr, "a > b: %d\n", a - b);
	} else {
		fprintf(stderr, "a < b: %d\n", a - b);
	}
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

void	debug_inner_cmp() {
	fprintf(stderr, "cmp: inner start!\n");
}
void	debug_inner_cond() {
	fprintf(stderr, "cond: inner!\n");
}
void	debug_outer_cond() {
	fprintf(stderr, "cond: outer!\n");
}
void	debug_outer_cond_complete() {
	fprintf(stderr, "cond: outer complete!\n");
}
void	debug_outer_iter() {
	fprintf(stderr, "iter outer!\n");
}
void	debug_outer_iter_done() {
	fprintf(stderr, "next outer!\n");
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
	fprintf(stderr, "result of cmp: %d\n", ft_list_sort(dbl_ptr, cmp_bubble));
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
	// assert(not_cmp(&arr[0], &arr[1]) < 0);
	// ft_list_sort(dbl_ptr, not_cmp);
	// t_list	*re_unordered = *dbl_ptr;
	// for (int i = 0; i < 5; i++) {
	// 	assert(arr[i] == *(int *)re_unordered->data);
	// 	re_unordered = re_unordered->next;
	// }
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