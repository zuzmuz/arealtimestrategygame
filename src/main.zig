const std = @import("std");
const rl = @import("raylib");
const shapes = @import("shapes.zig");
const entities = @import("entities.zig");


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

    var base = entities.Entity{
        .shapes = shapes.base,
        .transform = rl.math.matrixTranslate(-100, 20, 0),
        .player_number = 7,
    };

    var res_drop = entities.Entity{
        .shapes = shapes.res_drop,
        .transform = rl.math.matrixTranslate(100, -20, 0),
        .player_number = 8,
    };

    var worker = entities.Entity{
        .shapes = shapes.worker,
        .transform = rl.math.matrixTranslate(100, -150, 0),
        .player_number = 3,
    };

    var war_factory = entities.Entity{
        .shapes = shapes.war_factory,
        .transform = rl.math.matrixTranslate(-100, 150, 0),
        .player_number = 4,
    };

    var tank = entities.Entity{
        .shapes = shapes.tank,
        .transform = rl.math.matrixTranslate(-100, -110, 0),
        .player_number = 5,
    };

    var fighter = entities.Entity{
        .shapes = shapes.fighter,
        .transform = rl.math.matrixTranslate(100, 110, 0),
        .player_number = 6,
        .selected = true,
    };

    const entity_list: [6]*entities.Entity = .{
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
            for (entity_list) |entity| {
                entity.selected = false;
            }

            for (entity_list) |entity| {
                if (entity.contains(rl.getMousePosition(), main_transform)) {
                    entity.selected = true;
                }
            }
        }

        if (rl.isMouseButtonDown(.left)) {
            for (entity_list) |entity| {
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
                for (entity_list) |entity| {
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

        for (entity_list) |entity| {
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
