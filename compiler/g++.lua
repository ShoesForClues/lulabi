return function(thread,build_config) --output,std,include_dir,lib_dir,libs,is_object
	local core_files_string,include_files_string,dependencies_string,cflags_string,defines_string,libs_string="","","","","",""
	for _,file in pairs(build_config.core_files) do
		core_files_string=core_files_string..file.." "
	end
	for _,file in pairs(build_config.includes) do
		include_files_string=include_files_string.."-I "..file.." "
	end
	for _,file in pairs(build_config.dependencies) do
		dependencies_string=dependencies_string.."-l"..file.." "
	end
	for _,cflag in pairs(build_config.cflags) do
		cflags_string=cflags_string.."-"..cflag.." "
	end
	for _,define in pairs(build_config.defines) do
		defines_string=defines_string.."-D "..define.." "
	end
	for _,lib in pairs(build_config.libs) do
		libs_string=libs_string.."-L"..lib.." "
	end
	return thread.platform:execute_command(build_config.compiler.." -o "..build_config.output.." -std="..build_config.std.." "..cflags_string..defines_string..core_files_string..include_files_string..dependencies_string..libs_string)
end