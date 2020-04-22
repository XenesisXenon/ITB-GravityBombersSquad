--INIT.LUA--

local mod = {
	id = "xen_GravBombers",
	name = "Gravity Bombers Squad",
	version = "WIP8",
	modApiVersion = "2.5.1",
	icon = "img/mod_icon.png",
	requirements = {}
}

function mod:init()
	local scriptPath = self.scriptPath
	local resourcePath = self.resourcePath
	
	require(self.scriptPath.."FURL")(self, {
	 {
    		Type = "color",
    		Name = "GravityBombers",
    		PawnLocation = self.scriptPath.."pawns",
			
			PlateHighlight = {230, 210, 115}, --lights
			PlateLight =     { 89, 101, 161}, --main highlight
			PlateMid =       { 43,  61,  87}, --main light
			PlateDark =      { 19,  34,  41}, --main mid
			PlateOutline =   {  5,  10,  10}, --main dark
			BodyHighlight =  {115,  83,  52}, --metal light
			BodyColor =      { 77,  62,  46}, --metal mid
			PlateShadow =    { 36,  34,  26}, --metal dark
			
    },
	});
	
	self.modApiExt = require(scriptPath .."modApiExt/modApiExt")
	self.modApiExt:init()
	
	self.pawns = require(self.scriptPath.."pawns")
	self.weapons = require(self.scriptPath.."weapons")
	
	self.pawns:init(self)
	self.weapons:init(self)
	
	modApi:appendAsset("img/combat/tile_icon/xen_tile_debuff.png",self.resourcePath.."img/tile_debuff.png")
	modApi:appendAsset("img/combat/tile_icon/xen_tile_buff.png",self.resourcePath.."img/tile_buff.png")
	modApi:appendAsset("img/combat/tile_icon/xen_tile_repair.png",self.resourcePath.."img/tile_repair.png")
	modApi:appendAsset("img/combat/tile_icon/xen_tile_debuff_repair.png",self.resourcePath.."img/tile_debuff_repair.png")
	modApi:appendAsset("img/combat/tile_icon/xen_tile_buff_repair.png",self.resourcePath.."img/tile_buff_repair.png")
	modApi:appendAsset("img/weapons/xen_weapon_prime_throw.png",self.resourcePath.."img/weapon_prime_throw.png")
	modApi:appendAsset("img/weapons/xen_weapon_ranged_mechlauncher.png",self.resourcePath.."img/weapon_ranged_mechlauncher.png")
	modApi:appendAsset("img/weapons/xen_weapon_science_recall.png",self.resourcePath.."img/weapon_science_recall.png")
	modApi:appendAsset("img/weapons/xen_weapon_passive_nullzone.png",self.resourcePath.."img/weapon_passive_nullzone.png")
	modApi:appendAsset("img/weapons/xen_weapon_passive_ampzone.png",self.resourcePath.."img/weapon_passive_ampzone.png")
	
	require(scriptPath .."achievements/init")
	require(scriptPath .."achievements")
	require(scriptPath .."achievementTriggers"):init(options)	
	local achvApi = require(scriptPath .."/achievements/api")
	
	modApi:addGenerationOption(
		"Squad_Passive",
		"Squad Passive",
		"Select the passive skill included with the squad.\n\nDefault: Dampening Field",
		{
			strings = {
				xen_Passive_NullZone.Name,
				--xen_Passive_AmpZone.Name,
				--xen_Passive_RepairZone.Name,
--[[
				"Flame Shielding",
				"Storm Generator",
				"Viscera Nanobots",
				"Repair Field",
				"Networked Armor",
				"Stabilizers",
				"Auto-Shields",
				"Psionic Receiver",
				"Kickoff Boosters",
				"Medical Supplies",
				"Vek Hormones",
				"Force Amp",
				"Critical Shields", 
]]
				
		},
		values = {
			1,
			--2,
			--3,
--[[ 			
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			16,
			18,
			 ]]
		},
		value = 1,
		}
	)
	
	local shop = require(self.scriptPath .."shop")
	shop:addWeapon({
		id = "xen_Prime_Yeet",
		name = xen_Prime_Yeet.Name .. " can be found",
		desc = "Adds " .. xen_Prime_Yeet.Name .. " to the store and equipment drop pool.",
	})
	shop:addWeapon({
		id = "xen_Ranged_CrushArtillery",
		name = xen_Ranged_CrushArtillery.Name .. " can be found",
		desc = "Adds " .. xen_Ranged_CrushArtillery.Name .. " to the store and equipment drop pool.",
	})
	shop:addWeapon({
		id = "xen_Science_RecallTeleporter",
		name = xen_Science_RecallTeleporter.Name .. " can be found",
		desc = "Adds " .. xen_Science_RecallTeleporter.Name .. " to the store and equipment drop pool.",
	})
	shop:addWeapon({
		id = "xen_Passive_NullZone",
		name = "Passive: " .. xen_Passive_NullZone.Name .. " can be found",
		desc = "Adds Passive: " .. xen_Passive_NullZone.Name .. " to the store and equipment drop pool.",
	})
	shop:addWeapon({
		id = "xen_Passive_AmpZone",
		name = "Passive: " .. xen_Passive_AmpZone.Name .. " can be found",
		desc = "Adds Passive: " .. xen_Passive_AmpZone.Name .. " to the store and equipment drop pool.",
	})
	shop:addWeapon({
		id = "xen_Passive_RepairZone",
		name = "Passive: " .. xen_Passive_RepairZone.Name .. " can be found",
		desc = "Adds Passive: " .. xen_Passive_RepairZone.Name .. " to the store and equipment drop pool.",
	})
end

function mod:load(options, version)
	local scriptPath = self.scriptPath
	self.modApiExt:load(self, options, version)
	self.weapons:load(self.modApiExt)
	local opt = options["Squad_Passive"].value
	self.pawns:load(self.modApiExt,opt)

	modApi:addSquad(
	{
		"Gravity Bombers",
		"xen_ThrowMech", 
		"xen_HeavyMech", 
		"xen_AssistMech"
	}, 
		"Gravity Bombers", 
		"This squad throws thousands of tonnes of metal and vek skywards...and gravity does the rest.", 
		self.resourcePath .. "img/mod_icon2.png"
	)
	
	require(self.scriptPath .."shop"):load(options)
	require(scriptPath .."achievementTriggers"):load(self)	
	
end

return mod