# Command line

## Syntax

**Long format**

`:workspace move left`

same as

**Short format**

a short format command begin with a `%`.

`:%wml`

### Syntax format:

* namespace (here: `workspace`)
* command (here: `move`)
* arg(s) (here: `left`)






## Calling

The parsing can be called from external modules (like keybinds) with :

`cmdline.eval` : use the global cmdline

`mycmdline:eval` : use `mycmdline` cmdline controller

Format: `eval(command, options)`

options :

* callback : (function) being executed after the command execution
* after : execute the command after N seconds
* ...

exemple: 

```lua
cmdline.eval("%wml")

cmdline.eval("@new", {
	callback = function()
		print("done")
	end
})
```

## Cmdline controller

cmdline control object with specific aliases, commands, etc...

* one global cmdline controller
* many other cmdline controller for specific use

It contains :

* all aliases
* all commands


### New

Create a new cmdline controller

format:

* `cmdline.new(id)` : create new empty controller with id `id`
* `mycmdline:new(id)` : create new controller with id `id` which inherits all infos from mycmdline



## Builtin commands

### Alias

#### Create :

**In shell** :
:alias new = tag new

**In code** :
```lua
local alias = cmdline.newAlias(name, command)
mycmdctrl:addAlias(alias)
```

#### Call :

:@new


### save cmdline controller ?

maybe.... for custom controller ?


## Commands


### workspace cmds

:workspace (**short**: :w)


#### move

`move` - `m` : move the workspace

**Format :**

`move <where>`

WHERE : where to move the current workspace

* `left` - `l` : move left of current
* `right` - `r` : move right of current
* `begin` - `0` : move begin of list
* `end` - `$` : move end of list


#### delete

`delete` - `d` : delete a workspace

**Format :**

`delete <which> <keepTags> [<wsTo>]`

WHICH : which workspace to delete

* `all` - `a` : delete all
* `current` - `c` : delete current

KEEPTAGS : keep contained tags or not

* `true`|`yes` - `y` : move all contained orphan tags to default workspace
* `false`|`no` - `n` : destroy all contained orphan tags to default workspace and move clients to default tag

WSTO : where (to which workspace) to move the tags if `keepTags` is `true`.


#### new

`new` - `n` : create a new workspace

**Format :**

`new [<name>]`

NAME :

The name of the workspace


#### rename

#### load (and reload ?)

#### save | write

save the workspace to disk, for later use/reload or after reboot






#TODO: move this section: >>> Orphan Tag

a tag can be in multiple workspace, if a tag is only in one workspace, and this workspace is deleted, the tag become orphan (orphelin)
