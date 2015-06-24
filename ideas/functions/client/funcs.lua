client = {
	getFocused = false,
	getAt = false, -- coords (x,y) OR mouse cursor

	--TODO: Faire un system de makage avancé des clients
	isMarked = false,
	setMark = false,

	--[[
		moveTo: -> a Tag
					-> create a new tag
				-> a Workspace
					-> at first available Tag
					-> create new tag
	]]
	moveTo = false,

	enterResizeMode = false,

}

