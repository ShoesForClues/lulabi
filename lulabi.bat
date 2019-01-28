@echo off

where >nul 2>nul lua

if %errorlevel% equ 0 (
	lua lulabi.lua %*
) else (
	echo Error: Lua is not installed!
)