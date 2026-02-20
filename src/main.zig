const std = @import("std");
const rl = @import("raylib");
const shapes = @import("shapes.zig");

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
/// Entity represent
const Entity = struct {
    shapes: []const shapes.Shape,
    transform: rl.Matrix,
    player_number: u8,
    // entity_type: EntityType,
    selected: bool = false,

    fn contains(
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

    fn in_selection(
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

    fn draw(self: *const Entity, transform: rl.Matrix) void {
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

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();
    // const allocator = arena.allocator();

    rl.initWindow(screenWidth, screenHeight, "aRealTimeStrategyGame");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    //--------------------------------------------------------------------------------------

    var base = Entity{
        .shapes = shapes.base,
        .transform = rl.math.matrixTranslate(-100, 20, 0),
        .player_number = 7,
    };

    var res_drop = Entity{
        .shapes = shapes.res_drop,
        .transform = rl.math.matrixTranslate(100, -20, 0),
        .player_number = 8,
    };

    var worker = Entity{
        .shapes = shapes.worker,
        .transform = rl.math.matrixTranslate(100, -150, 0),
        .player_number = 3,
    };

    var war_factory = Entity{
        .shapes = shapes.war_factory,
        .transform = rl.math.matrixTranslate(-100, 150, 0),
        .player_number = 4,
    };

    var tank = Entity{
        .shapes = shapes.tank,
        .transform = rl.math.matrixTranslate(-100, -110, 0),
        .player_number = 5,
    };

    var fighter = Entity{
        .shapes = shapes.fighter,
        .transform = rl.math.matrixTranslate(100, 110, 0),
        .player_number = 6,
        .selected = true,
    };

    const entities: [6]*Entity = .{
        &base,
        &res_drop,
        &worker,
        &war_factory,
        &tank,
        &fighter,
    };

    var selection = false;
    var selection_begin: ?rl.Vector2 = null;
    var selection_end: ?rl.Vector2 = null;

    const main_transform = rl.math.matrixTranslate(
        screenWidth * 0.5,
        screenHeight * 0.5,
        0,
    );

    while (!rl.windowShouldClose()) {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        if (rl.isMouseButtonPressed(.left)) {
            for (entities) |entity| {
                entity.selected = false;
            }

            for (entities) |entity| {
                if (entity.contains(rl.getMousePosition(), main_transform)) {
                    entity.selected = true;
                }
            }
        }

        if (rl.isMouseButtonDown(.left)) {
            for (entities) |entity| {
                entity.selected = false;
            }
            if (selection) {
                selection_end = rl.getMousePosition();
            } else {
                selection = true;
                selection_begin = rl.getMousePosition();
                selection_end = rl.getMousePosition();
            }
        }
        if (rl.isMouseButtonReleased(.left)) {
            selection = false;
            if (selection_begin) |s_begin| if (selection_end) |s_end| {
                const selection_rectange = rl.Rectangle{
                    .x = if (s_begin.x < s_end.x) s_begin.x else s_end.x,
                    .y = if (s_begin.y < s_end.y) s_begin.y else s_end.y,
                    .width = if (s_begin.x > s_end.x) s_begin.x - s_end.x else s_end.x - s_begin.x,
                    .height = if (s_begin.y > s_end.y) s_begin.y - s_end.y else s_end.y - s_begin.y,
                };
                for (entities) |entity| {
                    if (entity.in_selection(selection_rectange, main_transform)) {
                        entity.selected = true;
                    }
                }
            };

            selection_begin = null;
            selection_end = null;
        }

        if (rl.isMouseButtonPressed(.right)) {
        }

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        for (entities) |entity| {
            entity.draw(main_transform);
        }

        // Drawing selection block
        if (selection_begin) |s_begin| if (selection_end) |s_end| {
            rl.drawRectangleLinesEx(
                .{
                    .x = if (s_begin.x < s_end.x) s_begin.x else s_end.x,
                    .y = if (s_begin.y < s_end.y) s_begin.y else s_end.y,
                    .width = if (s_begin.x > s_end.x) s_begin.x - s_end.x else s_end.x - s_begin.x,
                    .height = if (s_begin.y > s_end.y) s_begin.y - s_end.y else s_end.y - s_begin.y,
                },
                2,
                .black,
            );
        };
    }
}
