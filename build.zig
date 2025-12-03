const std = @import("std");

pub fn build(b: *std.Build) void {
    const pic = b.option(bool, "pie", "Produce Position Independent Code");
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("libssh2", .{});

    const lib = b.addLibrary(.{
        .name = "ssh2",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    const target_info = target.result;
    const is_windows = target_info.os.tag == .windows;

    const config_header = b.addConfigHeader(.{
        .style = .{
            .cmake = upstream.path("src/libssh2_config_cmake.h.in"),
        },
        .include_path = "libssh2_config.h",
    }, .{
        .LIBSSH2_API = if (is_windows) "__declspec(dllexport)" else "",
        .LIBSSH2_HAVE_ZLIB = false,
        .HAVE_SYS_UIO_H = !is_windows,
        .HAVE_WRITEV = !is_windows,
        .HAVE_SYS_SOCKET_H = !is_windows,
        .HAVE_NETINET_IN_H = !is_windows,
        .HAVE_ARPA_INET_H = !is_windows,
        .HAVE_SYS_TYPES_H = !is_windows,
        .HAVE_INTTYPES_H = true,
        .HAVE_STDINT_H = true,
    });

    const base_cflags = [_][]const u8{"-DHAVE_CONFIG_H"};
    const cflags_with_pic = base_cflags ++ [_][]const u8{"-fPIC"};
    const cflags = if (pic orelse false) &cflags_with_pic else &base_cflags;

    const ssh2_src = if (is_windows) &ssh2_src_wincng else &ssh2_src_mbedtls;

    lib.addCSourceFiles(.{
        .root = upstream.path(""),
        .files = ssh2_src,
        .flags = cflags,
    });
    lib.installHeadersDirectory(upstream.path("include"), "", .{});
    lib.root_module.addConfigHeader(config_header);
    lib.root_module.addIncludePath(upstream.path("include"));

    // Crypto backend: WinCNG on Windows, mbedTLS (static) on macOS/Linux
    if (is_windows) {
        lib.root_module.addCMacro("LIBSSH2_WINCNG", "1");
        lib.linkSystemLibrary2("bcrypt", .{ .preferred_link_mode = .dynamic });
        lib.linkSystemLibrary2("ncrypt", .{ .preferred_link_mode = .dynamic });
    } else {
        lib.root_module.addCMacro("LIBSSH2_MBEDTLS", "1");

        const mbedtls_dep = b.dependency("mbedtls", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(mbedtls_dep.artifact("mbedtls"));
    }

    b.installArtifact(lib);
}

const ssh2_src_common = [_][]const u8{
    "src/agent.c",
    "src/bcrypt_pbkdf.c",
    "src/blowfish.c",
    "src/chacha.c",
    "src/channel.c",
    "src/cipher-chachapoly.c",
    "src/comp.c",
    "src/crypt.c",
    "src/global.c",
    "src/hostkey.c",
    "src/keepalive.c",
    "src/kex.c",
    "src/knownhost.c",
    "src/mac.c",
    "src/misc.c",
    "src/packet.c",
    "src/pem.c",
    "src/poly1305.c",
    "src/publickey.c",
    "src/scp.c",
    "src/session.c",
    "src/sftp.c",
    "src/transport.c",
    "src/userauth.c",
    "src/userauth_kbd_packet.c",
    "src/version.c",
};

const ssh2_src_wincng = ssh2_src_common ++ [_][]const u8{
    "src/wincng.c",
};

const ssh2_src_mbedtls = ssh2_src_common ++ [_][]const u8{
    "src/mbedtls.c",
};
