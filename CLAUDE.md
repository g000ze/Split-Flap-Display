# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A DIY split-flap display: hardware (laser-cut/CAD housing, PCBs) plus firmware and control software. There is no build system, package manager, or test suite — this is a multi-domain hardware project. Verification means opening files in the respective tool (OpenSCAD, KiCad, Arduino IDE) or reading through the logic by hand, not running `make`/`npm test`.

## Repository layout

- `OpenSCAD/` — 3D models for the module housing, carousel, flaps, and pulley, written in OpenSCAD. Open with the OpenSCAD app to render/export STL/DXF.
- `PCB/` — KiCad projects for two boards: `Module/` (per-character driver + Hall sensor board) and `Backplane/` (connects Arduino to 8 modules via card-edge connectors).
- `Arduino/` — Firmware for an Arduino Micro that drives 8 split-flap modules.
- `Raspberry_Pi/` — PHP control layer: talks to Arduino(s) over I2C and serves a small web UI to type text and trigger animations.

## OpenSCAD architecture

- `_settings.scad` — single source of truth for all physical dimensions (flap size, carousel diameter, pulley, spacer sizes, etc.). Change measurements here, not in the geometry files.
- `_font_setup.scad` — custom font (`MS-Gothic-SFD.ttf`) setup for flap character engraving.
- `2D_library.scad` / `3D_library.scad` — reusable primitive/shape modules used throughout the other files.
- `Split_Flap_Module.scad`, `Carousel_left.scad`, `Carousel_right.scad`, `Chassis.scad`, `PVC_Plate.scad` — the actual part geometries, composed from the libraries above.
- `Overallview.scad` / `Printview.scad` — top-level assemblies for visualizing the whole thing vs. arranging parts for printing/cutting.

When changing a dimension that affects fit (flap size, carousel diameter, spacer lengths), update it in `_settings.scad` so it propagates to every part.

## Arduino firmware (`Arduino/Split_Flap.ino`)

One Arduino Micro drives `modules = 8` split-flap units. Each module has a step pin (stepper motor) and a Hall-effect sensor pin (home position detection). Pin mappings live in `pins_v2.ino`; the ASCII-character-to-carousel-position table lives in `inputs_v2.ino` (`get_position()` — 50 flap positions: `0-9`, `A-Z`, `+ - ? ! . , @ : ; # * $ /` and space).

Key mechanics:
- Position is tracked in microsteps (`ms_per_flap = (motorsteps * microsteps) / flaps`), not flap indices, so motion is smooth and cumulative.
- `set_ms_to_go()` computes how many microsteps to advance to reach a new character, wrapping around the carousel if the target is behind the current position.
- The Hall sensor resyncs `cur_ms_pos` to 0 once per revolution (`update_ms_pos()` / `is_magnet_home()`), correcting for drift/missed steps.
- `motor_run()` in the main loop steps all 8 motors in lockstep on a timer (`speed`, tuned in microseconds between steps — see the comment block in the file for preset speeds).
- The I2C address and a per-board `init_ms_pos` calibration offset are read from EEPROM (`EEPROM.read(0)` / `(1)`), so each backplane board is configured individually via its EEPROM, not by reflashing different firmware.

Two input channels can set characters: Serial (`receive_serial_event`, newline-terminated, one char per module by position) and I2C (`receive_i2c_event`, used by the Raspberry Pi controller; only printable ASCII 0x20–0x7E is accepted). `request_i2c_event()` reports each module's status back over I2C: `255` while a module is still moving, otherwise its current flap position.

Multiple Arduino Micros are addressed independently over I2C (see `Raspberry_Pi/i2c_transmit.php` — addresses `0x0a`–`0x0f` for a 2x3 grid of 8-module boards), so a full display is composed of several of these boards in a grid.

## Raspberry Pi control layer (`Raspberry_Pi/`)

`split-flap.php` is the shared library; `i2c_transmit.php` is the CLI entry point; `html/text.php` is the HTTP entry point used by the web UI in `html/index.php`.

- `$targets` in `split-flap.php` defines the physical grid: rows → arduino boards → module count + I2C address. Edit this array to match the actual display's row/column layout and I2C addressing.
- `sanitize_string()` normalizes input text (Unicode NFKD, strips diacritics, ASCII-transliterates, uppercases, truncates to the total module count, replaces unsupported characters with `~`).
- `config_to_grid()` maps sanitized text onto the physical grid and computes, per module, how many flap positions it needs to walk (`pos_to_walk()`), based on current position read back from the Arduinos over I2C.
- `set_delay()` implements the animation modes (`start`, `stop`, `left`, `right`, `top`, `bottom`, `random`, `snake1-4`, `cross`, `diagonal`, `round`) by assigning a per-module start delay ("timer") so modules begin moving in a staggered pattern instead of all at once.
- `run_carrousel()` walks the delay-sorted schedule and writes characters to each Arduino over I2C at the right time; `block()` optionally waits (polling `get_current_positions()`) until all modules finish moving.
- The web UI (`html/index.php`, Bootstrap + jQuery) POSTs to `html/text.php`, which calls straight into `split-flap.php`. There's no separate REST layer — the PHP functions are the interface.

I2C access depends on the `php-i2c-extension` (https://github.com/tasoftch/php-i2c-extension) providing `i2c_open`/`i2c_select`/`i2c_read`/`i2c_write`/`i2c_close`.

## Editing conventions already established in this repo

- Physical constants (flap count, microsteps, motor steps) are duplicated between `Arduino/Split_Flap.ino` and `Raspberry_Pi/split-flap.php` — the two must be kept in sync (`flaps`, `microsteps`, `motorsteps`) since timing/position math is duplicated across firmware and controller.
- Character sets (ASCII → carousel position) are duplicated between `Arduino/inputs_v2.ino` (`get_position()`) and `Raspberry_Pi/split-flap.php` (`$characters` array) — keep both in sync if the flap set changes.
- Comments in code mix German and English (project author is Swiss/German-speaking); match existing language when editing nearby comments.
