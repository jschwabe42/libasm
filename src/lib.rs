mod atoi_base;

#[allow(dead_code)]
#[link(name = "asm", kind = "static")]
unsafe extern "C" {
	fn ft_strlen(str: *const u8) -> usize;
	fn ft_strcmp(str1: *const u8, str2: *const u8) -> i32;
	fn ft_strcpy(dest: *mut u8, src: *const u8) -> *mut u8;
}

#[rstest::rstest]
#[case(c"hello", 5)]
#[case(c"", 0)]
#[rstest::fixture]
fn test_strlen(#[case] input: &std::ffi::CStr, #[case] expected_len: usize) {
	unsafe {
		let libc_len = libc::strlen(input.as_ptr().cast());
		#[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
		let my_len = crate::ft_strlen(input.as_ptr().cast());
		assert_eq!(libc_len, expected_len, "sanity check");
		assert_eq!(libc_len, my_len, "comparison to libc strlen failed");
	}
}

#[test]
fn test_strlen_null_segfaults() {
	use mem_isolate::{
		MemIsolateError, errors::CallableStatusUnknownError, execute_in_isolated_process,
	};
	let libc_result = execute_in_isolated_process(|| unsafe { libc::strlen(std::ptr::null()) });
	#[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
	let my_result = execute_in_isolated_process(|| unsafe { crate::ft_strlen(std::ptr::null()) });
	for result in [libc_result, my_result] {
		assert!(
			result.is_err_and(|err| {
				matches!(
					err,
					MemIsolateError::CallableStatusUnknown(
						CallableStatusUnknownError::ChildProcessKilledBySignal(libc::SIGSEGV)
					)
				)
			}),
			"expected segfault with null input"
		)
	}
}

#[rstest::rstest]
#[case(c"hello", c"")]
#[case(c"", c"hello")]
#[case(c"", c"")]
#[case(c"he", c"h")]
#[case(c"h", c"he")]
#[rstest::fixture]
fn test_strcmp(#[case] input: &std::ffi::CStr, #[case] input2: &std::ffi::CStr) {
	unsafe {
		let libc_len = libc::strcmp(input.as_ptr().cast(), input2.as_ptr().cast());
		#[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
		let my_len = crate::ft_strcmp(input.as_ptr().cast(), input2.as_ptr().cast());
		assert_eq!(libc_len, my_len, "comparison to libc strlen failed");
	}
}

#[test]
fn test_strcpy() {
	use mem_isolate::{
		MemIsolateError, errors::CallableStatusUnknownError, execute_in_isolated_process,
	};
	let source_buf = std::ffi::CString::new("somebiggerthing").unwrap();
	let libc_result = execute_in_isolated_process(|| unsafe {
		let mut small_buf: [libc::c_char; 16] = [b'\0' as i8; 16];
		let _dst_buf = libc::strcpy(small_buf.as_mut_ptr().cast(), source_buf.as_ptr().cast());
	});
	// #[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
	let my_result = execute_in_isolated_process(|| unsafe {
		let mut small_buf: [libc::c_char; 16] = [b'\0' as i8; 16];
		let _dst_buf = crate::ft_strcpy(small_buf.as_mut_ptr().cast(), source_buf.as_ptr().cast());
	});
	// #[cfg(any(target_arch = "aarch64", target_arch = "arm"))]
	// let my_result =
	// 	execute_in_isolated_process(|| unsafe { todo!() });
	#[cfg(any(target_arch = "aarch64", target_arch = "arm"))]
	eprintln!("using arm64 inlined version!");
	for result in [libc_result, my_result] {
		assert!(
			result.is_ok()
				| result.is_err_and(|err| matches!(
					err,
					MemIsolateError::CallableStatusUnknown(
						CallableStatusUnknownError::ChildProcessKilledBySignal(libc::SIGABRT)
					)
				))
		)
	}
}
