--[[************************************************************

	Stdlib written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,3,7};
		enum={
			object_type={
				property={};
			};
		};
		root_functions={
			math={
				floor=math.floor;
				ceil=math.ceil;
				asin=math.asin;
				sin=math.sin;
				cos=math.cos;
				tan=math.tan;
				rad=math.rad;
				deg=math.deg;
				sqrt=math.sqrt;
				exp=math.exp;
				abs=math.abs;
				random=math.random;
				max=math.max;
				min=math.min;
				pi=math.pi;
			};
			string={
				len=string.len;
				sub=string.sub;
				gsub=string.gsub;
				match=string.match;
				gmatch=string.gmatch;
				format=string.format;
				upper=string.upper;
				lower=string.lower;
				byte=string.byte;
				char=string.char;
				find=string.find;
			};
			table={
				unpack=unpack;
				insert=table.insert;
				remove=table.remove;
				sort=table.sort;
			};
			coroutine={
				create=coroutine.create;
				resume=coroutine.resume;
				yield=coroutine.yield;
				status=coroutine.status;
			};
		};
	}
	
	if _VERSION=="Lua 5.3" then
		API.root_functions.table.unpack=table.unpack
	end
	
	function API:group_tables(...) --Indexes must be integral!
		local tables={...}
		local grouped_table=API:copy(tables[1])
		for i=2,#tables do
			for _,object in pairs(tables[i]) do
				grouped_table[#grouped_table+1]=object
			end
		end
		return grouped_table
	end
	
	function API:replace_string(current_text,point,text)
		local current_length=API.root_functions.string.len(current_text)
		local new_length=API.root_functions.string.len(text)
		if current_length<point+new_length then
			for i=current_length,point+new_length do
				current_text=current_text.." "
				current_length=current_length+1
			end
		end
		return API.root_functions.string.sub(current_text,0,point-1)..text..API.root_functions.string.sub(current_text,point+new_length,current_length)
	end

	function API:rotate_point(point,origin,angle)
		local s=API.root_functions.math.sin(API.root_functions.math.rad(angle))
		local c=API.root_functions.math.cos(API.root_functions.math.rad(angle))
		point.x,point.y=point.x-origin.x,point.y-origin.y
		return {x=(point.x*c-point.y*s)+origin.x,y=(point.x*s+point.y*c)+origin.y}
	end
	
	function API:lerp_number(start,goal,percent) return start+((goal-start)*percent) end

	function API:magnitude(a,b) return API.root_functions.math.sqrt((a-b)^2) end

	function API:round(num,decimal_place)
		local mult=10^(decimal_place or 0)
		return API.root_functions.math.floor(num*mult+0.5)/mult
	end
	
	function API:round_multiple(num,multiple)
	    if multiple==0 then return num end
	    local remainder=num%multiple
	    if remainder==0 then return num end
	    return num+multiple-remainder;
	end

	function API:clamp(val,min_val,max_val)
		if val<min_val or val~=val then
			val=min_val
		elseif val>max_val then
			val=max_val
		end
		return val
	end

	function API:partition(array,left,right,p_index,get_value)
		local p_value=get_value(array[p_index])
		array[p_index],array[right]=array[right],array[p_index]
		local stored_index=left
		for i=left,right-1 do
			if get_value(array[i])<=p_value then
				array[i],array[stored_index]=array[stored_index],array[i]
				stored_index=stored_index+1
			end
			array[stored_index],array[right]=array[right],array[stored_index]
		end
		return stored_index
	end

	function API:quick_sort(array,left,right,get_value)
		get_value=get_value or function(object) return object end
		if right>left then
			local p_new_index=API:partition(array,left,right,left,get_value)
			API:quick_sort(array,left,p_new_index-1,get_value)
			API:quick_sort(array,p_new_index+1,right,get_value)
		end
	end

	function API:set_program_environment(program,object_name,value)
		if type(program)=="function" then
			local environment=getfenv(program)
			environment[object_name]=value
			setfenv(program,environment)
		elseif type(program)=="table" then
			for _,object in pairs(program) do
				if type(object)=="function" then
					local environment=getfenv(object)
					environment[object_name]=value
					setfenv(object,environment)
				end
			end
		end
	end

	function API:set_program_environment_table_list(program,list)
		for object_name,value in pairs(list) do
			API:set_program_environment(program,object_name,value)
		end
	end

	function API:limit(value,min,max)
		if value<min then
			value=min
		elseif value>max then
			value=max
		end
	end

	function API:copy(object,deep)
		local object_copy={}
		for k,v in pairs(object) do
			if deep==true and type(v)=="table" then
				v=self:copy(v,deep)
			end
			object_copy[k]=v
		end
		return object_copy
	end
	
	function API:delete(object,deep)
		for k,v in pairs(object) do
			if deep==true and type(v)=="table" then
				API:delete(v,deep)
			end
			object[k]=nil
		end
	end

	function API:create_signal(multithread)
		local signal={
			binds={};
			multithread=multithread or false;
		}
		function signal:attach_bind(action,thread)
			if action==nil or type(action)~="function" then return end
			local bind={action=action;thread=thread}
			function bind:detach()
				for i,current_bind in pairs(signal.binds) do
					if current_bind==bind then API.root_functions.table.remove(signal.binds,i);break end
				end
			end
			if thread~=nil then
				thread.killed:attach_bind(function()
					bind:detach()
				end)
			end
			signal.binds[#signal.binds+1]=bind
			return bind
		end
		function signal:invoke(...) local values={...}
			for _,bind in pairs(signal.binds) do
				if signal.multithread==true then
					thread:create_thread(function(thread)
						bind.action(API.root_functions.table.unpack(values))
					end)
				elseif bind.thread==nil or bind.thread.runtime.run_state.value==true then
					bind.action(API.root_functions.table.unpack(values))
				end
			end
		end
		return signal
	end

	function API:create_property(value,multithread)
		local property={
			value=value;
			binds={};
			multithread=multithread or false;
		}
		function property:invoke(custom_value)
			local old_value=self.value
			for _,bind in pairs(self.binds) do
				if type(bind.action)=="function" then
					if property.multithread==true then
						thread:create_thread(function(thread)
							bind.action(custom_value,old_value)
						end)
					elseif bind.thread==nil or bind.thread.runtime.run_state.value==true then
						bind.action(custom_value,old_value)
					end
				end
			end
		end
		function property:set_value(value)
			if self.value==value then return end
			self:invoke(value)
			self.value=value
		end
		function property:add_value(value,index)
			if value~=nil and type(self.value)=="table" then
				self:invoke(value)
				self.value[index or #self.value+1]=value
			end
		end
		function property:remove_value(index)
			if index~=nil and type(self.value)=="table" then
				self:invoke(self.value[index])
				API.root_functions.table.remove(self.value,index)
			end
		end
		function property:attach_bind(action,thread)
			if action==nil or type(action)~="function" then return end
			local bind={action=action;thread=thread}
			function bind:detach()
				for i,current_bind in pairs(property.binds) do
					if current_bind==bind then API.root_functions.table.remove(property.binds,i);break end
				end
			end
			if thread~=nil then
				thread.killed:attach_bind(function()
					bind:detach()
				end)
			end
			property.binds[#property.binds+1]=bind
			return bind
		end
		return property
	end
	
	function API:get_parent_directory(path,parent_index)
		if path==nil then return "" end
		parent_index=parent_index or 1
		local current_index=0
		local path_length=API.root_functions.string.len(path)
		local parent_length=0
		for i=1,path_length do
			if current_index<parent_index then
				local char=API.root_functions.string.sub(path,path_length+1-i,path_length+1-i)
				if char=="/" or char=="\\" then
					current_index=current_index+1
					parent_length=path_length+1-i
				end
			else
				break
			end
		end
		return API.root_functions.string.sub(path,1,parent_length)
	end
	
	function API:create_properties_table(properties)
		function properties:extract()
			local extracted={}
			for i,v in pairs(properties) do
				if type(v)=="table" then
					extracted[i]=v.value
				end
			end
			return extracted
		end
		return properties
	end
	
	function API:create_name_space(env)
		env()
	end
	
	function API:merge_tables(...)
		local tables={...}
		local new_table={}
		
		for _,current_table in pairs(tables) do
			for i,v in pairs(current_table) do
				if new_table[i]==nil then
					new_table[i]=v
				end
			end
		end
		
		return new_table
	end
	
	function API:find(t,value)
		local indexes={}
		for i,v in pairs(t) do
			if v==value then
				indexes[#indexes+1]=i
			end
		end
		return indexes
	end

	return API
end