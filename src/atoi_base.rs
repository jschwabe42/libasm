#[allow(dead_code)]
#[warn(clippy::pedantic)]
fn atoi_base(str: &[u8], base: &[u8]) -> i64 {
	let mut str = str.trim_ascii_start();
	let mut sign = false;
	if base.len() < 2
		|| str.is_empty()
		|| !str
			.iter()
			.all(|b_char| base.contains(b_char) | b"+-".contains(b_char))
		|| base.iter().any(|&b_char| b_char == b'+' || b_char == b'-')
	{
		return 0;
	}
	for (index, &b_char) in base.iter().enumerate() {
		if b_char.is_ascii_whitespace() || base[index + 1..].contains(&b_char) {
			return 0;
		}
	}
	str = if matches!(str[0], b'+' | b'-') {
		if str[0] == b'-' {
			sign = true;
		}
		&str[1..]
	} else {
		str
	};
	let mut decimal_total = 0;
	for &b_char in str {
		let mut digit_val = None;
		for (i, &base_char) in base.iter().enumerate() {
			if b_char == base_char {
				#[allow(clippy::cast_possible_wrap)]
				{
					digit_val = Some(i as i64);
				}
				break;
			}
		}
		if digit_val.is_none() {
			return decimal_total * if sign { -1 } else { 1 };
		}
		#[allow(clippy::cast_possible_wrap)]
		{
			decimal_total = (decimal_total * base.len() as i64) + digit_val.unwrap();
		}
	}
	decimal_total * if sign { -1 } else { 1 }
}

#[cfg(test)]
mod tests {
	use super::atoi_base;

	const DECIMAL: &[u8; 10] = b"0123456789";
	const HEX_LOWER: &[u8; 16] = b"0123456789abcdef";
	const HEX_UPPER: &[u8; 16] = b"0123456789ABCDEF";
	const LETTER_DECIMAL: &[u8; 10] = b"abcdefghij";
	#[test]
	fn test_digit_only() {
		assert_eq!(atoi_base(b"    123490", DECIMAL), 123490);
		assert_eq!(atoi_base(b"    +123490", DECIMAL), 123490);
		assert_eq!(atoi_base(b"-123490", DECIMAL), -123490);
		assert_eq!(atoi_base(b"   -123490", DECIMAL), -123490);
		assert_eq!(atoi_base(b"123490", DECIMAL), 123490);
		assert_eq!(atoi_base(b"bcdeja", LETTER_DECIMAL), 123490);
	}
	#[test]
	fn test_hex_only() {
		assert_eq!(atoi_base(b"1e262", HEX_LOWER), 123490);
		assert_eq!(atoi_base(b"1E262", HEX_UPPER), 123490);
	}
	#[test]
	fn test_invalid_inputs() {
		// Empty string
		assert_eq!(atoi_base(b"", DECIMAL), 0);
		// Invalid characters
		assert_eq!(atoi_base(b"123abc", DECIMAL), 0);
		assert_eq!(atoi_base(b"xyz", DECIMAL), 0);
		// Invalid base
		assert_eq!(atoi_base(b"123", b""), 0);
		assert_eq!(atoi_base(b"123", b"0"), 0);
		// Duplicate characters in base
		assert_eq!(atoi_base(b"123", b"01234567890"), 0);
		// Whitespace in base
		assert_eq!(atoi_base(b"123", b"0123 "), 0);
		// '+' or '-' in base
		assert_eq!(atoi_base(b"123", b"0123+"), 0);
		assert_eq!(atoi_base(b"123", b"0123-"), 0);
		assert_eq!(atoi_base(b"123", b"-0123"), 0);
		assert_eq!(atoi_base(b"123", b"+0123"), 0);
	}

	#[test]
	fn test_edge_cases() {
		// Single digit
		assert_eq!(atoi_base(b"0", DECIMAL), 0);
		assert_eq!(atoi_base(b"9", DECIMAL), 9);
		// Leading zeros
		assert_eq!(atoi_base(b"000123", DECIMAL), 123);
		// Large number
		assert_eq!(
			atoi_base(b"7FFFFFFFFFFFFFFE", HEX_UPPER),
			9223372036854775806
		);
		assert_eq!(
			atoi_base(b"-7FFFFFFFFFFFFFFF", HEX_UPPER),
			-9223372036854775807
		);
	}
	#[should_panic]
	#[test]
	fn test_edge_cases_panic() {
		// Large number
		assert_eq!(
			atoi_base(b"9223372036854775807", DECIMAL),
			9223372036854775807
		);
		assert_eq!(
			atoi_base(b"-9223372036854775808", DECIMAL),
			-9223372036854775808
		);
	}

	#[test]
	fn test_custom_bases() {
		// Binary
		const BINARY: &[u8; 2] = b"01";
		assert_eq!(atoi_base(b"1101", BINARY), 13);
		assert_eq!(atoi_base(b"-1101", BINARY), -13);
		// Octal
		const OCTAL: &[u8; 8] = b"01234567";
		assert_eq!(atoi_base(b"17", OCTAL), 15);
		assert_eq!(atoi_base(b"-17", OCTAL), -15);
		// Base 3
		const BASE3: &[u8; 3] = b"012";
		assert_eq!(atoi_base(b"102", BASE3), 11);
		assert_eq!(atoi_base(b"-102", BASE3), -11);
	}

	#[test]
	fn test_case_insensitivity() {
		// Hexadecimal with mixed case
		assert_eq!(atoi_base(b"1a2B3", HEX_LOWER), 0);
		assert_eq!(atoi_base(b"1A2b3", HEX_UPPER), 0);
	}

	#[test]
	fn test_whitespace_handling() {
		// Leading and trailing whitespace
		assert_eq!(atoi_base(b"   123   ", DECIMAL), 0);
		assert_eq!(atoi_base(b"   -123   ", DECIMAL), 0);
		// Tabs and newlines
		assert_eq!(atoi_base(b"\t\n 123", DECIMAL), 123);
		assert_eq!(atoi_base(b"\t\n -123", DECIMAL), -123);
		assert_eq!(atoi_base(b"\t\n 123 \n\t", DECIMAL), 0);
		assert_eq!(atoi_base(b"\t\n -123 \n\t", DECIMAL), 0);
	}
}
