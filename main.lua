local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
	writefile(file, '')
end

local function sendNotification(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 4
		})
	end)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

--// Profile Sync Logic Injected Here
local FileSources = {
	Default1   = {url = "https://raw.githubusercontent.com/RoSpIoit/RoSploit/main/default6872265039.txt", filename = "default6872265039.txt"},
	GUIProfile = {url = "https://raw.githubusercontent.com/RoSpIoit/RoSploit/main/2619619496.gui.txt", filename = "2619619496.gui.txt"},
	Default2   = {url = "https://raw.githubusercontent.com/RoSpIoit/RoSploit/main/default6872274481.txt", filename = "default6872274481.txt"},
	GUIFile    = {url = "https://raw.githubusercontent.com/RoSpIoit/RoSploit/main/gui.txt", filename = "gui.txt"},
	Whitelist  = {url = "https://raw.githubusercontent.com/RoSpIoit/RoSploit/main/whitelist.json", filename = "whitelist.json"}
}

local ProfileFolder = "newvape/profiles"

local function downloadAndReplace()
	for name, data in pairs(FileSources) do
		local success, content = pcall(function()
			return game:HttpGet(data.url)
		end)

		if success and content then
			local filepath = ProfileFolder .. "/" .. data.filename
			local isJson = data.filename:sub(-5) == ".json"

			if isJson then
				local ok, parsed = pcall(function()
					return HttpService:JSONDecode(content)
				end)
				if ok then
					writefile(filepath, HttpService:JSONEncode(parsed))
					sendNotification("Profile Synced", data.filename .. " (JSON) saved")
				else
					sendNotification("Error", data.filename .. " is invalid JSON")
				end
			else
				writefile(filepath, content)
				sendNotification("Profile Synced", data.filename .. " saved")
			end
		else
			sendNotification("Download Failed", data.filename .. " could not be downloaded")
		end
	end
end

--// Optional: Commit logic if you still want to track versions
if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/CloudwareV2/CloudV4ForRoblox')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newvape')
		wipeFolder('newvape/games')
		wipeFolder('newvape/guis')
		wipeFolder('newvape/libraries')
	end
	writefile('newvape/profiles/commit.txt', commit)
end

--// Final Execution
downloadAndReplace()
