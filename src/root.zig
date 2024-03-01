// MIT License
//
// Copyright (c) 2024 Alexei Kireev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// zigStructPrint is available from https://github.com/Durobot/zigStructPrint

const std = @import("std");

pub fn printStruct(s: anytype, shorten_types: bool, indent: comptime_int) void
{
    const s_type_info = @typeInfo(@TypeOf(s));
    if (s_type_info != .Struct)
        @compileError("fn printStruct: `s` is " ++ @typeName(s) ++ " , expected a struct");

    const ind_str = "    " ** indent;
    const ind_str_2 = "    " ** (indent + 1);
    std.debug.print("{s}{{\n", .{ ind_str });
    var name_buf = [_]u8 { 0 } ** 100;
    inline for (s_type_info.Struct.fields) |fld|
        switch (@typeInfo(fld.type))
        {
            .Int, .Float, .ComptimeInt, .ComptimeFloat =>
                std.debug.print("{s}{s}{s}: {s} = {d}\n",
                                .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                   fld.name, @typeName(fld.type), @field(s, fld.name) }),
            .Bool =>
                std.debug.print("{s}{s}{s}: {s} = {}\n",
                                .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                   fld.name, @typeName(fld.type), @field(s, fld.name) }),
            .Struct =>
            {
                std.debug.print("{s}{s}{s}: {s} =\n",
                                .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                   fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types) });
                printStruct(@field(s, fld.name), shorten_types, indent + 1);
            },
            .Array =>
            {
                std.debug.print("{s}{s}{s}: {s} = [ ",
                                .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                   fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types) });
                printArray(@field(s, fld.name), shorten_types);
                std.debug.print("]\n", .{});
            },
            .Pointer => |ptr_type_info|
            {
                switch (ptr_type_info.size)
                {
                    .One, .Many, .C =>
                        std.debug.print("{s}{s}{s}: {s} = {*}\n",
                                        .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                           fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types),
                                           @field(s, fld.name) }),
                    .Slice =>
                        if (ptr_type_info.child == u8)
                            std.debug.print("{s}{s}{s}: {s} = \"{s}\"\n",
                                            .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                               fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types),
                                               @field(s, fld.name) })
                        else
                        {
                            std.debug.print("{s}{s}{s}: {s} = [ ",
                                            .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                               fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types) });
                            printArray(@field(s, fld.name), shorten_types);
                            std.debug.print("]\n", .{});
                        }
                }
            },
            .Enum => std.debug.print("{s}{s}{s}: {s} = {s}\n",
                                    .{ ind_str_2, if (fld.is_comptime) "comptime " else "",
                                       fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types),
                                       @tagName(@field(s, fld.name)) }),
            else => std.debug.print("{s}{s}{s}: {s} = -\n",
                                    .{ ind_str_2, if (fld.is_comptime) "comptime " else "", fld.name,
                                       typeName(@typeName(fld.type), &name_buf, shorten_types) }),
        };
    std.debug.print("{s}}}\n", .{ ind_str });
}

pub fn printStructInline(s: anytype, shorten_types: bool) void
{
    const s_type_info = @typeInfo(@TypeOf(s));
    if (s_type_info != .Struct)
        @compileError("fn printStructInline: `s` is " ++ @typeName(s) ++ " , expected a struct");

    std.debug.print("{{ ", .{});
    var name_buf = [_]u8 { 0 } ** 100;
    inline for (s_type_info.Struct.fields) |fld|
        switch (@typeInfo(fld.type))
        {
            .Int, .Float, .ComptimeInt, .ComptimeFloat =>
                std.debug.print("{s}{s}: {s} = {d}, ",
                                .{ if (fld.is_comptime) "comptime " else "",
                                   fld.name, @typeName(fld.type), @field(s, fld.name) }),
            .Bool =>
                std.debug.print("{s}{s}: {s} = {}, ",
                                .{ if (fld.is_comptime) "comptime " else "",
                                   fld.name, @typeName(fld.type), @field(s, fld.name) }),
            .Struct =>
            {
                std.debug.print("{s}{s}: {s} = ",
                                .{ if (fld.is_comptime) "comptime " else "",
                                   fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types) });
                printStruct(@field(s, fld.name), 0, true);
            },
            .Array =>
            {
                std.debug.print("{s}{s}: {s} = [ ",
                                .{ if (fld.is_comptime) "comptime " else "",
                                   fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types) });
                printArray(@field(s, fld.name), shorten_types);
                std.debug.print("], ", .{});
            },
            .Pointer => |ptr_type_info|
            {
                switch (ptr_type_info.size)
                {
                    .One, .Many, .C =>
                        std.debug.print("{s}{s}: {s} = {*}, ",
                                        .{ if (fld.is_comptime) "comptime " else "",
                                           fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types),
                                           @field(s, fld.name) }),
                    .Slice =>
                        if (ptr_type_info.child == u8)
                            std.debug.print("{s}{s}: {s} = \"{s}\", ",
                                            .{ if (fld.is_comptime) "comptime " else "",
                                               fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types),
                                               @field(s, fld.name) })
                        else
                        {
                            std.debug.print("{s}{s}: {s} = [ ",
                                            .{ if (fld.is_comptime) "comptime " else "",
                                               fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types) });
                            printArray(@field(s, fld.name), shorten_types);
                            std.debug.print("], ", .{});
                        }
                }
            },
            .Enum => std.debug.print("{s}{s}: {s} = {s}, ",
                                    .{ if (fld.is_comptime) "comptime " else "",
                                       fld.name, typeName(@typeName(fld.type), &name_buf, shorten_types),
                                       @tagName(@field(s, fld.name)) }),
            else => std.debug.print("{s}{s}: {s} = -, ",
                                    .{ if (fld.is_comptime) "comptime " else "", fld.name,
                                       typeName(@typeName(fld.type), &name_buf, shorten_types) }),
        };
    std.debug.print("}}, ", .{});
}

