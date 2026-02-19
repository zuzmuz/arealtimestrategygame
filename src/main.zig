const std = @import("std");
const arealtimestrategygame = @import("arealtimestrategygame");
const rl = @import("raylib");

const Shape = union(enum) {
    circle: struct {
        center: rl.Vector2,
        radius: f32,
    },
    triangle: struct {
        points: [3]rl.Vector2,
    },

    fn draw(self: *const Shape, transform: rl.Matrix) void {
        switch (self.*) {
            .circle => |*circle| {
                const transformed = rl.math.vector2Transform(circle.center, transform);
                rl.drawCircleV(
                    transformed,
                    circle.radius,
                    .red,
                );
            },
            .triangle => |*triangle| {
                const points: [3]rl.Vector2 = .{
                    rl.math.vector2Transform(triangle.points[0], transform),
                    rl.math.vector2Transform(triangle.points[1], transform),
                    rl.math.vector2Transform(triangle.points[2], transform),
                };
                rl.drawTriangle(
                    points[0],
                    points[1],
                    points[2],
                    .blue,
                );
            },
        }
    }
};

const Unit = struct { entity: *const Entity, unit_type: UnitType, selected: bool };

const UnitType = enum { worker, military, building };

/// Entity represent
const Entity = struct {
    id: usize,
    shapes: []const Shape,
    links: std.ArrayList(Link),

    fn draw(self: *const Entity, transform: rl.Matrix) void {
        // Draw the entity itself
        for (self.shapes) |shape| {
            shape.draw(transform);
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

    const circle_shape: Shape = .{
        .circle = .{
            .center = .{ .x = 0, .y = 0 },
            .radius = 10,
        },
    };
    const triangle_shape: Shape = .{
        .triangle = .{
            .points = .{
                .{ .x = 0, .y = 10 },
                .{ .x = 5, .y = -5 },
                .{ .x = -5, .y = -5 },
            },
        },
    };

    const entity_1 = Entity{
        .id = 2,
        .shapes = &.{triangle_shape},
        .links = .empty,
    };

    const entity_2 = Entity{
        .id = 2,
        .shapes = &.{circle_shape},
        .links = .empty,
    };

    var entity_3_links: std.ArrayList(Link) = try .initCapacity(allocator, 2);
    entity_3_links.appendAssumeCapacity(.{
        .transform = rl.math.matrixTranslate(20, 0, 0),
        .entity = &entity_1,
    });
    entity_3_links.appendAssumeCapacity(.{
        .transform = rl.math.matrixTranslate(-20, 0, 0),
        .entity = &entity_2,
    });

    const entity_3 = Entity{
        .id = 1,
        .shapes = &.{circle_shape},
        .links = entity_3_links,
    };

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
        entity_3.draw(rl.math.matrixTranslate(
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
