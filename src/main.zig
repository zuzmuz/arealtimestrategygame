const std = @import("std");
const arealtimestrategygame = @import("arealtimestrategygame");
const rl = @import("raylib");

const Shape = union(enum) {
    circle: struct {
        center: rl.Vector3,
        radius: f32,
    },
    triangle: struct {
        points: [3]rl.Vector3,
    },

    fn draw(self: *const Shape) void {
        switch (self.*) {
            .circle => |*circle| {
                rl.drawCircleV(
                    .{
                        .x = circle.center.x,
                        .y = circle.center.y,
                    },
                    circle.radius,
                    .red,
                );
            },
            .triangle => |*triangle| {
                rl.drawTriangle(
                    .{ .x = triangle.points[0].x, .y = triangle.points[0].y },
                    .{ .x = triangle.points[1].x, .y = triangle.points[1].y },
                    .{ .x = triangle.points[2].x, .y = triangle.points[2].y },
                    .blue,
                );
            },
        }
    }
};

const Entity = struct {
    id: usize,
    shape: Shape,
    links: std.ArrayList(Link),

    fn draw(self: *const Entity) void {
        self.shape.draw();
    }
};

const Link = struct {
    transform: rl.Matrix,
    entity: *Entity,
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
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    
    const links: std.ArrayList(Link) = try .initCapacity(allocator, 0);
    const entity1 = Entity{
        .id = 1,
        .shape = .{
            .circle = .{ .center = .{ .x = 0, .y = 0, .z = 0 }, .radius = 10 },
        },
        .links = links,
    };

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
        entity1.draw();
        // rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}
