--________________________________Dependencies_________________________________
local stdplib=require("lib/stdplib")
local lfs=require("lfs")
--_____________________________________________________________________________

local platform={
	_target="none";
	_version={0,3,7};
	_platform={operating_system="unknown";bits=32;};
	_config={
		hide_info=false;
		raw_file_path=false;
	};
	
	start_tick=os.clock();
	
	enum={
		filter_mode={
			linear="linear";
			nearest="nearest";
		};
		blend_mode={
			alpha="alpha";
			multiply="multiply";
			replace="replace";
			screen="screen";
			add="add";
			subtract="subtract";
			lighten="lighten";
			darken="darken";
		};
		blend_alpha_mode={
			alpha_multiply="alphamultiply";
			pre_multiplied="premultiplied";
		};
		audio_state={
			play=0x01;
			stop=0x02;
			pause=0x03;
			resume=0x04;
		};
		file_type={
			image=0x05;
			font=0x06;
			audio=0x07;
			script=0x08;
			model=0x09;
		};
		format={
			color={
				r8="r8";
				rg8="rg8";
				rgba8="rgba8";
				srgba8="srgba8";
				rgba16="rba16";
				r16f="r16f";
				rg16f="rg16f";
				rgba16f="rgba16f";
				r32f="r32f";
				rg32f="rg32f";
				rgba32f="rgba32f";
				rgba4="rgba4";
				rgb5a1="rgb5a1";
				rgb565="rgb565";
				rgb10a2="rgb10a2";
				rg11b10f="rg11b10f";
			};
			depth={
				stencil8="stencil8";
				depth16="depth16";
				depth24="depth24";
				depth32f="depth32f";
				depth24_stencil98="depth24stencil8";
				depth32f_stencil8="depth32f_stencil8";
			};
		};
		screen_mode={
			full_screen="FULL_SCREEN";
			window="WINDOW";
		};
		value_type={
			int={};
			float={};
			matrix_4={};
			vector_4={};
		};
		file_mode={
			read="r";
			write="w";
		};
	};
	
	assets={}; --Asset bank
	
	text_input=stdplib:create_signal();
	key_state=stdplib:create_signal();
	joystick_key_state=stdplib:create_signal();
	mouse_key_state=stdplib:create_signal();
	mouse_moved=stdplib:create_signal();
	wheel_scrolled=stdplib:create_signal();
	mouse_position=stdplib:create_property({x=0,y=0});
	pointers=stdplib:create_property({});

	update_stepped=stdplib:create_signal();
	render_stepped=stdplib:create_signal();
	
	current_screen_mode=stdplib:create_property("WINDOW");
	screen_resolution=stdplib:create_property({x=0,y=0});
	
	output_update=stdplib:create_signal();
	
	default={
		font={};
		current_file="";
	};
}

function platform:get_running_platform()                                                           --Get the platform specs
	if stdplib.root_functions.string.find(stdplib.root_functions.string.lower(select(2,platform:execute_command("ver"))),"windows")~=nil then
		platform._platform={operating_system="windows";bits=32;}
	elseif stdplib.root_functions.string.find(stdplib.root_functions.string.lower(select(2,platform:execute_command("uname"))),"linux")~=nil then
		platform._platform={operating_system="linux";bits=32;}
	elseif stdplib.root_functions.string.find(stdplib.root_functions.string.lower(select(2,platform:execute_command("sw_vers"))),"OS X")~=nil then
		platform._platform={operating_system="osx";bits=32;}
	end
	return platform._platform
end

function platform:execute_command(code,multithread)                                                --Execute OS specific commands
	if code==nil then return end
	local status,output=false,""
	
	if multithread==true then
		
	else
		local handle=io.popen(code)
		if handle~=nil then
			output=handle:read("*a")
			status=handle:close()
		end
	end
	
	return status,output
end

function platform:exit() os.exit() end                                                             --End the program

