local API={
	_version={0,0,5};
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

function API:create_signal()
	local signal={
		binds={};
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
			--[[
			thread:create_thread(function(thread)
				bind.action(API.root_functions.table.unpack(values))
			end)
			--]]
			if bind.thread==nil or bind.thread.runtime.run_state.value==true then
				bind.action(API.root_functions.table.unpack(values))
			end
		end
	end
	return signal
end

function API:create_property(value)
	local property={
		value=value;
		binds={};
	}
	function property:invoke(custom_value)
		local old_value=self.value
		for _,bind in pairs(self.binds) do
			if type(bind.action)=="function" then
				--thread:create_thread(function(thread) bind.action(custom_value,self.value) end)
				if bind.thread==nil or bind.thread.runtime.run_state.value==true then
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

function API:get_time_stamp(seconds)
	seconds=API.root_functions.math.floor(tonumber(seconds))
	if seconds <= 0 then
		return "00:00:00";
	else
		local hours=API.root_functions.string.format("%02.f",API.root_functions.math.floor(seconds/3600));
		local mins=API.root_functions.string.format("%02.f",API.root_functions.math.floor(seconds/60-(hours*60)));
		local secs=API.root_functions.string.format("%02.f",API.root_functions.math.floor(seconds-hours*3600-mins*60));
		return hours..":"..mins..":"..secs
	end
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

return API