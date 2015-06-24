#!/usr/bin/env lua

function readFile(path, nbLine)
	nbLine = type(nbLine) == "number" and nbLine or false
	local f = io.open(path)
	if not f then return nil end
	local tab = {}
	if not nbLine then
		for line in f:lines() do
			table.insert(tab, line)
		end
	else
		local i = 1
		for line in f:lines() do
			table.insert(tab, line)
			if nbLine == i then
				break
			end
			i = i + 1
		end
	end
	return tab
end


function do_test(path, nb)
	path = path and path or "nil"
	nb = nb and nb or "nil"
	print("---===##> readFile with " .. path .. " " .. nb .. " <##===---")
	local lines = readFile(path, nb)
	if not lines then
		print("nil")
	else
		for _, l in ipairs(lines) do
			print(l)
		end
	end
	print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n")
end


do_test("/home/lesell_b/bla")
do_test("/home/lesell_b/bla", 1)
do_test("/home/lesell_b/bla", 2)
do_test("/home/lesell_b/bla", 3)
do_test("/home/lesell_b/bla", 4)
do_test("/home/lesell_b/bla", false)
do_test("fjkd hlsdk fsdlk lskd sldk ", false)
