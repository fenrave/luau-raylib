--!strict
--!optimize 2
--!native

-- Based on https://github.com/raysan5/raylib/blob/78a607b778cb806818c8a66d06190dc3548f3786/examples/core/core_3d_camera_fps.c

local raylib = require("@raylib")

local lib = raylib.lib;
local const = raylib.const;
local structs = raylib.structs;

local screenWidth = 800;
local screenHeight = 450;

-- Movement constants
local GRAVITY         = 32.0
local MAX_SPEED       = 20.0
local CROUCH_SPEED    =  5.0
local JUMP_FORCE      = 12.0
local MAX_ACCEL       = 150.0
-- Grounded drag
local FRICTION        = 0.86
-- Increasing air drag, increases strafing speed
local AIR_DRAG        = 0.98
-- Responsiveness for turning movement direction to looked direction
local CONTROL         = 15.0
local CROUCH_HEIGHT   =  0.0
local STAND_HEIGHT    =  1.0
local BOTTOM_HEIGHT   =  0.5

local NORMALIZE_INPUT = 0

local sensitivity = structs.Vector2:new{ x = 0.01, y = 0.01 };

type Body = {
    position: raylib.Vector3,
    velocity: raylib.Vector3,
    dir: raylib.Vector3,
    isGrounded: boolean,
}
local player: Body = {
    position = structs.Vector3:new{ x = 0.0, y = 2.0, z = 0.0 },
    velocity = structs.Vector3:new{ x = 0.0, y = 0.0, z = 0.0 },
    dir = structs.Vector3:new{ x = 0.0, y = 0.0, z = 0.0 },
    isGrounded = false,
}
local lookRotation = structs.Vector2:new{ x = 0.0, y = 0.0 };
local headTimer = 0.0;
local walkLerp = 0.0;
local headLerp = STAND_HEIGHT;
local lean = structs.Vector2:new{ x = 0.0, y = 0.0 };

local function fromVector3(v: raylib.Vector3): vector
    return vector.create(buffer.readf32(v, 0), buffer.readf32(v, 4), buffer.readf32(v, 8));
end

local function toVector3(v: vector): raylib.Vector3
    return structs.Vector3:new{ x = v.x, y = v.y, z = v.z };
end

local function Vector3Angle(a: raylib.Vector3 | vector, b: raylib.Vector3 | vector): number
    local v1: vector = if (type(a) == "buffer") then fromVector3(a) else a;
    local v2: vector = if (type(b) == "buffer") then fromVector3(b) else b;

    return vector.angle(v1, v2);
end

local function Vector3RotateByAxisAngle(vec: raylib.Vector3, axis: raylib.Vector3, angle: number): raylib.Vector3
    local v = fromVector3(vec);
    local ax = fromVector3(axis);

    local length = math.sqrt(ax.x * ax.x + ax.y * ax.y + ax.z * ax.z);
    if (length == 0.0) then
        length = 1.0;
    end
    local ilength = 1.0 / length;

    ax *= vector.create(ilength, ilength, ilength);

    angle /= 2.0;
    local a = math.sin(angle);
    local w = vector.create(ax.x * a, ax.y * a, ax.z * a);
    a = math.cos(angle);

    local wv = vector.create(w.y*v.z - w.z*v.y, w.z*v.x - w.x*v.z, w.x*v.y - w.y*v.x);
    local wwv = vector.create(w.y*wv.z - w.z*wv.y, w.z*wv.x - w.x*wv.z, w.x*wv.y - w.y*wv.x);

    a *= 2.0;
    wv *= a;

    wwv *= 2.0;

    return toVector3(v + wv + wwv);
end

local function vectorlerp(a: vector, b: vector, t: number): vector
    return a + (b - a) * t;
end

