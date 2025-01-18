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
NUM_BLOCKS_X :: 10;
NUM_BLOCKS_Y :: 8;
BLOCK_WIDTH :: 36;
BLOCK_HEIGHT :: 12;

BlockColor :: enum
{
    YELLOW,
    GREEN,
    PURPLE,
    RED
}

rowColors := [NUM_BLOCKS_Y]BlockColor {
    .RED,
    .RED,
    .PURPLE,
    .PURPLE,
    .GREEN,
    .GREEN,
    .YELLOW,
    .YELLOW
};

blockColorValues := [BlockColor]rl.Color {
    .YELLOW = {255, 250, 150, 255},
    .GREEN = {180, 245, 190, 255},
    .PURPLE = {170, 120, 250, 255},
    .RED = {250, 90, 85, 255}
}

blocks: [NUM_BLOCKS_X][NUM_BLOCKS_Y]bool;
playerPosX: f32;
ballPos: rl.Vector2;
ballDir: rl.Vector2;
started: bool;

restart :: proc()
{
    playerPosX = SCREEN_SIZE / 2 - PLAYER_WIDTH / 2;
    ballPos = {SCREEN_SIZE / 2, BALL_START_Y};
    started = false;

    for x in 0..<NUM_BLOCKS_X
    {
        for y in 0..<NUM_BLOCKS_Y
        {
            blocks[x][y] = true;
        }
    }
}

reflect :: proc(dir: rl.Vector2, normal: rl.Vector2) -> rl.Vector2
{
    newDir := linalg.reflect(dir, linalg.normalize(normal));
    return linalg.normalize(newDir);
}

calcBlockRect :: proc(x: int, y: int) -> rl.Rectangle
{
    return {
        f32(20 + x * BLOCK_WIDTH),
        f32(40 + y * BLOCK_HEIGHT),
        BLOCK_WIDTH,
        BLOCK_HEIGHT
    };
}

blockExists :: proc(x: int, y: int) -> bool
{
    if x < 0 || y < 0 || x >= NUM_BLOCKS_X || y >= NUM_BLOCKS_Y
    {
        return false;
    }

    return blocks[x][y];
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
                SCREEN_SIZE / 2 + f32(math.cos(rl.GetTime()) * SCREEN_SIZE / 2.5),
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

        prevBallPos := ballPos;
        ballPos += ballDir * BALL_SPEED * dt;

        if ballPos.x + BALL_RADIUS > SCREEN_SIZE
        {
            ballPos.x = SCREEN_SIZE - BALL_RADIUS;
            ballDir = reflect(ballDir, {-1, 0});
        }
        if ballPos.x - BALL_RADIUS < 0
        {
            ballPos.x = BALL_RADIUS;
            ballDir = reflect(ballDir, {1, 0});
        }
        if ballPos.y - BALL_RADIUS < 0
        {
            ballPos.y = BALL_RADIUS;
            ballDir = reflect(ballDir, {0, 1});
        }
        if ballPos.y > SCREEN_SIZE + BALL_RADIUS * 6
        {
            restart();
        }

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

        playerRect := rl.Rectangle{
            playerPosX, PLAYER_POS_Y,
            PLAYER_WIDTH, PLAYER_HEIGHT
        };

        if rl.CheckCollisionCircleRec(ballPos, BALL_RADIUS, playerRect)
        {
            collisionNormal: rl.Vector2;

            if prevBallPos.y < playerRect.y + playerRect.height
            {
                collisionNormal += {0, -1};
                ballPos.y = playerRect.y - BALL_RADIUS;
            }
            if prevBallPos.y > playerRect.y + playerRect.height
            {
                collisionNormal += {0, 1};
                ballPos.y = playerRect.y + playerRect.height + BALL_RADIUS;
            }
            if prevBallPos.x < playerRect.x
            {
                collisionNormal += {-1, 0};
            }
            if prevBallPos.x > playerRect.x + playerRect.width
            {
                collisionNormal += {1, 0};
            }

            if collisionNormal != 0
            {
                ballDir = reflect(ballDir, collisionNormal);
            }
        }

        blockXLoop: for x in 0..<NUM_BLOCKS_X
        {
            for y in 0..<NUM_BLOCKS_Y
            {
                if blocks[x][y] == false
                {
                    continue;
                }

                blockRect := calcBlockRect(x, y);

                if rl.CheckCollisionCircleRec(ballPos, BALL_RADIUS, blockRect)
                {
                    collisionNormal: rl.Vector2;

                    if prevBallPos.y < blockRect.y
                    {
                        collisionNormal += {0, -1};
                    }
                    if prevBallPos.y > blockRect.y + blockRect.height
                    {
                        collisionNormal += {0, 1};
                    }
                    if prevBallPos.x < blockRect.x
                    {
                        collisionNormal += {-1, 0};
                    }
                    if prevBallPos.x > blockRect.x + blockRect.width
                    {
                        collisionNormal += {1, 0};
                    }

                    if blockExists(x + int(collisionNormal.x), y)
                    {
                        collisionNormal.x = 0;
                    }
                    if blockExists(x, y + int(collisionNormal.y))
                    {
                        collisionNormal.y = 0;
                    }

                    if collisionNormal != 0
                    {
                        ballDir = reflect(ballDir, collisionNormal);
                    }

                    blocks[x][y] = false;
                    break blockXLoop;
                }
            }
        }

        rl.BeginDrawing();
        rl.ClearBackground({150, 190, 220, 255});

        camera := rl.Camera2D{
            zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE)
        };

        rl.BeginMode2D(camera);

        rl.DrawRectangleRec(playerRect, {50, 150, 90, 255});
        rl.DrawCircleV(ballPos, BALL_RADIUS, {200, 90, 20, 255});

        for x in 0..<NUM_BLOCKS_X
        {
            for y in 0..<NUM_BLOCKS_Y
            {
                if blocks[x][y] == false
                {
                    continue;
                }

                blockRect := calcBlockRect(x, y);

                topLeft := rl.Vector2{blockRect.x, blockRect.y};
                topRight := rl.Vector2{blockRect.x + blockRect.width, blockRect.y};
                bottomLeft := rl.Vector2{blockRect.x, blockRect.y + blockRect.height};
                bottomRight := rl.Vector2{blockRect.x + blockRect.width, blockRect.y + blockRect.height};

                rl.DrawRectangleRec(blockRect, blockColorValues[rowColors[y]]);
                rl.DrawLineEx(topLeft, topRight, 1, {255, 255, 150, 100});
                rl.DrawLineEx(topLeft, bottomLeft, 1, {255, 255, 150, 100});
                rl.DrawLineEx(topRight, bottomRight, 1, {0, 0, 50, 100});
                rl.DrawLineEx(bottomLeft, bottomRight, 1, {0, 0, 50, 100});
            }
        }

        rl.EndMode2D();
        rl.EndDrawing();
    }

    rl.CloseWindow();
}
