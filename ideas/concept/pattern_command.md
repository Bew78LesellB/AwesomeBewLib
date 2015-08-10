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



### `Command.register (name, [callback], [condition])`

* `Command.register (name)` : register a command group, return the command group instance

* `Command.register (name, callback)` : register a command (group &) action, return nothing

* `Command.register (name, callback, condition)` : same as `(name, callback)` but by default, the callback will be executed only if the condition return true



### `grp:register (name, callback, [condition])`

* `grp:register (name, callback)` : register a command action for the group `grp`, return the group `grp`

* `grp:register (name, callback, condition)` : same as `(name, callback)` but by default, the callback will be executed only if the condition function return true



### `Command.run (name, [force])`

* `Command.run (name)` : run the command given by `name`. If the command has a condition, the command is run if the condition function return `true`.

* `Command.run (name, force)` : run the command given by `name`. If the command has a condition and `force` is true, the condition result doesn't matter, and the condition is executed




idea: `(name, options)` with options :

- force (bool)
- args (table)





