package breakout

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

SCREEN_SIZE :: 400;
PLAYER_WIDTH :: 50;
PLAYER_HEIGHT :: 6;
PLAYER_SPEED :: 200;
PLAYER_POS_Y :: 340;
BALL_SPEED :: 260;
BALL_RADIUS :: 4;
BALL_START_Y :: 200;

playerPosX: f32;
ballPos: rl.Vector2;
ballDir: rl.Vector2;
started: bool;

restart :: proc()
{
    playerPosX = SCREEN_SIZE / 2 - PLAYER_WIDTH / 2;
    ballPos = {SCREEN_SIZE / 2, BALL_START_Y};
    started = false;
}

main :: proc()
{
    rl.SetConfigFlags({.VSYNC_HINT});
    rl.InitWindow(800, 800, "Breakout");
    rl.SetTargetFPS(240);

    restart();

    for !rl.WindowShouldClose()
    {
        dt: f32;

        if !started
        {
            ballPos = {
                SCREEN_SIZE / 2 + f32(math.cos(rl.GetTime())) * SCREEN_SIZE / 2.5,
                BALL_START_Y
            };

            if rl.IsKeyPressed(.SPACE)
            {
                playerMiddle := rl.Vector2{playerPosX + PLAYER_WIDTH / 2, PLAYER_POS_Y};
                ballToPlayer := playerMiddle - ballPos;
                ballDir = linalg.normalize0(ballToPlayer);
                started = true;
            }
        }
        else
        {
            dt = rl.GetFrameTime();
        }

        ballPos += ballDir * BALL_SPEED * dt;
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

        camera := rl.Camera2D{
            zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE)
        };

        rl.BeginMode2D(camera);

        playerRect := rl.Rectangle{
            playerPosX, PLAYER_POS_Y,
            PLAYER_WIDTH, PLAYER_HEIGHT
        };
        rl.DrawRectangleRec(playerRect, {50, 150, 90, 255});
        rl.DrawCircleV(ballPos, BALL_RADIUS, {200, 90, 20, 255});

        rl.EndMode2D();
        rl.EndDrawing();
    }

    rl.CloseWindow();
}
