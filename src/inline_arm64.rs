#[cfg(any(target_arch = "aarch64", target_arch = "arm"))]
core::arch::global_asm!(include_str!("../asm/arm/strlen.S"));
#[cfg(any(target_arch = "aarch64", target_arch = "arm"))]
core::arch::global_asm!(include_str!("../asm/arm/strcmp.S"));

#[allow(dead_code)]
unsafe extern "C" {
	pub fn my_strlen(str: *const u8) -> usize;
	pub fn my_strcmp(str1: *const u8, str2: *const u8) -> i32;
}
