local Array = { prototype = {}, }

local function apply_metatable(instance)
  return setmetatable(instance, {
    __index = function(self, field)
      if type(field) == "number" then
        -- maybe a negative index?
        return Array.prototype.unsafe_at(self, field)
      else
        return Array.prototype[field]
      end
    end,

    __newindex = function(self, field, value)
      if type(field) == "number" then
        -- maybe a negative index?
        return Array.prototype.unsafe_set(self, field, value)
      else
        error("Cannot set '" .. tostring(field) .. "' for Array type")
      end
    end,
  })
end

local function remove_metatable(instance)
  return setmetatable(instance, nil)
end

function Array.from_table(table)
  table = table or {}
  table.__class = Array

  return apply_metatable(table)
end

function Array.new()
  local instance = {
    __class = Array,
  }

  return apply_metatable(instance)
end

--- NOTE: you won't be able to call any Array methods after this call
function Array.prototype:to_table()
  self.__class = nil
  return remove_metatable(self)
end

function Array.prototype:unsafe_at(idx)
  if idx < 0 then
    idx = idx + #self
  end
  return rawget(self, idx)
end

function Array.prototype:unsafe_set(idx, value)
  if idx < 0 then
    idx = idx + #self
  end
  rawset(self, idx, value)
  return value
end

function Array.prototype:append(item)
  table.insert(self, item)
  return item
end

function Array.prototype:insert(idx, item)
  if idx < 0 then
    idx = idx + #self
  end
  table.insert(self, idx, item)
  return item
end

function Array.prototype:each(callback)
  for idx, item in ipairs(self) do
    callback(item, idx)
  end
end

function Array.prototype:map(callback)
  local arr = Array.new()

  for idx, item in ipairs(self) do
    arr:append(callback(item, idx))
  end

  return arr
end

return Array
