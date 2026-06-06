# loam 🌱

_In the United States Department of Agriculture, textural classification triangle, the only soil that is not predominantly sand, silt, or clay is called "loam". Loam soils generally contain more nutrients, moisture, and humus than sandy soils, have better drainage and infiltration of water and air than silt- and clay-rich soils, and are easier to till than clay soils... Loam soil is suitable for growing most plant varieties._ [wikipedia](https://en.wikipedia.org/wiki/Loam)

`loam` is a Zig library that aims to fill the missing developer experience layer for using Zig + microzig for embedded development. Making both getting started, and ongoing development, a pleasant experience. You might say that `loam` makes embedded development with Zig, bloom.

## Install

Fetch `loam` into your project's `build.zig.zon`:

```sh
zig fetch --save git+https://github.com/loam-zig/loam.git#v0.1.0
```

`loam` builds on [microzig](https://github.com/ZigEmbeddedGroup/microzig), so your project should already depend on it too. Loam is currently targeted at the RP2xxx family (e.g. the Raspberry Pi Pico or Raspberry Pi Pico 2).

## Wire it up

In your `build.zig`, grab the `loam` module and add it to your microzig firmware. The `.depend_on_microzig = true` option is required — it lets loam resolve the same microzig you're building against:

```zig
const loam_dep = b.dependency("loam", .{});
const loam_mod = loam_dep.module("loam");

// ...after you create your microzig firmware `fw`:
fw.add_app_import("loam", loam_mod, .{ .depend_on_microzig = true });
```

## Use it

```zig
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
```

## License

MIT — see [LICENSE](LICENSE).
