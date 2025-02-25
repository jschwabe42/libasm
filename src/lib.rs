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

#[test]
fn test_strlen_null_segfaults() {
	use nix::sys::signal::Signal;
	use nix::unistd::{ForkResult, fork};
	// Fork process so the segfault doesn't kill the test runner
	match unsafe { fork() } {
		Ok(ForkResult::Parent { child }) => {
			// Parent process waits for child
			let wait_status = nix::sys::wait::waitpid(child, None).expect("waitpid failed");

			// Check if child terminated by segmentation fault
			if let nix::sys::wait::WaitStatus::Signaled(_, signal, _) = wait_status {
				assert_eq!(
					signal,
					Signal::SIGSEGV,
					"Expected SIGSEGV from null pointer"
				);
			} else {
				panic!("Child didn't receive segfault as expected");
			}
		}

		Ok(ForkResult::Child) => {
			// Child process calls the function with NULL
			unsafe {
				let _ = crate::strlen(std::ptr::null());
				// If we reach here, there was no segfault
				libc::exit(0);
			};
		}

		Err(e) => panic!("Fork failed: {}", e),
	}
}
