#![feature(extern_types)]

mod atoi_base;

mod mandatory {
	#[cfg(test)]
	#[link(name = "asm", kind = "static")]
	unsafe extern "C" {
		fn ft_strlen(str: *const u8) -> usize;
		fn ft_strcmp(str1: *const u8, str2: *const u8) -> i32;
		fn ft_strcpy(dest: *mut u8, src: *const u8) -> *mut u8;
		// fn ft_strdup(src: *const u8) -> *mut u8;
		// fn ft_read(fildes: i32, buf: *mut u8, nbyte: usize) -> isize;
		// fn ft_write(fildes: i32, buf: *const u8, nbyte: usize) -> isize;
	}

	#[rstest::rstest]
	#[case(c"hello", 5)]
	#[case(c"", 0)]
	#[rstest::fixture]
	fn test_strlen(#[case] input: &std::ffi::CStr, #[case] expected_len: usize) {
		unsafe {
			let libc_len = libc::strlen(input.as_ptr().cast());
			let my_len = self::ft_strlen(input.as_ptr().cast());
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
		let my_result =
			execute_in_isolated_process(|| unsafe { self::ft_strlen(std::ptr::null()) });
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
			let my_len = self::ft_strcmp(input.as_ptr().cast(), input2.as_ptr().cast());
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
			let _dst_buf =
				self::ft_strcpy(small_buf.as_mut_ptr().cast(), source_buf.as_ptr().cast());
		});
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
}

#[cfg(test)]
mod bonus {
	// list interaction
	#[repr(C)]
	struct SList {
		data: *mut u8,
		next: *mut SList,
	}
	// on > 0: swap elements
	type CmpSort = unsafe extern "C" fn(
		node_data: *mut libc::c_void,
		next_data: *mut libc::c_void,
	) -> libc::c_int;
	// on == 0, remove data, free its Node
	type CmpRemove = unsafe extern "C" fn(
		node_data: *mut libc::c_void,
		data_ref: *mut libc::c_void,
	) -> libc::c_int;
	// called on node_data
	type CmpFreeFct = unsafe extern "C" fn(node_data: *mut libc::c_void) -> ();

	#[link(name = "asm", kind = "static")]
	unsafe extern "C" {
		// fn ft_atoi_base(str: *mut u8, base: *mut u8) -> i32;
		fn ft_create_elem(data: *mut libc::c_void) -> *mut SList;
		fn ft_list_push_front(begin_list: *mut *mut SList, data: *mut libc::c_void) -> ();
		fn ft_list_size(begin_list: *mut SList) -> i32;
		fn ft_list_sort(begin_list: *mut *mut SList, cmp: CmpSort) -> i32;
		fn ft_list_remove_if(
			begin_list: *mut *mut SList,
			data_ref: *mut u8,
			cmp: CmpRemove,
			free_fct: CmpFreeFct,
		) -> ();
	}

	#[cfg(test)]
	fn free_list_data(begin_list: *mut SList, free_fct: CmpFreeFct) {
		assert!(!begin_list.is_null());
		let mut cur = begin_list;
		while !cur.is_null() {
			let next = unsafe { (*cur).next };
			unsafe { free_fct((*cur).data.cast()) };
			unsafe { libc::free(cur.cast()) };
			if next.is_null() {
				break;
			}
			cur = next;
		}
	}

