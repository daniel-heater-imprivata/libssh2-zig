const std = @import("std");
const c = @cImport({
    @cInclude("libssh2.h");
});

pub fn main() !void {
    const version = c.libssh2_version(0);
    if (version) |v| {
        std.debug.print("libssh2 version: {s}\n", .{v});
    } else {
        std.debug.print("Failed to get libssh2 version\n", .{});
        return error.VersionCheckFailed;
    }
    
    std.debug.print("libssh2 test successful!\n", .{});
}

