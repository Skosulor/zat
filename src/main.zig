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
    defer std.process.argsFree(allocator, args);
    var flags = Flags{};

    var file: std.fs.File = undefined;

    const version = "0.1.0";

    for (args[1..args.len]) |arg| {
        if(compare(arg, "-h") or compare(arg, "--help")){
            flags.help = true;
        }
        else if(compare(arg, "--version")){
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

    if(flags.help){
        printHelp();
    }
    else if(flags.version){
        std.debug.print("{s}\n", .{version});
    }
    else{
        try printFile(file, flags);
    }
}


fn printFile(file: std.fs.File, flags: Flags) !void {
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024*1024]u8 = undefined;
    var i: usize = 0;

    const prev_line = struct {
        var was_empty: bool = false;
    };

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {

        if(flags.squeeze and line.len == 0){
            if(prev_line.was_empty)
                continue;
            prev_line.was_empty = true;
        }
        else{
            prev_line.was_empty = false;
        }

        if(flags.number){
            std.debug.print("{d} ", .{i});
            i += 1;
        }
        else if(flags.non_blank and line.len != 0){
            std.debug.print("{d} ", .{i});
            i += 1;
        }


        if(flags.non_print){
            printNonPrintable(line);
        }
        else{
            std.debug.print("{s}\n", .{line});
        }
    }

}

fn printNonPrintable(line: []const u8) void {
    for(line) |char| {
        if(nonPrintable(char)){
            std.debug.print("{c}", .{'@'});
        }
        else{
            std.debug.print("{c}", .{char});
        }
    }
}

fn nonPrintable(char: u8) bool {
    return char < 32 or char == 127;
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


fn printHelp() void{
    std.debug.print("Usage: zat [OPTION]... [FILE]...\n", .{});
    std.debug.print("Concatenate FILE(s) to standard output.\n", .{});
    std.debug.print("  -b, --number-nonblank    number nonempty output lines, overrides -n\n", .{});
    std.debug.print("  -n, --number             number all output lines\n", .{});
    std.debug.print("  -s, --squeeze-blank      suppress repeated empty output lines\n", .{});
    std.debug.print("  -v, --show-nonprinting   show non-printing chars as @\n", .{});
    std.debug.print("  -h  --help     display this help and exit\n", .{});
    std.debug.print("      --version  output version information and exit\n", .{});
    std.debug.print("Examples:\n", .{});
    std.debug.print("  zat f - g  Output f's contents, then standard input, then g's contents.\n", .{});
    std.debug.print("  zat        Copy standard input to standard output.\n", .{});
}
