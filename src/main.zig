const std = @import("std");
const rl = @import("raylib");
const shapes = @import("shapes.zig");

const Unit = struct { entity: *const Entity, unit_type: UnitType, selected: bool };

const UnitType = enum { worker, military, building };

/// Entity represent
const Entity = struct {
    id: usize,
    shapes: []const shapes.Shape,
    colors: []const rl.Color,
    links: std.ArrayList(Link),

    fn draw(self: *const Entity, transform: rl.Matrix) void {
        // Draw the entity itself
        for (self.shapes, self.colors) |shape, color| {
            shape.draw(transform, color);
        }

        // Draw linked entities
        for (self.links.items) |link| {
            link.entity.draw(rl.math.matrixMultiply(transform, link.transform));
        }
    }
};

const Link = struct {
    transform: rl.Matrix,
    entity: *const Entity,
};

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    rl.initWindow(screenWidth, screenHeight, "aRealTimeStrategyGame");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    //--------------------------------------------------------------------------------------

    var root = Entity{
        .id = 1,
        .shapes = &.{},
        .colors = &.{},
        .links = .empty,
    };

    const base = Entity{
        .id = 2,
        .shapes = shapes.base,
        .colors = &.{.blue},
        .links = .empty,
    };

    const res_drop = Entity{
        .id = 2,
        .shapes = shapes.res_drop,
        .colors = &.{ .red, .red, .red },
        .links = .empty,
    };

    const worker = Entity{
        .id = 3,
        .shapes = shapes.worker,
        .colors = &.{.yellow},
        .links = .empty,
    };
    
    const tank = Entity{
        .id = 4,
        .shapes = shapes.tank,
        .colors = &.{ .green, .green, .green },
        .links = .empty,
    };

    const fighter = Entity{
        .id = 5,
        .shapes = shapes.fighter,
        .colors = &.{ .orange },
        .links = .empty,
    };

    try root.links.append(allocator, .{
        .transform = rl.math.matrixTranslate(-100, 20, 0),
        .entity = &base,
    });

    try root.links.append(allocator, .{
        .transform = rl.math.matrixTranslate(100, -20, 0),
        .entity = &res_drop,
    });

    try root.links.append(allocator, .{
        .transform = rl.math.matrixTranslate(100, -150, 0),
        .entity = &worker,
    });

    try root.links.append(allocator, .{
        .transform = rl.math.matrixTranslate(-100, -110, 0),
        .entity = &tank,
    });

    try root.links.append(allocator, .{
        .transform = rl.math.matrixTranslate(100, 110, 0),
        .entity = &fighter,
    });

    // var base_unit = Unit {
    //     .entity = &base,
    //     .unit_type = .building,
    //     .selected = false
    // };

    var selection = false;
    var selection_begin: ?rl.Vector2 = null;
    var selection_end: ?rl.Vector2 = null;

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        if (rl.isMouseButtonDown(.left)) {
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
            selection_begin = null;
            selection_end = null;
        }

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        root.draw(rl.math.matrixTranslate(
            screenWidth * 0.5,
            screenHeight * 0.5,
            0,
        ));

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
