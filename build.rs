use std::env;
use std::path::PathBuf;

fn main() {
	// Path to the directory containing your static library
	let lib_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap())
		.join("asm")
		.join("nasm");

	// Tell cargo to look for libraries in the specified directory
	println!("cargo:rustc-link-search=native={}", lib_dir.display());

	// Tell cargo to link against the static library
	println!("cargo:rustc-link-lib=static=asm");

	// Only rerun the build script if Makefile changes
	println!("cargo:rerun-if-changed=asm/nasm/Makefile");

	// Get the target architecture
	let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap_or_else(|_| {
		// Fallback detection
		if cfg!(target_arch = "x86_64") {
			"x86_64".to_string()
		} else if cfg!(target_arch = "aarch64") {
			"arm64".to_string()
		} else {
			panic!("Unsupported architecture");
		}
	});

	// Map Rust arch name to Apple's architecture flag format
	let arch_flag = match target_arch.as_str() {
		"x86_64" => "x86_64",
		"aarch64" => "arm64",
		_ => panic!("Unsupported architecture: {}", target_arch),
	};

	println!("cargo:warning=Building for architecture: {}", arch_flag);

	// Build the library from Rust with the correct architecture flag
	let status = std::process::Command::new("make")
		.current_dir(lib_dir)
		.env("CFLAGS", format!("-arch {}", arch_flag))
		.env("ASFLAGS", format!("-arch {}", arch_flag))
		.status()
		.expect("Failed to build libasm.a");

	if !status.success() {
		panic!("Failed to build static library");
	}
}
