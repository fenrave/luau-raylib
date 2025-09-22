--!strict
--!optimize 2
--!native

local ffi = zune.ffi;

local int = ffi.types.i32;
local uint = ffi.types.u32;
local bool = ffi.types.u8;
local float = ffi.types.float;

local function array(t: any, n: number): FFIStructureType
    local fields = {};
    for i = 1, n do
        table.insert(fields, { [`_{i}`] = t });
    end
    return ffi.struct(fields);
end

local Vector2 = ffi.struct({
    { x = float },
    { y = float },
});
export type Vector2 = typeof(Vector2:new({}))

local Vector3 = ffi.struct({
    { x = float },
    { y = float },
    { z = float },
});
export type Vector3 = typeof(Vector3:new({}))

local Vector4 = ffi.struct({
    { x = float },
    { y = float },
    { z = float },
    { w = float },
});
export type Vector4 = typeof(Vector4:new({}))

local Quaternion = Vector4;
export type Quaternion = typeof(Quaternion:new({}))

local Matrix = ffi.struct({
    { m0 = float }, { m4 = float }, { m8 = float }, { m12 = float },
    { m1 = float }, { m5 = float }, { m9 = float }, { m13 = float },
    { m2 = float }, { m6 = float }, { m10 = float }, { m14 = float },
    { m3 = float }, { m7 = float }, { m11 = float }, { m15 = float },
});
export type Matrix = typeof(Matrix:new({}))

local Color = ffi.struct({
    { r = ffi.types.u8 },
    { g = ffi.types.u8 },
    { b = ffi.types.u8 },
    { a = ffi.types.u8 },
});
export type Color = typeof(Color:new({}))

local Rectangle = ffi.struct({
    { x = float },
    { y = float },
    { width = float },
    { height = float },
});
export type Rectangle = typeof(Rectangle:new({}))

local Image = ffi.struct({
    { data = ffi.types.pointer },
    { width = int },
    { height = int },
    { mipmaps = int },
    { format = int },
});
export type Image = typeof(Image:new({}))

local Texture = ffi.struct({
    { id = uint },
    { width = int },
    { height = int },
    { mipmaps = int },
    { format = int },
});
export type Texture = typeof(Texture:new({}))

local Texture2D = Texture;
export type Texture2D = typeof(Texture2D:new({}))

local TextureCubemap = Texture;
export type TextureCubemap = typeof(TextureCubemap:new({}))

local RenderTexture = ffi.struct({
    { id = uint },
    { texture = Texture },
    { depth = Texture },
});
export type RenderTexture = typeof(RenderTexture:new({}))

local RenderTexture2D = RenderTexture;
export type RenderTexture2D = typeof(RenderTexture2D:new({}))

local NPatchInfo = ffi.struct({
    { source = Rectangle },
    { left = int },
    { top = int },
    { right = int },
    { bottom = int },
    { layout = int },
});
export type NPatchInfo = typeof(NPatchInfo:new({}))

local GlyphInfo = ffi.struct({
    { value = int },
    { offsetX = int },
    { offsetY = int },
    { advanceX = int },
    { image = Image },
});
export type GlyphInfo = typeof(GlyphInfo:new({}))

local Font = ffi.struct({
    { baseSize = int },
    { glyphCount = int },
    { glyphPadding = int },
    { texture = Texture2D },
    { recs = ffi.types.pointer },
    { glyphs = ffi.types.pointer },
});
export type Font = typeof(Font:new({}))

local Camera3D = ffi.struct({
    { position = Vector3 },
    { target = Vector3 },
    { up = Vector3 },
    { fovy = float },
    { projection = int },
});
export type Camera3D = typeof(Camera3D:new({}))

local Camera = Camera3D;

local Camera2D = ffi.struct({
    { offset = Vector2 },
    { target = Vector2 },
    { rotation = float },
    { zoom = float },
});
export type Camera2D = typeof(Camera2D:new({}))

