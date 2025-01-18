package breakout

import rl "vendor:raylib"

main :: proc()
{
    rl.SetConfigFlags({.VSYNC_HINT});
    rl.InitWindow(800, 800, "Breakout");
    rl.SetTargetFPS(240);

    for !rl.WindowShouldClose()
    {
        rl.BeginDrawing();

        rl.ClearBackground(rl.WHITE);
        rl.DrawText("Hello window!", rl.GetScreenWidth() / 2, rl.GetScreenHeight() / 2, 20, rl.BLACK);

        rl.EndDrawing();
    }

    rl.CloseWindow();
}
