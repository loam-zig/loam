const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const usb = microzig.core.usb;

// USB Polling
const USB_Device = rp2xxx.usb.Polled(.{});
var usb_device: USB_Device = undefined;
var started: bool = false;

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
    tick();
    return true;
}

pub fn tick() void {
    poll_usb();
}
