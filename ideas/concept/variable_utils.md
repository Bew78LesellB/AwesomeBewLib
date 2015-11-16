# bewlib - Variable Utils


## Read only variable (const ?)

Lockable variable

### Usage

```lua
myReadOnlyVar = "bla"			--error
myReadOnlyVar.set("bla")	--error

print(myReadOnlyVar)			-- no problem

myReadOnlyVar.unlock(myUnlocker, "blabla")
```

You need to have an unlocker to be able to edit the variable

This is usefull when you want to be able to modify the variable in a specific
file (the file which created the variable for exemple)

The unlocker is created at variable creation time

```lua
-- Create the UNLOCKER
-- The 'local' is important, you don't want the user to modify the variable !!!
-- So don't put the unlocker in the global environnement !
local thisFileUnlocker = Var.new("unlocker")

-- Create the readonly variable
myReadOnlyVar = Var.new("readonly", thisFileUnlocker, "default value")

myReadOnlyVar = "bla"			-- error (is it possible to do nothing ?)
myReadOnlyVar:set("bla")		-- error

myReadOnlyVar:set(thisFileUnlocker, "new value")	-- ok
```

### For study

#### Case 1

Found at [lua-users.org](http://lua-users.org/lists/lua-l/2003-06/msg00364.html)

First the Lua :
$ `cat ro.lua`
```lua
-- make some global variables readonly

local ReadOnly = {
  x = 5,
  y = 'bob',
}

local function check(tab, name, value)
  if rawget(ReadOnly, name) then
    error(name ..' is a read only variable', 2)
  end
  rawset(tab, name, value)
end

setmetatable(_G, {__index=ReadOnly, __newindex=check})
```

Then the test :
$ `lua -i ro.lua`
```
> = x
5
> = y
bob
> z = 'junk'
> x = 4
stdin:1: x is a read only variable
stack traceback:
        [C]: in function `error'
        ro.lua:11: in function <ro.lua:9>
        stdin:1: in main chunk
        [C]: ?
> = x
5
> = z
junk
>
```

#### Case 2


```lua
-- make global variables readonly

local f = function (t,i)
	error("cannot redefine global variable `"..i.."'",2)
end
local g = {}
local G = getfenv()
setmetatable(g, {
	__index = G,
	__newindex = f
})
setfenv(1, g)

-- an example
rawset(g, "x", 3)
x = 2
y = 1 -- cannot redefine `y'
```


### Set multiple value with the same unlocker

You can also do a `batchUnlock`, to be able to change multiple variable
without always giving the unlocker

```lua
-- Create the unlocker
local thisFileUnlocker = Var.new("unlocker")

-- Create some variable to change
read1 = Var.new("readonly", thisFileUnlocker, "default1")
read2 = Var.new("readonly", thisFileUnlocker, "default2")
read3 = Var.new("readonly", thisFileUnlocker, "default3")

-- Change them
-- TODO: make this function less long
Var.batchUnlock({read1, read2, read3}, thisFileUnlocker, function(read1, read2, read3) -- THIS IS TOO LONG
	read1:set("new1")
	read2:set(myGlobal)
	read3:set("new3")
end)
```


### Possible uses

* An ID, that must be set only once (maybe, this can be a SetOnce variable...)
* An interface for others
* 




## SetOnce Variable

A variable that you can set only once, it will do absolutly nothing if you try
to reset it, even if you created it !




