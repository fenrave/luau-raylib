local raylib = require("@raylib")


local lib = raylib.lib
local const = raylib.const
local ffi = zune.ffi

local GetShaderLocation = lib.GetShaderLocation
local SetShaderValue = lib.SetShaderValue

local function float_ptr(value: number): FFIPointer
    local ptr = ffi.create(ffi.types.float)
    ptr:writef32(0, value)
    return ptr
end

--[[+

Rewrite & assets borrowed from
https://github.com/raysan5/raylib/blob/master/examples/shaders/shaders_texture_waves.c

+]]--

local function main(): ()
    
    lib.InitWindow(1000, 600, "Shader Test")
    lib.SetWindowMonitor(0)
    lib.GuiEnable()

    local Texture: raylib.Texture2D = lib.LoadTexture("examples/resources/space.png")

    --[=[+

    @Buffer_offsets

    Since luau doesn't have a native struct system, buffers are used instead to represent them, in Zune at least.
    If you already know how many bytes a value can take up, then you should be able to guess the position in the buffer.

    Textures have an ID (unsigned int), Width/Height value (set by image size, represented by int) -
    - and a mipmaps & format value (stored as ints).

    The buffer positions for these are:

    0-3: ID
    
    4-7: Width
    8-11: Height
    12-15: Mipmap
    16: pixelformat value

    +]=]--

    buffer.writei32(Texture, 4, 1000)
    buffer.writei32(Texture, 8, 600)

    local Shader: raylib.Texture2D = lib.LoadShaderFromMemory(ffi.null,  zune.fs.readFile("examples/resources/wave.fs"))
    
    local secondsLoc: number = GetShaderLocation(Shader, "seconds")
    local freqXLoc: number = GetShaderLocation(Shader, "freqX")
    local freqYLoc: number = GetShaderLocation(Shader, "freqY")
    local ampXLoc: number = GetShaderLocation(Shader, "ampX")
    local ampYLoc: number = GetShaderLocation(Shader, "ampY")
    local speedXLoc: number = GetShaderLocation(Shader, "speedX")
    local speedYLoc: number = GetShaderLocation(Shader, "speedY")
    local size: number = GetShaderLocation(Shader, "size")

    local freqX: number = 25.0
    local freqY: number = 25.0
    local ampX: number = 5.0
    local ampY: number = 5.0
    local speedX: number = 8.0
    local speedY: number = 8.0


    --[=[+
    
    @C_Arrays

    In the original example this was used to represent screen size:
    float screenSize[2] = { (float)GetScreenWidth(), (float)GetScreenHeight() };

    Which is an array containing both the screen height and width. Since Luau tables are entirely different - 
    - We have to use the following:

    +]=]--
    local screenSize: FFIPointer = ffi.create(ffi.types.float:array(2))
    screenSize:writef32(0, lib.GetScreenWidth())
    screenSize:writef32(4, lib.GetScreenHeight())

    --You could potentially make this easier on yourself by wrapping it into a function, but you really only need this for shader interaction.

    SetShaderValue(Shader, size, screenSize, 1)
    SetShaderValue(Shader, freqXLoc, float_ptr(freqX), 0)
    SetShaderValue(Shader, freqXLoc, float_ptr(freqX), 0)
    SetShaderValue(Shader, freqYLoc, float_ptr(freqY), 0)
    SetShaderValue(Shader, ampXLoc, float_ptr(ampX), 0)
    SetShaderValue(Shader, ampYLoc, float_ptr(ampY), 0)
    SetShaderValue(Shader, speedXLoc, float_ptr(speedX), 0)
    SetShaderValue(Shader, speedYLoc, float_ptr(speedY), 0)

    local seconds: number = 0

    while lib.WindowShouldClose() == 0 do
        seconds += lib.GetFrameTime()
        lib.SetShaderValue(Shader, secondsLoc, float_ptr(seconds), 0)


        lib.BeginDrawing(); do
            
            lib.ClearBackground(const.RAYWHITE)

            lib.BeginShaderMode(Shader); do
                
                
                lib.DrawTexture(Texture, 0, 0, const.WHITE)
                lib.DrawTexture(Texture, buffer.readf32(Texture, 4), 0, const.WHITE)

                
            end; lib.EndShaderMode()
            
        end; lib.EndDrawing()
        

    end

    lib.UnloadShader(Shader)
    lib.UnloadTexture(Texture)


end; main()

lib.CloseWindow()
    
zune.process.exit(0)