pub fn printArray(a: anytype, shorten_types: bool) void
{
    const a_type_info = @typeInfo(@TypeOf(a));
    if (a_type_info != .Array and
        (a_type_info != .Pointer or a_type_info.Pointer.size != .Slice))
        @compileError("fn printArray: `a` is " ++ @typeName(a) ++ " , expected an array or a slice");

    if (a_type_info == .Pointer and a_type_info.Pointer.child == u8 and a_type_info.Pointer.is_const)
    {
        std.debug.print("\"{s}\" ", .{a});
        return;
    }

    for (a) |e|
        switch (@typeInfo(@TypeOf(e)))
        {
            .Int, .Float, .ComptimeInt, .ComptimeFloat =>
                std.debug.print("{d}, ", .{ e }),
            .Bool => std.debug.print("{}, ", .{ e }),
            .Array =>
            {
                std.debug.print("[ ", .{});
                printArray(e, shorten_types);
                std.debug.print("], ", .{});
            },
            .Struct => printStructInline(e, shorten_types),
            .Pointer => |ptr_info|
                if (ptr_info.size == .Slice)
                {
                    std.debug.print("[ ", .{});
                    printArray(e, shorten_types);
                    std.debug.print("], ", .{});
                }
                else
                    std.debug.print("-, ", .{}),
            .Enum => std.debug.print("{s}, ", .{ @tagName(e) }),
            else => std.debug.print("-, ", .{}),
        };
}

