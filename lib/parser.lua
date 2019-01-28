--[[************************************************************

	Parser written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,0,7};
		_dependencies={
			"stdlib";
		};
	}
	
	function API:get_lines(text)
		local lines={}
		local x,a,b=1
		while x<thread.libraries["stdlib"].root_functions.string.len(text) do
			a,b=thread.libraries["stdlib"].root_functions.string.find(text,'.-\n',x)
			if not a then
				break
			else
				lines[#lines+1]=thread.libraries["stdlib"].root_functions.string.sub(text,a,b)
			end
			x=b+1
		end;
		return lines
	end
	
	function API:parse(text)
		if text==nil then return {} end
		text=text.." "
		local tokens,current_token,s={},"",0
		local text_len=thread.libraries["stdlib"].root_functions.string.len(text)
		while s<text_len do
			s=s+1
			local char=thread.libraries["stdlib"].root_functions.string.sub(text,s,s)
			if char~=" " and char~='"' and char~="'" and char~="'" and char~="'" and char~="," and s<=text_len then
				current_token=current_token..char
			else
				if char=='"' then
					for sb=s+1,text_len do
						local sub_char=thread.libraries["stdlib"].root_functions.string.sub(text,sb,sb)
						if sub_char~='"' then
							current_token=current_token..sub_char
						else
							s=sb
							break
						end
					end
				elseif char=="'" then
					for sb=s+1,text_len do
						local sub_char=thread.libraries["stdlib"].root_functions.string.sub(text,sb,sb)
						if sub_char~="'" then
							current_token=current_token..sub_char
						else
							s=sb
							break
						end
					end
				end
				if thread.libraries["stdlib"].root_functions.string.len(current_token)>0 then
					tokens[#tokens+1]=tonumber(current_token) or current_token
					current_token=""
				end
			end
		end
		return tokens
	end
	
	function API:get_option(args,option,value_type)
		if args==nil or option==nil then return false,nil end
		local has_option,value=false,nil
		for i,arg in pairs(args) do
			if arg==option then
				has_option=true
				if value_type=="number" then
					value=tonumber(args[i+1]) or 0
				elseif value_type=="string" then
					value=tostring(args[i+1]) or ""
				elseif value_type=="boolean" then
					if args[i+1]=="true" or args[i+1]=="1" then
						value=true
					elseif args[i+1]=="false" or args[i+1]=="0" then
						value=false
					end
				end
				break
			end
		end
		return has_option,value
	end
	
	function API:get_name(path)
		if path==nil then return "" end
		local name=""
		local path_len=thread.libraries["stdlib"].root_functions.string.len(path)
		for i=1,path_len do
			local char=thread.libraries["stdlib"].root_functions.string.sub(path,path_len+1-i,path_len+1-i)
			if char~="/" and char~="\\" then
				name=char..name
			else
				break
			end
		end
		return name
	end
	
	function API:split(line,divider,manipulator)
		line=line..divider
		local tokens={}
		local i=1
		while i<=thread.libraries["stdlib"].root_functions.string.len(line) do
			local next_i=thread.libraries["stdlib"].root_functions.string.find(line,divider)
			if next_i~=nil then
				local token=thread.libraries["stdlib"].root_functions.string.sub(line,1,next_i-1)
				if manipulator~=nil then
					token=manipulator(token) or token
				end
				tokens[#tokens+1]=token
				i=1
			end
			line=thread.libraries["stdlib"].root_functions.string.sub(line,next_i+1,thread.libraries["stdlib"].root_functions.string.len(line))
		end
		return tokens
	end
	
	return API
end