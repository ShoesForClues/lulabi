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
	thread:import("lib/ansicolors","ansicolors")
	thread:import("lib/lulabi","lulabi")
	
	if arg==nil or #arg<=0 then
		thread.platform:print("Lua Light Application Building Interface [Version "..thread.libraries["ansicolors"].cyan..tostring(thread.libraries["lulabi"]._version[1])..thread.libraries["ansicolors"].reset.."."..thread.libraries["ansicolors"].cyan..tostring(thread.libraries["lulabi"]._version[2])..thread.libraries["ansicolors"].reset.."."..thread.libraries["ansicolors"].cyan..tostring(thread.libraries["lulabi"]._version[3])..thread.libraries["ansicolors"].reset.."]")
		thread.platform:print("Software created by Jason Lee (c) 2019")
		thread.platform:print("Type '"..thread.libraries["ansicolors"].yellow.."lulabi help"..thread.libraries["ansicolors"].reset.."' for a list of commands")
	elseif thread.libraries["stdlib"].root_functions.string.lower(arg[1])=="help" then
		thread.platform:print("usage: lulabi build -c "..thread.libraries["ansicolors"].blue.."<compiler>"..thread.libraries["ansicolors"].reset.." -std "..thread.libraries["ansicolors"].blue.."<c_standard>"..thread.libraries["ansicolors"].reset.." -o "..thread.libraries["ansicolors"].blue.."<output_file>"..thread.libraries["ansicolors"].reset.." -f "..thread.libraries["ansicolors"].blue.."<source_directory>"..thread.libraries["ansicolors"].reset)
		thread.platform:print("")
		thread.platform:print("options:")
		thread.platform:print("-c "..thread.libraries["ansicolors"].blue.."  <compiler>"..thread.libraries["ansicolors"].reset.."              Select compiler (default g++ | configured from lulabi_make)")
		thread.platform:print("-std "..thread.libraries["ansicolors"].blue.."<c_standard>"..thread.libraries["ansicolors"].reset.."            Select C/C++ standard (default c++0x | configured from lulabi_make)")
		thread.platform:print("-o "..thread.libraries["ansicolors"].blue.."  <output_file>"..thread.libraries["ansicolors"].reset.."           Set output file (default 'output' | configured from lulabi_make)")
		thread.platform:print("-f "..thread.libraries["ansicolors"].blue.."  <source_directory>"..thread.libraries["ansicolors"].reset.."      Set source directory to compile")
	elseif thread.libraries["stdlib"].root_functions.string.lower(arg[1])=="build" then
		local _,file=thread.libraries["parser"]:get_option(arg,"-f","string")
		local _,compiler=thread.libraries["parser"]:get_option(arg,"-c","string")
		local _,std=thread.libraries["parser"]:get_option(arg,"-std","string")
		local _,output=thread.libraries["parser"]:get_option(arg,"-o","string")
		local build_config={
			compiler=compiler;
			std=std;
			output=output;
		}
		
		if file~=nil and thread.platform:file_exists(file)==true then
			thread.libraries["lulabi"]:build(file,build_config)
		else
			thread.platform:info("Error: Source directory invalid")
		end
	end
	thread.platform:exit()
end)

fusion.platform:initialize({
	window_title="lulabi";
})

return 0