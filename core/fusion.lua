--[[************************************************************

	 ______  __  __   ______   __   ______   __   __    
	/\  ___\/\ \/\ \ /\  ___\ /\ \ /\  __ \ /\ "-.\ \   
	\ \  __\\ \ \_\ \\ \___  \\ \ \\ \ \_\ \\ \ \-.  \  
	 \ \_\   \ \_____\\/\_____\\ \_\\ \_____\\ \_\\"\_\ 
	  \/_/    \/_____/ \/_____/ \/_/ \/_____/ \/_/ \/_/ 

	Fusion framework created by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

local fusion={
	_version={0,7,0};
	configuration={
		show_splash_screen=false;
		dependencies_folder="core/dep";
	};
	libraries={};
	dependencies={
		"eztask";
	};
}

function fusion:import(library,library_name)
	if library_name==nil then return fusion:output("Library name is required") end
	fusion.libraries[library_name]=library
	if type(fusion.libraries[library_name])=="table" then
		fusion.libraries[library_name].platform=fusion.platform
	end
	if fusion.libraries[library_name]~=nil then
		fusion.platform:info("Imported: "..library_name)
	else
		fusion.platform:info("Failed to import: "..library_name)
	end
	return fusion.libraries[library_name]
end

function fusion:setup(file)
	fusion.platform=file
	if fusion.platform==nil then return end
	
	fusion.platform.directory=file
	
	fusion.platform:info("Fusion Framework created by Jason Lee")
	fusion.platform:info("Version: "..fusion._version[1].."."..fusion._version[2].."."..fusion._version[3])
	
	for _,library_name in pairs(fusion.dependencies) do
		fusion:import(fusion.platform:require(fusion.configuration.dependencies_folder.."/"..library_name),library_name)
	end
	
	fusion.scheduler=fusion.libraries["eztask"]:create_scheduler({
		thread_initialization=function(current_thread)
			current_thread.platform=fusion.platform;
		end;
		platform=fusion.platform;
		cycle_speed=60;
	})
	
	fusion.platform.update_stepped:attach_bind(function()
		for _,output in pairs(fusion.scheduler:cycle(fusion.platform:get_tick())) do
			fusion.platform:info(output)
		end
	end)
end

return fusion