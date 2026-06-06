//! Loam makes embedded Zig development easy.

/// --- GPIO ---
const gpio = @import("gpio.zig");
pub const Pin = gpio.Pin;
pub const Output = gpio.Output;
pub const Input = gpio.Input;
pub const pin = gpio.pin;
/// --- Runtime ---
const runtime = @import("runtime.zig");
pub const running = runtime.running;
/// --- Time ---
const time = @import("time.zig");
pub const Duration = time.Duration;
pub const wait = time.wait;
pub const every = time.every;
