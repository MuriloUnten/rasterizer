package main

import "core:mem"
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

get_edge_x :: proc(a: Point, b: Point, y: f32) -> (x: f32, ok: bool) {
    if (a.y <= y && y < b.y) || (b.y <= y && y < a.y) {
        t := (y - a.y) / (b.y - a.y)
        return a.x + t * (b.x - a.x), true
    }
    return 0, false
}

// for triangles, this isn't a problem because exactly one case is guaranteed to fail 
get_scanline_indices :: proc(t: ^Triangle, y: i32) -> (i32, i32) {
    measures := [2]f32{0, 0}
    i := 0

    yf := f32(y)
    if x, ok := get_edge_x(t.a, t.b, yf); ok {
        measures[i] = x
        i += 1
    }
    if x, ok := get_edge_x(t.b, t.c, yf); ok {
        measures[i] = x
        i += 1
    }
    if x, ok := get_edge_x(t.c, t.a, yf); ok {
        measures[i] = x
        i += 1
    }
    start := i32(min(measures[0], measures[1]))
    end := i32(max(measures[0], measures[1]))
    return start, end
}

main :: proc() {
    triangles: [2]Triangle = {
        {{500, 500}, {800, 400}, {200, 200}, rl.BLUE},
        {{400, 700}, {700, 100}, {300, 150}, rl.RED},
    }

    rl.InitWindow(W_WIDTH, W_HEIGHT, "raylib window")
    image := rl.GenImageColor(W_WIDTH, W_HEIGHT, rl.BLACK)
    texture := rl.LoadTextureFromImage(image)

    for !rl.WindowShouldClose() {
        // hack to clear the image buffer very quickly
        // TODO: refactor this into my own framebuffer and decouple from raylib
        mem.zero(image.data, W_WIDTH * W_HEIGHT * size_of(rl.Color))
        framebuffer := cast([^]rl.Color)image.data

        for &t in triangles {
            top    := i32(min(t.a.y, t.b.y, t.c.y))
            bottom := i32(max(t.a.y, t.b.y, t.c.y))

            for y: i32 = top; y <= bottom; y += 1 {
                start_x, end_x := get_scanline_indices(&t, y)
                for x: i32 = start_x; x <= end_x; x += 1 {
                    framebuffer[y * W_WIDTH + x] = t.color
                }
            }
        }

        rl.UpdateTexture(texture, image.data)
        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)
            rl.DrawTexture(texture, 0, 0, rl.WHITE)
            rl.DrawFPS(0, 0)
        rl.EndDrawing()
    }

    rl.UnloadImage(image)
    rl.UnloadTexture(texture)
    rl.CloseWindow()
}
