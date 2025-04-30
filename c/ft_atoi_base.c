// - Write a function that converts the initial portion of the string pointed by str to int representation.
// - str is in a specific base given as a second parameter.
// - excepted the base rule, the function should work exactly like ft_ atoi.
// - If there's an invalid argument, the function should return 0. Examples of invalid arguments :
#include <ctype.h>
#include <stddef.h>
#include <string.h>

static size_t	base_valid_len(const char *base) {
	if (!base[0] || !base[1])
		return (0);
	const size_t	base_len = strlen(base);
	size_t	i = 0;
	while (i < base_len) {
		// for each character c
		const char c = base[i];
		// - base contains + or - or whitespaces;
		if (c == '+' || c == '-' || isspace(c)) {
			return (0);
		}
		// - base contains the same character twice ;
		size_t	ii = i + 1;
		while (ii < base_len) {
			if (base[ii] == c) {
				return (0);
			}
			ii++;
		}
		i++;
	}
	return (base_len);
}
#include <stdbool.h>

/**
 * @param str number of base base
 * @param base base for number provided as str
 */
int ft_atoi_base(char *str, char *base) {
	// - base is empty or size of 1;
	const size_t	base_len = base_valid_len(base);
	while (isspace(*str)) {
		str++;
	}
	// convert using base
	bool sign = false;
	if (*str == '+' || *str == '-') {
		if (*str == '-') {
			sign = true;
		}
		str++;
	}
	int	decimal_total = 0;
	while (*str) {
		if (isspace(*str)) {
			return 0;
		}
		int	digit_value = -1;
		size_t	i = 0;
		while (i < base_len) {
			if (*str == base[i]) {
				digit_value = i;
				break;
			}
			i++;
		}
		if (digit_value == -1) {
			return (decimal_total * sign);
		}
		decimal_total = (decimal_total * base_len) + digit_value;
		str++;
	}
	return (decimal_total ^ -sign) + sign;
}

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

void test_decimal() {
	printf("Testing decimal conversions...\n");
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
	// Invalid characters
	assert(ft_atoi_base("123abc", "0123456789") == 0);
	assert(ft_atoi_base("xyz", "0123456789") == 0);
	// Invalid base
	assert(ft_atoi_base("123", "0") == 0);
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
	assert(ft_atoi_base("\t\n 123", "0123456789") == 123);
	assert(ft_atoi_base("\t\n -123", "0123456789") == -123);
	// Trailing whitespace should fail or stop parsing
	assert(ft_atoi_base("\t\n 123 \n\t", "0123456789") == 0);
	assert(ft_atoi_base("\t\n -123 \n\t", "0123456789") == 0);
	printf("✅ Whitespace tests passed\n");
}

int main() {
	printf("Testing ft_atoi_base...\n\n");
	
	test_decimal();
	test_hex();
	test_invalid_inputs();
	test_edge_cases();
	test_custom_bases();
	test_whitespace_handling();
	
	printf("\nAll tests passed! ✅\n");
	return 0;
}