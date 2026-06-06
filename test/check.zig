const loam = @import("loam");
const microzig = @import("microzig");
pub const panic = microzig.panic;

pub const std_options = microzig.std_options(.{});

const led = loam.pin(25).output();
var blink = loam.every(.{ .seconds = 0.5 });

pub fn main() !void {
    while (loam.running()) {
        if (blink.ready()) led.toggle();
    }
}
