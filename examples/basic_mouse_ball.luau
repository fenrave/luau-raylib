--!strict
--!optimize 2
--!native

local raylib = require("@raylib")

local lib = raylib.lib;
local const = raylib.const;
local structs = raylib.structs;

local screenWidth = 800;
local screenHeight = 450;

lib.InitWindow(screenWidth, screenHeight, "ZUNE + Raylib");

lib.SetTargetFPS(240);

local pos: raylib.Vector2 = vector.zero;

local bgColor = structs.Color:new({ r = 16, g = 16, b = 16, a = 255 });

while lib.WindowShouldClose() == 0 do
    lib.BeginDrawing();

    lib.ClearBackground(bgColor);

    pos = lib.GetMousePosition();

    lib.DrawRectangleRounded(structs.Rectangle:new{ x = 350, y = 100, width = 150, height = 100 }, 0.2, 10, const.RED);
    lib.DrawRectangleRoundedLinesEx(structs.Rectangle:new{ x = 350, y = 100, width = 150, height = 100 }, 0.2, 10, 4, const.BLACK);
    lib.DrawCircleV(pos, 40, const.BLUE);

    lib.DrawFPS(10, 10);

    lib.DrawText("ZUNE RAYLIB BINDINGS", 240, 400, 40, const.BLACK);

    lib.EndDrawing();
end

lib.CloseWindow();
zune.process.exit(0);
