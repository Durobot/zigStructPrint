zigStructPrint

Small library to pretty-print Zig structs (and arrays)

**zigStructPrint** is licensed under under [the MIT License](https://en.wikipedia.org/w/index.php?title=MIT_License&useskin=vector) and available from https://github.com/Durobot/zigStructPrint

Please note that only Zig **0.14.0-dev.1421+f87dd43c1** (give or take) and up is supported because of [this breaking change](https://github.com/ziglang/zig/commit/0fe3fd01ddc2cd49c6a2b939577d16b9d2c65ea9) in the Zig standard library. If you need zigStructPrint for an earlier version of Zig, get [this version](https://github.com/Durobot/zigStructPrint/releases/tag/v0.1-beta) instead.

To use, either drop [zsp.zig](https://github.com/Durobot/zigStructPrint/blob/main/src/zsp.zig) into your project, or, if you prefer Zig package manager:

1. In `build.zig.zon`, in `.dependencies`, add

   ```zig
   .zigStructPrint =
   .{
       .url = "https://github.com/Durobot/zigStructPrint/archive/<COMMIT HASH, 40 HEX DIGITS>.tar.gz",
       .hash = "<ZIG PACKAGE HASH, 68 HEX DIGITS>" // Use arbitrary hash, get correct hash from the error 
   }
   ```

2. In `build.zig`, in `pub fn build`, before `b.installArtifact(exe);`, add

   ```zig
   const zsp = b.dependency("zigStructPrint",
   .{
       .target = target,
       .optimize = optimize,
   });
   exe.root_module.addImport("zigStructPrint", zsp.module("zigStructPrint"));
   ```

Build with `zig build`, as you normally do.

Actually printing out your struct:

```zig
const zsp = @import("zigStructPrint");
. . .
const MyStruct = struct
{
    a: i8 = -10,
    b: u32 = 10,
    c: [3]u8 = [_]u8 { 1, 2, 3 },
    d: [2]Nested = .{ .{ .f = 10.0, .g = "Hello" }, .{ .f = -20.0, .g = "Bye" }, },
    e: [3]Color = .{ .red, .green, .yellow },

    const Nested = struct { f: f32, g: []const u8 };
    const Color = enum { red, yellow, green };
};
const ms = MyStruct {};
zsp.printStruct(ms, true, 0); // try `false` to get full type names
```

And the output is:

```zig
{
    a: i8 = -10
    b: u32 = 10
    c: [3]u8 = [ 1, 2, 3, ]
    d: [2]Nested = [ { f: f32 = 10, g: []const u8 = "Hello", }, { f: f32 = -20, g: []const u8 = "Bye", }, ]
    e: [3]Color = [ red, green, yellow, ]
}
```