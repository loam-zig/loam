const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const time = rp2xxx.time;

const runtime = @import("runtime.zig");

pub const Duration = struct {
    seconds: f64 = 0,
    millis: u64 = 0,
    micros: u64 = 0,

    pub fn to_us(self: Duration) u64 {
        var micros: u64 = @intFromFloat(self.seconds * 1_000_000);
        micros += (self.millis * 1_000);
        micros += self.micros;
        return micros;
    }
};

pub const Every = struct {
    period_us: u64,
    next_due: u64 = 0,

    pub fn ready(self: *Every) bool {
        const now = time.get_time_since_boot().to_us();
        if (now < self.next_due) return false;
        self.next_due = now + self.period_us;
        return true;
    }
};

pub fn wait(duration: Duration) void {
    // Determine deadline and poll for USB interrupt while we "sleep"
    const deadline = time.get_time_since_boot().to_us() + duration.to_us();
    while (time.get_time_since_boot().to_us() < deadline) {
        runtime.tick();
    }
}

pub fn every(duration: Duration) Every {
    return .{ .period_us = duration.to_us() };
}
