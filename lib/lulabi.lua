return function(thread)
	local API={
		_version={0,1,2};
		_dependencies={
			"stdlib";
			"parser";
			"json";
			"lip";
			"ansicolors";
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
			build_config=thread.libraries["stdlib"]:merge_tables(build_config,thread.libraries["json"].decode(thread.platform:read_text_file(file.."/lulabi_make",thread.runtime.wait)))
		end
		
		local temp_files={}
	
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
			libs={};
		})
		
		thread.platform:info(thread.libraries["ansicolors"].cyan.."Building: "..thread.libraries["ansicolors"].reset..tostring(build_config.project_name))
		
		thread.platform:info("Compiler: "..tostring(build_config.compiler))
		thread.platform:info("Standard: "..tostring(build_config.std))
		
		if thread.platform:file_exists("compiler/"..build_config.compiler..".lua")==true then
			local compiler=thread.platform:require("compiler/"..build_config.compiler)
			
			build_config.output=file.."/"..build_config.output
			
			local sub_includes={}
			
			for i,embed in pairs(build_config.embeds) do
				local attributes=thread.platform:get_file_attributes(file.."/"..embed)
				if attributes.type=="directory" then
					sub_includes[#sub_includes+1]=file.."/"..embed
					for _,sub_file in pairs(API:get_all_descendants(file.."/"..embed)) do
						local embed_attributes=thread.platform:get_file_attributes(sub_file)
						if embed_attributes.type~="directory" then
							thread.platform:info("Embedding: "..sub_file)
							local embed_name=thread.libraries["stdlib"].root_functions.string.gsub(thread.libraries["parser"]:get_name(sub_file),"%.","_")
							local embed_file=thread.platform:create_file(file.."/"..embed.."/"..embed_name..".h")
							
							local embed_data=thread.platform:read_raw_file(sub_file,thread.runtime.wait)
							
							temp_files[#temp_files+1]=file.."/"..embed.."/"..embed_name..".h"
							embed_file:open("w")
							
							embed_file:write("static const char "..embed_name.."[]={\n")
							
							local current_line,current_line_size="",0
							for a,b in pairs(embed_data) do
								if a<#embed_data then
									current_line=current_line..tostring(b)..","
								else
									current_line=current_line..tostring(b)
								end
								current_line_size=current_line_size+1
								if current_line_size>20 or a>=#embed_data then
									embed_file:write(current_line.."\n")
									current_line=""
									current_line_size=0
								end
							end
							
							embed_file:write("};")
							
							embed_file:close()
						end
					end
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
			build_config.includes=thread.libraries["stdlib"]:group_tables({file},build_config.includes,sub_includes)
			
			for _,include in pairs(build_config.includes) do
				for _,sub_file in pairs(thread.platform:get_sub_files(include)) do
					if #thread.libraries["stdlib"]:find(API.default.core_file_extensions,thread.libraries["parser"]:get_extension(thread.libraries["parser"]:get_name(include.."/"..sub_file)))>0 then
						build_config.core_files[#build_config.core_files+1]=include.."/"..sub_file
					end
				end
			end
			
			--[[
			for _,sub_file in pairs(API:get_all_descendants(file)) do
				if #thread.libraries["stdlib"]:find(API.default.core_file_extensions,thread.libraries["parser"]:get_extension(thread.libraries["parser"]:get_name(sub_file)))>0 then
					build_config.core_files[#build_config.core_files+1]=sub_file
				end
			end
			--]]
			
			if select(1,compiler(thread,build_config))==true then
				thread.platform:info(thread.libraries["ansicolors"].green.."Compiling successful.")
			else
				thread.platform:info(thread.libraries["ansicolors"].red.."Compiling failed.")
			end
		else
			thread.platform:info("Error: Cannot find compiler "..build_config.compiler)
		end
		
		for _,file in pairs(temp_files) do
			thread.platform:info("Deleting temp file: "..file)
			thread.platform:delete_file(file)
		end
	end
	
	return API
end