const std = @import("std");
const stdout = std.io.getStdOut().writer();

usingnamespace @import("inread.zig");
usingnamespace @import("data.zig");

var character: struct {
    class: u8 = 0,
    race: u8 = 0,
    level: u8 = 0,

    stats: [6]u8 = [_]u8{0} ** 6,
} = .{};

fn _pick_class() bool {
    stdout.print("Please pick a class\n", .{}) catch return false;
    for (classLinks) |it, n| {
        const asInt = @truncate(u8, n);
        const t = @tagName(@intToEnum(Class_t, asInt));
        stdout.print("{}. {}\t: ({})\n", .{ n + 1, t, it }) catch return false;
    }

    character.class = pick_a_number(classLinks.len) catch return false;
    return true;
}

fn _pick_race() bool {
    stdout.print("Pick a race\n", .{}) catch return false;
    for (raceLinks) |it, n| {
        const asInt = @truncate(u8, n);
        const t = @tagName(@intToEnum(Common_Race_t, asInt));
        stdout.print("{}. {}\t: ({})\n", .{ n + 1, t, it }) catch return false;
    }

    character.race = pick_a_number(raceLinks.len) catch return false;
    return true;
}

fn _pick_level() bool {
    stdout.print("Enter starting level\n", .{}) catch return false;
    character.level = pick_a_number(255) catch return false;
    return true;
}

fn _base_stats() bool {
    return true;
}

fn _review() bool {
    const cc = @tagName (@intToEnum (Class_t, character.class));
    const cr = @tagName (@intToEnum (Common_Race_t, character.race));
    stdout.print ("\n=== Character Sheet ===\nClass:\t{}\nRace:\t{}\nLevel:\t{}\n", .{cc, cr, character.level}) catch return false;

    stdout.print ("\n= Stats =\n", .{}) catch return false;
    for (character.stats) |it, n| {
        const tn = @tagName (@intToEnum (Base_Stat_t, @truncate (u8, n)));
        stdout.print ("{}:\t{}\n", .{tn, it}) catch return false;
    }
    return false;
}

const sections = [_]fn () bool{
    _pick_class,
    _pick_race,
    _pick_level,
    _review,
};

const sectionNames = [_][]const u8{
    "Class",
    "Race",
    "Starting Level",
    "Review",
};

fn valid_character() bool {
    var total: usize = 0;
    for (character.stats) |it| {
        total += it;
    }
    return total > 4*6 and character.level > 0;
}

pub fn main() !void {
    const rng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));
    try stdout.print("hi welcome to gert's character creator.\n", .{});

    var quitting: bool = false;
    var reviewMode: bool = false;
    while (!quitting) {
        try stdout.print("\n\n=== SECTION OVERVIEW ===\n", .{});

        for (sectionNames) |it, n| {
            try stdout.print("{}. {}\n", .{ n + 1, it });
        }

        var select = pick_a_number (sections.len) catch |x| {
            if (x == PickError.QUIT) {
                break;
            }
            return x;
        };

        while (sections [select]()) {
            select += 1;
            if (reviewMode or select >= sections.len) {
                break;
            }
        }

        if (valid_character()) {
            reviewMode = true;
        }
    }

    // check if character is complete //
    // print sheet to random file lol //
}
