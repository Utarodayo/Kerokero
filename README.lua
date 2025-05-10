local scriptCode = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents
local KillEvent = ReplicatedStorage:WaitForChild("AdminKill")
local KickEvent = ReplicatedStorage:WaitForChild("AdminKick")
local BanEvent = ReplicatedStorage:WaitForChild("AdminBan")
local MsgEvent = ReplicatedStorage:WaitForChild("AdminMsg")

-- 管理者リスト（ユーザー名）
local ADMINS = {
	["dabaf05"] = true,
	["Happy25594"] = true,
	["DB_SUBBB"] = true,
	["dabaf07"] = true,
	["qwarf17"] = true
}

local bannedUsers = {}

Players.PlayerAdded:Connect(function(player)
	if bannedUsers[player.Name] then
		player:Kick("You are banned from this server.")
	end
end)

local function killPlayer(player)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.Health = 0
	end
end

local function sendMessage(player, text)
	local message = Instance.new("Message", player:WaitForChild("PlayerGui"))
	message.Text = text
	game:GetService("Debris"):AddItem(message, 5)
end

-- Durationを年、月、時間、分、秒で処理する関数
local function convertDurationToSeconds(duration)
    local num = tonumber(duration:match("%d+")) -- 数字を取り出す
    local unit = duration:match("%a+") -- 単位（y, m, h, m, s）

    if not num or not unit then return 0 end

    if unit == "y" then
        return num * 365 * 24 * 60 * 60 -- 1年を秒に換算
    elseif unit == "m" then
        return num * 30 * 24 * 60 * 60 -- 1ヶ月を30日と仮定して秒に換算
    elseif unit == "h" then
        return num * 60 * 60 -- 1時間を秒に換算
    elseif unit == "min" or unit == "m" then
        return num * 60 -- 1分を秒に換算
    elseif unit == "s" then
        return num -- 秒そのまま
    else
        return 0 -- 無効な単位は0にする
    end
end

-- RemoteEventsで受け取る処理
KillEvent.OnServerEvent:Connect(function(player, targetName)
	if not ADMINS[player.Name] then return end
	local target = Players:FindFirstChild(targetName)
	if target then
		killPlayer(target)
	end
end)

KickEvent.OnServerEvent:Connect(function(player, targetName, reason)
	if not ADMINS[player.Name] then return end
	local target = Players:FindFirstChild(targetName)
	if target then
		target:Kick("Kicked by admin. Reason: " .. reason)
	end
end)

BanEvent.OnServerEvent:Connect(function(player, targetName, reason, duration)
	if not ADMINS[player.Name] then return end
	local target = Players:FindFirstChild(targetName)
	if target then
		-- バンの期間を秒に変換
		local durationInSeconds = convertDurationToSeconds(duration)
		bannedUsers[target.Name] = true
		target:Kick("Banned by admin. Reason: " .. reason)
		if durationInSeconds > 0 then
			-- 期間（秒）後に解除
			wait(durationInSeconds)
			bannedUsers[target.Name] = nil
		end
	end
end)

MsgEvent.OnServerEvent:Connect(function(player, targetName, message)
	if not ADMINS[player.Name] then return end
	local target = Players:FindFirstChild(targetName)
	if target then
		sendMessage(target, message)
	end
end)
]]

local func, err = loadstring(scriptCode)
if func then
	func()
else
	warn("Error loading script: " .. err)
end