local function UpdateBody(body: Body, rot: number, side: number, forward: number, jumpPressed: boolean, crouchHold: boolean)
    local input = vector.create(side, -forward);

    if (NORMALIZE_INPUT) then
        -- Slow down diagonal movement
        if (side ~= 0 and forward ~= 0) then
            input = vector.normalize(input);
        end
    end

    local delta = lib.GetFrameTime();

    if (not body.isGrounded) then
        buffer.writef32(body.velocity, 4, buffer.readf32(body.velocity, 4) - GRAVITY * delta);
    end

    if (body.isGrounded and jumpPressed) then
        buffer.writef32(body.velocity, 4, JUMP_FORCE);
        body.isGrounded = false;

        -- Sound can be played at this moment
        --SetSoundPitch(fxJump, 1.0f + (GetRandomValue(-100, 100)*0.001));
        --PlaySound(fxJump);
    end

    local front = vector.create(math.sin(rot), 0.0, math.cos(rot));
    local right = vector.create(math.cos(-rot), 0.0, math.sin(-rot));

    local desiredDir = vector.create(input.x*right.x + input.y*front.x, 0.0, input.x*right.z + input.y*front.z);
    buffer.copy(body.dir, 0, toVector3(vectorlerp(fromVector3(body.dir), desiredDir, CONTROL * delta)), 0, 12);

    local decel = if (body.isGrounded) then FRICTION else AIR_DRAG;
    local hvel = vector.create(buffer.readf32(body.velocity, 0) * decel, 0.0, buffer.readf32(body.velocity, 8) * decel);

    local hvelLength = vector.magnitude(hvel); -- Magnitude
    if (hvelLength < (MAX_SPEED * 0.01)) then
        hvel = vector.create(0.0, 0.0, 0.0);
    end

    -- This is what creates strafing
    local speed = vector.dot(hvel, fromVector3(body.dir));

    -- Whenever the amount of acceleration to add is clamped by the maximum acceleration constant,
    -- a Player can make the speed faster by bringing the direction closer to horizontal velocity angle
    -- More info here: https://youtu.be/v3zT3Z5apaM?t=165
    local maxSpeed = if (crouchHold) then CROUCH_SPEED else MAX_SPEED;
    local accel = math.clamp(maxSpeed - speed, 0.0, MAX_ACCEL * delta);
    hvel += vector.create(buffer.readf32(body.dir, 0) * accel, 0.0, buffer.readf32(body.dir, 8) * accel);

    buffer.writef32(body.velocity, 0, hvel.x);
    buffer.writef32(body.velocity, 8, hvel.z);

    buffer.writef32(body.position, 0, buffer.readf32(body.position, 0) + buffer.readf32(body.velocity, 0) * delta);
    buffer.writef32(body.position, 4, buffer.readf32(body.position, 4) + buffer.readf32(body.velocity, 4) * delta);
    buffer.writef32(body.position, 8, buffer.readf32(body.position, 8) + buffer.readf32(body.velocity, 8) * delta);

    -- Fancy collision system against the floor
    if (buffer.readf32(body.position, 4) <= 0.0) then
        buffer.writef32(body.position, 4, 0.0);
        buffer.writef32(body.velocity, 4, 0.0);
        body.isGrounded = true; -- Enable jumping
    end
end

local function UpdateCameraFPS(camera: raylib.Camera3D)
    local up = structs.Vector3:new{ x = 0.0, y = 1.0, z = 0.0 };
    local targetOffset = structs.Vector3:new{ x = 0.0, y = 0.0, z = -1.0 };

    -- Left and right
    local yaw = Vector3RotateByAxisAngle(targetOffset, up, buffer.readf32(lookRotation, 0));

    -- Clamp view up
    local maxAngleUp = Vector3Angle(up, yaw);
    maxAngleUp -= 0.001; -- Avoid numerical errors
    if ( -(buffer.readf32(lookRotation, 4)) > maxAngleUp) then
        buffer.writef32(lookRotation, 4, -maxAngleUp);
    end

    -- Clamp view down
    local maxAngleDown = Vector3Angle(-fromVector3(up), yaw);
    maxAngleDown *= -1.0; -- Downwards angle is negative
    maxAngleDown += 0.001; -- Avoid numerical errors
    if ( -(buffer.readf32(lookRotation, 4)) < maxAngleDown) then
        buffer.writef32(lookRotation, 4, -maxAngleDown);
    end

    -- Up and down
    local right: raylib.Vector3; do
        local r = vector.cross(fromVector3(yaw), fromVector3(up));
        right = toVector3(vector.normalize(r));
    end

    -- Rotate view vector around right axis
    local pitchAngle = -buffer.readf32(lookRotation, 4) - buffer.readf32(lean, 4);
    pitchAngle = math.clamp(pitchAngle, -math.pi/2 + 0.0001, math.pi/2 - 0.0001); -- Clamp angle so it doesn't go past straight up or straight down
    local pitch = Vector3RotateByAxisAngle(yaw, right, pitchAngle);

    -- Head animation
    -- Rotate up direction around forward axis
    local headSin = math.sin(headTimer*math.pi);
    local headCos = math.cos(headTimer*math.pi);
    local stepRotation = 0.01;
    buffer.copy(camera, 24, Vector3RotateByAxisAngle(up, pitch, headSin*stepRotation + buffer.readf32(lean, 0)), 0, 12);

    -- Camera BOB
    local bobSide = 0.1;
    local bobUp = 0.15;
    local rightVec = fromVector3(right);
    local bobbing = rightVec * (headSin * bobSide);
    bobbing = vector.create(bobbing.x, math.abs(headCos*bobUp), bobbing.z);

    local camera_pos = structs.Vector3:new{ x = 0.0, y = 0.0, z = 0.0 };
    buffer.copy(camera_pos, 0, camera, 0, 12);

    local camera_target_vec = fromVector3(camera_pos) + bobbing * walkLerp;
    buffer.copy(camera, 0, toVector3(camera_target_vec), 0, 12);
    buffer.copy(camera, 12, toVector3(camera_target_vec + fromVector3(pitch)), 0, 12);
end

