const std = @import("std");

var buffer_: [256]u8 = undefined;

pub fn stdin_read_line() ?[]u8 {
    const stdin = std.io.getStdIn().reader();
    const readCount = stdin.read(&buffer_) catch return null;

    if (readCount <= 1 or buffer_[readCount - 1] != '\n') {
        return null;
    }

    return buffer_[0 .. readCount - 1];
}

pub const PickError = error{QUIT};

pub fn pick_a_number(max: u8) !u8 {
    const stdout = std.io.getStdOut().writer();

    outer: while (stdin_read_line()) |line| {
        if (line.len == 0 or line[0] == 'q') {
            return PickError.QUIT;
        }

        if (line[0] == '-') {
            try stdout.print("Clearly there are no negative numbers here, what is wrong with you?\n", .{});
            continue :outer;
        }

        var num: usize = 0;
        for (line) |it| {
            if (it > '9' or it < '0') {
                try stdout.print("Unknown char in number \"{c}\", q to exit\n", .{it});
                continue :outer;
            }
            num *= 10;
            num += it - '0';
        }

        if (num > max or num == 0) {
            try stdout.print("Invalid number \"{}\", q to exit\n", .{num});
            continue :outer;
        } else {
            return @truncate(u8, num - 1);
        }
    }

    return PickError.QUIT;
}
