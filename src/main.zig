const std = @import("std");
const rl = @import("raylib");
const shapes = @import("shapes.zig");

const Unit = struct { entity: *const Entity, unit_type: UnitType, selected: bool };

const UnitType = enum { worker, military, building };

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
/// Entity represent
const Entity = struct {
    shapes: []const shapes.Shape,
    transform: rl.Matrix,
    player_number: u8,

    fn draw(self: *const Entity, transform: rl.Matrix) void {
        for (self.shapes) |shape| {
            shape.draw(
                rl.math.matrixMultiply(transform, self.transform),
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

    const base = Entity{
        .shapes = shapes.base,
        .transform = rl.math.matrixTranslate(-100, 20, 0),
        .player_number = 7,
    };

    const res_drop = Entity{
        .shapes = shapes.res_drop,
        .transform = rl.math.matrixTranslate(100, -20, 0),
        .player_number = 8,
    };

    const worker = Entity{
        .shapes = shapes.worker,
        .transform = rl.math.matrixTranslate(100, -150, 0),
        .player_number = 3,
    };

    const war_factory = Entity{
        .shapes = shapes.war_factory,
        .transform = rl.math.matrixTranslate(-100, 150, 0),
        .player_number = 4,
    };

    const tank = Entity{
        .shapes = shapes.tank,
        .transform = rl.math.matrixTranslate(-100, -110, 0),
        .player_number = 5,
    };

    const fighter = Entity{
        .shapes = shapes.fighter,
        .transform = rl.math.matrixTranslate(100, 110, 0),
        .player_number = 6,
    };

    const entities: []const Entity = &.{
        base,
        res_drop,
        worker,
        war_factory,
        tank,
        fighter,
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
