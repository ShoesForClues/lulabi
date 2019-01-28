# LuLABI
Lua Light Application Building Interface [Version 0.0.1]

Software created by Jason Lee © 2019

LuLABI (lullaby) is a build system written in pure lua that allows the user to easily compile 
their C/C++ projects. The only dependencies are LuaFileSystem which can be acquired from 
LuaRocks, and a compiler such as GCC, DJGPP, Open Watcom or Visual Studio cl. It's supported 
to run in Windows, Linux, Mac OSX, and probably other Unix systems.

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
This software is free to use. You can modify it and redistribute it under 
the terms of the MIT license.
