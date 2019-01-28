# LuLABI
Lua Lightweight Application Building Interface [Version 0.0.1]

Software created by Jason Lee © 2019

LuLABI (lullaby) is a build system written in pure lua that allows the user to easily compile 
their C/C++ projects.

# Installation
You must have [LuaRocks](https://github.com/luarocks/luarocks) installed in order to run LuLABI.

Once LuaRocks has been installed, you must then install LuaFileSystem:

```luarocks install luafilesystem```

You will also need some compiler such as:

- [GCC](https://gcc.gnu.org/) (Linux/Unix/[MinGW](https://osdn.net/projects/mingw/releases/))
- [DJGPP](https://github.com/andrewwutw/build-djgpp) (Linux/DOS/Windows)
- [Visual Studio](https://visualstudio.microsoft.com/) (Windows)

# Usage
```
lulabi help
lulabi build -c <compiler> -std <c_standard> -o <output_file> -f <source_directory>

-c <compiler>                Select compiler (default GCC | configured from lulabi_make)
-std <c_standard>            Select C standard (default c++0x | configured from lulabi_make)
-o <output_file>             Set output file (default "output" | configured from lulabi_make)
-f <source_directory>        Set source directory to compile
```

# License
This software is free to use. You can modify it and redistribute it under the terms of the 
MIT license. Check [LICENSE](LICENSE) for further details.
