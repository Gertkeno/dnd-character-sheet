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

fn _pick_base_stats() bool {
    var rng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())).random;
    var totals: [6]u8 = undefined;

    for (totals) |*tstat| {
        stdout.print("rolled: ", .{}) catch return false;
        var stubRolls: [4]u8 = [4]u8{ 0, 0, 0, 0 };

        var total: u8 = 0;
        var lowest: u8 = 6;
        for (stubRolls) |*it| {
            it.* = rng.uintLessThan(u8, 6) + 1;
            stdout.print("{},", .{it.*}) catch return false;
            total += it.*;
            if (it.* < lowest) {
                lowest = it.*;
            }
        }

        stdout.print("\tvalue: {}\n", .{total - lowest}) catch return false;
        tstat.* = total - lowest;
    }
    character.stats = totals;
    stdout.print("Assigning stats in that order, please reorder manually!\n\n", .{}) catch return false;

    return true;
}

fn gr(comptime T: type, l: T, r: T) bool {
    return l > r;
}

fn _reorder_base_stats() bool {
    var cstats: [6]u8 = character.stats;
    var rplstats: [6]u8 = character.stats;

    std.sort.sort(u8, &cstats, u8, gr);

    var pickableStat: [6]bool = [_]bool{true} ** 6;
    for (cstats) |t| {
        // backup incase slot is take/failed choice
        while (true) {
            stdout.print("placing stat: {}...\n", .{t}) catch return false;
            for (pickableStat) |ps, n| {
                const tn = @tagName(@intToEnum(Core_Stat_t, @truncate(u8, n)));
                stdout.print("{c}. {}\n", .{ if (ps) '0' + @intCast(u8, n) + 1 else 'x', tn }) catch return false;
            }

            const slot = pick_a_number(6) catch return false;
            if (pickableStat[slot]) {
                rplstats[slot] = t;
                pickableStat[slot] = false;
                break;
            } else {
                stdout.print("Slot {} already taken\n", .{slot + 1}) catch return false;
            }
        }
    }

    character.stats = rplstats;

    return true;
}

fn _review() bool {
    const cc = @tagName(@intToEnum(Class_t, character.class));
    const cr = @tagName(@intToEnum(Common_Race_t, character.race));
    stdout.print("\n=== Character Sheet ===\nClass:\t{}\nRace:\t{}\nLevel:\t{}\n", .{ cc, cr, character.level }) catch return false;

    stdout.print("\n= Stats =\n", .{}) catch return false;
    for (character.stats) |it, n| {
        const tn = @tagName(@intToEnum(Core_Stat_t, @truncate(u8, n)));
        stdout.print("{}:\t{}\n", .{ tn, it }) catch return false;
    }
    return false;
}

const sections = [_]fn () bool{
    _pick_class,
    _pick_race,
    _pick_level,
    _pick_base_stats,
    _reorder_base_stats,
    _review,
};

const sectionNames = [_][]const u8{
    "Class",
    "Race",
    "Starting Level",
    "Core Stats",
    "Reorder Core Stats",
    "Review",
};

fn valid_character() bool {
    var total: usize = 0;
    for (character.stats) |it| {
        total += it;
    }
    return total > 4 * 6 and character.level > 0;
}

pub fn main() !void {
    try stdout.print("hi welcome to gert's character creator.\n", .{});

    var quitting: bool = false;
    var reviewMode: bool = false;
    while (!quitting) {
        try stdout.print("\n\n=== SECTION OVERVIEW ===\n", .{});

        for (sectionNames) |it, n| {
            try stdout.print("{}. {}\n", .{ n + 1, it });
        }

        var select = pick_a_number(sections.len) catch |x| {
            if (x == PickError.QUIT) {
                break;
            }
            return x;
        };

        while (sections[select]()) {
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
