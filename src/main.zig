const std = @import("std");
var stdout: *const std.fs.File.Writer = undefined;

usingnamespace @import("inread.zig");
usingnamespace @import("data.zig");
usingnamespace @import("character.zig");
usingnamespace @import("rand.zig");

var character: Character = .{};

fn _pick_class() bool {
    stdout.print("\nPlease pick a class\n", .{}) catch return false;
    for (classLinks) |it, n| {
        const asInt = @truncate(u8, n);
        const t = @tagName(@intToEnum(Class_t, asInt));
        stdout.print("{}. {}\t: ({})\n", .{ n + 1, t, it }) catch return false;
    }

    character.class = pick_a_number(classLinks.len) catch return false;
    return true;
}

fn _pick_race() bool {
    stdout.print("\nPick a race\n", .{}) catch return false;
    for (raceLinks) |it, n| {
        const asInt = @truncate(u8, n);
        const t = @tagName(@intToEnum(Common_Race_t, asInt));
        stdout.print("{}. {}\t: ({})\n", .{ n + 1, t, it }) catch return false;
    }

    character.race = pick_a_number(raceLinks.len) catch return false;
    return true;
}

fn _pick_level() bool {
    stdout.print("\nEnter starting level\n", .{}) catch return false;
    character.level = pick_a_number(255) catch return false;
    character.level += 1;
    return true;
}

/// roll 4d6, remove the lowest
/// just to populate the character's stats, ordering is later
fn _pick_base_stats() bool {
    var totals: [6]u8 = [_]u8{0} ** 6;

    stdout.print("\nRolling 4d6 per stat...\n", .{}) catch return false;
    for (totals) |*tstat| {
        stdout.print("rolled: ", .{}) catch return false;
        var stubRolls: [4]u8 = [_]u8{0} ** 4;

        var total: u8 = 0;
        var lowest: u8 = 6;
        for (stubRolls) |*it| {
            it.* = @truncate (u8, rand_range (1, 7));
            stdout.print("{}, ", .{it.*}) catch return false;
            total += it.*;
            if (it.* < lowest) {
                lowest = it.*;
            }
        }

        stdout.print("\tvalue: {}\n", .{total - lowest}) catch return false;
        tstat.* = total - lowest;
    }
    character.stats = totals;
    stdout.print("Assigning stats in that order, please reorder manually!\n", .{}) catch return false;

    return true;
}

// for std.sort.sort
fn gr(comptime T: type, l: T, r: T) bool {
    return l > r;
}

