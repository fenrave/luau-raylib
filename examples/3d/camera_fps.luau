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

local sensitivity: raylib.Vector2 = vector.create(0.01, 0.01)

type Body = {
    position: raylib.Vector3,
    velocity: raylib.Vector3,
    dir: raylib.Vector3,
    isGrounded: boolean,
}
local player: Body = {
    position = vector.create(0.0, 2.0, 0.0),
    velocity = vector.zero,
    dir = vector.zero,
    isGrounded = false,
}
local lookRotation: raylib.Vector2 = vector.zero;
local headTimer = 0.0;
local walkLerp = 0.0;
local headLerp = STAND_HEIGHT;
local lean: raylib.Vector2 = vector.zero;

local function Vector3RotateByAxisAngle(v: raylib.Vector3, axis: raylib.Vector3, angle: number): raylib.Vector3
    local length = vector.magnitude(axis);
    if (length == 0.0) then
        length = 1.0;
    end
    local ilength = 1.0 / length;

    axis *= vector.create(ilength, ilength, ilength);

    angle /= 2.0;
    local a = math.sin(angle);
    local w = vector.create(axis.x * a, axis.y * a, axis.z * a);
    a = math.cos(angle);

    local wv = vector.create(w.y*v.z - w.z*v.y, w.z*v.x - w.x*v.z, w.x*v.y - w.y*v.x);
    local wwv = vector.create(w.y*wv.z - w.z*wv.y, w.z*wv.x - w.x*wv.z, w.x*wv.y - w.y*wv.x);

    a *= 2.0;
    wv *= a;

    wwv *= 2.0;

    return v + wv + wwv;
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
        body.velocity -= vector.create(0.0, GRAVITY * delta, 0.0);
    end

    if (body.isGrounded and jumpPressed) then
        body.velocity += vector.create(0.0, JUMP_FORCE, 0.0);
        body.isGrounded = false;

        -- Sound can be played at this moment
        --SetSoundPitch(fxJump, 1.0f + (GetRandomValue(-100, 100)*0.001));
        --PlaySound(fxJump);
    end

    local front = vector.create(math.sin(rot), 0.0, math.cos(rot));
    local right = vector.create(math.cos(-rot), 0.0, math.sin(-rot));

    local desiredDir = vector.create(input.x*right.x + input.y*front.x, 0.0, input.x*right.z + input.y*front.z);
    body.dir = vectorlerp(body.dir, desiredDir, CONTROL * delta);

    local decel = if (body.isGrounded) then FRICTION else AIR_DRAG;
    local hvel = body.velocity * vector.create(decel, 0.0, decel);

    local hvelLength = vector.magnitude(hvel); -- Magnitude
    if (hvelLength < (MAX_SPEED * 0.01)) then
        hvel = vector.create(0.0, 0.0, 0.0);
    end

    -- This is what creates strafing
    local speed = vector.dot(hvel, body.dir);

    -- Whenever the amount of acceleration to add is clamped by the maximum acceleration constant,
    -- a Player can make the speed faster by bringing the direction closer to horizontal velocity angle
    -- More info here: https://youtu.be/v3zT3Z5apaM?t=165
    local maxSpeed = if (crouchHold) then CROUCH_SPEED else MAX_SPEED;
    local accel = math.clamp(maxSpeed - speed, 0.0, MAX_ACCEL * delta);
    hvel += body.dir * vector.create(accel, 0.0, accel);

    body.velocity = vector.create(hvel.x, body.velocity.y, hvel.z);

    body.position += body.velocity * delta;

    -- Fancy collision system against the floor
    if (body.position.y <= 0.0) then
        body.position *= vector.create(1.0, 0.0, 1.0);
        body.velocity *= vector.create(1.0, 0.0, 1.0);
        body.isGrounded = true; -- Enable jumping
    end
end

