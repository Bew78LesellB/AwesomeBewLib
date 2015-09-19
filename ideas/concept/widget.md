# Bewlib Widgets


## Tag list

	Tag1 [Tag2] Tag3 Tag4

usage :

```lua
local Widget = require("bewlib.widget")

-- all tags, no filter
widget = Widget.newTagList()

-- same as :
widget = Widget.newTagList({
	filter = Widget.TagList.filter.all,
	-- same as :
	filter = "all",
})


widget = Widget.newTagList({
	filter = {
		workspace = "current", -- "current" is a special workspace id
	},
})
```




## WS (Workspace) list

	[Workspace1] Workspace2 Workspace3


## WSTag list

WS list and Tag list combined

	[Workspace1] Workspace2 Workspace3 -- Tag1 [Tag2] Tag3 Tag4



