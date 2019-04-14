# LuLABI
Lua Lightweight Application Building Interface [Version 0.1.2]

Software created by Jason Lee © 2019

LuLABI (lullaby) is a build system written in pure lua that allows the user to easily compile 
their C/C++ projects.

# Installation
You must install lua such as [LuaRocks](https://github.com/luarocks/luarocks) in order to run LuLABI.

Once lua has been installed, you must then install LuaFileSystem. Some lua interpreters may already include it.

Installing LFS on Luarocks:
```luarocks install luafilesystem```

You will also need some compiler such as:

- [GCC/G++](https://gcc.gnu.org/) (Linux/Unix/[MinGW](https://osdn.net/projects/mingw/releases/))
- [DJGPP](https://github.com/andrewwutw/build-djgpp) (Linux/DOS/Windows)
- [Visual Studio](https://visualstudio.microsoft.com/) (Windows)

# Usage
```
lulabi build -c <compiler> -std <c_standard> -o <output_file> -f <source>

-c <compiler>           Select compiler (default g++ | configured from lulabi_make)
-std <c_standard>       Select C/C++ standard (default c++0x | configured from lulabi_make)
-o <output_file>        Set output file (default "output" | configured from lulabi_make)
-f <source>             Set source directory to compile
```

It is recommended to use a lulabi_make file, which is a JSON encoded text file:
```json
{
	"project_name": "test",
	"output": "test",
	"compiler": "g++",
	"std": "gnu++0x",
	"dependencies": [],
	"includes": ["include_directory"],
	"libs": [],
	"embeds": [],
	"cflags": ["O2","Wall","s"],
	"defines": []
}
```
You can then build the project as so:
```
rem You must use the full path to the source directory
lulabi build -f C:/Users/%username%/desktop/test
```

The lulabi_make file should be in the root of the source directory.

# License
This software is free to use. You can modify it and redistribute it under the terms of the 
MIT license. Check [LICENSE](LICENSE) for further details.
