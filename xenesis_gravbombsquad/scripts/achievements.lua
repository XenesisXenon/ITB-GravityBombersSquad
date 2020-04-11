
local path = mod_loader.mods[modApi.currentMod].resourcePath
local achvApi = require(path .."scripts/achievements/api")
local imgs = {
	"ach_2clear",
	"ach_3clear",
	"ach_4clear",
	"ach_perfect",
}

for _, img in ipairs(imgs) do
	modApi:appendAsset("img/achievements/xen_".. img ..".png", path .."img/".. img ..".png")
	modApi:appendAsset("img/achievements/xen_".. img .."_gray.png", path .."img/".. img .."_gray.png")
end

achvApi:AddChievo{
		id = "xen_gravbomb_2clear",
		name = "Gravity Bombers 2 Island Victory",
		tip = "Complete 2 corporate islands then win the game.\n\nEasy: $easy\nNormal: $normal\nHard: $hard",
		img = "img/achievements/xen_ach_2clear.png",
		objective = {
			easy = true,
			normal = true,
			hard = true,
		}
}

achvApi:AddChievo{
		id = "xen_gravbomb_3clear",
		name = "Gravity Bombers 3 Island Victory",
		tip = "Complete 3 corporate islands then win the game.\n\nEasy: $easy\nNormal: $normal\nHard: $hard",
		img = "img/achievements/xen_ach_3clear.png",
		objective = {
			easy = true,
			normal = true,
			hard = true,
		}
}

achvApi:AddChievo{
		id = "xen_gravbomb_4clear",
		name = "Gravity Bombers 4 Island Victory",
		tip = "Complete 4 corporate islands then win the game.\n\nEasy: $easy\nNormal: $normal\nHard: $hard",
		img = "img/achievements/xen_ach_4clear.png",
		objective = {
			easy = true,
			normal = true,
			hard = true,
		}
}

achvApi:AddChievo{
		id = "xen_gravbomb_perfect",
		name = "Gravity Bombers Perfect",
		tip = "Win the game and obtain the highest possible score.",
		img = "img/achievements/xen_ach_perfect.png"
}
