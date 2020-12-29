/////////////
// CLASSES //
/////////////
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

const CLASS_LEN = comptime @typeInfo(Class_t).Enum.fields.len;

pub const classLinks = [CLASS_LEN][]const u8{
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

pub const classHealthRolls = [CLASS_LEN]struct {
    start: i8,
    die: u8,
    min: i8,
}{
    .{ .start = 8, .die = 8, .min = 5 }, //Artificer
    .{ .start = 12, .die = 12, .min = 7 }, //Barbarian
    .{ .start = 8, .die = 8, .min = 5 }, //Bard_
    .{ .start = 8, .die = 8, .min = 5 }, //Cleric
    .{ .start = 8, .die = 8, .min = 5 }, //Druid
    .{ .start = 10, .die = 10, .min = 6 }, //Fighter
    .{ .start = 8, .die = 8, .min = 5 }, //Monk
    .{ .start = 10, .die = 10, .min = 6 }, //Paladin
    .{ .start = 10, .die = 10, .min = 6 }, //Ranger
    .{ .start = 8, .die = 8, .min = 5 }, //Rune_Scribe
    .{ .start = 8, .die = 8, .min = 5 }, //Rogue
    .{ .start = 6, .die = 6, .min = 4 }, //Sorcerer
    .{ .start = 8, .die = 8, .min = 5 }, //Warlock
    .{ .start = 6, .die = 6, .min = 4 }, //Wizard
};

pub const classSavingThrows = [CLASS_LEN][2]Core_Stat_t{
    .{ Core_Stat_t.Constitution, Core_Stat_t.Intelligence }, //Artificer
    .{ Core_Stat_t.Strength, Core_Stat_t.Constitution }, //Barbarian
    .{ Core_Stat_t.Dexterity, Core_Stat_t.Charisma }, //Bard_
    .{ Core_Stat_t.Wisdom_, Core_Stat_t.Charisma }, //Cleric
    .{ Core_Stat_t.Intelligence, Core_Stat_t.Wisdom_ }, //Druid
    .{ Core_Stat_t.Strength, Core_Stat_t.Constitution }, //Fighter
    .{ Core_Stat_t.Strength, Core_Stat_t.Dexterity }, //Monk_
    .{ Core_Stat_t.Wisdom_, Core_Stat_t.Charisma }, //Paladin
    .{ Core_Stat_t.Strength, Core_Stat_t.Dexterity }, //Ranger
    .{ Core_Stat_t.Dexterity, Core_Stat_t.Intelligence }, //Rune Scribe??
    .{ Core_Stat_t.Dexterity, Core_Stat_t.Intelligence }, //Rogue
    .{ Core_Stat_t.Constitution, Core_Stat_t.Charisma }, //Sorcerer
    .{ Core_Stat_t.Wisdom_, Core_Stat_t.Charisma }, //Warlock
    .{ Core_Stat_t.Intelligence, Core_Stat_t.Wisdom_ }, //Wizard
};

//////////
// RACE //
//////////
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

const RACE_LEN = comptime @typeInfo(Common_Race_t).Enum.fields.len;

pub const raceLinks = [RACE_LEN][]const u8{
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

pub const racialModifiers = [RACE_LEN][6]u8{
    .{ 2, 0, 0, 0, 0, 1 }, // dragonbon
    .{ 0, 0, 2, 0, 0, 0 }, // dwarf
    .{ 0, 2, 0, 0, 0, 0 }, // elf
    .{ 0, 0, 0, 0, 2, 0 }, // gnome
    .{ 0, 0, 0, 0, 0, 2 }, // half-elf
    .{ 2, 0, 1, 0, 0, 0 }, // half-orc
    .{ 0, 2, 0, 0, 0, 0 }, // halfling
    .{ 1, 1, 1, 1, 1, 1 }, // human
    .{ 0, 0, 0, 0, 0, 2 }, // tiefling
};

////////////////
// CORE STATS //
////////////////
pub const Core_Stat_t = enum(u8) {
    Strength,
    Dexterity,
    Constitution,
    Wisdom_,
    Intelligence,
    Charisma,
};

pub fn core_stat_modifier(base: u8) i32 {
    return @divFloor(@intCast(i32, base) - 10, 2);
}

pub fn get_proficiency_bonus(level: u8) i32 {
    if (level > 20)
        return 6;

    return (level - 1) / 4 + 2;
}

///////////////////////
// PROFICIENT SKILLS //
///////////////////////
pub const Skill_t = enum(u8) {
    Acrobatics,
    Animal_Handling,
    Arcana,
    Athletics,
    Deception,
    History,
    Insight,
    Intimidation,
    Investigation,
    Medicine,
    Nature,
    Perception,
    Performance,
    Persuassion,
    Religion,
    Slight_of_Hand,
    Stealth,
    Survival,
};

const SKILL_LEN = comptime @typeInfo(Skill_t).Enum.fields.len;

const classSkillProficiencies = [CLASS_LEN]u18{
    0b001000111100100100, //Artificer
    0b100000110010001010, //Barbarian
    0b111111111111111111, //Bard_
    0b000110001001100000, //Cleric
    0b100100111001000110, //Druid
    0b100000100011101011, //Fighter
    0b010100000001101001, //Monk
    0b000110001011001000, //Paladin
    0b110000110101001010, //Ranger
    0b000000000000000000, //Rune_Scribe???
    0b011011100111011001, //Rogue
    0b000110000011010100, //Sorcerer
    0b000100010110110100, //Warlock
    0b000100001101100100, //Wizard
};

pub const classSkillProficienciesCount = [CLASS_LEN]u8{
    2, 2, 3, 2, 2, 2, 2, 2, 3, 0, 4, 2, 2, 2,
};

pub fn class_has_proficiency(c: u8, s: Skill_t) bool {
    const bitindex = @as(u256, 1) << @enumToInt(s);
    return classSkillProficiencies[c] & bitindex != 0;
}

pub const skillStatModifier = [SKILL_LEN]Core_Stat_t{
    Core_Stat_t.Dexterity,
    Core_Stat_t.Wisdom_,
    Core_Stat_t.Intelligence,
    Core_Stat_t.Strength,
    Core_Stat_t.Charisma,
    Core_Stat_t.Intelligence,
    Core_Stat_t.Wisdom_,
    Core_Stat_t.Charisma,
    Core_Stat_t.Intelligence,
    Core_Stat_t.Wisdom_,
    Core_Stat_t.Intelligence,
    Core_Stat_t.Wisdom_,
    Core_Stat_t.Charisma,
    Core_Stat_t.Charisma,
    Core_Stat_t.Intelligence,
    Core_Stat_t.Dexterity,
    Core_Stat_t.Dexterity,
    Core_Stat_t.Wisdom_,
};
