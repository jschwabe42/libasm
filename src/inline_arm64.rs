#[cfg(any(target_arch = "aarch64", target_arch = "arm"))]
core::arch::global_asm!(include_str!("../asm/arm/strlen.S"));

#[allow(dead_code)]
unsafe extern "C" {
	pub fn strlen(str: *const u8) -> usize;
}
