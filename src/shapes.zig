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

const base_measure = 50;
const sqrt3 = 1.732;

const base_size = 1.3;
pub const base: []const Shape = &.{.{
    .triangle = .{ .points = .{
        .{ .x = 0, .y = -base_size * base_measure },
        .{
            .x = -0.5 * base_size * sqrt3 * base_measure,
            .y = 0.5 * base_size * base_measure,
        },
        .{
            .x = 0.5 * sqrt3 * base_size * base_measure,
            .y = 0.5 * base_size * base_measure,
        },
    } },
}};

const res_size = 0.5;
pub const res_drop: []const Shape = &.{ .{
    .triangle = .{ .points = .{
        .{ .x = -1.2 * res_size * base_measure, .y = -0.5 * res_size * base_measure },
        .{ .x = -1.2 * res_size * base_measure, .y = 0.5 * res_size * base_measure },
        .{ .x = 1.2 * res_size * base_measure, .y = 0.5 * res_size * base_measure },
    } },
}, .{
    .triangle = .{ .points = .{
        .{ .x = -1.2 * res_size * base_measure, .y = -0.5 * res_size * base_measure },
        .{ .x = 1.2 * res_size * base_measure, .y = 0.5 * res_size * base_measure },
        .{ .x = 1.2 * res_size * base_measure, .y = -0.5 * res_size * base_measure },
    } },
}, .{
    .circle = .{
        .center = .{ .x = 0, .y = 0 },
        .radius = 0.75 * res_size * base_measure,
    },
} };

const worker_size = 0.1;
pub const worker: []const Shape = &.{.{
    .circle = .{
        .center = .{ .x = 0, .y = 0 },
        .radius = worker_size * base_measure,
    },
}};

const war_factory_size = 1;
pub const war_factory: []const Shape = &.{ .{
    .triangle = .{ .points = .{
        .{ .x = -war_factory_size * base_measure, .y = -0.7 * war_factory_size * base_measure },
        .{ .x = -war_factory_size * base_measure, .y = 0.7 * war_factory_size * base_measure },
        .{ .x = war_factory_size * base_measure, .y = -0.7 * war_factory_size * base_measure },
    } },
}, .{
    .triangle = .{ .points = .{
        .{ .x = war_factory_size * base_measure, .y = -0.7 * war_factory_size * base_measure },
        .{ .x = -war_factory_size * base_measure, .y = 0.7 * war_factory_size * base_measure },
        .{ .x = war_factory_size * base_measure, .y = 0.7 * war_factory_size * base_measure },
    } },
}, .{
    .triangle = .{ .points = .{
        .{ .x = -0.6 * war_factory_size * base_measure, .y = 0.7 * war_factory_size * base_measure },
        .{ .x = -0.4 * war_factory_size * base_measure, .y = war_factory_size * base_measure },
        .{ .x = -0.2 * war_factory_size * base_measure, .y = 0.7 * war_factory_size * base_measure },
    } },
}, .{
    .triangle = .{ .points = .{
        .{ .x = 0.2 * war_factory_size * base_measure, .y = 0.7 * war_factory_size * base_measure },
        .{ .x = 0.4 * war_factory_size * base_measure, .y = war_factory_size * base_measure },
        .{ .x = 0.6 * war_factory_size * base_measure, .y = 0.7 * war_factory_size * base_measure },
    } },
}, .{
    .triangle = .{ .points = .{
        .{ .x = -0.2 * war_factory_size * base_measure, .y = -0.7 * war_factory_size * base_measure },
        .{ .x = -0.4 * war_factory_size * base_measure, .y = -war_factory_size * base_measure },
        .{ .x = -0.6 * war_factory_size * base_measure, .y = -0.7 * war_factory_size * base_measure },
    } },
}, .{
    .triangle = .{ .points = .{
        .{ .x = 0.6 * war_factory_size * base_measure, .y = -0.7 * war_factory_size * base_measure },
        .{ .x = 0.4 * war_factory_size * base_measure, .y = -war_factory_size * base_measure },
        .{ .x = 0.2 * war_factory_size * base_measure, .y = -0.7 * war_factory_size * base_measure },
    } },
} };

const tank_size = 0.3;
pub const tank: []const Shape = &.{ .{
    .triangle = .{ .points = .{
        .{ .x = -tank_size * base_measure, .y = -tank_size * base_measure },
        .{ .x = -tank_size * base_measure, .y = tank_size * base_measure },
        .{ .x = tank_size * base_measure, .y = -tank_size * base_measure },
    } },
}, .{
    .triangle = .{ .points = .{
        .{ .x = tank_size * base_measure, .y = -tank_size * base_measure },
        .{ .x = -tank_size * base_measure, .y = tank_size * base_measure },
        .{ .x = tank_size * base_measure, .y = tank_size * base_measure },
    } },
}, .{
    .circle = .{ .center = .{
        .x = 0,
        .y = -tank_size * base_measure,
    }, .radius = 0.5 * tank_size * base_measure },
} };

const fighter_size = 0.3;
pub const fighter: []const Shape = &.{.{
    .triangle = .{ .points = .{
        .{ .x = 0, .y = -1.5 * fighter_size * base_measure },
        .{ .x = -0.375 * fighter_size * base_measure, .y = 0 },
        .{ .x = 0.375 * fighter_size * base_measure, .y = 0 },
    } },
}};
