-- 03: Spy v2 - igual ao v1, mas tambem mostra o RETORNO das RemoteFunction
-- ([Remote](args) -> retorno). Ainda usa __namecall.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local lines, box = {}, nil

local function add(s)
	table.insert(lines, s)
	if #lines > 60 then table.remove(lines, 1) end
	if box then box.Text = table.concat(lines, "\n") end
end

local function fmt(v, d)
	d = d or 0
	if typeof(v) == "table" and d < 2 then
		local t = {}
		for k, x in pairs(v) do t[#t + 1] = tostring(k) .. "=" .. fmt(x, d + 1) end
		return "{" .. table.concat(t, ", ") .. "}"
	elseif typeof(v) == "Instance" then
		return "Inst:" .. v:GetFullName()
	end
	return typeof(v) .. ":" .. tostring(v)
end

local gui = Instance.new("ScreenGui")
gui.Name = "SpyRemotes"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

box = Instance.new("TextBox")
box.Size = UDim2.new(0, 320, 0, 220)
box.Position = UDim2.new(0.5, -160, 0.5, -110)
box.BackgroundColor3 = Color3.new(0, 0, 0)
box.BackgroundTransparency = 0.2
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.Code
box.TextSize = 11
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextWrapped = true
box.MultiLine = true
box.ClearTextOnFocus = false
box.Text = "Treine, jogue, venda manualmente."
box.Parent = gui

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 60, 0, 22)
close.Position = UDim2.new(0.5, 100, 0.5, -136)
close.Text = "Fechar"
close.BackgroundColor3 = Color3.fromRGB(190, 55, 55)
close.TextColor3 = Color3.new(1, 1, 1)
close.Parent = gui
close.Activated:Connect(function() gui:Destroy() end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
	local m = getnamecallmethod()
	if (m == "InvokeServer" or m == "FireServer") and typeof(self) == "Instance"
		and self.Parent and self.Parent.Name == "Remotes" then
		local args = table.pack(...)
		local t = {}
		for i = 1, args.n do t[i] = fmt(args[i]) end
		local argStr = table.concat(t, ", ")
		if m == "InvokeServer" then
			local res = table.pack(old(self, ...))
			local r = {}
			for i = 1, res.n do r[i] = fmt(res[i]) end
			task.defer(add, "[" .. self.Name .. "](" .. argStr .. ") -> " .. table.concat(r, ", "))
			return table.unpack(res, 1, res.n)
		end
		task.defer(add, "[" .. self.Name .. "] " .. argStr)
	end
	return old(self, ...)
end)

setreadonly(mt, true)
