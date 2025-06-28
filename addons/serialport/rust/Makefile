
# 检查 rust 是否安装
ifeq (, $(shell which cargo))
$(error "未检测到 Rust，请先安装 Rust：https://www.rust-lang.org/tools/install")
endif

# 检查 zigbuild 是否安装
ifeq (, $(shell which zig))
$(error "未检测到 zig，请先安装 zig: https://ziglang.org/download/")
endif
ifeq (, $(shell which cargo-zigbuild))
$(error "未检测到 cargo-zigbuild，请先运行: cargo install cargo-zigbuild")
endif

# 默认构建所有平台
all: linux_arm64 linux_arm32 linux_riscv64 linux_x86_32 windows_arm64 windows_x86_32 android_arm32 android_arm64 android_x86_32 android_x86_64 macos_arm64 macos_x86_64 wasm
linux_arm32:
	@if ! rustup target list --installed | grep -q armv7-unknown-linux-gnueabihf; then \
		echo "自动安装 armv7-unknown-linux-gnueabihf target..."; \
		rustup target add armv7-unknown-linux-gnueabihf; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --no-default-features --release --target armv7-unknown-linux-gnueabihf
	mkdir -p ../bin/armv7-unknown-linux-gnueabihf/; cp target/armv7-unknown-linux-gnueabihf/release/libserialport_module.so ../bin/armv7-unknown-linux-gnueabihf/ || true

linux_riscv64:
	@if ! rustup target list --installed | grep -q riscv64gc-unknown-linux-gnu; then \
		echo "自动安装 riscv64gc-unknown-linux-gnu target..."; \
		rustup target add riscv64gc-unknown-linux-gnu; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --no-default-features --release --target riscv64gc-unknown-linux-gnu
	mkdir -p ../bin/riscv64gc-unknown-linux-gnu/; cp target/riscv64gc-unknown-linux-gnu/release/libserialport_module.so ../bin/riscv64gc-unknown-linux-gnu/ || true

linux_x86_32:
	@if ! rustup target list --installed | grep -q i686-unknown-linux-gnu; then \
		echo "自动安装 i686-unknown-linux-gnu target..."; \
		rustup target add i686-unknown-linux-gnu; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --no-default-features --release --target i686-unknown-linux-gnu
	mkdir -p ../bin/i686-unknown-linux-gnu/; cp target/i686-unknown-linux-gnu/release/libserialport_module.so ../bin/i686-unknown-linux-gnu/ || true

macos_arm64:
	@if ! rustup target list --installed | grep -q aarch64-apple-darwin; then \
		echo "自动安装 aarch64-apple-darwin target..."; \
		rustup target add aarch64-apple-darwin; \
	fi
	cargo zigbuild --release --target aarch64-apple-darwin
	mkdir -p ../bin/aarch64-apple-darwin/; cp target/aarch64-apple-darwin/release/libserialport_module.dylib ../bin/aarch64-apple-darwin/ || true

macos_x86_64:
	@if ! rustup target list --installed | grep -q x86_64-apple-darwin; then \
		echo "自动安装 x86_64-apple-darwin target..."; \
		rustup target add x86_64-apple-darwin; \
	fi
	cargo zigbuild --release --target x86_64-apple-darwin
	mkdir -p ../bin/x86_64-apple-darwin/; cp target/x86_64-apple-darwin/release/libserialport_module.dylib ../bin/x86_64-apple-darwin/ || true

linux_arm64:
	@if ! rustup target list --installed | grep -q aarch64-unknown-linux-gnu; then \
		echo "自动安装 aarch64-unknown-linux-gnu target..."; \
		rustup target add aarch64-unknown-linux-gnu; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --no-default-features --release --target aarch64-unknown-linux-gnu
	mkdir -p ../bin/aarch64-unknown-linux-gnu/; cp target/aarch64-unknown-linux-gnu/release/libserialport_module.so ../bin/aarch64-unknown-linux-gnu/ || true

windows_arm64:
	@if ! rustup target list --installed | grep -q aarch64-pc-windows-gnu; then \
		echo "自动安装 aarch64-pc-windows-gnu target..."; \
		rustup target add aarch64-pc-windows-gnu; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --release --target aarch64-pc-windows-gnu
	mkdir -p ../bin/aarch64-pc-windows-gnu/; cp target/aarch64-pc-windows-gnu/release/serialport_module.dll ../bin/aarch64-pc-windows-gnu/ || true

windows_x86_32:
	@if ! rustup target list --installed | grep -q i686-pc-windows-gnu; then \
		echo "自动安装 i686-pc-windows-gnu target..."; \
		rustup target add i686-pc-windows-gnu; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --release --target i686-pc-windows-gnu
	mkdir -p ../bin/i686-pc-windows-gnu/; cp target/i686-pc-windows-gnu/release/serialport_module.dll ../bin/i686-pc-windows-gnu/ || true

android_arm32:
	@if ! rustup target list --installed | grep -q armv7-linux-androideabi; then \
		echo "自动安装 armv7-linux-androideabi target..."; \
		rustup target add armv7-linux-androideabi; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --release --target armv7-linux-androideabi
	mkdir -p ../bin/armv7-linux-androideabi/; cp target/armv7-linux-androideabi/release/serialport_module.so ../bin/armv7-linux-androideabi/ || true

android_arm64:
	@if ! rustup target list --installed | grep -q aarch64-linux-android; then \
		echo "自动安装 aarch64-linux-android target..."; \
		rustup target add aarch64-linux-android; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --release --target aarch64-linux-android
	mkdir -p ../bin/aarch64-linux-android/; cp target/aarch64-linux-android/release/serialport_module.so ../bin/aarch64-linux-android/ || true

android_x86_32:
	@if ! rustup target list --installed | grep -q i686-linux-android; then \
		echo "自动安装 i686-linux-android target..."; \
		rustup target add i686-linux-android; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --release --target i686-linux-android
	mkdir -p ../bin/i686-linux-android/; cp target/i686-linux-android/release/serialport_module.so ../bin/i686-linux-android/ || true

android_x86_64:
	@if ! rustup target list --installed | grep -q x86_64-linux-android; then \
		echo "自动安装 x86_64-linux-android target..."; \
		rustup target add x86_64-linux-android; \
	fi
	export PKG_CONFIG_ALLOW_CROSS=1; cargo zigbuild --release --target x86_64-linux-android
	mkdir -p ../bin/x86_64-linux-android/; cp target/x86_64-linux-android/release/serialport_module.so ../bin/x86_64-linux-android/ || true

wasm:
	@if ! rustup target list --installed | grep -q wasm32-unknown-emscripten; then \
		echo "自动安装 wasm32-unknown-emscripten target..."; \
		rustup target add wasm32-unknown-emscripten; \
	fi
	cargo build --release --target wasm32-unknown-emscripten
	mkdir -p ../bin/wasm32-unknown-emscripten/; cp target/wasm32-unknown-emscripten/release/serialport_module.wasm ../bin/wasm32-unknown-emscripten/ || true

clean:
	cargo clean