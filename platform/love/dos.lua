--________________________________Dependencies_________________________________
local stdplib=require("lib/stdplib")
--_____________________________________________________________________________

local platform={
	_target="love_dos";
	_version={0,2,2};
	
	start_tick=os.clock();
	
	enum={
		filter_mode={
			linear="linear";
			nearest="nearest";
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
	};
	
	assets={}; --Asset bank
	
	text_input=stdplib:create_signal();
	key_state=stdplib:create_signal();
	joystick_key_state=stdplib:create_signal();
	mouse_key_state=stdplib:create_signal();
	mouse_moved=stdplib:create_signal();
	mouse_scrolled=stdplib:create_signal();
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
	return {operating_system="DOS";bits=16;}
end

function platform:execute_command(code) if code==nil then return end                               --Execute OS specific commands
	local handle=io.popen(code)
	local output=handle:read("*a")
	handle:close()
	return output
end

function platform:exit() love.event.quit() end                                                     --End the program

function platform:print(text) print(text) platform.output_update:invoke(text) end                  --Output text to console
function platform:info(message) if message==nil then return end                                    --Output info to console
	return platform:print("["..stdplib:get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:get_file(path,current_file)                                                      --Retrieve file via path
	path=path.." "
	current_file=current_file or platform.default.current_file
	local path_length,step,file_name=stdplib.root_functions.string.len(path),0,""
	for a=1,path_length do
		local char=stdplib.root_functions.string.sub(path,a,a)
		if char~="/" and char~="<" and a<path_length then
			file_name=file_name..char
		else
			if step<=0 and file_name=="root" then
				if stdplib.root_functions.string.find(stdplib.root_functions.string.lower(love.system.getOS()),"windows") or stdplib.root_functions.string.find(stdplib.root_functions.string.lower(love.system.getOS()),"dos") then
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
				current_file=current_file.."/.."
			end
			step=step+1
			file_name=""
		end
	end
	return current_file
end

function platform:file_exists(file)                                                                --Check if file exists
	return love.filesystem.exists(platform:get_file(file))
end
function platform:get_sub_files(file)                                                              --Get a list of sub files
	return love.filesystem.getDirectoryItems(platform:get_file(file))
end
function platform:get_full_path(file)                                                              --Get full path of file
	return love.filesystem.getRealDirectory(platform:get_file(file))
end

function platform:require(file)                                                                    --Get a value from a lua file
	local success,lib=pcall(require,platform:get_file(file))
	if success==false then
		platform:info(lib)
	end
	return lib
end

function platform:yield(duration) love.timer.sleep(duration) end                                   --Yield the entire thread
function platform:get_tick() return os.clock()-platform.start_tick end                             --Get the current clock tick
function platform:get_frame_rate() return love.timer.getFPS() end                                  --Get the current FPS

function platform:get_joystick_key_press(joystick_id,...)                                          --Check if joystick button is pressed
	local state=false
	for id,joystick in pairs(love.joystick.getJoysticks()) do
		if joystick_id==id then
			state=joystick:isDown(...) or false
		end
	end
	return state
end
function platform:get_key_press(...) return love.keyboard.isDown(...) end                          --Check if keyboard button is pressed
function platform:get_mouse_key_press(...) return love.mouse.isDown(...) end                       --Check if mouse button is pressed
function platform:update_pointers()                                                                --Update pointers
	local pointers={}
	local mouse_x,mouse_y=love.mouse.getPosition()
	table.insert(pointers,#pointers+1,{id=1,position={x=mouse_x,y=mouse_y},state=love.mouse.isDown(1)})
	--[[
	for _,id in pairs(love.touch.getTouches()) do
		local touch_x,touch_y=love.touch.getPosition(id)
		table.insert(pointers,#pointers+1,{id=id,position={x=touch_x,y=touch_y},state=true})
	end
	--]]
	platform.pointers:set_value(pointers)
end

function platform:set_filter_mode(min_mode,max_mode,anistropy)                                     --Set image scaling filter mode
	--love.graphics.setDefaultFilter(min_mode,max_mode,anistropy)
end
function platform:set_cursor_visibility(state)                                                     --Set cursor visibility
	--love.mouse.setVisible(state)
end
function platform:get_buffer_resolution(buffer)                                                    --Get current screen resolution
	local resolution={x=love.graphics.getWidth(),y=love.graphics.getHeight()}
	if buffer~=nil then
		resolution={x=buffer:getWidth(),y=buffer:getHeight()}
	else
		platform.screen_resolution:set_value(resolution)
	end
	return resolution
end

function platform:load_source(file,file_type,properties)                                           --Load asset in memory for future reference
	if file==nil or file_type==nil then return end
	properties=properties or {}
	if file_type==platform.enum.file_type.image then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(love.graphics.newImage,platform:get_file(file))
			if success==false then
				platform:info("Failed to load image: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.font then
		if platform.assets[file]==nil then
			local font={}
			for i=6,108 do
				success,font[i]=pcall(love.graphics.newFont,platform:get_file(file),i)
				if success==false then
					platform:info("Failed to load font: "..file)
					break
				end
			end
			platform.assets[file]=font
		end
	elseif file_type==platform.enum.file_type.audio then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(love.sound.newSoundData,platform:get_file(file))
			if success==false then
				platform:info("Failed to load audio: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.model then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(iqm.load,platform:get_file(file))
			if success==false then
				platform:info("Failed to load model: "..file)
			end
		end
	end
	return platform.assets[file]
end
function platform:load_sources(files) if files==nil or type(file)~="table" then return end         --Load multiple files
	for _,file in pairs(files) do platform:load_source(file[1],file[2],file[3]) end
end
function platform:unload_source(file) platform.assets[file]=nil end                                --Unload asset
function platform:clear_sources() platform.assets={} end 

function platform:set_current_buffer(...)                                                          --Begin drawing to a buffer
	love.graphics.setCanvas(...)
end
function platform:clear_buffer(color,opacity,active_buffers)                                       --Clears buffer
	love.graphics.clear({color.r*255,color.g*255,color.b*255,(1-opacity)*255},unpack(active_buffers))
	love_3d.clear()
end

function platform:set_current_buffer(buffer)                                                       --Begin drawing to a buffer
	love.graphics.setCanvas(buffer)
end
function platform:set_current_shader(shader)                                                       --Set current shader
	--love.graphics.setShader()
end
function platform:render_image(source,position,size,rotation,wrap,background_color,source_color,filter_mode,anistropy,buffer) --Render image to the buffer
	if source==nil or position==nil or size==nil then return end
	local source_area={x=0,y=0,width=source.width,height=source.height}
	local destination_area={x=position.x,y=position.y,width=size.x,height=size.y}
	local origin={x=0,y=0}
	if wrap~=nil then
		if position.x+size.x<wrap.x1 or position.x>wrap.x2 or position.y+size.y<wrap.y1 or position.y>wrap.y2 then return end
		if position.x<wrap.x1 then
			source_area.x=stdplib:round((wrap.x1-position.x)/size.x*source:getWidth())
			source_area.width=stdplib:round((position.x+size.x-wrap.x1)/size.x*source:getWidth())
			destination_area.x,destination_area.width=wrap.x1,size.x-(wrap.x1-position.x)
		end
		if position.x+size.x>wrap.x2 then
			source_area.width=stdplib:round((wrap.x2-destination_area.x)/size.x*source:getWidth())
			destination_area.width=destination_area.width-(position.x+size.x-wrap.x2)
		end
		if position.y<wrap.y1 then
			source_area.y=stdplib:round((wrap.y1-position.y)/size.y*source:getHeight())
			source_area.height=stdplib:round((position.y+size.y-wrap.y1)/size.y*source:getHeight())
			destination_area.y,destination_area.height=wrap.y1,size.y-(wrap.y1-position.y)
		end
		if position.y+size.y>wrap.y2 then
			source_area.height=stdplib:round((wrap.y2-destination_area.y)/size.y*source:getHeight())
			destination_area.height=destination_area.height-(position.y+size.y-wrap.y2)
		end
	end
	love.graphics.setColor(background_color.r*255,background_color.g*255,background_color.b*255)
	love.graphics.rectangle("fill",position.x,position.y,size.x,size.y)
	--source:setFilter(filter_mode or platform.enum.filter_mode.nearest,filter_mode or platform.enum.filter_mode.nearest,anistropy or 0)
	if source~=nil then
		love.graphics.setColor(color.r*255,color.g*255,color.b*255)
		love.graphics.draw(
			source,love.graphics.newQuad(source_area.x,source_area.y,source_area.width,source_area.height),
			destination_area.x,destination_area.y,false,destination_area.width/source:getWidth(),destination_area.height/source:getHeight()
		)
	end
	--love.graphics.rotate(0)
	--love.graphics.setScissor()
	love.graphics.setColor(255,255,255)
end
function platform:get_text_size(text,font,font_size)
	return {x=font[font_size]:getWidth(text),y=font[font_size]:getHeight()}
end
function platform:render_text(text,position,wrap,wrapped,color,alignment,font,font_size,buffer)    --Render text to the screen
	font=font or platform.default.font
	love.graphics.setCanvas(buffer)
	local text_size=platform:get_text_size(text,font,font_size)
	local wrap_center={x=(wrap.x1+wrap.x2)/2,y=(wrap.y1+wrap.y2)/2}
	if alignment.x=="center" then
		position.x=wrap_center.x-(text_size.x/2)
	elseif alignment.x=="right" then
		position.x=wrap.x2-text_size.x
	end
	if alignment.y=="center" then
		position.y=wrap_center.y-(text_size.y/2)
	elseif alignment.y=="bottom" then
		position.y=wrap.y2-text_size.y
	end
	if wrapped==true and wrap~=nil then
		--love.graphics.setScissor(wrap.x1,wrap.y1,wrap.x2-wrap.x1,wrap.y2-wrap.y1)
	end
	if color~=nil then
		love.graphics.setColor(color.r*255,color.g*255,color.b*255)
	end
	if font[font_size]~=nil then
		font[font_size]:setFilter(platform.enum.filter_mode.nearest,platform.enum.filter_mode.nearest,0)
		love.graphics.setFont(font[font_size])
		love.graphics.print(text,position.x,position.y)
	end
	love.graphics.setCanvas()
	love.graphics.setFont(love.graphics.newFont(18))
	--love.graphics.setScissor()
	love.graphics.setColor(255,255,255)
end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio_object={
		source=love.audio.newSource(properties.source);
	}
	function audio_object:set_source(source)
		audio_object.source=love.audio.newSource(source)
	end
	function audio_object:set_state(state)
		if state==platform.enum.audio_state.play then
			audio_object.source:play()
		elseif state==platform.enum.audio_state.stop then
			audio_object.source:stop()
		elseif state==platform.enum.audio_state.pause then
			audio_object.source:pause()
		end
	end
	function audio_object:play()
		audio_object.source:play()
	end
	function audio_object:pause()
		audio_object.source:pause()
	end
	function audio_object:resume()
		audio_object.source:resume()
	end
	function audio_object:stop()
		audio_object.source:stop()
	end
	function audio_object:set_position(position) position=position or 0
		--audio_object.source:seek(position)
	end
	function audio_object:set_loop(state) state=state or false
		audio_object.source:setLooping(state)
	end
	function audio_object:set_pitch(pitch) pitch=pitch or 1
		audio_object.source:setPitch(pitch)
	end
	function audio_object:set_volume(volume) volume=volume or 1
		audio_object.source:setVolume(volume)
	end
	function audio_object:get_source() return source end
	function audio_object:get_playing_state()
		return audio_object.source:isPlaying()
	end
	function audio_object:get_pause_state()
		return audio_object.source:isPaused()
	end
	function audio_object:get_position()
		return audio_object.source:tell()
	end
	function audio_object:get_duration()
		return audio_object.source:getDuration()
	end
	function audio_object:get_loop_state()
		return audio_object.source:isLooping()
	end
	function audio_object:get_volume()
		return audio_object.source:getVolume()
	end
	function audio_object:get_pitch()
		return audio_object.source:getPitch()
	end
	
	--audio_object:play();audio_object:pause();
	audio_object:set_volume(properties.volume)
	audio_object:set_position(properties.position)
	audio_object:set_pitch(properties.pitch)
	audio_object:set_loop(properties.loop)
	
	return audio_object
end

function platform:set_screen_mode(mode)
	if mode~=nil then
		platform.current_screen_mode:set_value(mode)
	end
end
function platform:set_window(resolution,title,frame_rate)
	
end

--____________________________________Setup____________________________________
function platform:initialize(properties)
	properties=properties or {}
	
	--platform:set_window(properties.screen_resolution,properties.window_title,properties.frame_rate)
	--platform:set_screen_mode(properties.screen_mode)
	--platform:set_cursor_visibility(properties.cursor_visible)
	
	--::::::::::::::::::::[Callbacks]::::::::::::::::::::
	function love.keypressed(key) platform.key_state:invoke({key=key,state=true}) end
	function love.keyreleased(key) platform.key_state:invoke({key=key,state=false}) end
	--[[
	function love.joystickpressed(joystick,key)
		local id,_=joystick:getID()
		platform.joystick_key_state:invoke({id=id or 1,key=key,state=true})
	end
	function love.joystickreleased(joystick,key)
		local id,_=joystick:getID()
		platform.joystick_key_state:invoke({id=id or 1,key=key,state=false})
	end
	--]]
	function love.textinput(text) platform.text_input:invoke(text) end
	function love.mousepressed(x,y,id)
		platform.mouse_key_state:invoke({key=id,state=true})
	end
	function love.mousereleased(x,y,id)
		platform.mouse_key_state:invoke({key=id,state=false})
	end
	function love.mousemoved(x,y,dx,dy)
		platform.mouse_position:set_value({x=x,y=y})
		platform.mouse_moved:invoke({x=dx,y=dy})
	end
	--function love.touchmoved() platform:update_pointers() end
	function love.update(...) platform.update_stepped:invoke(...) end
	--function love.resize(x,y) platform.screen_resolution:set_value({x=x,y=y}) end

	platform:get_buffer_resolution()

	for i=6,72 do
		_,platform.default.font[i]=pcall(love.graphics.newFont,i)
	end

	--::::::::::::::::::::[Rendering]::::::::::::::::::::
	function love.draw(...)
		platform.render_stepped:invoke(...)
		love.graphics.print("FPS: "..tostring(platform:get_frame_rate()),5,5)
	end
end
--_____________________________________________________________________________

return platform