## libssh2-zig {{VERSION}}

Zig package for libssh2 SSH2 protocol library.

**Version scheme**: `<upstream-version>[-<build-number>]`
- Base version matches upstream libssh2
- Build number increments for package-only changes

### Usage

```sh
zig fetch --save https://github.com/{{REPO}}/archive/refs/tags/{{VERSION}}.tar.gz
```

In your `build.zig`:

```zig
const libssh2_dep = b.dependency("libssh2", .{
    .target = target,
    .optimize = optimize,
});
your_compilation.linkLibrary(libssh2_dep.artifact("ssh2"));
```

### What's included

- Static library (`libssh2.a` on Linux/macOS, `ssh2.lib` on Windows)
- Headers (`libssh2.h`, `libssh2_sftp.h`, etc.)
- Cross-compilation support:
  - Linux: x86_64, aarch64
  - macOS: x86_64 (Intel), aarch64 (Apple Silicon)
  - Windows: x86_64, aarch64
- Position Independent Code (PIC) support via `-Dpie=true`

### Crypto backends

- **Windows**: WinCNG (native, dynamically linked)
- **macOS/Linux**: mbedTLS (statically linked)

All crypto dependencies are included - no need to install OpenSSL or other crypto libraries on end-user machines.

### Cross-compilation example

```sh
zig build -Dtarget=aarch64-linux -Doptimize=ReleaseSafe
zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSafe
```

