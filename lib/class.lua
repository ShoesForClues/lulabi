--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

return function(thread)
	local object={};object.__index=object

	function object:new() end

	function object:extend()
		local class={}
		for k,v in pairs(self) do
			if k:find("__")==1 then
				class[k]=v
			end
		end
		class.__index=class
		class.super=self
		setmetatable(class,self)
		return class
	end

	function object:implement(...)
		for _,class in pairs({...}) do
			for k,v in pairs(class) do
				if self[k]==nil and type(v)=="function" then
					self[k]=v
				end
			end
		end
	end

	function object:is(object_type) local meta_table=getmetatable(self)
		while meta_table do
			if meta_table==object_type then
				return true
			end
			meta_table=getmetatable(meta_table)
		end
		return false
	end

	function object:__tostring() return "object" end

	function object:__call(...)
		local new_object=setmetatable({},self)
		new_object:new(...)
		return new_object
	end

	return object
end