pub const Class_t = enum(u8) {
    Artificer,
    Barbarian,
    Bard_,
    Cleric,
    Druid,
    Fighter,
    Monk_,
    Paladin,
    Ranger,
    Rune_Scribe,
    Rogue,
    Sorcerer,
    Warlock,
    Wizard,
};

pub const classLinks = [_][]const u8{
    "http://dnd5e.wikidot.com/artificer",
    "http://dnd5e.wikidot.com/barbarian",
    "http://dnd5e.wikidot.com/bard",
    "http://dnd5e.wikidot.com/cleric",
    "http://dnd5e.wikidot.com/druid",
    "http://dnd5e.wikidot.com/fighter",
    "http://dnd5e.wikidot.com/monk",
    "http://dnd5e.wikidot.com/paladin",
    "http://dnd5e.wikidot.com/ranger",
    "http://dnd5e.wikidot.com/rune-scribe",
    "http://dnd5e.wikidot.com/rogue",
    "http://dnd5e.wikidot.com/sorcerer",
    "http://dnd5e.wikidot.com/warlock",
    "http://dnd5e.wikidot.com/wizard",
};

pub const Atrificer_Sub_t = enum {
    Alchemist,
    Armorer,
    Artillerist,
    Battle_Smith,
};

pub const Common_Race_t = enum(u8) {
    Dragonborn,
    Dwarf,
    Elf__,
    Gnome,
    Half_Elf,
    Half_Orc,
    Halfling,
    Human,
    Tiefling,
};

pub const raceLinks = [_][]const u8{
    "http://dnd5e.wikidot.com/dragonborn",
    "http://dnd5e.wikidot.com/dwarf",
    "http://dnd5e.wikidot.com/elf",
    "http://dnd5e.wikidot.com/gnome",
    "http://dnd5e.wikidot.com/half-elf",
    "http://dnd5e.wikidot.com/half-orc",
    "http://dnd5e.wikidot.com/halfling",
    "http://dnd5e.wikidot.com/human",
    "http://dnd5e.wikidot.com/tiefling",
};

const assert = @import("std").testing.expect;

pub const Base_Stat_t = enum(u8) {
    Strength,
    Dexterity,
    Constitution,
    Wisdom_,
    Intelligence,
    Charisma,
};

pub const Base_Stat_Len = @typeInfo(Base_Stat_t).Enum.fields.len;

test "lengths match" {
    assert(@typeInfo(Class_t).Enum.fields.len == classLinks.len);
    assert(@typeInfo(Common_Race_t).Enum.fields.len == raceLinks.len);
}
