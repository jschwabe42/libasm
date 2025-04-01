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