local function UpdateCameraFPS(camera: raylib.Camera3D)
    local up = vector.create(0.0, 1.0, 0.0);
    local targetOffset = vector.create(0.0, 0.0, -1.0);

    -- Left and right
    local yaw = Vector3RotateByAxisAngle(targetOffset, up, lookRotation.x);

    -- Clamp view up
    local maxAngleUp = vector.angle(up, yaw);
    maxAngleUp -= 0.001; -- Avoid numerical errors
    if ( -lookRotation.y > maxAngleUp) then
        lookRotation = vector.create(lookRotation.x, -maxAngleUp, lookRotation.z);
    end

    -- Clamp view down
    local maxAngleDown = vector.angle(-up, yaw);
    maxAngleDown *= -1.0; -- Downwards angle is negative
    maxAngleDown += 0.001; -- Avoid numerical errors
    if ( -lookRotation.y < maxAngleDown) then
        lookRotation = vector.create(lookRotation.x, -maxAngleDown, lookRotation.z);
    end

    -- Up and down
    local right: raylib.Vector3 = vector.cross(yaw, up);
    right = vector.normalize(right);

    -- Rotate view vector around right axis
    local pitchAngle = -lookRotation.y - lean.y;
    pitchAngle = math.clamp(pitchAngle, -math.pi/2 + 0.0001, math.pi/2 - 0.0001); -- Clamp angle so it doesn't go past straight up or straight down
    local pitch = Vector3RotateByAxisAngle(yaw, right, pitchAngle);

    -- Head animation
    -- Rotate up direction around forward axis
    local headSin = math.sin(headTimer*math.pi);
    local headCos = math.cos(headTimer*math.pi);
    local stepRotation = 0.01;
    zune.mem.writeVector3(camera, 24, Vector3RotateByAxisAngle(up, pitch, headSin*stepRotation + lean.x));

    -- Camera BOB
    local bobSide = 0.1;
    local bobUp = 0.15;
    local bobbing = right * (headSin * bobSide);
    bobbing = vector.create(bobbing.x, math.abs(headCos*bobUp), bobbing.z);

    local camera_pos = zune.mem.toVector3(camera, 0);

    local camera_target_vec = camera_pos + bobbing * walkLerp;
    zune.mem.writeVector3(camera, 0, camera_target_vec);
    zune.mem.writeVector3(camera, 12, camera_target_vec + pitch);
end

local function DrawLevel()
    local floorExtent = 25;
    local tileSize = 5.0;
    local tileColor1 = structs.Color:new({ r = 150, g = 200, b = 200, a = 255 });

    -- Floor tiles
    for y = -floorExtent, floorExtent - 1 do
        for x = -floorExtent, floorExtent - 1 do
            if (bit32.band(y, 1) ~= 0 and bit32.band(x, 1) ~= 0) then
                lib.DrawPlane(vector.create(x * tileSize, 0.0, y * tileSize), vector.create(tileSize, tileSize), tileColor1);
            elseif (bit32.band(y, 1) == 0 and bit32.band(x, 1) == 0) then
                lib.DrawPlane(vector.create(x * tileSize, 0.0, y * tileSize), vector.create(tileSize, tileSize), const.LIGHTGRAY);
            end
        end
    end

    local towerSize = vector.create(16.0, 32.0, 16.0);
    local towerColor = structs.Color:new({ r = 150, g = 200, b = 200, a = 255 });

    local towerPos = vector.create(16.0, 16.0, 16.0);
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);

    towerPos *= vector.create(-1.0, 1.0, 1.0);
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);
    
    towerPos *= vector.create(1.0, 1.0, -1.0);
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);
    
    towerPos *= vector.create(-1.0, 1.0, 1.0);
    lib.DrawCubeV(towerPos, towerSize, towerColor);
    lib.DrawCubeWiresV(towerPos, towerSize, const.DARKBLUE);

    -- Red sun
    lib.DrawSphere(vector.create(300.0, 300.0, 0), 100.0, structs.Color:new({ r = 255, g = 0, b = 0, a = 255 }));
end

lib.InitWindow(screenWidth, screenHeight, "ZUNE + Raylib - 3d camera fps example");

lib.SetTargetFPS(60);

local fovy = 60.0;
local camera = structs.Camera3D:new{
    position = player.position + vector.create(0.0, BOTTOM_HEIGHT + headLerp, 0.0),
    target = vector.create(0.0, 2.0, 0.0),
    up = vector.create(0.0, 1.0, 0.0),
    fovy = fovy,
    projection = const.CameraProjection.CAMERA_PERSPECTIVE,
};

UpdateCameraFPS(camera);

lib.DisableCursor();

while lib.WindowShouldClose() == 0 do
    local mouseDelta = lib.GetMouseDelta();
    lookRotation += vector.create(-mouseDelta.x * sensitivity.x, mouseDelta.y * sensitivity.y);

    local sideway = lib.IsKeyDown(const.KeyboardKey.KEY_D) - lib.IsKeyDown(const.KeyboardKey.KEY_A);
    local forward = lib.IsKeyDown(const.KeyboardKey.KEY_W) - lib.IsKeyDown(const.KeyboardKey.KEY_S);
    local crouching = lib.IsKeyDown(const.KeyboardKey.KEY_LEFT_CONTROL) ~= 0;
    UpdateBody(player, lookRotation.x, sideway, forward, lib.IsKeyPressed(const.KeyboardKey.KEY_SPACE) ~= 0, crouching);

    local delta = lib.GetFrameTime();
    headLerp = math.lerp(headLerp, if (crouching) then CROUCH_HEIGHT else STAND_HEIGHT, 20.0 * delta);
    zune.mem.writeVector3(camera, 0, player.position + vector.create(0.0, BOTTOM_HEIGHT + headLerp, 0.0));

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