local Mesh = ffi.struct({
    { vertexCount = int },
    { triangleCount = int },
    { vertices = ffi.types.pointer },
    { texcoords = ffi.types.pointer },
    { texcoords2 = ffi.types.pointer },
    { normals = ffi.types.pointer },
    { tangents = ffi.types.pointer },
    { colors = ffi.types.pointer },
    { indices = ffi.types.pointer },
    { animVertices = ffi.types.pointer },
    { animNormals = ffi.types.pointer },
    { boneIds = ffi.types.pointer },
    { boneWeights = ffi.types.pointer },
    { vaoId = uint },
    { vboId = ffi.types.pointer },
});
export type Mesh = typeof(Mesh:new({}))

local Shader = ffi.struct({
    { id = uint },
    { locs = ffi.types.pointer },
});
export type Shader = typeof(Shader:new({}))

local MaterialMap = ffi.struct({
    { texture = Texture2D },
    { color = Color },
    { value = float },
});
export type MaterialMap = typeof(MaterialMap:new({}))

local float2 = ffi.struct({{_1 = float}, {_2 = float}});
local float4 = ffi.struct({{_1 = float}, {_2 = float}, {_3 = float}, {_4 = float}});

local Material = ffi.struct({
    { shader = Shader },
    { maps = ffi.types.pointer },
    { params = float4},
});
export type Material = typeof(Material:new({}))

local Transform = ffi.struct({
    { translation = Vector3 },
    { rotation = Quaternion },
    { scale = Vector3 },
});
export type Transform = typeof(Transform:new({}))

local BoneInfo = ffi.struct({
    { name = array(ffi.types.u8, 32) },
    { parent = int },
});
export type BoneInfo = typeof(BoneInfo:new({}))

local Model = ffi.struct({
    { transform = Matrix },
    { meshCount = int },
    { materialCount = int },
    { meshes = ffi.types.pointer },
    { materials = ffi.types.pointer },
    { meshMaterial = ffi.types.pointer },
    { boneCount = int },
    { bones = ffi.types.pointer },
    { bindPose = ffi.types.pointer },
});
export type Model = typeof(Model:new({}))

local ModelAnimation = ffi.struct({
    { boneCount = int },
    { frameCount = int },
    { bones = ffi.types.pointer },
    { framePoses = ffi.types.pointer },
    { name = array(ffi.types.u8, 32) },
});
export type ModelAnimation = typeof(ModelAnimation:new({}))

local Ray = ffi.struct({
    { position = Vector3 },
    { direction = Vector3 },
});
export type Ray = typeof(Ray:new({}))

local RayCollision = ffi.struct({
    { hit = bool },
    { distance = float },
    { point = Vector3 },
    { normal = Vector3 },
});
export type RayCollision = typeof(RayCollision:new({}))

local BoundingBox = ffi.struct({
    { min = Vector3 },
    { max = Vector3 },
});
export type BoundingBox = typeof(BoundingBox:new({}))

local Wave = ffi.struct({
    { frameCount = uint },
    { sampleRate = uint },
    { sampleSize = uint },
    { channels = uint },
    { data = ffi.types.pointer },
});
export type Wave = typeof(Wave:new({}))

local rAudioBuffer = ffi.struct({}); -- opaque
export type rAudioBuffer = typeof(rAudioBuffer:new({}))
local rAudioProcessor = ffi.struct({}); -- opaque
export type rAudioProcessor = typeof(rAudioProcessor:new({}))

local AudioStream = ffi.struct({
    { buffer = ffi.types.pointer },
    { processor = ffi.types.pointer },
    { sampleRate = uint },
    { sampleSize = uint },
    { channels = uint },
});
export type AudioStream = typeof(AudioStream:new({}))

local Sound = ffi.struct({
    { stream = AudioStream },
    { frameCount = uint },
});
export type Sound = typeof(Sound:new({}))

local Music = ffi.struct({
    { stream = AudioStream },
    { frameCount = uint },
    { looping = bool },
    { ctxType = int },
    { ctxData = ffi.types.pointer },
});
export type Music = typeof(Music:new({}))

