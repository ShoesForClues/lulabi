@echo off
set default_directory=%cd%
cd /d %~dp0

where >nul 2>nul lua

if %errorlevel% equ 0 (
	lua main.lua %*
) else (
	echo Error: Lua is not installed
)

cd /d %default_directory%