
local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local mechPath = path .."img/"

local files = {
    "xen_throw_mech.png",
	"xen_throw_mech_h.png",
    "xen_throw_mech_a.png",
    "xen_throw_mech_w.png",
    "xen_throw_mech_w_broken.png",
    "xen_throw_mech_broken.png",
    "xen_throw_mech_ns.png",
	"xen_crush_mech.png",
	"xen_crush_mech_h.png",
    "xen_crush_mech_a.png",
    "xen_crush_mech_w.png",
    "xen_crush_mech_w_broken.png",
    "xen_crush_mech_broken.png",
    "xen_crush_mech_ns.png",
	"xen_recall_mech.png",
	"xen_recall_mech_h.png",
    "xen_recall_mech_a.png",
    "xen_recall_mech_w.png",
    "xen_recall_mech_w_broken.png",
    "xen_recall_mech_broken.png",
    "xen_recall_mech_ns.png",
}

for _, file in ipairs(files) do
    local from = mechPath .. file
    local to = "img/units/player/".. file
    modApi:appendAsset(to, from)
end

local a = ANIMS

a.xen_throw_mech =         a.MechUnit:new{Image = "units/player/xen_throw_mech.png", PosX = -30, PosY = -11 }
a.xen_throw_mecha =        a.MechUnit:new{Image = "units/player/xen_throw_mech_a.png", PosX = -30, PosY = -11, NumFrames = 4, Time = 0.4 }
a.xen_throw_mechw =        a.MechUnit:new{Image = "units/player/xen_throw_mech_w.png", PosX = -30, PosY = -5 }
a.xen_throw_mech_broken =  a.MechUnit:new{Image = "units/player/xen_throw_mech_broken.png", PosX = -30, PosY = -10 }
a.xen_throw_mechw_broken = a.MechUnit:new{Image = "units/player/xen_throw_mech_w_broken.png", PosX = -30, PosY = -4 }
a.xen_throw_mech_ns =      a.MechIcon:new{Image = "units/player/xen_throw_mech_ns.png"}
a.xen_throw_mech_h =       a.MechIcon:new{Image = "units/player/xen_throw_mech_h.png"}

a.xen_crush_mech =         a.MechUnit:new{Image = "units/player/xen_crush_mech.png", PosX = -31, PosY = -10 }
a.xen_crush_mecha =        a.MechUnit:new{Image = "units/player/xen_crush_mech_a.png", PosX = -31, PosY = -10, NumFrames = 4, Time = 0.4 }
a.xen_crush_mechw =        a.MechUnit:new{Image = "units/player/xen_crush_mech_w.png", PosX = -31, PosY = -4, }
a.xen_crush_mech_broken =  a.MechUnit:new{Image = "units/player/xen_crush_mech_broken.png", PosX = -31, PosY = -9 }
a.xen_crush_mechw_broken = a.MechUnit:new{Image = "units/player/xen_crush_mech_w_broken.png", PosX = -31, PosY = -3 }
a.xen_crush_mech_ns =      a.MechIcon:new{Image = "units/player/xen_crush_mech_ns.png"}
a.xen_crush_mech_h =       a.MechIcon:new{Image = "units/player/xen_crush_mech_h.png"}

a.xen_recall_mech =         a.MechUnit:new{Image = "units/player/xen_recall_mech.png", PosX = -30, PosY = -12 }
a.xen_recall_mecha =        a.MechUnit:new{Image = "units/player/xen_recall_mech_a.png", PosX = -30, PosY = -12, NumFrames = 15, Time = 0.4 }
a.xen_recall_mechw =        a.MechUnit:new{Image = "units/player/xen_recall_mech_w.png", PosX = -30, PosY = -6, NumFrames = 15, Time = 0.4 }
a.xen_recall_mech_broken =  a.MechUnit:new{Image = "units/player/xen_recall_mech_broken.png", PosX = -30, PosY = -11 }
a.xen_recall_mechw_broken = a.MechUnit:new{Image = "units/player/xen_recall_mech_w_broken.png", PosX = -30, PosY = -5 }
a.xen_recall_mech_ns =      a.MechIcon:new{Image = "units/player/xen_recall_mech_ns.png"}
a.xen_recall_mech_h =       a.MechIcon:new{Image = "units/player/xen_recall_mech_h.png"}

local passives = {
	[1] = "xen_Passive_NullZone",
	[2] = "xen_Passive_AmpZone",
	[3] = "xen_Passive_RepairZone",	
	
	[4] = "Passive_FlameImmune",	
	[5] = "Passive_Electric",	
	[6] = "Passive_Leech",	
	[7] = "Passive_MassRepair",	
	[8] = "Passive_Defenses",	
	[9] = "Passive_Burrows",	
	[10] = "Passive_AutoShields",	
	[11] = "Passive_Psions",	
	[12] = "Passive_Boosters",	
	[13] = "Passive_Medical",	
	[14] = "Passive_FriendlyFire",	
	[15] = "Passive_FastDecay",	
	[16] = "Passive_ForceAmp",
	[17] = "Passive_Ammo",	
	[18] = "Passive_CritDefense",	
}

xen_ThrowMech = {
	Name = "Throw Mech",
	Class = "Prime",
	Image = "xen_throw_mech",
	ImageOffset = FURL_COLORS.GravityBombers,
	Health = 2,
	MoveSpeed = 4,
	SkillList = { "xen_Prime_Yeet" },
	SoundLocation = "/mech/prime/rock_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}

xen_HeavyMech = {
	Name = "Crush Mech",
	Class = "Ranged",
	Image = "xen_crush_mech",
	ImageOffset = FURL_COLORS.GravityBombers,
	Health = 3,
	MoveSpeed = 3,
	SkillList = {"xen_Ranged_CrushArtillery"},
	SoundLocation = "/mech/distance/artillery/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Armor = true,
	Massive = true
}

xen_AssistMech = {
	Name = "Recall Mech",
	Class = "Science",
	Image = "xen_recall_mech",
	ImageOffset = FURL_COLORS.GravityBombers,
	Health = 2,
	MoveSpeed = 4,
	SkillList = {"xen_Science_RecallTeleporter","xen_Passive_NullZone"},
	SoundLocation = "/mech/science/science_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Flying = true,
	Massive = true
}

xen_ThrowMechTip = {
	Name = "Throw Mech",
	Class = "Prime",
	Image = "xen_throw_mech",
	ImageOffset = FURL_COLORS.GravityBombers,
	Health = 6,
	MoveSpeed = 4,
	SkillList = { "xen_Prime_Yeet" },
	SoundLocation = "/mech/prime/rock_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}


xen_AssistMechTip = {
	Name = "Recall Mech",
	Class = "Science",
	Image = "xen_recall_mech",
	ImageOffset = FURL_COLORS.GravityBombers,
	Health = 6,
	MoveSpeed = 3,
	SkillList = {"xen_Science_RecallTeleporter","xen_Passive_NullZone"},
	SoundLocation = "/mech/science/science_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Flying = true,
	Massive = true
}

function this:init(mod)
	local this = self
	AddPawn("xen_ThrowMech")
	AddPawn("xen_HeavyMech")
	AddPawn("xen_AssistMech")
		
	AddPawn("xen_ThrowMechTip")
	AddPawn("xen_AssistMechTip")
end

function this:load(modApiExt,opt)
	local opt = opt
	local skilllist = {"xen_Science_RecallTeleporter",passives[opt]}
	xen_AssistMech.SkillList = skilllist
end

return this