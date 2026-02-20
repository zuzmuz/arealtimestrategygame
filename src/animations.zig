const std = @import("std");
const rl = @import("raylib");


const Animation = struct {
    initial_state: rl.Vector2,
    end_state: rl.Vector2,
    current_state: rl.Vector2,
};
