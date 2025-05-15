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

	// Build the library from Rust with the correct architecture flag
	let status = std::process::Command::new("make")
		.current_dir(lib_dir)
		.env("CFLAGS", format!("-arch {}", "x86_64"))
		.env("ASFLAGS", format!("-arch {}", "x86_64"))
		.status()
		.expect("Failed to build libasm.a");

	if !status.success() {
		panic!("Failed to build static library");
	}
}
