var z1: u32 = 12345;
var z2: u32 = 12345;
var z3: u32 = 12345;
var z4: u32 = 12345;

// lmao stack overflow https://stackoverflow.com/a/1180465
pub fn rand() u32 {
   var b: u32 = ((z1 << 6) ^ z1) >> 13;
   z1 = ((z1 & 4294967294) << 18) ^ b;
   b  = ((z2 << 2) ^ z2) >> 27;
   z2 = ((z2 & 4294967288) << 2) ^ b;
   b  = ((z3 << 13) ^ z3) >> 21;
   z3 = ((z3 & 4294967280) << 7) ^ b;
   b  = ((z4 << 3) ^ z4) >> 12;
   z4 = ((z4 & 4294967168) << 13) ^ b;
   return (z1 ^ z2 ^ z3 ^ z4);
}

pub fn srand(seed: u64) void {
    z1 = @truncate (u32, seed);
    z2 = @truncate (u32, seed >> 32);
    z3 = z1;
    z4 = z2;
}

pub fn rand_range (at_least: u32, less_than: u32) u32 {
    if (less_than <= at_least)
        unreachable;

    return (rand() % (less_than - at_least)) + at_least;
}