	#[test]
	fn test_list_create() {
		unsafe {
			let somedata = libc::strdup(c"HAS_TO_BE_END".as_ptr());
			let created_first = ft_create_elem(somedata.cast());
			assert!(!created_first.is_null());
			assert_eq!(0, ft_list_size(std::ptr::null_mut()));
			assert_eq!(1, ft_list_size(created_first));
			assert_eq!((*created_first).data, somedata.cast());
			assert_eq!((*created_first).next, std::ptr::null_mut());
			// push elem
			let dbl_ptr: *mut *mut SList = libc::calloc(8, 1).cast();
			assert!(!dbl_ptr.is_null());
			*dbl_ptr = created_first;
			assert!(!(*dbl_ptr).is_null());
			let nowfirstdata = libc::strdup(c"START".as_ptr());
			ft_list_push_front(dbl_ptr, nowfirstdata.cast());
			assert!(!(*dbl_ptr).is_null());
			assert!(!((**dbl_ptr).next).is_null());
			assert!((*((**dbl_ptr).next)).next.is_null());
			assert_eq!((**dbl_ptr).next, created_first);
			assert_eq!(2, ft_list_size(*dbl_ptr));
			assert_eq!((*created_first).next, std::ptr::null_mut());
			// libc::free(somedata.cast());
			// libc::free(created_first.cast());
			// libc::free(nowfirstdata.cast());
			// libc::free(*dbl_ptr.cast());
			free_list_data(*dbl_ptr, libc::free);
			libc::free(dbl_ptr.cast());
		}
	}

	#[test]
	fn test_list_sort_remove() {
		unsafe extern "C" fn cmp_bubble(
			ptr_a: *mut libc::c_void,
			ptr_b: *mut libc::c_void,
		) -> libc::c_int {
			let a: *mut libc::c_int = { ptr_a.cast() };
			let b: *mut libc::c_int = { ptr_b.cast() };
			unsafe { *a - *b }
		}
		unsafe extern "C" fn not_cmp(
			ptr_a: *mut libc::c_void,
			ptr_b: *mut libc::c_void,
		) -> libc::c_int {
			unsafe { cmp_bubble(ptr_b, ptr_a) }
		}
		unsafe extern "C" fn is_odd(
			ptr_a: *mut libc::c_void,
			_ptr_b: *mut libc::c_void,
		) -> libc::c_int {
			let a: *mut libc::c_int = { ptr_a.cast() };
			if unsafe { *a } % 2 == 0 { 1 } else { 0 }
		}
		unsafe extern "C" fn free_nothing(_ptr_a: *mut libc::c_void) {}

		let dbl_ptr: *mut *mut SList = unsafe { libc::calloc(8, 1).cast() };
		let mut arr_ordered: [i32; 5] = [1, 2, 3, 4, 5];
		let mut arr_unordered = arr_ordered.clone();
		arr_unordered.reverse();
		let last = unsafe { ft_create_elem((&raw mut arr_ordered[0]).cast()) };
		unsafe { *dbl_ptr = last };
		for i in 1..5 {
			unsafe { ft_list_push_front(dbl_ptr, (&raw mut arr_ordered[i]).cast()) };
		}
		// unordered
		unsafe {
			let mut assert = *dbl_ptr;
			for i in arr_unordered {
				assert_eq!(i, *((*assert).data).cast());
				assert = (*assert).next;
			}
		}
		assert_eq!(5, unsafe { ft_list_size(*dbl_ptr) });
		unsafe { ft_list_sort(dbl_ptr, cmp_bubble) };
		// ordered
		assert_eq!(5, unsafe { ft_list_size(*dbl_ptr) });
		unsafe {
			let mut assert = *dbl_ptr;
			for i in arr_ordered {
				assert_eq!(i, *((*assert).data).cast());
				assert = (*assert).next;
			}
		}
		unsafe { ft_list_sort(dbl_ptr, not_cmp) };
		// unordered
		unsafe {
			let mut assert = *dbl_ptr;
			for i in arr_unordered {
				assert_eq!(i, *((*assert).data).cast());
				assert = (*assert).next;
			}
		}
		// remove odd
		unsafe {
			ft_list_remove_if(dbl_ptr, std::ptr::null_mut(), is_odd, free_nothing);
			assert!((*((**dbl_ptr).next)).next.is_null());
			assert_eq!(4, *((**dbl_ptr).data as *mut libc::c_int));
			assert_eq!(2, *((*(**dbl_ptr).next).data as *mut libc::c_int));
			free_list_data(*dbl_ptr, free_nothing);
			libc::free(dbl_ptr.cast());
		};
	}
}
