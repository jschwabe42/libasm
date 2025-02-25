use core::arch::global_asm;

// Cargo will rebuild the file on change
// global_asm!("") /* or combination with include_str!(relative to src dir) */
#[cfg(any(target_arch = "aarch64", target_arch = "arm"))]
global_asm!(include_str!("../asm/arm/strlen.S"));
#[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
global_asm!(
	// include_str!("../asm/x86/strlen.S")
);
unsafe extern "C" {
	fn strlen(str: *const u8) -> usize;
}

#[rstest::rstest]
#[case(c"hello", 5)]
#[case(c"", 0)]
#[rstest::fixture]
fn test_strlen(#[case] input: &std::ffi::CStr, #[case] expected_len: usize) {
	unsafe {
		let libc_len = libc::strlen(input.as_ptr().cast());
		let my_len = crate::strlen(input.as_ptr().cast());
		assert_eq!(libc_len, expected_len, "sanity check");
		assert_eq!(libc_len, my_len, "comparison to libc strlen failed");
	}
}