local function DrawLevel()
    local floorExtent = 25;
    local tileSize = 5.0;
    local tileColor1 = structs.Color:new({ r = 150, g = 200, b = 200, a = 255 });

    -- Floor tiles
    for y = -floorExtent, floorExtent - 1 do
        for x = -floorExtent, floorExtent - 1 do
            if (bit32.band(y, 1) ~= 0 and bit32.band(x, 1) ~= 0) then
                lib.DrawPlane(structs.Vector3:new{ x = x * tileSize, y = 0.0, z = y * tileSize }, structs.Vector2:new{ x = tileSize, y = tileSize }, tileColor1);
            elseif (bit32.band(y, 1) == 0 and bit32.band(x, 1) == 0) then
                lib.DrawPlane(structs.Vector3:new{ x = x * tileSize, y = 0.0, z = y * tileSize }, structs.Vector2:new{ x = tileSize, y = tileSize }, const.LIGHTGRAY);
            end
        end
    end

    local towerSize = structs.Vector3:new{ x = 16.0, y = 32.0, z = 16.0 };
    local towerColor = structs.Color:new({ r = 150, g = 200, b = 200, a = 255 });

    local towerPos = structs.Vector3:new{ x = 16.0, y = 16.0, z = 16.0 };
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);

    buffer.writef32(towerPos, 0, buffer.readf32(towerPos, 0) * -1);
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);

    buffer.writef32(towerPos, 8, buffer.readf32(towerPos, 8) * -1);
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);

    buffer.writef32(towerPos, 0, buffer.readf32(towerPos, 0) * -1);
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);

    -- Red sun
    lib.DrawSphere(structs.Vector3:new{ x = 300.0, y = 300.0, z = 0.0 }, 100.0, structs.Color:new({ r = 255, g = 0, b = 0, a = 255 }));
end

lib.InitWindow(screenWidth, screenHeight, "ZUNE + Raylib - 3d camera fps example");

lib.SetTargetFPS(60);

local fovy = 60.0;
local camera = structs.Camera3D:new{
    position = structs.Vector3:new{ 
        x = buffer.readf32(player.position, 0),
        y = buffer.readf32(player.position, 4) + (BOTTOM_HEIGHT + headLerp),
        z = buffer.readf32(player.position, 8),
    },
    target = structs.Vector3:new{ x = 0.0, y = 2.0, z = 0.0 },
    up = structs.Vector3:new{ x = 0.0, y = 1.0, z = 0.0 },
    fovy = fovy,
    projection = const.CameraProjection.CAMERA_PERSPECTIVE,
};

UpdateCameraFPS(camera);

lib.DisableCursor();

while lib.WindowShouldClose() == 0 do
    local mouseDelta = lib.GetMouseDelta();
    buffer.writef32(lookRotation, 0, buffer.readf32(lookRotation, 0) - buffer.readf32(mouseDelta, 0) * buffer.readf32(sensitivity, 0));
    buffer.writef32(lookRotation, 4, buffer.readf32(lookRotation, 4) + buffer.readf32(mouseDelta, 4) * buffer.readf32(sensitivity, 4));

    local sideway = lib.IsKeyDown(const.KeyboardKey.KEY_D) - lib.IsKeyDown(const.KeyboardKey.KEY_A);
    local forward = lib.IsKeyDown(const.KeyboardKey.KEY_W) - lib.IsKeyDown(const.KeyboardKey.KEY_S);
    local crouching = lib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) ~= 0;
    UpdateBody(player, buffer.readf32(lookRotation, 0), sideway, forward, lib.IsKeyPressed(const.KeyboardKey.KEY_SPACE) ~= 0, crouching);

    local delta = lib.GetFrameTime();
    headLerp = math.lerp(headLerp, if (crouching) then CROUCH_HEIGHT else STAND_HEIGHT, 20.0 * delta);
    buffer.copy(camera, 0, structs.Vector3:new{
        x = buffer.readf32(player.position, 0),
        y = buffer.readf32(player.position, 4) + (BOTTOM_HEIGHT + headLerp),
        z = buffer.readf32(player.position, 8),
    }, 0, 12);

    if (player.isGrounded and (forward ~= 0 or sideway ~= 0)) then
        headTimer += delta * 3.0;
        walkLerp = math.lerp(walkLerp, 1.0, 10.0 * delta);
        fovy = math.lerp(fovy, 55.0, 5.0 * delta);
    else
        walkLerp = math.lerp(walkLerp, 0.0, 10.0 * delta);
        fovy = math.lerp(fovy, 60.0, 5.0 * delta);
    end
    buffer.writef32(camera, 36, fovy);

    UpdateCameraFPS(camera);

    lib.BeginDrawing(); do
        lib.ClearBackground(const.RAYWHITE);

        lib.BeginMode3D(camera); do
            DrawLevel();
        end
        lib.EndMode3D();
    
        lib.DrawFPS(10, 10);
    end
    lib.EndDrawing();
end

lib.CloseWindow();
zune.process.exit(0);
