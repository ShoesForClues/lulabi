--[[************************************************************

	NPTask written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.
	
	This is a non-preemptive multithreader.

--************************************************************]]

local API={
	version={0,2,2};
}

function API:create_property(value)
	local property={value=value;binds={};}
	function property:invoke(custom_value)
		for _,bind in pairs(self.binds) do
			if bind~=nil and bind.action~=nil and type(bind.action)=="function" then
				bind.action(custom_value or self.value)
			end
		end
	end
	function property:set_value(value)
		if self==value or self.value==value then return end
		self.value=value
		self:invoke(self.value)
	end
	function property:add_value(value,index)
		if value~=nil and type(self.value)=="table" then
			table.insert(self.value,index or #self.value+1,value)
			self:invoke(self.value)
		end
	end
	function property:remove_value(index)
		if index~=nil and type(self.value)=="table" and self.value[index]~=nil then
			table.remove(self.value,index)
			self:invoke(self.value)
		end
	end
	function property:attach_bind(action)
		if action==nil or type(action)~="function" then return end
		local bind={action=action;}
		function bind:detach() bind.action,bind=nil,nil end
		table.insert(self.binds,#self.binds+1,bind)
		return bind
	end
	return property
end

function API:create_scheduler(properties) properties=properties or {}
	local scheduler={
		current_tick=0;
		max_threads=properties.max_threads or math.huge;
		threads={};
	}
	
	function scheduler:create_thread(environment,priority)
		if environment==nil or #scheduler.threads>=scheduler.max_threads then return end
		local thread={
			runtime={
				run_state=API:create_property(true);
				resume_tick=0;
			};
			priority=priority or 0;
			scheduler=scheduler;
			libraries={};
		}
		
		function thread.runtime:wait(duration)
			thread.runtime.resume_tick=scheduler.current_tick+(duration or 0)
			local pause_tick=scheduler.current_tick
			coroutine.yield()
			return scheduler.current_tick-pause_tick
		end
		
		function thread:set_run_state(state)
			thread.runtime.run_state:set_value(state or false)
		end
		
		function thread:import(library,library_name)
			if library==nil or thread==nil or library_name==nil then return end
			if type(library)=="function" then
				thread.libraries[library_name]=library(thread)
			else
				library=thread.scheduler.platform:require(library)
				if type(library)=="function" then
					thread.libraries[library_name]=library(thread)
				else
					thread.libraries[library_name]=library
				end
			end
			if type(thread.libraries[library_name])=="table" and thread.libraries[library_name].post_import_setup~=nil then
				thread.libraries[library_name]:post_import_setup()
			end
			return thread.libraries[library_name]
		end
		
		function thread:delete()
			thread.runtime.run_state:set_value(false)
			for i,obj in pairs(thread.scheduler.threads) do
				if obj==thread then
					table.remove(thread.scheduler.threads,i);break
				end
			end
			--coroutine.yield()
		end
		
		thread.coroutine=coroutine.create(environment)
		table.insert(scheduler.threads,#scheduler.threads+1,thread)
		return thread
	end
	
	function scheduler:cycle(tick)
		local output_buffer={}
		if tick~=nil and type(tick)=="number" then
			scheduler.current_tick=tick
		end
		for i,thread in pairs(scheduler.threads) do
			if thread==nil or coroutine.status(thread.coroutine)=="dead" then
				table.remove(scheduler.threads,i)
			elseif thread.runtime.run_state.value==true and thread.runtime.resume_tick<=scheduler.current_tick then
				local _,output=coroutine.resume(thread.coroutine,thread)
				table.insert(output_buffer,#output_buffer+1,output)
			end
		end
		return output_buffer
	end
	
	function scheduler:set_all_threads(priority,action) if action==nil then return end
		priority=priority or math.huge
		for i,thread in pairs(scheduler.threads) do
			if thread.priority<=priority then
				action(thread)
			end
		end
	end
	
	return scheduler
end

return API