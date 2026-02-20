const std = @import("std");
const rl = @import("raylib");


const Animation = struct {
    initial_state: f32,
    end_state: f32,
    current_state: f32,
};
