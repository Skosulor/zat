const std = @import("std");

const Flags = struct {
    help: bool = false,
    version: bool = false,
    non_blank: bool = false,
    non_print: bool = false,
    number: bool = false,
    squeeze: bool = false,
};


pub fn main() !void {
    var allocator = std.heap.page_allocator;
    var args = try std.process.argsAlloc(allocator);

    for (args[1..args.len]) |arg| {
        std.debug.print("{s}\n", .{arg});
    }

    var flags = Flags{};

    var file: std.fs.File = undefined;

    for (args[1..args.len]) |arg| {
        if(compare(arg, "-h") or compare(arg, "--help")){
            flags.help = true;
        }
        else if(compare(arg, "-v") or compare(arg, "--version")){
            flags.version = true;
        }
        else if(compare(arg, "-b") or compare(arg, "--number-nonblank")){
            flags.non_blank = true;
        }
        else if(compare(arg, "-v") or compare(arg, "--show-nonprint")){
            flags.non_print = true;
        }
        else if(compare(arg, "-n") or compare(arg, "--number")){
            flags.number = true;
        }
        else if(compare(arg, "-s") or compare(arg, "--squeeze-blank")){
            flags.squeeze = true;
        }
        else{
            file = try std.fs.cwd().openFile(arg, .{});
        }
    }

    if(flags.help)
        printHelp();

    try printFile(file);
}

fn printFile(file: std.fs.File) !void {
    var buffer: [1024]u8 = undefined;
    var read: usize = undefined;

    while(true){
        read = try file.read(buffer[0..]);
        if(read == 0)
            break;
        std.debug.print("{s}", .{buffer[0..read]});
    }
}

fn compare(str1: []const u8, str2: []const u8) bool {
    if(str1.len != str2.len)
        return false;

    for(str1) |char1, i| {
        if(char1 != str2[i])
            return false;
    }

    return true;
}



fn printHelp() void
{
        std.debug.print("Usage: zat [OPTION]... [FILE]...\n", .{});
        std.debug.print("Concatenate FILE(s) to standard output.\n", .{});
        std.debug.print("  -b, --number-nonblank    number nonempty output lines, overrides -n\n", .{});
        std.debug.print("  -n, --number             number all output lines\n", .{});
        std.debug.print("  -s, --squeeze-blank      suppress repeated empty output lines\n", .{});
        std.debug.print("  -v, --show-nonprinting   use ^ and M- notation, except for LFD and TAB\n", .{});
        std.debug.print("  -h  --help     display this help and exit\n", .{});
        std.debug.print("  -v  --version  output version information and exit\n", .{});
        std.debug.print("Examples:\n", .{});
        std.debug.print("  zat f - g  Output f's contents, then standard input, then g's contents.\n", .{});
        std.debug.print("  zat        Copy standard input to standard output.\n", .{});

}