local VrDeviceInfo = ffi.struct({
    { hResolution = int },
    { vResolution = int },
    { hScreenSize = float },
    { vScreenSize = float },
    { eyeToScreenDistance = float },
    { lensSeparationDistance = float },
    { interpupillaryDistance = float },
    { lensDistortionValues = float4 },
    { chromaAbCorrection = float4 },
});
export type VrDeviceInfo = typeof(VrDeviceInfo:new({}))

local VrStereoConfig = ffi.struct({
    { projection = ffi.struct({{_1 = Matrix}, {_2 = Matrix}}) },
    { viewOffset = ffi.struct({{_1 = Matrix}, {_2 = Matrix}}) },
    { leftLensCenter = float2 },
    { rightLensCenter = float2 },
    { leftScreenCenter = float2 },
    { rightScreenCenter = float2 },
    { scale = float2 },
    { scaleIn = float2 },
});
export type VrStereoConfig = typeof(VrStereoConfig:new({}))

local FilePathList = ffi.struct({
    { capacity = uint },
    { count = uint },
    { paths = ffi.types.pointer },
});
export type FilePathList = typeof(FilePathList:new({}))

local AutomationEvent = ffi.struct({
    { frame = uint },
    { type = uint },
    { params = ffi.struct({{_1 = int}, {_2 = int}, {_3 = int}, {_4 = int}}) },
});
export type AutomationEvent = typeof(AutomationEvent:new({}))

local AutomationEventList = ffi.struct({
    { capacity = uint },
    { count = uint },
    { events = ffi.types.pointer },
});
export type AutomationEventList = typeof(AutomationEventList:new({}))

