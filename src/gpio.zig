const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const gpio = rp2xxx.gpio;

// pin config
var configured: u64 = 0;

pub const Pin = struct {
    raw: gpio.Pin,

    pub fn output(self: Pin) Output {
        return .{ .raw = self.raw };
    }

    pub fn input(self: Pin) Input {
        return .{ .raw = self.raw };
    }
};

pub const Output = struct {
    raw: gpio.Pin,

    fn ensure(self: Output) void {
        const bit = @as(u64, 1) << @intFromEnum(self.raw);
        if (configured & bit == 0) {
            self.raw.set_function(.sio);
            self.raw.set_direction(.out);
            configured |= bit;
        }
    }

    pub fn toggle(self: Output) void {
        self.ensure();
        self.raw.toggle();
    }

    pub fn high(self: Output) void {
        self.ensure();
        self.raw.put(1);
    }

    pub fn low(self: Output) void {
        self.ensure();
        self.raw.put(0);
    }
};

pub const Input = struct {
    raw: gpio.Pin,

    fn ensure(self: Input) void {
        const bit = @as(u64, 1) << @intFromEnum(self.raw);
        if (configured & bit == 0) {
            self.raw.set_function(.sio);
            self.raw.set_direction(.in);
            configured |= bit;
        }
    }

    pub fn read(self: Input) u1 {
        self.ensure();
        return self.raw.read();
    }
};

pub fn pin(number: u9) Pin {
    return .{
        .raw = gpio.num(number),
    };
}
