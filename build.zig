const std = @import("std");

fn package_dir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

const src_path = package_dir() ++ std.fs.path.sep_str ++ "src";

const source_files = [_][]const u8{
    "src/tools.c",
    // "src/lib/libcurses.c",
    "src/lib/libhigh.c",
    "src/lib/libxtra.c",
    "src/lib/report-lib.c",
};

const flags = [_][]const u8{};

pub fn build(b: *std.Build) void {
    const module = b.createModule(.{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    module.addCMacro("GPM_ABI_LEV", "2");
    module.addCMacro("GPM_ABI_AGE", "1");
    module.addCMacro("GPM_ABI_REV", "0");
    module.addCMacro("GPM_ABI_FULL", "\"2.1.0\"");
    module.addCMacro("SBINDIR", "\"/usr/bin\"");
    const lib = b.addLibrary(.{ .name = "gpm", .root_module = module });
    lib.linkLibC();
    lib.addIncludePath(b.path("src"));
    for (source_files) |file| {
        lib.addCSourceFiles(.{ .files = &[_][]const u8{file}, .flags = &flags });
    }
    if (lib.rootModuleTarget().os.tag == .linux)
        lib.addCSourceFiles(.{ .files = &[_][]const u8{"src/lib/liblow.c"}, .flags = &flags });

    b.installArtifact(lib);
    lib.installHeader(b.path("src/headers/gpm.h"), "gpm.h");
}