fn _reorder_base_stats() bool {
    var cstats: [6]u8 = character.stats;
    var rplstats: [6]u8 = character.stats;

    std.sort.sort(u8, &cstats, u8, gr);

    var pickableStat: [6]bool = [_]bool{true} ** 6;
    for (cstats) |t| {
        // repeat if slot is taken/failed choice
        while (true) {
            stdout.print("\nplacing stat: {}...\n", .{t}) catch return false;
            for (pickableStat) |ps, n| {
                const tn = @tagName(@intToEnum(Core_Stat_t, @truncate(u8, n)));
                if (ps) {
                    stdout.print("{}. {}\n", .{ n + 1, tn }) catch return false;
                } else {
                    stdout.print("x. {}({})\n", .{ tn, rplstats [n] }) catch return false;
                }
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

// character specific, must complete stats, class, and level //
fn _pick_max_health() bool {
    const chr = classHealthRolls[character.class];
    const con = character.get_modifier(Core_Stat_t.Constitution);

    // base //
    character.maxHealth = chr.start + con;

    stdout.print("Your Constitution modifier is {}\n", .{con}) catch return false;
    stdout.print("Starting health is {}\n", .{character.maxHealth}) catch return false;
    var i: usize = 1;
    while (i < character.level) : (i += 1) {
        const roll = @intCast (i32, rand_range (1, chr.die+1));
        const totaled = std.math.max(roll, chr.min) + con;
        character.maxHealth += totaled;
        stdout.print("Rolled {}; adding to {} after modifiers; total {}\n", .{ roll, totaled, character.maxHealth }) catch return false;
    }
    stdout.print("Totaled max health: {}\n", .{character.maxHealth}) catch return false;

    return true;
}

// used to detect if a proficient skill has been taken
fn any_equal(comptime T: type, arr: []const T, val: T) bool {
    for (arr) |it| {
        if (it == val) {
            return true;
        }
    }
    return false;
}

fn _pick_proficient_skills() bool {
    // generate array of selectable skills //
    var profSkillCount: u8 = 0;
    var profSkills: [18]Skill_t = undefined;

    inline for (skillStatModifier) |bstat, n| {
        const nskill = @intToEnum(Skill_t, n);
        if (class_has_proficiency(character.class, nskill)) {
            profSkills[profSkillCount] = nskill;
            profSkillCount += 1;
        }
    }

    // operate on skills slice //
    const profSkillSlice: []const Skill_t = profSkills[0..profSkillCount];
    const spc = classSkillProficienciesCount[character.class];
    var selectedTotal: usize = 0;

    while (selectedTotal < spc) {
        stdout.print("\nSelect proficient skills, {} remain\n", .{spc - selectedTotal}) catch return false;

        for (profSkillSlice) |it, n| {
            const alreadyPicked = any_equal(Skill_t, character.skills[0..selectedTotal], it);

            if (alreadyPicked) {
                stdout.print("x. {}({})\n", .{ @tagName(it), character.get_skill_bonus(it) }) catch return false;
            } else {
                stdout.print("{}. {}({})\n", .{ n + 1, @tagName(it), character.get_skill_bonus(it) }) catch return false;
            }
        }

        const select = pick_a_number(profSkillCount) catch return false;
        const sskill = profSkillSlice[select];

        if (any_equal(Skill_t, character.skills[0..selectedTotal], sskill)) {
            stdout.print("Skill {} already selected\n", .{sskill}) catch return false;
        } else {
            character.skills[selectedTotal] = sskill;
            selectedTotal += 1;
        }
    }

    character.skillCount = selectedTotal;

    return true;
}

fn _sub_review_generic(writer: anytype) !void {
    if (!character.valid_full()) {
        try writer.print("\nCharacter is incomplete!", .{});
    }

    const cc = @tagName(@intToEnum(Class_t, character.class));
    const cr = @tagName(@intToEnum(Common_Race_t, character.race));
    try writer.print("\n=== Character Sheet ===\nClass:\t{}\t({})\nRace:\t{}\t({})\nLevel:\t{}\nMax Health:\t{}\n", .{
        cc,
        classLinks[character.class],
        cr,
        raceLinks[character.race],
        character.level,
        character.maxHealth,
    });

    try writer.print("\n= Stats =\n", .{});
    for (character.stats) |it, n| {
        const tn = @tagName(@intToEnum(Core_Stat_t, @truncate(u8, n)));
        try writer.print("{}:\t{}({})\n", .{ tn, it, core_stat_modifier(it) });
    }

    const st = classSavingThrows[character.class];
    const pb = get_proficiency_bonus(character.level);
    const m1 = character.get_modifier(st[0]) + pb;
    const m2 = character.get_modifier(st[1]) + pb;
    try writer.print("\n= Saving Throws =\n{}({}) & {}({})\n", .{ @tagName(st[0]), m1, @tagName(st[1]), m2 });

    try writer.print("\n= Skills =\nProficiency Bonus: {}\n", .{pb});
    for (character.skills[0..character.skillCount]) |it, n| {
        try writer.print("{} ({})\n", .{ @tagName(it), character.get_skill_bonus(it) });
    }
}

fn _review() bool {
    _sub_review_generic(stdout) catch return false;
    return false;
}

const sections = [_]fn () bool{
    _pick_class,
    _pick_race,
    _pick_level,
    _pick_base_stats,
    _reorder_base_stats,
    // class specific //
    _pick_max_health,
    _pick_proficient_skills,
    _review,
};

const sectionNames = [_][]const u8{
    "Class",
    "Race",
    "Starting Level",
    "Core Stats",
    "Reorder Core Stats",
    // class specific //
    "Max Health",
    "Proficient Skills",
    "Review",
};

pub fn main() !void {
    const lstdout = std.io.getStdOut().writer();
    stdout = &lstdout;

    try stdout.print("hi welcome to gert's character creator. start by typing 1. >:(\n", .{});
    srand (@intCast (u64, std.time.milliTimestamp()));

    var quitting: bool = false;
    while (!quitting) {
        // display sections //
        try stdout.print("\n=== SECTION OVERVIEW ===\n", .{});

        for (sectionNames) |it, n| {
            try stdout.print("{}. {}\n", .{ n + 1, it });
        }
        if (character.valid_full()) {
            try stdout.print("q. Save & Quit\n", .{});
        }

        // select and error check //
        var select = pick_a_number(sections.len) catch |x| {
            if (x == PickError.QUIT) {
                break;
            }
            return x;
        };

        // continue sections if not failed (false) and not reviewing //
        while (sections[select]()) {
            select += 1;
            if (character.valid_full() or select >= sections.len) {
                _ = _review();
                break;
            }
        }
    }

    // check if character is complete //
    if (character.valid_full()) {
        const stdin = std.io.getStdIn().reader();

        var namebuffer: [1024]u8 = undefined;
        try stdout.print("Enter a filename for the character sheet, don't forget .txt\n", .{});
        const namelen = try stdin.read(&namebuffer);

        if (namelen <= 1) {
            try stdout.print("Aborting...\n", .{});
            return;
        }

        const name: []const u8 = namebuffer[0 .. namelen - 1];
        const dir = std.fs.cwd();
        var file = try dir.createFile(name, .{ .read = true, .exclusive = true });
        defer file.close();

        const fw = file.writer();
        try _sub_review_generic(fw);
    }
}
