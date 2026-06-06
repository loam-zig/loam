const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const gpio = rp2xxx.gpio;
const time = rp2xxx.time;
const usb = microzig.core.usb;

// USB Polling
const USB_Device = rp2xxx.usb.Polled(.{});
var usb_device: USB_Device = undefined;
var started: bool = false;

// comptime pin config
var configured: u64 = 0;

var usb_controller: usb.DeviceController(.{
    .bcd_usb = USB_Device.max_supported_bcd_usb,
    .device_triple = .unspecified,
    .vendor = USB_Device.default_vendor_id,
    .product = USB_Device.default_product_id,
    .bcd_device = .from(1, 0),
    .serial = "0001",
    .max_supported_packet_size = 64,
    .configurations = &.{.{
        .attributes = .{ .self_powered = false },
        .max_current_ma = 100,
        .Drivers = struct {
            reset: rp2xxx.usb.ResetDriver(null, 0),
        },
    }},
}, .{
    .{ .reset = "Reset" }, // interface_str for the reset driver
}) = .init;

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

    fn ensure(self: Output) void {
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

pub fn pin(number: u9) Pin {
    return .{
        .raw = gpio.num(number),
    };
}

pub fn wait(duration: Duration) void {
    // Determine deadline and poll for USB interrupt while we "sleep"
    const deadline = time.get_time_since_boot().to_us() + duration.to_us();
    while (time.get_time_since_boot().to_us() < deadline) {
        poll_usb();
    }
}

fn ensure_started() void {
    if (!started) {
        usb_device = USB_Device.init();
        started = true;
    }
}

fn poll_usb() void {
    ensure_started();
    usb_device.poll(&usb_controller);
}

pub fn running() bool {
    poll_usb();
    return true;
}

pub fn every(duration: Duration) Every {
    return .{ .period_us = duration.to_us() };
}
