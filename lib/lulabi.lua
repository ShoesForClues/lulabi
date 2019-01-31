return function(thread)
	local API={
		_version={0,0,7};
		_dependencies={
			"stdlib";
			"parser";
			"json";
			"lip";
		};
		default={
			core_file_extensions={"c","cc","cpp"};
			header_file_extensions={"h","hpp"};
		};
	}
	
	function API:get_all_descendants(file)
		local files={}
		for _,file_name in pairs(thread.platform:get_sub_files(file)) do
			if file_name~="." and file_name~=".." then
				local sub_file=file.."/"..file_name
				files[#files+1]=sub_file
				local attribute=thread.platform:get_file_attributes(sub_file)
				if attribute.type=="directory" then
					files=thread.libraries["stdlib"]:group_tables(files,API:get_all_descendants(sub_file))
				end
			end
		end
		return files
	end
	
	function API:build(file,build_config)
		if thread.platform:file_exists(file.."/lulabi_make")==true then
			build_config=thread.libraries["stdlib"]:merge_tables(build_config,thread.libraries["json"].decode(thread.platform:read_file(file.."/lulabi_make",thread.runtime.wait)))
		end
	
		build_config=thread.libraries["stdlib"]:merge_tables(build_config,{
			project_name="project";
			compiler="g++";
			std="c++0x";
			output="output";
			includes={};
			dependencies={};
			cflags={};
			defines={};
			core_files={};
			embeds={};
		})
		
		thread.platform:info("Building project: "..tostring(build_config.project_name))
		
		thread.platform:print("Compiler: "..tostring(build_config.compiler))
		thread.platform:print("Standard: "..tostring(build_config.std))
		
		if thread.platform:file_exists("compiler/"..build_config.compiler..".lua")==true then
			local compiler=thread.platform:require("compiler/"..build_config.compiler)
			
			build_config.output=file.."/"..build_config.output
			
			local sub_includes={file}
			
			for i,embed in pairs(build_config.embeds) do
				local attributes=thread.platform:get_file_attributes(file.."/"..embed)
				if attributes.type=="directory" then
					sub_includes[#sub_includes+1]=file.."/"..embed
				end
			end
			
			for i,include in pairs(build_config.includes) do
				build_config.includes[i]=file.."/"..include
				for _,sub_file in pairs(API:get_all_descendants(build_config.includes[i])) do
					local attributes=thread.platform:get_file_attributes(sub_file)
					if attributes.type=="directory" then
						sub_includes[#sub_includes+1]=sub_file
					end
				end
			end
			build_config.includes=thread.libraries["stdlib"]:group_tables(build_config.includes,sub_includes)
			
			for _,sub_file in pairs(API:get_all_descendants(file)) do
				if #thread.libraries["stdlib"]:find(API.default.core_file_extensions,thread.libraries["parser"]:get_extension(thread.libraries["parser"]:get_name(sub_file)))>0 then
					build_config.core_files[#build_config.core_files+1]=sub_file
				end
			end
			
			thread.platform:info(compiler(thread,build_config))
			thread.platform:info("Finished.")
		else
			thread.platform:info("Error: Cannot find compiler "..build_config.compiler)
		end
	end
	
	return API
end