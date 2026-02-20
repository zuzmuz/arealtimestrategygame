const rl = @import("raylib");

pub const Shape = union(enum) {
    circle: struct {
        center: rl.Vector2,
        radius: f32,
    },
    triangle: struct {
        points: [3]rl.Vector2,
    },

    pub fn contains(
        self: *const Shape,
        point: rl.Vector2,
        transform: rl.Matrix,
    ) bool {
        switch (self.*) {
            .circle => |*circle| {
                const transformed_center = rl.math.vector2Transform(
                    circle.center,
                    transform,
                );
                const transformed_radius = circle.radius * rl.math.matrixDeterminant(transform);

                return rl.checkCollisionPointCircle(
                    point,
                    transformed_center,
                    transformed_radius,
                );
            },
            .triangle => |*triangle| {
                const points: [3]rl.Vector2 = .{
                    rl.math.vector2Transform(triangle.points[0], transform),
                    rl.math.vector2Transform(triangle.points[1], transform),
                    rl.math.vector2Transform(triangle.points[2], transform),
                };

                return rl.checkCollisionPointTriangle(
                    point,
                    points[0],
                    points[1],
                    points[2],
                );
            },
        }
    }

    pub fn in_selection(
        self: *const Shape,
        selection: rl.Rectangle,
        transform: rl.Matrix,
    ) bool {
        switch (self.*) {
            .circle => |*circle| {
                const transformed_center = rl.math.vector2Transform(
                    circle.center,
                    transform,
                );
                const transformed_radius = circle.radius * rl.math.matrixDeterminant(transform);
                return rl.checkCollisionCircleRec(
                    transformed_center,
                    transformed_radius,
                    selection,
                );
            },
            .triangle => |*triangle| {
                const points: [3]rl.Vector2 = .{
                    rl.math.vector2Transform(triangle.points[0], transform),
                    rl.math.vector2Transform(triangle.points[1], transform),
                    rl.math.vector2Transform(triangle.points[2], transform),
                };
                for (points) |point| {
                    if (rl.checkCollisionPointRec(point, selection)) {
                        return true;
                    }
                }
                const rec_points: [4]rl.Vector2 = .{
                    .{ .x = selection.x, .y = selection.y },
                    .{ .x = selection.x + selection.width, .y = selection.y },
                    .{ .x = selection.x, .y = selection.y + selection.height },
                    .{
                        .x = selection.x + selection.width,
                        .y = selection.y + selection.height,
                    },
                };
                for (rec_points) |rec_point| {
                    if (rl.checkCollisionPointTriangle(
                        rec_point,
                        points[0],
                        points[1],
                        points[2],
                    )) {
                        return true;
                    }
                }
                return false;
            },
        }
    }

    pub fn draw(
        self: *const Shape,
        transform: rl.Matrix,
        color: rl.Color,
        selected: bool,
    ) void {
        switch (self.*) {
            .circle => |*circle| {
                const transformed_center = rl.math.vector2Transform(
                    circle.center,
                    transform,
                );
                var transformed_radius = circle.radius * rl.math.matrixDeterminant(transform);

                if (selected) {
                    transformed_radius += 3;
                }

                rl.drawCircleV(
                    transformed_center,
                    transformed_radius,
                    color,
                );
            },
            .triangle => |*triangle| {
                var points: [3]rl.Vector2 = .{
                    rl.math.vector2Transform(triangle.points[0], transform),
                    rl.math.vector2Transform(triangle.points[1], transform),
                    rl.math.vector2Transform(triangle.points[2], transform),
                };

                if (selected) {
                    const center = rl.Vector2{
                        .x = (points[0].x + points[1].x + points[2].x) / 3,
                        .y = (points[0].y + points[1].y + points[2].y) / 3,
                    };

                    const norm_vectors: [3]rl.Vector2 = .{
                        rl.math.vector2Normalize(
                            rl.math.vector2Subtract(points[0], center),
                        ),
                        rl.math.vector2Normalize(
                            rl.math.vector2Subtract(points[1], center),
                        ),
                        rl.math.vector2Normalize(
                            rl.math.vector2Subtract(points[2], center),
                        ),
                    };

                    points[0] = rl.math.vector2Add(
                        points[0],
                        rl.math.vector2Scale(norm_vectors[0], 3),
                    );
                    points[1] = rl.math.vector2Add(
                        points[1],
                        rl.math.vector2Scale(norm_vectors[1], 3),
                    );
                    points[2] = rl.math.vector2Add(
                        points[2],
                        rl.math.vector2Scale(norm_vectors[2], 3),
                    );
                }

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
