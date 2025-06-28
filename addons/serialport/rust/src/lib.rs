mod wrapper;

use godot::global::godot_print;
use godot::init::{gdextension, ExtensionLibrary, InitLevel};
struct RustExtension;
#[gdextension]
unsafe impl ExtensionLibrary for RustExtension {
    fn min_level() -> InitLevel {
        InitLevel::Scene
    }
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            godot_print!("init libserialport successful");
        }
    }
    fn on_level_deinit(level: InitLevel) {
        if level == InitLevel::Scene {
            godot_print!("deinit libserialport successful");
        }
    }
}