function platform:print(text) print(text) platform.output_update:invoke(text) end                  --Output text to console
function platform:info(message)                                                                    --Output info to console
	if message==nil or platform._config.hide_info==true then return end
	return platform:print("["..stdplib:get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:get_file(path,current_file)                                                      --Retrieve file via path
	if path==nil then return end
	if platform._config.raw_file_path==true or (stdplib.root_functions.string.find(stdplib.root_functions.string.lower(platform._platform.operating_system),"windows")==nil and stdplib.root_functions.string.find(stdplib.root_functions.string.lower(platform._platform.operating_system),"dos")==nil) then 
		return path
	end
	path=path.." "
	current_file=current_file or platform.default.current_file
	local path_length,step,file_name=stdplib.root_functions.string.len(path),0,""
	for a=1,path_length do
		local char=stdplib.root_functions.string.sub(path,a,a)
		if char~="/" and char~="<" and a<path_length then
			file_name=file_name..char
		else
			if step<=0 and file_name=="root" then
				if stdplib.root_functions.string.find(stdplib.root_functions.string.lower(platform._platform.operating_system),"windows") or stdplib.root_functions.string.find(stdplib.root_functions.string.lower(platform._platform.operating_system),"dos") then
					current_file="C:"
				else
					current_file="/"
				end
			elseif stdplib.root_functions.string.len(file_name)>0 then
				if stdplib.root_functions.string.len(current_file)>0 then
					current_file=current_file.."/"..file_name
				else
					current_file=file_name
				end
			end
			if char=="<" then
				current_file=stdplib:get_parent_directory(current_file,1)
			end
			step=step+1
			file_name=""
		end
	end
	return current_file
end

function platform:file_exists(file)                                                                --Check if file exists
	file=platform:get_file(file)
	local exists,_,code=os.rename(file,file)
	if not exists then
		if code==13 then
			return true
		end
	end
	return exists
end

function platform:get_sub_files(file)                                                              --Get a list of sub files
	local files={}
	for file in lfs.dir(platform:get_file(file)) do
		files[#files+1]=file
	end
	return files
end
function platform:get_file_attributes(file)
	local attributes=lfs.attributes(platform:get_file(file))
	if attributes==nil then return end
	return {
		drive=attributes.dev;
		type=attributes.mode;
		size=attributes.size;
		permissions=attributes.permissions;
		user_owner_id=attributes.uid;
		group_owner_id=attributes.gid;
		time_accessed=attributes.access;
		time_modified=attributes.modification;
	}
end
function platform:get_full_path(file)                                                              --Get full path of file
	return ""
end
function platform:read_text_file(file,yield_call)
	if platform:file_exists(file)==false then return "" end
	local data=""
	local line_count=0
	for line in io.lines(platform:get_file(file)) do
		line_count=line_count+1
		if line_count>1 then
			data=data.."\n"..line
		else
			data=data..line
		end
		if yield_call~=nil then
			yield_call()
		end
	end
	return data
end
function platform:read_raw_file(file,yield_call)
	if platform:file_exists(file)==false then return {} end
	file=platform:get_file(file)
	local f=assert(io.open(file,'rb'))
	local data={}
	repeat
		local str=f:read(4*1024)
		for c in (str or ''):gmatch'.' do
			data[#data+1] = c:byte()
		end
		if yield_call~=nil then
			yield_call()
		end
	until not str
	f:close()
	return data
end
function platform:create_file(file_name)
	if file_name==nil then return end
	
	local source,error=io.open(platform:get_file(file_name),"w")
	
	if error~=nil then
		platform:info(error)
	end
	
	local file={
		source=source;
	}
	
	function file:write(data)
		file.source:write(data)
	end
	function file:clear()
		file.source:flush()
	end
	function file:open(file_mode)
		--file.source:open(file_mode)
	end
	function file:close()
		file.source:close()
	end
	
	return file
end

function platform:create_directory(file)
	return lfs.mkdir(platform:get_file(file))
end
function platform:delete_file(file)
	file=platform:get_file(file)
	if platform:file_exists(file)==false then return end
	local attributes=lfs.attributes(file)
	
	if attributes.type=="directory" then
		return lfs.rmdir(file)
	else
		return os.remove(file)
	end
end

function platform:require(file)                                                                    --Get a value from a lua file
	local success,lib=pcall(require,platform:get_file(file))
	if success==false then
		platform:info(lib)
	end
	return lib
end

function platform:yield(duration)                                                                  --Yield the entire thread
	local s=os.clock()
	while os.clock()-s<=duration do end
end
function platform:get_tick() return os.clock()-platform.start_tick end                             --Get the current clock tick
function platform:get_frame_rate() return 0 end                                                    --Get the current FPS

function platform:get_joystick_key_press(joystick_id,...)                                          --Check if joystick button is pressed
	return false
end
function platform:get_key_press(...) end                                                           --Check if keyboard button is pressed
function platform:get_mouse_key_press(...) end                                                     --Check if mouse button is pressed
function platform:update_pointers()                                                                --Update pointers
	
end

function platform:set_filter_mode(min_mode,max_mode,anistropy)                                     --Set image scaling filter mode
	
end

function platform:set_blend_mode(mode,alpha_mode)                                                  --Set blend mode
	
end

function platform:set_cursor_visibility(state)                                                     --Set cursor visibility
	
end

function platform:set_cursor_lock(state)                                                           --Set cursor lock
	
end

function platform:get_buffer_resolution(buffer)                                                    --Get current screen resolution
	return {x=0,y=0}
end

function platform:get_max_resolution()                                                             --Get max supported screen resolution
	return {x=0,y=0}
end

function platform:load_source(file,file_type,properties)                                           --Load asset in memory for future reference
	if file==nil or file_type==nil then return end
	properties=properties or {}
	if file_type==platform.enum.file_type.image then
		if platform.assets[file]==nil then
			
		end
	elseif file_type==platform.enum.file_type.font then
		if platform.assets[file]==nil then
			
		end
	elseif file_type==platform.enum.file_type.audio then
		if platform.assets[file]==nil then
			
		end
	elseif file_type==platform.enum.file_type.model then
		if platform.assets[file]==nil then
			
		end
	end
	return platform.assets[file]
end
function platform:load_sources(files) if files==nil or type(file)~="table" then return end         --Load multiple files
	for _,file in ipairs(files) do platform:load_source(file[1],file[2],file[3]) end
end
function platform:unload_source(file)                                                              --Unload asset
	if platform.assets[file]~=nil then
		--platform.assets[file]:release()
		platform.assets[file]=nil
	end
end
function platform:clear_sources()                                                                  --Unload every assets
	for i,_ in pairs(platform.assets) do
		platform:unload_source(i)
	end
end

function platform:create_buffer(...)                                                               --Create an external buffer
	
end
function platform:set_current_buffer(...)                                                          --Begin drawing to a buffer
	
end
function platform:clear_buffer(color,opacity,active_buffers)                                       --Clears buffer
	
end

function platform:render_image(source,position,size,rotation,wrap,background_color,source_color,filter_mode,anistropy,buffer) --Render image to the buffer
	
end

function platform:get_text_size(text,font,font_size)
	return {x=0,y=0}
end
function platform:render_text(text,position,wrap,wrapped,color,alignment,font,font_size,buffer)    --Render text to the screen
	
end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio_object={
		source;
	}
	function audio_object:set_source(source)
		
	end
	function audio_object:set_state(state)
		if state==platform.enum.audio_state.play then
			--audio_object.source:play()
		elseif state==platform.enum.audio_state.stop then
			--audio_object.source:stop()
		elseif state==platform.enum.audio_state.pause then
			--audio_object.source:pause()
		end
	end
	function audio_object:play()
		--audio_object.source:play()
	end
	function audio_object:pause()
		--audio_object.source:pause()
	end
	function audio_object:resume()
		--audio_object.source:resume()
	end
	function audio_object:stop()
		--audio_object.source:stop()
	end
	function audio_object:set_position(position) position=position or 0
		--audio_object.source:seek(position)
	end
	function audio_object:set_loop(state) state=state or false
		--audio_object.source:setLooping(state)
	end
	function audio_object:set_pitch(pitch) pitch=pitch or 1
		--audio_object.source:setPitch(pitch)
	end
	function audio_object:set_volume(volume) volume=volume or 1
		--audio_object.source:setVolume(volume)
	end
	function audio_object:get_source() return source end
	function audio_object:get_playing_state()
		return false
	end
	function audio_object:get_pause()
		return false
	end
	function audio_object:get_position()
		return 0
	end
	function audio_object:get_duration()
		return 0
	end
	function audio_object:get_loop()
		return false
	end
	function audio_object:get_volume()
		return 0
	end
	function audio_object:get_pitch()
		return 0
	end
	
	--audio_object:play();audio_object:pause();
	audio_object:set_volume(properties.volume)
	audio_object:set_position(properties.position)
	audio_object:set_pitch(properties.pitch)
	audio_object:set_loop(properties.loop)
	
	return audio_object
end

function platform:set_error_handler(handler)
	
end

function platform:set_screen_mode(mode)
	
end
function platform:set_window(resolution,title,frame_rate)
	
end
function platform:set_window_position(position)
	
end

--____________________________________Setup____________________________________
function platform:initialize(properties)
	properties=properties or {}
	
	platform:get_running_platform()
	
	if lfs==nil then
		platform:print("Error: LuaFileSystem is not installed")
		platform:exit()
	end
	
	while true do
		platform.update_stepped:invoke()
		platform:yield(1/60)
	end

	--::::::::::::::::::::[Rendering]::::::::::::::::::::
	
end
--_____________________________________________________________________________

return platform