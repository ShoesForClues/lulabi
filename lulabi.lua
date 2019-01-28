local fusion=require("core/fusion")
local platform=require("platform/default")

platform._config.hide_info=true
fusion:setup(platform)
platform._config.hide_info=false

fusion.scheduler:create_thread(function(thread)
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/parser","parser")
	thread:import("lib/json","json")
	thread:import("lib/lip","lip")
	thread:import("lib/lulabi","lulabi")
	
	if arg==nil or #arg<=0 then
		thread.platform:print("Lua Light Application Building Interface [Version "..tostring(thread.libraries["lulabi"]._version[1]).."."..tostring(thread.libraries["lulabi"]._version[2]).."."..tostring(thread.libraries["lulabi"]._version[3]).."]")
		thread.platform:print("Software created by Jason Lee (c) 2019")
		thread.platform:print("Type 'lulabi help' for a list of commands")
	elseif thread.libraries["stdlib"].root_functions.string.lower(arg[1])=="help" then
		thread.platform:print("usage: lulabi build -c <compiler> -std <c_standard> -o <output_file> -f <source_directory>")
		thread.platform:print("")
		thread.platform:print("options:")
		thread.platform:print("-c <compiler>                Select compiler (default GCC | configured from lulabi_make)")
		thread.platform:print("-std <c_standard>            Select C standard (default c++0x | configured from lulabi_make)")
		thread.platform:print("-o <output_file>             Set output file (default 'output' | configured from lulabi_make)")
		thread.platform:print("-f <source_directory>        Set source directory to compile")
	elseif thread.libraries["stdlib"].root_functions.string.lower(arg[1])=="build" then
		local _,file=thread.libraries["parser"]:get_option(arg,"-f","string")
		local _,compiler=thread.libraries["parser"]:get_option(arg,"-c","string")
		local _,std=thread.libraries["parser"]:get_option(arg,"-std","string")
		local _,output=thread.libraries["parser"]:get_option(arg,"-o","string")
		
		if file~=nil and thread.platform:file_exists(file)==true then
			
		else
			thread.platform:print("Error: Source directory invalid")
		end
	end
	thread.platform:exit()
end)

fusion.platform:initialize({
	window_title="lulabi";
})

return 0