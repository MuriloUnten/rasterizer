package main

import "core:fmt"
import rl "vendor:raylib"

W_WIDTH :: 1024
W_HEIGHT :: 768

Vec2 :: [2]f32
Vec3 :: [3]f32

Point :: Vec2

Triangle :: struct {
    a: Point,
    b: Point,
    c: Point,
    color: rl.Color,
}

vec2_dot_product :: proc(a, b: Vec2) -> f32 {
    return a.x * b.x + a.y * b.y
}

vec3_dot_product :: proc(a, b: Vec3) -> f32 {
    return (a.x * b.x) + (a.y * b.y) + (a.z + b.z)
}

vec2_perpendicular :: proc(vec: Vec2) -> Vec2 {
    return Vec2{vec.y, -vec.x}
}

left_of_line :: proc(line_start: Point, line_end: Point, point: Point) -> bool {
    line_perpendicular := vec2_perpendicular((line_end - line_start).xy)
    dot := vec2_dot_product(line_perpendicular, (point - line_start).xy)
    return dot >= 0
}

point_in_triangle :: proc(t: ^Triangle, point: Point) -> bool {
    left_of_ab := left_of_line(t.a, t.b, point)
    left_of_bc := left_of_line(t.b, t.c, point)
    left_of_ca := left_of_line(t.c, t.a, point)
    return left_of_ab && left_of_bc && left_of_ca
}

main :: proc() {
    triangles: [2]Triangle = {
        {{500, 500}, {800, 400}, {200, 200}, rl.BLUE},
        {{400, 700}, {700, 100}, {300, 150}, rl.RED},
    }

    rl.InitWindow(W_WIDTH, W_HEIGHT, "raylib window")
    framebuffer := rl.GenImageColor(W_WIDTH, W_HEIGHT, rl.BLACK)
    texture := rl.LoadTextureFromImage(framebuffer)

    for !rl.WindowShouldClose() {
        for &t in triangles {
            left   := i32(min(t.a.x, t.b.x, t.c.x))
            top    := i32(min(t.a.y, t.b.y, t.c.y))
            right  := i32(max(t.a.x, t.b.x, t.c.x))
            bottom := i32(max(t.a.y, t.b.y, t.c.y))

            for y: i32 = top; y <= bottom; y += 1 {
                for x: i32 = left; x <= right; x += 1 {
                    pixel := Vec2{f32(x), f32(y)}

                    if point_in_triangle(&t, pixel) { 
                        rl.ImageDrawPixel(&framebuffer, x, y, t.color)
                    }
                }
            }
        }

        rl.UpdateTexture(texture, framebuffer.data)
        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)
            rl.DrawTexture(texture, 0, 0, rl.WHITE)
            rl.DrawFPS(0, 0)
        rl.EndDrawing()
    }

    rl.UnloadImage(framebuffer)
    rl.UnloadTexture(texture)
    rl.CloseWindow()
}
