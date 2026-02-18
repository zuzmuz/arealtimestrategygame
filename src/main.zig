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

/// Entity represent
const Entity = struct {
    id: usize,
    shape: Shape,
    links: []const Link,

    fn draw(self: *const Entity, transform: rl.Matrix) void {
        // Draw the entity itself
        self.shape.draw(transform);

        // Draw linked entities
        for (self.links) |link| {
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
    // const allocator = arena.allocator();

    rl.initWindow(screenWidth, screenHeight, "aRealTimeStrategyGame");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
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
        .shape = triangle_shape,
        .links = &.{},
    };

    const entity_2 = Entity{
        .id = 2,
        .shape = circle_shape,
        .links = &.{},
    };


    const entity_3 = Entity{
        .id = 1,
        .shape = circle_shape,
        .links = &.{
            .{
                .transform = rl.math.matrixTranslate(20, 0, 0),
                .entity = &entity_1,
            },
            .{
                .transform = rl.math.matrixTranslate(-20, 0, 0),
                .entity = &entity_2,
            },
        },
    };

    // links.append(allocator, .{ )

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

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
        // rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}