local export = {
    structs = {
        Vector2 = Vector2,
        Vector3 = Vector3,
        Vector4 = Vector4,
        Quaternion = Quaternion,
        Matrix = Matrix,
        Color = Color,
        Rectangle = Rectangle,
        Image = Image,
        Texture = Texture,
        Texture2D = Texture2D,
        TextureCubemap = TextureCubemap,
        RenderTexture = RenderTexture,
        RenderTexture2D = RenderTexture2D,
        NPatchInfo = NPatchInfo,
        GlyphInfo = GlyphInfo,
        Font = Font,
        Camera3D = Camera3D,
        Camera = Camera,
        Camera2D = Camera2D,
        Mesh = Mesh,
        Shader = Shader,
        MaterialMap = MaterialMap,
        Material = Material,
        Transform = Transform,
        BoneInfo = BoneInfo,
        Model = Model,
        ModelAnimation = ModelAnimation,
        Ray = Ray,
        RayCollision = RayCollision,
        BoundingBox = BoundingBox,
        Wave = Wave,
        rAudioBuffer = rAudioBuffer,
        rAudioProcessor = rAudioProcessor,
        AudioStream = AudioStream,
        Sound = Sound,
        Music = Music,
        VrDeviceInfo = VrDeviceInfo,
        VrStereoConfig = VrStereoConfig,
        FilePathList = FilePathList,
        AutomationEvent = AutomationEvent,
        AutomationEventList = AutomationEventList,
    },
    ptrs = {
        Camera = ffi.types.pointer:newTag("Camera"),
    },

    LIGHTGRAY = Color:new{ r = 200, g = 200, b = 200, a = 255 },
    GRAY = Color:new{ r = 130, g = 130, b = 130, a = 255 },
    DARKGRAY = Color:new{ r = 80, g = 80, b = 80, a = 255 },
    YELLOW = Color:new{ r = 253, g = 249, b = 0, a = 255 },
    GOLD = Color:new{ r = 255, g = 203, b = 0, a = 255 },
    ORANGE = Color:new{ r = 255, g = 161, b = 0, a = 255 },
    PINK = Color:new{ r = 255, g = 109, b = 194, a = 255 },
    RED = Color:new{ r = 230, g = 41, b = 55, a = 255 },
    MAROON = Color:new{ r = 190, g = 33, b = 55, a = 255 },
    GREEN = Color:new{ r = 0, g = 228, b = 48, a = 255 },
    LIME = Color:new{ r = 0, g = 158, b = 47, a = 255 },
    DARKGREEN = Color:new{ r = 0, g = 117, b = 44, a = 255 },
    SKYBLUE = Color:new{ r = 102, g = 191, b = 255, a = 255 },
    BLUE = Color:new{ r = 0, g = 121, b = 241, a = 255 },
    DARKBLUE = Color:new{ r = 0, g = 82, b = 172, a = 255 },
    PURPLE = Color:new{ r = 200, g = 122, b = 255, a = 255 },
    VIOLET = Color:new{ r = 135, g = 60, b = 190, a = 255 },
    DARKPURPLE = Color:new{ r = 112, g = 31, b = 126, a = 255 },
    BEIGE = Color:new{ r = 211, g = 176, b = 131, a = 255 },
    BROWN = Color:new{ r = 127, g = 106, b = 79, a = 255 },
    DARKBROWN = Color:new{ r = 76, g = 63, b = 47, a = 255 },

    WHITE = Color:new{ r = 255, g = 255, b = 255, a = 255 },
    BLACK = Color:new{ r = 0, g = 0, b = 0, a = 255 },
    BLANK = Color:new{ r = 0, g = 0, b = 0, a = 0 },
    MAGENTA = Color:new{ r = 255, g = 0, b = 255, a = 255 },
    RAYWHITE = Color:new{ r = 245, g = 245, b = 245, a = 255 },

    ConfigFlags = {
        FLAG_VSYNC_HINT         = 0x00000040,   -- Set to try enabling V-Sync on GPU
        FLAG_FULLSCREEN_MODE    = 0x00000002,   -- Set to run program in fullscreen
        FLAG_WINDOW_RESIZABLE   = 0x00000004,   -- Set to allow resizable window
        FLAG_WINDOW_UNDECORATED = 0x00000008,   -- Set to disable window decoration (frame and buttons)
        FLAG_WINDOW_HIDDEN      = 0x00000080,   -- Set to hide window
        FLAG_WINDOW_MINIMIZED   = 0x00000200,   -- Set to minimize window (iconify)
        FLAG_WINDOW_MAXIMIZED   = 0x00000400,   -- Set to maximize window (expanded to monitor)
        FLAG_WINDOW_UNFOCUSED   = 0x00000800,   -- Set to window non focused
        FLAG_WINDOW_TOPMOST     = 0x00001000,   -- Set to window always on top
        FLAG_WINDOW_ALWAYS_RUN  = 0x00000100,   -- Set to allow windows running while minimized
        FLAG_WINDOW_TRANSPARENT = 0x00000010,   -- Set to allow transparent framebuffer
        FLAG_WINDOW_HIGHDPI     = 0x00002000,   -- Set to support HighDPI
        FLAG_WINDOW_MOUSE_PASSTHROUGH = 0x00004000, -- Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
        FLAG_BORDERLESS_WINDOWED_MODE = 0x00008000, -- Set to run program in borderless windowed mode
        FLAG_MSAA_4X_HINT       = 0x00000020,   -- Set to try enabling MSAA 4X
        FLAG_INTERLACED_HINT    = 0x00010000    -- Set to try enabling interlaced video format (for V3D)
    },

    TraceLogLevel = {
        LOG_ALL = 0,        -- Display all logs
        LOG_TRACE = 1,      -- Trace logging, intended for internal use only
        LOG_DEBUG = 2,      -- Debug logging, used for internal debugging, it should be disabled on release builds
        LOG_INFO = 3,       -- Info logging, used for program execution info
        LOG_WARNING = 4,    -- Warning logging, used on recoverable failures
        LOG_ERROR = 5,      -- Error logging, used on unrecoverable failures
        LOG_FATAL = 6,      -- Fatal logging, used to abort program: exit(EXIT_FAILURE)
        LOG_NONE = 7        -- Disable logging
    },

    KeyboardKey = {
        KEY_NULL            = 0,        -- Key: NULL, used for no key pressed
        -- Alphanumeric keys
        KEY_APOSTROPHE      = 39,       -- Key: '
        KEY_COMMA           = 44,       -- Key: ,
        KEY_MINUS           = 45,       -- Key: -
        KEY_PERIOD          = 46,       -- Key: .
        KEY_SLASH           = 47,       -- Key: /
        KEY_ZERO            = 48,       -- Key: 0
        KEY_ONE             = 49,       -- Key: 1
        KEY_TWO             = 50,       -- Key: 2
        KEY_THREE           = 51,       -- Key: 3
        KEY_FOUR            = 52,       -- Key: 4
        KEY_FIVE            = 53,       -- Key: 5
        KEY_SIX             = 54,       -- Key: 6
        KEY_SEVEN           = 55,       -- Key: 7
        KEY_EIGHT           = 56,       -- Key: 8
        KEY_NINE            = 57,       -- Key: 9
        KEY_SEMICOLON       = 59,       -- Key: ;
        KEY_EQUAL           = 61,       -- Key: =
        KEY_A               = 65,       -- Key: A | a
        KEY_B               = 66,       -- Key: B | b
        KEY_C               = 67,       -- Key: C | c
        KEY_D               = 68,       -- Key: D | d
        KEY_E               = 69,       -- Key: E | e
        KEY_F               = 70,       -- Key: F | f
        KEY_G               = 71,       -- Key: G | g
        KEY_H               = 72,       -- Key: H | h
        KEY_I               = 73,       -- Key: I | i
        KEY_J               = 74,       -- Key: J | j
        KEY_K               = 75,       -- Key: K | k
        KEY_L               = 76,       -- Key: L | l
        KEY_M               = 77,       -- Key: M | m
        KEY_N               = 78,       -- Key: N | n
        KEY_O               = 79,       -- Key: O | o
        KEY_P               = 80,       -- Key: P | p
        KEY_Q               = 81,       -- Key: Q | q
        KEY_R               = 82,       -- Key: R | r
        KEY_S               = 83,       -- Key: S | s
        KEY_T               = 84,       -- Key: T | t
        KEY_U               = 85,       -- Key: U | u
        KEY_V               = 86,       -- Key: V | v
        KEY_W               = 87,       -- Key: W | w
        KEY_X               = 88,       -- Key: X | x
        KEY_Y               = 89,       -- Key: Y | y
        KEY_Z               = 90,       -- Key: Z | z
        KEY_LEFT_BRACKET    = 91,       -- Key: [
        KEY_BACKSLASH       = 92,       -- Key: '\'
        KEY_RIGHT_BRACKET   = 93,       -- Key: ]
        KEY_GRAVE           = 96,       -- Key: `
        -- Function keys
        KEY_SPACE           = 32,       -- Key: Space
        KEY_ESCAPE          = 256,      -- Key: Esc
        KEY_ENTER           = 257,      -- Key: Enter
        KEY_TAB             = 258,      -- Key: Tab
        KEY_BACKSPACE       = 259,      -- Key: Backspace
        KEY_INSERT          = 260,      -- Key: Ins
        KEY_DELETE          = 261,      -- Key: Del
        KEY_RIGHT           = 262,      -- Key: Cursor right
        KEY_LEFT            = 263,      -- Key: Cursor left
        KEY_DOWN            = 264,      -- Key: Cursor down
        KEY_UP              = 265,      -- Key: Cursor up
        KEY_PAGE_UP         = 266,      -- Key: Page up
        KEY_PAGE_DOWN       = 267,      -- Key: Page down
        KEY_HOME            = 268,      -- Key: Home
        KEY_END             = 269,      -- Key: End
        KEY_CAPS_LOCK       = 280,      -- Key: Caps lock
        KEY_SCROLL_LOCK     = 281,      -- Key: Scroll down
        KEY_NUM_LOCK        = 282,      -- Key: Num lock
        KEY_PRINT_SCREEN    = 283,      -- Key: Print screen
        KEY_PAUSE           = 284,      -- Key: Pause
        KEY_F1              = 290,      -- Key: F1
        KEY_F2              = 291,      -- Key: F2
        KEY_F3              = 292,      -- Key: F3
        KEY_F4              = 293,      -- Key: F4
        KEY_F5              = 294,      -- Key: F5
        KEY_F6              = 295,      -- Key: F6
        KEY_F7              = 296,      -- Key: F7
        KEY_F8              = 297,      -- Key: F8
        KEY_F9              = 298,      -- Key: F9
        KEY_F10             = 299,      -- Key: F10
        KEY_F11             = 300,      -- Key: F11
        KEY_F12             = 301,      -- Key: F12
        KEY_LEFT_SHIFT      = 340,      -- Key: Shift left
        KEY_LEFT_CONTROL    = 341,      -- Key: Control left
        KEY_LEFT_ALT        = 342,      -- Key: Alt left
        KEY_LEFT_SUPER      = 343,      -- Key: Super left
        KEY_RIGHT_SHIFT     = 344,      -- Key: Shift right
        KEY_RIGHT_CONTROL   = 345,      -- Key: Control right
        KEY_RIGHT_ALT       = 346,      -- Key: Alt right
        KEY_RIGHT_SUPER     = 347,      -- Key: Super right
        KEY_KB_MENU         = 348,      -- Key: KB menu
        -- Keypad keys
        KEY_KP_0            = 320,      -- Key: Keypad 0
        KEY_KP_1            = 321,      -- Key: Keypad 1
        KEY_KP_2            = 322,      -- Key: Keypad 2
        KEY_KP_3            = 323,      -- Key: Keypad 3
        KEY_KP_4            = 324,      -- Key: Keypad 4
        KEY_KP_5            = 325,      -- Key: Keypad 5
        KEY_KP_6            = 326,      -- Key: Keypad 6
        KEY_KP_7            = 327,      -- Key: Keypad 7
        KEY_KP_8            = 328,      -- Key: Keypad 8
        KEY_KP_9            = 329,      -- Key: Keypad 9
        KEY_KP_DECIMAL      = 330,      -- Key: Keypad .
        KEY_KP_DIVIDE       = 331,      -- Key: Keypad /
        KEY_KP_MULTIPLY     = 332,      -- Key: Keypad *
        KEY_KP_SUBTRACT     = 333,      -- Key: Keypad -
        KEY_KP_ADD          = 334,      -- Key: Keypad +
        KEY_KP_ENTER        = 335,      -- Key: Keypad Enter
        KEY_KP_EQUAL        = 336,      -- Key: Keypad =
        -- Android key buttons
        KEY_BACK            = 4,        -- Key: Android back button
        KEY_MENU            = 5,        -- Key: Android menu button
        KEY_VOLUME_UP       = 24,       -- Key: Android volume up button
        KEY_VOLUME_DOWN     = 25        -- Key: Android volume down button
    },

    MouseButton = {
        MOUSE_BUTTON_LEFT    = 0,       -- Mouse button left
        MOUSE_BUTTON_RIGHT   = 1,       -- Mouse button right
        MOUSE_BUTTON_MIDDLE  = 2,       -- Mouse button middle (pressed wheel)
        MOUSE_BUTTON_SIDE    = 3,       -- Mouse button side (advanced mouse device)
        MOUSE_BUTTON_EXTRA   = 4,       -- Mouse button extra (advanced mouse device)
        MOUSE_BUTTON_FORWARD = 5,       -- Mouse button forward (advanced mouse device)
        MOUSE_BUTTON_BACK    = 6,       -- Mouse button back (advanced mouse device)
    },

    MouseCursor = {
        MOUSE_CURSOR_DEFAULT       = 0,     -- Default pointer shape
        MOUSE_CURSOR_ARROW         = 1,     -- Arrow shape
        MOUSE_CURSOR_IBEAM         = 2,     -- Text writing cursor shape
        MOUSE_CURSOR_CROSSHAIR     = 3,     -- Cross shape
        MOUSE_CURSOR_POINTING_HAND = 4,     -- Pointing hand cursor
        MOUSE_CURSOR_RESIZE_EW     = 5,     -- Horizontal resize/move arrow shape
        MOUSE_CURSOR_RESIZE_NS     = 6,     -- Vertical resize/move arrow shape
        MOUSE_CURSOR_RESIZE_NWSE   = 7,     -- Top-left to bottom-right diagonal resize/move arrow shape
        MOUSE_CURSOR_RESIZE_NESW   = 8,     -- The top-right to bottom-left diagonal resize/move arrow shape
        MOUSE_CURSOR_RESIZE_ALL    = 9,     -- The omnidirectional resize/move cursor shape
        MOUSE_CURSOR_NOT_ALLOWED   = 10     -- The operation-not-allowed shape
    },

    GamepadButton = {
        GAMEPAD_BUTTON_UNKNOWN = 0,              -- Unknown button, just for error checking
        GAMEPAD_BUTTON_LEFT_FACE_UP = 1,         -- Gamepad left DPAD up button
        GAMEPAD_BUTTON_LEFT_FACE_RIGHT = 2,      -- Gamepad left DPAD right button
        GAMEPAD_BUTTON_LEFT_FACE_DOWN = 3,       -- Gamepad left DPAD down button
        GAMEPAD_BUTTON_LEFT_FACE_LEFT = 4,       -- Gamepad left DPAD left button
        GAMEPAD_BUTTON_RIGHT_FACE_UP = 5,        -- Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
        GAMEPAD_BUTTON_RIGHT_FACE_RIGHT = 6,     -- Gamepad right button right (i.e. PS3: Circle, Xbox: B)
        GAMEPAD_BUTTON_RIGHT_FACE_DOWN = 7,      -- Gamepad right button down (i.e. PS3: Cross, Xbox: A)
        GAMEPAD_BUTTON_RIGHT_FACE_LEFT = 8,      -- Gamepad right button left (i.e. PS3: Square, Xbox: X)
        GAMEPAD_BUTTON_LEFT_TRIGGER_1 = 9,       -- Gamepad top/back trigger left (first), it could be a trailing button
        GAMEPAD_BUTTON_LEFT_TRIGGER_2 = 10,      -- Gamepad top/back trigger left (second), it could be a trailing button
        GAMEPAD_BUTTON_RIGHT_TRIGGER_1 = 11,     -- Gamepad top/back trigger right (first), it could be a trailing button
        GAMEPAD_BUTTON_RIGHT_TRIGGER_2 = 12,     -- Gamepad top/back trigger right (second), it could be a trailing button
        GAMEPAD_BUTTON_MIDDLE_LEFT = 13,         -- Gamepad center buttons, left one (i.e. PS3: Select)
        GAMEPAD_BUTTON_MIDDLE = 14,              -- Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
        GAMEPAD_BUTTON_MIDDLE_RIGHT = 15,        -- Gamepad center buttons, right one (i.e. PS3: Start)
        GAMEPAD_BUTTON_LEFT_THUMB = 16,          -- Gamepad joystick pressed button left
        GAMEPAD_BUTTON_RIGHT_THUMB = 17          -- Gamepad joystick pressed button right
    },

    GamepadAxis = {
        GAMEPAD_AXIS_LEFT_X        = 0,     -- Gamepad left stick X axis
        GAMEPAD_AXIS_LEFT_Y        = 1,     -- Gamepad left stick Y axis
        GAMEPAD_AXIS_RIGHT_X       = 2,     -- Gamepad right stick X axis
        GAMEPAD_AXIS_RIGHT_Y       = 3,     -- Gamepad right stick Y axis
        GAMEPAD_AXIS_LEFT_TRIGGER  = 4,     -- Gamepad back trigger left, pressure level: [1..-1]
        GAMEPAD_AXIS_RIGHT_TRIGGER = 5      -- Gamepad back trigger right, pressure level: [1..-1]
    },

    CameraMode = {
        CAMERA_CUSTOM       = 0,          -- Camera custom, controlled by user (UpdateCamera() does nothing)
        CAMERA_FREE         = 1,          -- Camera free mode
        CAMERA_ORBITAL      = 2,          -- Camera orbital, around target, zoom supported
        CAMERA_FIRST_PERSON = 3,          -- Camera first person
        CAMERA_THIRD_PERSON = 4           -- Camera third person
    },

    CameraProjection = {
        CAMERA_PERSPECTIVE  = 0,          -- Perspective projection
        CAMERA_ORTHOGRAPHIC = 1           -- Orthographic projection
    },
}

return export;