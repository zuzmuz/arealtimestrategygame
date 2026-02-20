const std = @import("std");
const rl = @import("raylib");
const shapes = @import("shapes.zig");

/// Entity represent
pub const Entity = struct {
    shapes: []const shapes.Shape,
    transform: rl.Matrix,
    player_number: u8,
    // entity_type: EntityType,
    selected: bool = false,

    pub fn contains(
        self: *const Entity,
        point: rl.Vector2,
        transform: rl.Matrix,
    ) bool {
        const object_transform = rl.math.matrixMultiply(
            transform,
            self.transform,
        );
        for (self.shapes) |shape| {
            if (shape.contains(point, object_transform)) {
                return true;
            }
        }
        return false;
    }

    pub fn in_selection(
        self: *const Entity,
        selection: rl.Rectangle,
        transform: rl.Matrix,
    ) bool {
        // TODO: I need to invert the matrix or transform the shapes
        const object_transform = rl.math.matrixMultiply(
            transform,
            self.transform,
        );
        for (self.shapes) |shape| {
            if (shape.in_selection(selection, object_transform)) {
                return true;
            }
        }
        return false;
    }

    pub fn draw(self: *const Entity, transform: rl.Matrix) void {
        const object_transform = rl.math.matrixMultiply(
            transform,
            self.transform,
        );
        if (self.selected) {
            const selectable_transform = rl.math.matrixScale(1.5, 1.5, 1);
            for (self.shapes) |shape| {
                shape.draw(
                    rl.math.matrixMultiply(
                        selectable_transform,
                        object_transform,
                    ),
                    getPlayerColor(255),
                );
            }
        }
        for (self.shapes) |shape| {
            shape.draw(
                object_transform,
                getPlayerColor(self.player_number),
            );
        }
    }
};

const Unit = struct {
    base_health: u16,
    current_health: u16,
    attack: u16,
    defense: u16,
    range: u16,
    velocity: u16,
    first_attack_delay: u16,
    attack_delay: u16,
};

const Building = struct {
    base_health: u16,
    current_health: u16,
    attack: u16,
    defense: u16,
    range: u16,
    first_attack_delay: u16,
    attack_delay: u16,
};

const EntityType = union(enum) {
    unit: Unit,
    building: Building,
    // resource: Resource,
};

fn getPlayerColor(number: u8) rl.Color {
    return switch (number) {
        0 => .fromHSV(0, 0, 0.5),
        1 => .fromHSV(0, 0.5, 0.9),
        2 => .fromHSV(180, 0.5, 0.9),
        3 => .fromHSV(60, 0.5, 0.9),
        4 => .fromHSV(240, 0.5, 0.9),
        5 => .fromHSV(30, 0.5, 0.9),
        6 => .fromHSV(210, 0.5, 0.9),
        7 => .fromHSV(90, 0.5, 0.9),
        8 => .fromHSV(300, 0.5, 0.9),
        else => .fromHSV(0, 0, 0),
    };
}
