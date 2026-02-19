const rl = @import("raylib");

pub const Shape = union(enum) {
    circle: struct {
        center: rl.Vector2,
        radius: f32,
    },
    triangle: struct {
        points: [3]rl.Vector2,
    },

    pub fn draw(
        self: *const Shape,
        transform: rl.Matrix,
        color: rl.Color,
    ) void {
        switch (self.*) {
            .circle => |*circle| {
                const transformed = rl.math.vector2Transform(
                    circle.center,
                    transform,
                );
                rl.drawCircleV(
                    transformed,
                    circle.radius,
                    color,
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
                    color,
                );
            },
        }
    }
};

pub const base: []const Shape = &.{.{
    .triangle = .{
        .points = .{
            .{ .x = 0, .y = -20 },
            .{ .x = -17.32, .y = 10 },
            .{ .x = 17.32, .y = 10 },
        },
    },
}};

pub const res_drop: []const Shape = &.{ .{
    .triangle = .{
        .points = .{
            .{ .x = -13.2, .y = 5 },
            .{ .x = 13.2, .y = 5 },
            .{ .x = -13.2, .y = -5 },
        },
    },
}, .{
    .triangle = .{
        .points = .{
            .{ .x = -13.2, .y = -5 },
            .{ .x = 13.2, .y = 5 },
            .{ .x = 13.2, .y = -5 },
        },
    },
}, .{
    .circle = .{ .center = .{ .x = 0, .y = 0 }, .radius = 7 },
} };
