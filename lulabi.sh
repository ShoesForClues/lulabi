if ! lua_loc="$(type -p "$lua")" || [[ -z $lua_loc ]]; then
	echo >&2 "Error: Lua is not installed!";
	exit 1;
else
	lua lulabi.lua "$@";
fi