
local path = mod_loader.mods[modApi.currentMod].scriptPath
local achvApi = require(path .."achievements/api")
local getModUtils = require(path .."getModUtils")

local this = {}

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

function this:init(options)
	local oldMissionEnd = Mission_Final_Cave.MissionEnd
	
function Mission_Final_Cave:MissionEnd()
	oldMissionEnd()
	
	--Win the Game Achievements
	if GAME.squadTitles["TipTitle_"..GameData.ach_info.squad] ~= "Gravity Bombers" then return end
	--LOG("Game end achievment trigger code")
	xen_gravbomb_achievmentTriggers:Victory()
	xen_gravbomb_achievmentTriggers:Highscore()
end
	
end

function this:load(self)
	local modUtils = getModUtils()
	xen_gravbomb_achievmentTriggers = Skill:new{}

function xen_gravbomb_achievmentTriggers:Victory(mode)
	if GAME.squadTitles["TipTitle_"..GameData.ach_info.squad] ~= "Gravity Bombers" then return end
	local difficulty = GetRealDifficulty()
	local islands = 0
	for i = 0, 3 do
		if RegionData["island" .. i]["secured"] then
			islands = islands +1
		end
	end
	if islands < 2 then return end
	--achvApi:TriggerChievo("xen_gravbomb_complete", {win = true})		
	for i = 0, difficulty do
		if i == 0 then
			if islands == 2 then
				achvApi:TriggerChievo("xen_gravbomb_2clear", {easy = true})				
			elseif islands == 3 then
				achvApi:TriggerChievo("xen_gravbomb_3clear", {easy = true})				
			elseif islands == 4 then
				achvApi:TriggerChievo("xen_gravbomb_4clear", {easy = true})
			end
		elseif i == 1 then
			if islands == 2 then
				achvApi:TriggerChievo("xen_gravbomb_2clear", {normal = true})				
			elseif islands == 3 then
				achvApi:TriggerChievo("xen_gravbomb_3clear", {normal = true})				
			elseif islands == 4 then
				achvApi:TriggerChievo("xen_gravbomb_4clear", {normal = true})
			end
		elseif i == 2 then
			if islands == 2 then
				achvApi:TriggerChievo("xen_gravbomb_2clear", {hard = true})				
			elseif islands == 3 then
				achvApi:TriggerChievo("xen_gravbomb_3clear", {hard = true})				
			elseif islands == 4 then
				achvApi:TriggerChievo("xen_gravbomb_4clear", {hard = true})
			end
		end
	end	
	--self:Complete()	
end

function xen_gravbomb_achievmentTriggers:Highscore()
	if GAME.squadTitles["TipTitle_"..GameData.ach_info.squad] ~= "Gravity Bombers" then return end
	local highscore = GameData["current"]["score"]
	if highscore == 30000 then
		achvApi:TriggerChievo("xen_gravbomb_perfect")
	end
	
end

-- function xen_gravbomb_achievmentTriggers:Complete()
	-- --Don't re-trigger the toast if already cleared
	-- if achvApi:IsChievoProgress("xen_gravbomb_complete", {reward = true })	then return end
	-- if achvApi:IsChievoProgress("xen_gravbomb_complete", {prime = true, brute = true, ranged = true,	win = true,})	then
		-- local completetoast = {
			-- unlockTitle = "Unlocked!",
			-- name = "Bonus",
			-- tip = "You unlocked a bonus!",
			-- img = "img/achievements/xen_ach_prize.png"	
		-- }
			-- achvApi:TriggerChievo("xen_gravbomb_complete", { reward = true } )
			-- achvApi:ToastUnlock(completetoast)
	-- end	
-- end

end

return this