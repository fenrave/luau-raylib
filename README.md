# luau-raylib

Luau bindings for [raylib](https://www.raylib.com/). Powered by [zune](https://github.com/Scythe-Technology/zune).

Base bindings made by Sythivo at [luau-raylib](https://github.com/Scythe-Technology/luau-raylib)

You must provide your own raylib version with raygui built with it.

Make sure raylib isn't compiling with -fvisibility=hidden. Seems to be an issue on Raylibs end, as of Raylib 5.5. It should be exposing all of the modules in the API, but it strips out RayGui symbols.

You might have to copy the contents of raygui.h into a raygui.c, or just rename it. Make sure you toggle the raygui module option in the makefile.
Make sure the `RAYGUI_IMPLEMENTATION` macro is defined.
