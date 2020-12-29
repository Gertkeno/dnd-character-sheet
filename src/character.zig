usingnamespace @import("data.zig");

pub const Character = struct {
    class: u8 = 0,
    race: u8 = 0,
    level: u8 = 1,
    stats: [6]u8 = [_]u8{0} ** 6,
    skills: [4]Skill_t = [_]Skill_t{Skill_t.Acrobatics} ** 4,
    skillCount: usize = 0,

    maxHealth: i32 = 0,

    pub fn get_modifier(self: @This(), s: Core_Stat_t) i32 {
        return core_stat_modifier(self.stats[@enumToInt(s)]);
    }

    pub fn get_skill_bonus(self: @This(), s: Skill_t) i32 {
        const sbase = skillStatModifier[@enumToInt(s)];
        return self.get_modifier(sbase) + get_proficiency_bonus(self.level);
    }

    fn valid_stats(self: @This()) bool {
        for (self.stats) |it| {
            if (it < 3) {
                return false;
            }
        }
        return true;
    }

    fn valid_skills(self: @This()) bool {
        return self.skillCount == classSkillProficienciesCount[self.class];
    }

    fn valid_health(self: @This()) bool {
        return self.maxHealth > 0;
    }

    pub fn valid_full(self: @This()) bool {
        return self.valid_stats() and self.valid_health() and self.valid_skills();
    }
};
