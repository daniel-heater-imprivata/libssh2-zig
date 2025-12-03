[![CI](https://github.com/allyourcodebase/libssh2/actions/workflows/ci.yaml/badge.svg)](https://github.com/allyourcodebase/libssh2/actions)

# libssh2

This is [libssh2](https://github.com/libssh2/libssh2), packaged for [Zig](https://ziglang.org/).

## Installation

First, update your `build.zig.zon`:

```
# Initialize a `zig build` project if you haven't already
zig init
zig fetch --save git+https://github.com/allyourcodebase/libssh2.git#libssh2-1.11.1
```

You can then import `libssh2` in your `build.zig` with:

```zig
const libssh2_dependency = b.dependency("libssh2", .{
    .target = target,
    .optimize = optimize,
});
your_exe.linkLibrary(libssh2_dependency.artifact("ssh2"));
```

## Build Options

Position Independent Code (PIC) can be enabled:

```zig
const libssh2_dependency = b.dependency("libssh2", .{
    .target = target,
    .optimize = optimize,
    .pie = true, // Enable Position Independent Code (default=false)
});
```

## Crypto Backends

- **Windows**: WinCNG (native, dynamically linked)
- **macOS/Linux**: mbedTLS (statically linked)

All crypto dependencies are included - no need to install OpenSSL or other crypto libraries on end-user machines. The resulting binaries are self-contained.
