package main

import rl "vendor:raylib"

W_WIDTH :: 1024
W_HEIGHT :: 768

main :: proc() {
    rl.InitWindow(W_WIDTH, W_HEIGHT, "raylib window")

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
            rl.ClearBackground(rl.LIGHTGRAY)
            rl.DrawFPS(0, 0)
        rl.EndDrawing()
    }
}
