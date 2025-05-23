#include <assert.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern int ft_atoi_base(char *str, char *base);

extern char *ft_strdup(const char *src);
extern int check_base(char *base, size_t length);
extern int my_isspace(int c);
extern int check_plus_minus(int c);

void test_decimal() {
	printf("Testing decimal conversions...\n");
	fprintf(stderr, "non-ws: %d\n", ft_atoi_base("123490", "0123456789"));
	fprintf(stderr, "whitespace: %d\n", ft_atoi_base("    123490", "0123456789"));
	assert(ft_atoi_base("123490", "0123456789") == 123490);
	assert(ft_atoi_base("    123490", "0123456789") == 123490);
	assert(ft_atoi_base("    +123490", "0123456789") == 123490);
	assert(ft_atoi_base("-123490", "0123456789") == -123490);
	assert(ft_atoi_base("   -123490", "0123456789") == -123490);
	assert(ft_atoi_base("123490", "0123456789") == 123490);
	printf("✅ Decimal tests passed\n");
}

void test_hex() {
	printf("Testing hex conversions...\n");
	assert(ft_atoi_base("1e262", "0123456789abcdef") == 123490);
	assert(ft_atoi_base("1E262", "0123456789ABCDEF") == 123490);
	printf("✅ Hex tests passed\n");
}

void test_invalid_inputs() {
	printf("Testing invalid inputs...\n");
	// Empty string
	assert(ft_atoi_base("", "0123456789") == 0);
	assert(ft_atoi_base("-0", "0123456789") == 0);
	// Invalid characters
	assert(ft_atoi_base("123abc", "0123456789") == 0);
	assert(ft_atoi_base("123", "01234567890") == 0);
	assert(ft_atoi_base("123abc", "0123456789abc") == 436851);
	assert(ft_atoi_base("xyz", "0123456789") == 0);
	// Invalid base
	assert(ft_atoi_base("123", "0") == 0);
	assert(ft_atoi_base("123", "0\"-_456789abcdefghijklmnopqrstuvwxyz/") == 0);
	printf("✅ Invalid input tests passed\n");
}

void test_edge_cases() {
	printf("Testing edge cases...\n");
	// Single digit
	assert(ft_atoi_base("0", "0123456789") == 0);
	assert(ft_atoi_base("9", "0123456789") == 9);
	// Leading zeros
	assert(ft_atoi_base("000123", "0123456789") == 123);
	printf("✅ Edge case tests passed\n");
}

void test_custom_bases() {
	printf("Testing various bases...\n");
	// Binary
	assert(ft_atoi_base("1101", "01") == 13);
	assert(ft_atoi_base("-1101", "01") == -13);
	// Octal
	assert(ft_atoi_base("17", "01234567") == 15);
	assert(ft_atoi_base("-17", "01234567") == -15);
	// Base 3
	assert(ft_atoi_base("102", "012") == 11);
	assert(ft_atoi_base("-102", "012") == -11);
	printf("✅ Custom base tests passed\n");
}

void test_whitespace_handling() {
	printf("Testing whitespace handling...\n");
	// Leading whitespace
	assert(ft_atoi_base(" 123", "0123456789") == 123);
	printf("passed 1\n");
	assert(ft_atoi_base("\t\n 123", "0123456789") == 123);
	printf("passed 2\n");
	assert(ft_atoi_base("\t\n -123", "0123456789") == -123);
	printf("passed 3\n");
	// Trailing whitespace should fail or stop parsing
	assert(ft_atoi_base("\t\n 123 \n\t", "0123456789") == 0);
	printf("passed 4\n");
	assert(ft_atoi_base("\t\n -123 \n\t", "0123456789") == 0);
	printf("passed 5\n");
	printf("✅ Whitespace tests passed\n");
}

void test_isspace() {
	#ifdef __APPLE__
	for (int i = 0; i < 256; i++) {
		// printf("'%c'\n", (char)i);
		assert(my_isspace(i) == isspace(i));
	}
	#else
	// windows based libc has different isspace!
	for (int i = 0; i < 9; i++) {
		assert(my_isspace(i) == 0);
	}
	for (int i = 9; i < 14; i++) {
		assert(my_isspace(i) == 1);
	}
	assert(my_isspace(32) == 1);
	#endif
	printf("✅ isspace tests passed\n\n");
}

void test_base_sanity() {
	assert(check_base("  a", 3) == 1);
	assert(check_base("-a", 3) == 1);
	assert(check_base("+a", 3) == 1);
	assert(check_base("01", 2) == 0);
	assert(check_base("+01", 2) == 1);
	assert(check_base("-01", 2) == 1);
	assert(check_base(" 01", 2) == 1);
	assert(check_base(" -01", 2) == 1);
	assert(check_base(" +01", 2) == 1);
	assert(check_base(" + 01", 2) == 1);
	assert(check_base(" 3 01", 2) == 1);
}

void test_plus_minus() {
	assert(check_plus_minus('+') == 1);
	assert(check_plus_minus('-') == 1);
	assert(check_plus_minus(44) == 0);
	for (int i = 0; i < 43; i++) {
		assert(check_plus_minus(i) == 0);
	}
	for (int i = 46; i < 256; i++) {
		assert(check_plus_minus(i) == 0);
	}
}

int main() {
	printf("Testing ft_atoi_base...\n\n");
	test_isspace();
	test_plus_minus();
	test_base_sanity();
	test_decimal();
	test_hex();
	test_edge_cases();
	test_custom_bases();
	test_whitespace_handling();
	test_invalid_inputs();
	// final boss
	printf("\nfinal boss - github actions weird behaviour!\n");
	char	*dup = ft_strdup("1e262");
	assert(dup != NULL);
	// function from bonus (compile with...)
	fprintf(stderr, "atoi_base: %d\n", ft_atoi_base(dup, "0123456789abcdef"));
	assert(ft_atoi_base(dup, "0123456789abcdef") == 123490);
	free(dup);
	printf("\natoi_base: All tests passed! ✅\n");
	return 0;
}