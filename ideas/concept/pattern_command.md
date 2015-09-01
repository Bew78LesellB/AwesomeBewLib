# Design pattern : COMMAND

## Concept

**Description**

A command is registered once, and can be triggered by different event..

**Command Block Structure**

* name			(string)
* callback	(function)
* [condition (function)]

**Command Group Block Structure**

* name

**Command naming**

__standalone action__ : `myAction`
__action in a group__ : `group.myAction`



## Application

Namespace: `Command`

Example variables:

* `grp` : a command group instance
* `cmd` : a command instance

We can :

- register a command
- run a command
- get a command's callback

### TODO: in register: args filter

ex:

```lua
-- register
Command.register("name", {
	callback = function() end,
	condition = nil,
	argsFilter = {
		"arg1",
		"arg2",
		"arg3",
	}
})

-- run
Command.run("name", {
	args = {
		arg1" = "bla",
		arg2 = 42,
		badArgument = "not accepted"
	}
})
-- Here, the "name"'s callback will not recieve the 'badArgument' arg, because it's not in the argsFilter.
```


### `Command.register (name, [callback], [condition])` & `Command.register (name, options)`

* `Command.register (name)` : register a command group, return the command group instance

* `Command.register (name, callback)` : register a command (group &) action, return nothing

* `Command.register (name, callback, condition)` : same as `(name, callback)` but by default, the callback will be executed only if the condition return true

* `Command.register (name, options)` :

Options is a table, with available fields :

```lua
options = {
	name = "commandName",
	condition = function() end,
  callback = function() end,
	argsFilter = { }
}
```


### `grp:register (name, callback, [condition])`

* `grp:register (name, callback)` : register a command action for the group `grp`, return the group `grp`

* `grp:register (name, callback, condition)` : same as `(name, callback)` but by default, the callback will be executed only if the condition function return true



### `Command.run (name, [args])` & `Command.forceRun (name, [args])`

TODO: `cmd:run (args)` & `cmd:forceRun (args)`

* `Command.run (name)` : run the command given by `name`. If the command has a condition, the command is run if the condition function return `true`.

* `Command.run (name, args)` Same as `Command.run (name)` but give `args` table to the callback function as argument

* `Command.forceRun (name)` : Same as `Command.run (name)` but override the condition function if any.

* `Command.forceRun (name, args)` : Same as `Command.run (name, args)` but override the condition function if any.




