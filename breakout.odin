package breakout

import rl "vendor:raylib"

SCREEN_SIZE :: 400;
PLAYER_WIDTH :: 50;
PLAYER_HEIGHT :: 6;
PLAYER_SPEED :: 200;
PLAYER_POS_Y :: 340;

playerPosX: f32;

restart :: proc()
{
    playerPosX = SCREEN_SIZE / 2 - PLAYER_WIDTH / 2;
}

main :: proc()
{
    rl.SetConfigFlags({.VSYNC_HINT});
    rl.InitWindow(800, 800, "Breakout");
    rl.SetTargetFPS(240);

    restart();

    for !rl.WindowShouldClose()
    {
        dt := rl.GetFrameTime();

        playerVelocity: f32;

        if rl.IsKeyDown(.LEFT)
        {
            playerVelocity -= PLAYER_SPEED;
        }
        if rl.IsKeyDown(.RIGHT)
        {
            playerVelocity += PLAYER_SPEED;
        }
        playerPosX += playerVelocity * dt;
        playerPosX = clamp(playerPosX, 0, SCREEN_SIZE - PLAYER_WIDTH);

        rl.BeginDrawing();
        rl.ClearBackground({150, 190, 220, 255});

        camera: rl.Camera2D = {
            zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE)
        };

        rl.BeginMode2D(camera);

        playerRect: rl.Rectangle = {
            playerPosX, PLAYER_POS_Y,
            PLAYER_WIDTH, PLAYER_HEIGHT
        };
        rl.DrawRectangleRec(playerRect, {50, 150, 90, 255});

        rl.EndMode2D();
        rl.EndDrawing();
    }

    rl.CloseWindow();
}
