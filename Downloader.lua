-- simple script to just download (popped in roblox studio, should look kinda like vape. i know its not perfect PRS welcome)

local HttpService = cloneref(game:GetService("HttpService"))

local Downloader = {}
local _tasks = setmetatable({}, {})
local _debug = false
local _LogoPath = ""

local Log = newcclosure(function(...)
	if not _debug then
		return
	end

	return warn(...)
end)

function Downloader.AddRBXDownloadTask(RBXAssetID, Path)
	local SanatizedAssetId = RBXAssetID:gsub("^rbxasset(id)?://", "")
	local NewUrl = `https://assetdelivery.roblox.com/v1/asset/?id={SanatizedAssetId}`

	return Downloader.AddTask(NewUrl, Path)
end

function Downloader.AddTask(url: string, path: string)
	local TaskGuid = HttpService:GenerateGUID(false)

	_tasks[TaskGuid] = {
		url = url,
		path = path,
	}

	Log(`Inserted Task {TaskGuid} for Url {url} to Download at Path {path}`)
	return TaskGuid
end

local TasksMT = getrawmetatable(_tasks)
TasksMT.__newindex = newcclosure(function(self, guid, valueTbl)
	rawset(self, guid, valueTbl) -- [!!!!] ALWAYS RAWSET TO AVOID RE-INVOKING TO CAUSE C Stack OVERFLOW!

	task.spawn(function()
		Log("Spawned Task ", coroutine.running(), " because the Newindex Metamethod was Called.")

		local Req = request({
			Url = valueTbl.url,
			Method = "GET",
		})

		local Body = Req.Body

		pcall(writefile, valueTbl.path, Body)

		Log("Downloaded & Saved ", valueTbl.url, "to ", valueTbl.path)
		rawset(_tasks, guid, nil) -- Yea Here too with the Stack overflow (This can sometimes Not let the gui end cause of the Coroutine. :sadge:)
	end)
end)

task.spawn(function()
	-- (Vapev4 Background Creation + Corner) --

	local ScreenGui = Instance.new("ScreenGui", gethui())

	local Frame = Instance.new("Frame", ScreenGui)
	Frame.Name = "V4DownloadFrame"
	Frame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(0, 738, 0, 415)
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0)

	local UICorner = Instance.new("UICorner", Frame)
	UICorner.CornerRadius = UDim.new(0, 8)

	local DLAssets = Instance.new("TextLabel", Frame)
	DLAssets.AnchorPoint = Vector2.new(0.5, 0.5)
	DLAssets.Size = UDim2.new(0, 318, 0, 50)
	DLAssets.BackgroundTransparency = 1
	DLAssets.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold)
	DLAssets.Text = "DOWNLOADING ASSETS"
	DLAssets.TextColor3 = Color3.fromRGB(255, 255, 255)
	DLAssets.TextSize = 25
	DLAssets.TextXAlignment = Enum.TextXAlignment.Center
	DLAssets.TextYAlignment = Enum.TextYAlignment.Center

	local Descr = Instance.new("TextLabel", Frame)
	Descr.Size = UDim2.new(0, 265, 0, 40)
	Descr.BackgroundTransparency = 1
	Descr.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular)
	Descr.Text = "[...]"
	Descr.TextColor3 = Color3.fromRGB(95, 95, 95)
	Descr.TextSize = 22
	Descr.TextXAlignment = Enum.TextXAlignment.Center
	Descr.TextYAlignment = Enum.TextYAlignment.Center

	local Layout = Instance.new("UIListLayout", Frame)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	Layout.Padding = UDim.new(0, 8)

	-- (Loading Text Creation + Automator) --

	while task.wait() do
		local TasksLen = 0
		for _ in pairs(_tasks) do
			TasksLen += 1
		end
		Descr.Text = `Please wait while {TasksLen or "?"} assets are being downloaded...`

		if TasksLen == 0 then
			Frame.Visible = false
		else
			Frame.Visible = true
		end
	end
end)

return Downloader