/// if (shorten_name) copy short name to name_buf; return name_buf;
/// else              return name;
fn typeName(name: []const u8, name_buf: []u8, shorten_name: bool) []const u8
{
    if (!shorten_name) return name;
    // type returned by a function, e.g.
    // "[2]zon_get_fields.makeStructRetType(zon_get_fields.test.zonToStruct big test.TargetStruct.ArrStruct)"
    // - must process function name part ("zon_get_fields.makeStructRetType")
    //   and argument part ("zon_get_fields.test.zonToStruct big test.TargetStruct.ArrStruct")
    //   separately, reconstructing the type in name_buf.
    // "[2]makeStructRetType(ArrStruct)" is what we're aiming for in our example.
    if (name.len > 0 and name[name.len - 1] == ')')
    {
        var first_free_name_buf_idx: usize = 0; // Index of the first free character in name_buf

        // First opening bracket index, indicating the end of the function name
        const open_bracket_idx = std.mem.indexOfScalar(u8, name, '(') orelse return name;
        // Find the first letter in function name and copy everything up to it to name_buf (e.g. "[2]")
        const fn_first_letter_idx =
        blk1:
        {
            for (name[0..open_bracket_idx], 0..) |c, i|
                if ((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z')) break :blk1 i;
            return name; // First letter in fn name not found o_O
        };
        //if (fn_first_letter_idx >= open_bracket_idx) return name; // What? How?? o_O
        if (fn_first_letter_idx > 0) // Copy this part into name_buf, if any
        {
            first_free_name_buf_idx = copyToBufAt(name_buf, name[0..fn_first_letter_idx], 0);
            if (first_free_name_buf_idx >= name_buf.len) return name_buf; // increase constness
        }

        // Find the first letter in function name after the last dot ('.'),
        // and copy everything starting with it up to the opening bracket, to name_buf
        const fn_first_char_after_dot_idx =
        blk2:
        {
            var i: usize = open_bracket_idx;
            while (i != fn_first_letter_idx)
            {
                i -= 1;
                if (name[i] == '.') break :blk2 i + 1;
            }
            break :blk2 fn_first_letter_idx; // '.' not found in fn name, pretend it's index is fn_first_letter_idx (?)
        };
        // Copy the rightmost part of the function name, including the opening bracket, to name_buf
        first_free_name_buf_idx = copyToBufAt(name_buf,
                                              name[fn_first_char_after_dot_idx..(open_bracket_idx+1)],
                                              first_free_name_buf_idx);
        if (first_free_name_buf_idx >= name_buf.len) return name_buf;

        // Now copy the shortened version of the type name inside the brackets (function argument)
        // to name_buf.
        if (std.mem.lastIndexOfScalar(u8, name[open_bracket_idx..], '.')) |dot_pos| // if it contains a dot
        {
//             std.debug.print("open_bracket_idx = {}, dot_pos = {}\n", .{open_bracket_idx, dot_pos});
//             std.debug.print("{s}\n", .{ name[open_bracket_idx..] });
            first_free_name_buf_idx = copyToBufAt(name_buf, name[(open_bracket_idx + dot_pos + 1)..],
                                                  first_free_name_buf_idx);
        }
        else // no dot
            first_free_name_buf_idx = copyToBufAt(name_buf, name[(open_bracket_idx+1)..],
                                                  first_free_name_buf_idx);
        return name_buf[0..first_free_name_buf_idx];
    }

    // Something like [10] or * or whatever
    if (name[0] < 'A' or (name[0] > 'Z' and name[0] < 'a') or name[0] > 'z')
    {
        var first_free_name_buf_idx: usize = 0; // Index of the first free character in name_buf
        // Find the first letter in function name and copy everything up to it to name_buf (e.g. "[2]")
        const first_letter_idx =
        blk:
        {
            for (name, 0..) |c, i|
                if ((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z')) break :blk i;
            return name; // First letter in name not found o_O
        };
        if (first_letter_idx > 0) // Copy this part into name_buf, if any
        {
            first_free_name_buf_idx = copyToBufAt(name_buf, name[0..first_letter_idx], 0);
            if (first_free_name_buf_idx >= name_buf.len) return name_buf;
        }

        // Now copy the shortened version of the type name into name_buf.
        if (std.mem.lastIndexOfScalar(u8, name[first_letter_idx..], '.')) |dot_pos| // if it contains a dot
        {
//             std.debug.print("open_bracket_idx = {}, dot_pos = {}\n", .{open_bracket_idx, dot_pos});
//             std.debug.print("{s}\n", .{ name[open_bracket_idx..] });
            first_free_name_buf_idx = copyToBufAt(name_buf, name[(first_letter_idx + dot_pos + 1)..],
                                                  first_free_name_buf_idx);
        }
        else // no dot
            first_free_name_buf_idx = copyToBufAt(name_buf, name[(first_letter_idx)..],
                                                  first_free_name_buf_idx);
        return name_buf[0..first_free_name_buf_idx];
    }

    if (std.mem.lastIndexOfScalar(u8, name, '.')) |dot_pos|
    {
        var short_name: []u8 = @constCast(name);
        if (name.len > dot_pos + 1) // name does not end with '.'
        {
            short_name.ptr += dot_pos + 1;
            short_name.len -= dot_pos + 1;
            if (short_name[short_name.len - 1] == ')') short_name.len -= 1;
        }
        return short_name;
    }
    else
        return name;
}

fn ellipsis(buf: []u8) void
{
    if (buf.len > 4)
    {
        buf[buf.len - 1] = '.';
        buf[buf.len - 2] = '.';
        buf[buf.len - 3] = '.';
    }
    else if (buf.len > 2)
    {
        buf[buf.len - 1] = '.';
        buf[buf.len - 2] = '.';
    }
}

/// Returns index of the next free character in dest, dest.len if no free characters
fn copyToBufAt(dest: []u8, src: []const u8, dest_pos: usize) usize
{
    if (dest_pos >= dest.len)
    {
        std.log.err("fn copyToBufAt: dest_pos ({}) >= dest.len ({})", .{ dest_pos, dest.len });
        return dest.len;
    }

    if (src.len >= (dest.len - dest_pos)) // fn name too long for the remainder of name_buf
    {
        const missing_chars = src.len - (dest.len - dest_pos);
        std.mem.copyForwards(u8, dest[dest_pos..], src[0..(src.len - missing_chars)]);
        ellipsis(dest);
        return dest.len;
    }

    std.mem.copyForwards(u8, dest[dest_pos..], src);
    return dest_pos + src.len;
}
