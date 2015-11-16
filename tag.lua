-- Grab environement
local capi = {
	tag = tag,
}

-- Grab dependencies
--local awful = require("awful") -- try without ;)
local utils = require("bewlib.utils")
local Type = require("bewlib.type")
local Eventemitter = require("bewlib.eventemitter")

local dump = require("gears.debug").dump_return

-- Module environement
local private = setmetatable({}, { __mode = "k" })

local Tag = Eventemitter({
	prototype = {},
})
Type.registerType("Tag")

-- Private environement
private[Tag] = {
	tags = {},
}




function Tag.prototype:setLabel(newlabel)
	if type(newlabel) == "function" then
		newlabel = newlabel(self)
	end

	if not newlabel or not type(newlabel) == "string" then
		-- warning "no label given" => no change
		return
	end

	private[self].label = newlabel
	return self
end




-- TODO TODO TODO TODO TODO
-- How to store tags with indexs ?
--
--
--
--
--
--
--
-- make a representation here, or think on a paper...
-- TODO TODO TODO TODO TODO




function Tag.prototype:moveToPosition(indexTarget)
	local currentIndex = self.index

	if indexTarget == currentIndex then
		return self -- do nothing
	end

	--FIXME: really remove then insert ?? no problem with index ?
	table.remove(private[Tag].tags, currentIndex)

	--table.insert

	return self
end


function Tag.prototype:moveToWorkspace(workspace)
	--local ws = Workspace.find(workspace)
	--if not ws then return end
	--TODO
end




--TODO: do a function that apply a specific method on a tag or set of tag... (see Tag.setLabel)

--- Set label for a tag or a table of tags, given or by filter
function Tag.setLabel(tagOrFilter, ...)
	local tagOrTags = Tag.find(tagOrFilter)
	if not tagOrTags then return end

	-- if the given filter contains pattern matching filters, Tag.find may
	-- return a table of tags....

	if Type(tagOrTags) == "table" then
		for _, tag in ipairs(tagOrTags) do
			if not tag:setLabel(...) then
				return false
			end
		end
		return true
	end

	return tagOrTags:setLabel(...)
end


function Tag.find(tagOrFilter)
	local t = Type(tagOrFilter)
	if t == Type.Tag then
		return tagOrFilter
	end

	if t == "string" and tagOrFilter == "current" then
		return Tag.current
	end

	local filter = tagOrFilter

	if filter.id then
		--TODO: find TagById
		return private[Tag].tags[filter.id]
	end

	--TODO: find with other filter

	-- warning "not found" + traceback
	utils.toast.warning("Cannot find a tag with filters : " .. dump(filter))
	return nil
end


function Tag.new(label, options)
	local options = options or {}

	-- reorder arguments if needed
	if not options and Type(label) == "table" then
		options = label
		label = nil
	end

	local label = label or " no label "
	local tagID = options.id or "id-" .. #private		-- incrementing id..

	--TODO: get more options
	-- workspace (current)
	-- layout (tiled)
	-- ...




	--TODO: do we really leave the newtag table empty ?
	-- => what do we put in it ?
	--
	-- put some readonly data (id)
	--
	-- put some evented/observed data (label)
	local newtag = setmetatable(Eventemitter({}), Tag.prototype.mt)

	private[newtag] = {
		c_tag = capi.tag({ name = label }),
	}

	private[Tag].tags[tagID] = newtag

	return newtag
end


Tag.mt = {
	__call = function(self, ...)
		--Tag.findById(...)
	end,
}

Tag = setmetatable(Tag, Tag.mt)

return Tag

