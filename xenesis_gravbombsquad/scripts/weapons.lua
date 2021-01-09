--WEAPONS.LUA--
local path = mod_loader.mods[modApi.currentMod].resourcePath
local scriptpath = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."scripts/getModUtils")
local scriptpath = mod_loader.mods[modApi.currentMod].scriptPath
local weaponApi = require(scriptpath .."weapons/api")

local this = {}

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

--Yeet Squad Weapon Definitions--
--Prime Throw (Prime)--
xen_Prime_Yeet = Skill:new{
	Name = "Prime Throw",
	Description = "Throw targets, creating an explosion where the target lands. Throw farther to do more damage.",
	Class = "Prime",
	Icon = "weapons/xen_weapon_prime_throw.png",
	Damage = 2,
	MinDamage = 1,
	SplashDamage = 0,
	PowerCost = 2,
	Upgrades = 2,
	AllyDamage = 0,
	BuildingDamage = true,
	UpgradeCost = {2,2},
	Range = 3,
	LaunchSound = "/weapons/shift",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,4),
		Enemy2 = Point(2,0),
		Building = Point(3,1),
		Building2 = Point(3,2),
		Friendly = Point(1,1),
		Friendly2 = Point(1,3),
		Second_Origin = Point(2,3),
		Second_Target = Point(3,3),
		}
}

function xen_Prime_Yeet:GetTargetArea(p1)
local ret = PointList()
  for dir = DIR_START, DIR_END do
    local curr = p1 - DIR_VECTORS[dir]
    if Board:IsPawnSpace(curr) and not Board:GetPawn(curr):IsGuarding() then
    	local throwrange = self.Range
    	for i = 1, throwrange do
    		local curr = p1 + DIR_VECTORS[dir]*i
    		if not Board:IsBlocked(curr, PATH_FLYER) then
    		ret:push_back(curr)
    		end
    	end
    end
  end
return ret
end

function xen_Prime_Yeet:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local target = p1+DIR_VECTORS[(direction+2)%4]
	ret:AddMelee(p1,SpaceDamage(target,0))
	local move = PointList()
	move:push_back(p1-DIR_VECTORS[direction])
	move:push_back(p2)
	ret:AddLeap(move, FULL_DELAY)
	
	local distance = p1:Manhattan(p2)
	--LOG(distance)

	local centre = SpaceDamage(p2,self.MinDamage + math.floor((distance / 2 )))
	if Board:IsPawnTeam(p1-DIR_VECTORS[direction],TEAM_PLAYER) then
		centre.iDamage = centre.iDamage - self.AllyDamage
		if centre.iDamage < 1 then
			centre.iDamage = 1
		end
	end
	ret:AddDamage(centre)
	ret:AddBounce(centre.loc,10)

	if distance > 1 then
		for i = -1, 1 do
			for j = -1, 1 do
				if i ~= j and i ~= -j then
					local damage = SpaceDamage(p2+Point(i,j),self.SplashDamage + math.floor((distance / 2 )))
					local animdir = GetDirection(p2+Point(i,j) - p2)
					damage.sAnimation = "explopush1_" .. animdir
					
					--damage.sAnimation = "ExploArt2"
					if Board:IsBuilding(p2+Point(i,j)) and self.BuildingDamage == false then
						damage.iDamage = 0
					end
					if Board:IsPawnTeam(p2+Point(i,j),TEAM_PLAYER) then
						damage.iDamage = damage.iDamage - self.AllyDamage
						if damage.iDamage < 1 then
							damage.iDamage = 0
						end
					end
					ret:AddDamage(damage)		
				end
			end
		end
	end
	return ret
end


xen_Prime_Yeet_A = xen_Prime_Yeet:new{
	UpgradeDescription = "Increase minimum throw damage by 1 and reduce damage to friendly units.",
	AllyDamage = 10,
	MinDamage = 2,
	SplashDamage = 1,
	Damage = 3,
}

xen_Prime_Yeet_B = xen_Prime_Yeet:new{
	UpgradeDescription = "Buildings take no damage and increase maximum throw distance by 1.",
	Range = 4,
	Damage = 3,
	BuildingDamage = false,
}

xen_Prime_Yeet_AB = xen_Prime_Yeet:new{
	Range = 4,
	AllyDamage = 10,
	MinDamage = 2,
	Damage = 4,
	SplashDamage = 1,
	BuildingDamage = false,
}

Weapon_Texts.xen_Prime_Yeet_Upgrade1 = "Damage Tuning"
Weapon_Texts.xen_Prime_Yeet_Upgrade2 = "Building & Range"

--Recall Teleport (Science)--
xen_Science_RecallTeleporter = Skill:new{
	Name = "Recall Teleporter",
	Class = "Science",
	Description = "Teleport forward and pull a unit with you. Teleporting repairs the mech. You can teleport forward to any allied unit.",
	Icon = "weapons/xen_weapon_science_recall.png",
	Rarity = 1,
	Explosion = "",
	Repair = -1,
	AllyRepair = 0,
	Range = 2,
	Acid = false,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },
	LaunchSound = "/weapons/swap",
	Animation = "ExploRepulse1",
	TipImage = {
		Unit = Point(3,2),
		Enemy1 = Point(3,3),
		Enemy2 = Point(3,1),
		Enemy3 = Point(2,2),
		Enemy4 = Point(4,2),
		Target = Point(1,2),
		Fire = Point(1,2),
		Friendly_Damaged = Point(1,1),
		Friendly2_Damaged = Point(1,3),
		}	
}

function xen_Science_RecallTeleporter:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for range = 1, self.Range do
			local curr = point + DIR_VECTORS[dir]*range
			if not Board:IsBlocked(curr, PATH_FLYER) and Board:IsValid(curr) then
				ret:push_back(curr)
			end
		end
		for range = 2, 8 do
			local curr = point + DIR_VECTORS[dir]*range
			for eir = DIR_START, DIR_END do
				if not Board:IsBlocked(curr, PATH_FLYER) and 
				Board:IsValid(curr) and 
				Board:GetPawnTeam(curr + DIR_VECTORS[eir]) == TEAM_PLAYER then
					ret:push_back(curr)
				end
			end
		end
	end	
	return ret
end

function xen_Science_RecallTeleporter:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	
	local animation = SpaceDamage(p1,0)
	animation.sAnimation = self.Animation
	ret:AddDamage(animation)	

	if self.Acid then
		for dir = DIR_START, DIR_END do
			damage = SpaceDamage(p1 + DIR_VECTORS[dir], 0)
			damage.iAcid = EFFECT_CREATE
			damage.sAnimation = "ExploAcid1"
			ret:AddDamage(damage)
		end
	end
	
	local delay = Board:IsPawnSpace(p2) and 0 or FULL_DELAY
	ret:AddTeleport(p1,p2, delay)
	if delay ~= FULL_DELAY then
		ret:AddTeleport(p2,p1, FULL_DELAY)
	end
	
	if self.Repair < 0 then
		local damage = SpaceDamage(p2,self.Repair)
		damage.iAcid = EFFECT_REMOVE
		damage.iFrozen = EFFECT_REMOVE
		damage.iFire = EFFECT_REMOVE	
		ret:AddDamage(damage)
	end
	
	if self.AllyRepair < 0 then
		for dir = DIR_START, DIR_END do
			if Board:GetPawnTeam(p2 + DIR_VECTORS[dir]) == TEAM_PLAYER
			and Board:IsPawnSpace(p2 + DIR_VECTORS[dir])
			then
				local curr = p2 + DIR_VECTORS[dir]
				if curr ~= p1 then
					damage = SpaceDamage(p2 + DIR_VECTORS[dir], self.AllyRepair)
					damage.iAcid = EFFECT_REMOVE
					damage.iFrozen = EFFECT_REMOVE
					damage.iFire = EFFECT_REMOVE	
					ret:AddDamage(damage)
				end
			end
		end		
	end
	
	local pull = SpaceDamage(p1 - DIR_VECTORS[direction], 0, direction)
	ret:AddDamage(pull)
	
	if IsTipImage() then
		ret:AddDelay(3)
	end
	return ret
end

xen_Science_RecallTeleporter_A = xen_Science_RecallTeleporter:new{
	Repair = -2,
	AllyRepair = -1,
	UpgradeDescription = "Repair adjacent allied units at your destination. Self repair increased to 2 HP."	
}

xen_Science_RecallTeleporter_B = xen_Science_RecallTeleporter:new{
	Acid = true,
	UpgradeDescription = "Create an A.C.I.D. explosion from your origin point."	
}

xen_Science_RecallTeleporter_AB = xen_Science_RecallTeleporter:new{
	Repair = -2,
	AllyRepair = -1,
	Acid = true,
}

Weapon_Texts.xen_Science_RecallTeleporter_Upgrade1 = "Patch-Up"
Weapon_Texts.xen_Science_RecallTeleporter_Upgrade2 = "A.C.I.D. Explosion"

--Crush Artillery (Ranged)
xen_Ranged_CrushArtillery =	Leap_Attack:new{
	Name = "Mech-Launcher",
	Class = "Ranged",
	Description = "Fire your own mech as a projectile, damaging self and forward tiles. Longer distance shots do increased damage and less self damage.",
	Icon = "weapons/xen_weapon_ranged_mechlauncher.png",	
	Rarity = 1,
	MinRange = 2,
	Range = 8,
	Cost = 1,
	Damage = 2,
	SelfDamage = 1,
	Push = false,
	Vertical = false,
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = {1,2},
	LaunchSound = "/weapons/artillery_volley",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,1),
		Enemy2 = Point(1,1),
		Enemy3 = Point(3,1),
		Enemy4 = Point(2,3),
		Target = Point(2,2)
	}
}

function xen_Ranged_CrushArtillery:GetTargetArea(point)
---For water in tipimage
	if not Board.gameBoard then 
		local p = {
			Point(2,2),
			Point(1,0),
			Point(3,0),
		}
		for _,v in pairs(p) do 
			
			local fx = SpaceDamage(v) ; fx.iTerrain = TERRAIN_WATER
			Board:DamageSpace(fx) 
				
		end		
	end
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		for k = self.MinRange, self.Range do
			local curr = DIR_VECTORS[i]*k + point
			if Board:IsValid(curr) and not Board:IsBlocked(curr, Pawn:GetPathProf()) then
				ret:push_back(DIR_VECTORS[i]*k + point)
			end
		end
	end
	
	--For self-targeting
	if self.Vertical then
		ret:push_back(point)
	end
		
	return ret
end

function xen_Ranged_CrushArtillery:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	--Standard forward shot
	if p1 ~= p2 then
		local move = PointList()
		move:push_back(p1)
		move:push_back(p2)
		ret:AddBounce(p1,5)
		ret:AddLeap(move, FULL_DELAY)
		ret:AddBounce(p2,5)
	
		local direction = GetDirection(p2 - p1)
		local reverse = GetDirection(p1 - p2)

		local damage = SpaceDamage(p2, self.SelfDamage)
		damage.sAnimation = "airpush_".. (direction)
		if p1:Manhattan(p2) == 1 then
			damage.iDamage = damage.iDamage + 1
		end
		if p1:Manhattan(p2) > 5 then
			damage.iDamage = 0
		end		
		ret:AddDamage(damage)	
		
		animation = SpaceDamage(p2,0)
		animation.sAnimation = "airpush_".. (reverse)
		ret:AddDamage(animation)
	
		ret:AddDelay(0.3)
		
		damage = SpaceDamage(p2 + DIR_VECTORS[direction], self.Damage)
		if p1:Manhattan(p2) == 1 then
			damage.iDamage = damage.iDamage - 1
			if damage.iDamage < 1 then
				damage.iDamage = 0
			end
		end
		if p1:Manhattan(p2) > 5 then
			damage.iDamage = damage.iDamage + 1
		end		
		damage.sAnimation = "explopush2_" .. direction
		damage.iPush = direction
		ret:AddDamage(damage)
			
		backdamage = SpaceDamage(p2 + DIR_VECTORS[reverse], 0)
		--damage.sAnimation = "airpush_".. (reverse)
		backdamage.iPush = reverse
		ret:AddDamage(backdamage)
		
		if self.Push then
			damage = SpaceDamage(p2 + DIR_VECTORS[direction] + (DIR_VECTORS[(direction+1)%4]), 0)
			damage.sAnimation = "airpush_".. (direction)
			damage.iPush = direction
			ret:AddDamage(damage)
						
			damage = SpaceDamage(p2 + DIR_VECTORS[direction] + (DIR_VECTORS[(direction-1)%4]), 0)
			damage.sAnimation = "airpush_".. (direction)
			damage.iPush = direction
			ret:AddDamage(damage)	
		end		
	end
	
	--Vertical shot
	if p1 == p2 and self.Vertical then
		ret:AddBounce(p1,-10)
		ret:AddDelay(0.5)
		ret:AddBounce(p1,2)
		
		local damage = SpaceDamage(p2, self.SelfDamage + 1)
		damage.sAnimation = "airpush_0"
		ret:AddDamage(damage)
		for dir = DIR_START, DIR_END do					
			--Animation
			animation = SpaceDamage(p2,0)
			animation.sAnimation = "airpush_".. (dir)
			ret:AddDamage(animation)
		end
		ret:AddDelay(0.3)
		for dir = DIR_START, DIR_END do
			local damage = SpaceDamage(p2 + DIR_VECTORS[dir], self.Damage - 1)
			local direction = GetDirection(p2 + DIR_VECTORS[dir] - p2)
			
			damage.sAnimation = "explopush2_" .. direction
			if self.Push then
				damage.iPush = direction
			end
			ret:AddDamage(damage)
		end
	end

	return ret
	
end

xen_Ranged_CrushArtillery_A = xen_Ranged_CrushArtillery:new{
	Vertical = true,
	MinRange = 1,
	UpgradeDescription = "Adjust the mech to fire vertically for short ranged attacks. Does reduced damage and increased self-damage.",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Enemy2 = Point(1,1),
		Enemy3 = Point(3,1),
		Enemy4 = Point(1,3),
		Target = Point(2,3),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,2),
	}	
}
xen_Ranged_CrushArtillery_B = xen_Ranged_CrushArtillery:new{
	Damage = 3,
	Push = true,
	UpgradeDescription = "Increase damage by 1 and push more targets."
}
xen_Ranged_CrushArtillery_AB = xen_Ranged_CrushArtillery:new{
	Damage = 3,
	Push = true,
	Vertical = true,
	MinRange = 1,
	--Fire = true
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,1),
		Enemy2 = Point(1,1),
		Enemy3 = Point(3,1),
		Enemy4 = Point(2,3),
		Target = Point(2,4),
		Second_Origin = Point(2,4),
		Second_Target = Point(2,2),
	}
}

Weapon_Texts.xen_Ranged_CrushArtillery_Upgrade1 = "Vertical Shot"
Weapon_Texts.xen_Ranged_CrushArtillery_Upgrade2 = "+1 Damage & Push"

--Nullification Zone (Passive)--
xen_Passive_NullZone = PassiveSkill:new{
	Name = "Dampening Field",
	Description = "Generates a field that reduces damage from all attacks started from inside it.",
	PowerCost = 1,
	Passive = "Dampening_Field",
	Icon = "weapons/xen_weapon_passive_nullzone.png",
	Upgrades = 2,
	UpgradeCost = {1,2},
	Damage = -1,
	TipImage = {
		Unit = Point(2,2),
		CustomPawn = "Leaper2",
		Target = Point(2,1),
	}
}

function xen_Passive_NullZone:GetSkillEffect(p1, p2)
	--For the TipImage only
	local pawn = PAWN_FACTORY:CreatePawn("Leaper2")
	Board:AddPawn(pawn)
	pawn:SetSpace(Point(1,3))
	
	local pawn = PAWN_FACTORY:CreatePawn("xen_AssistMechTip")
	Board:AddPawn(pawn)
	pawn:SetSpace(Point(2,1))
	
	local pawn = PAWN_FACTORY:CreatePawn("xen_ThrowMechTip")
	Board:AddPawn(pawn)
	pawn:SetSpace(Point(1,2))
		
	local ret = SkillEffect()
		
	local string = "Field: " .. self.Damage
	local zone = {
		Point(2,1),
		Point(2,2),
		Point(2,0),
		Point(1,1),
		Point(3,1),
	}
	Board:AddAlert(zone[1],string)
	for i,point in pairs(zone) do
		Board:Ping(point, GL_Color(30,40,250))
	end
	
	damage = SpaceDamage(Point(2,1), 5 + self.Damage)
	damage.sAnimation = "SwipeClaw2"
	ret:AddDamage(damage)	
	
	damage = SpaceDamage(Point(1,2), 5)
	damage.sAnimation = "SwipeClaw2"
	ret:AddDamage(damage)
	
	ret:AddDelay(1)

	return ret
end

xen_Passive_NullZone_A = xen_Passive_NullZone:new{
	Damage = -2,
	UpgradeDescription = "Damage reduced by 1",
	Passive = "Dampening_Field_A"
}
xen_Passive_NullZone_B = xen_Passive_NullZone:new{
	Damage = -2,
	UpgradeDescription = "Damage reduced by 1",
	Passive = "Dampening_Field_B"
}
xen_Passive_NullZone_AB = xen_Passive_NullZone:new{
	Damage = -3,
	Passive = "Dampening_Field_AB"
}

Weapon_Texts.xen_Passive_NullZone_Upgrade1 = "-1 Damage"
Weapon_Texts.xen_Passive_NullZone_Upgrade2 = "-1 Damage"

--Amplifier Zone (Passive)--
xen_Passive_AmpZone = PassiveSkill:new{
	Name = "Amplifier Field",
	Description = "Generates a field that increases damage from all attacks started from inside it.",
	PowerCost = 1,
	Passive = "Amplifier_Field",
	Icon = "weapons/xen_weapon_passive_ampzone.png",
	Upgrades = 1,
	UpgradeCost = {3},
	Damage = 1,
	TipImage = {
		Unit = Point(2,2),
		CustomPawn = "Scorpion1",
		Target = Point(2,1),
	}
}

function xen_Passive_AmpZone:GetSkillEffect(p1, p2)
	--For the TipImage only
	local pawn = PAWN_FACTORY:CreatePawn("Scorpion1")
	Board:AddPawn(pawn)
	pawn:SetSpace(Point(1,3))
	
	local pawn = PAWN_FACTORY:CreatePawn("xen_AssistMechTip")
	Board:AddPawn(pawn)
	pawn:SetSpace(Point(2,1))
	
	local pawn = PAWN_FACTORY:CreatePawn("xen_ThrowMechTip")
	Board:AddPawn(pawn)
	pawn:SetSpace(Point(1,2))
		
	local ret = SkillEffect()
		
	local string = "Field: +" .. self.Damage
	local zone = {
		Point(2,1),
		Point(2,2),
		Point(2,0),
		Point(1,1),
		Point(3,1),
	}
	Board:AddAlert(zone[1],string)
	for i,point in pairs(zone) do
		Board:Ping(point, GL_Color(250,40,30))
	end
	
	damage = SpaceDamage(Point(2,1), 1 + self.Damage)
	damage.sAnimation = "SwipeClaw2"
	ret:AddDamage(damage)	
	
	damage = SpaceDamage(Point(1,2), 1)
	damage.sAnimation = "SwipeClaw2"
	ret:AddDamage(damage)
	
	ret:AddDelay(1)

	return ret
end

xen_Passive_AmpZone_A = xen_Passive_AmpZone:new{
	Damage = 2,
	UpgradeDescription = "Damage increased by 1",
	Passive = "Amplifier_Field_A"
}
xen_Passive_AmpZone_B = xen_Passive_AmpZone:new{
	Damage = 2,
	UpgradeDescription = "Damage increased by 1",
	Passive = "Amplifier_Field_B"
}
xen_Passive_AmpZone_AB = xen_Passive_AmpZone:new{
	Damage = 3,
	Passive = "Amplifier_Field_AB"
}

Weapon_Texts.xen_Passive_AmpZone_Upgrade1 = "+1 Damage"

--Regeneration Zone (Passive)--
xen_Passive_RepairZone = PassiveSkill:new{
	Name = "Regeneration Field",
	Description = "Generates a field that repairs all units inside of it.",
	PowerCost = 1,
	Passive = "Repair_Field",
	Icon = "weapons/passives/passive_massrepair.png",
	LaunchSound = "/weapons/science_repulse",
	Repair = -1,
	HealEnemy = true,
	Upgrades = 2,
	UpgradeCost = {1,1},
	TipImage = {
		Unit_Damaged = Point(2,2),
		Friendly_Damaged = Point(2,1),
		Friendly2_Damaged = Point(1,2),
		Enemy_Damaged = Point(2,3),
		Fire1 = Point(2,2),
		Fire2 = Point(2,1),
		Fire3 = Point(1,2),
		Fire4 = Point(2,3),
		Target = Point(2,2),
	}
}

function xen_Passive_RepairZone:GetSkillEffect(p1, p2)
	--For the tipimage only
	local ret = SkillEffect()
	ret:AddBounce(p1,-2)
	local repair = self.Repair
	for i = DIR_START,DIR_END do
		local curr = p1 + DIR_VECTORS[i]
		local spaceDamage = SpaceDamage(curr, repair)
		
		if not self.HealEnemy and Board:GetPawnTeam(curr) == TEAM_ENEMY then
			spaceDamage.iDamage = 0
		end
		if spaceDamage.iDamage < 0 and Board:IsPawnSpace(spaceDamage.loc) then
			spaceDamage.iFire = EFFECT_REMOVE
			spaceDamage.iAcid = EFFECT_REMOVE
			spaceDamage.iFrozen = EFFECT_REMOVE
		end
		ret:AddDamage(spaceDamage)
		
		ret:AddBounce(curr,-1)
	end
	
	local selfDamage = SpaceDamage(p1,repair)
	if selfDamage.iDamage < 0 and Board:IsPawnSpace(selfDamage.loc) then
		selfDamage.iFire = EFFECT_REMOVE
		selfDamage.iAcid = EFFECT_REMOVE
		selfDamage.iFrozen = EFFECT_REMOVE
	end		
	selfDamage.sAnimation = "ExploRepulse1"
	ret:AddDamage(selfDamage)
	ret:AddDelay(3)
	
	return ret
end	

xen_Passive_RepairZone_A = xen_Passive_RepairZone:new{
	UpgradeDescription = "Only heals allied units.",
	HealEnemy = false,
	Passive = "Repair_Field_A"
}
xen_Passive_RepairZone_B = xen_Passive_RepairZone:new{
	UpgradeDescription = "+1 repaired health",
	Repair = -2,
	Passive = "Repair_Field_B"
}
xen_Passive_RepairZone_AB = xen_Passive_RepairZone:new{
	HealEnemy = false,
	Repair = -2,
	Passive = "Repair_Field_AB"
}

Weapon_Texts.xen_Passive_RepairZone_Upgrade1 = "Allies Only"
Weapon_Texts.xen_Passive_RepairZone_Upgrade2 = "+1 Repair"

---ZONE TOOLTIPS AND MARK ICONS---
TILE_TOOLTIPS["null_zone"] = { "Dampening Field (-1)", "Units that attack from this space will do 1 less damage." }
Location["combat/tile_icon/xen_tile_debuff.png"] = Point(-27, 2)

TILE_TOOLTIPS["null_zone2"] = { "Dampening Field (-2)", "Units that attack from this space will do 2 less damage." }
Location["combat/tile_icon/xen_tile_debuff.png"] = Point(-27, 2)

TILE_TOOLTIPS["null_zone3"] = { "Dampening Field (-3)", "Units that attack from this space will do 3 less damage." }
Location["combat/tile_icon/xen_tile_debuff.png"] = Point(-27, 2)

TILE_TOOLTIPS["amp_zone"] = { "Amplifier Field (+1)", "Units that attack from this space will do 1 more damage." }
Location["combat/tile_icon/xen_tile_buff.png"] = Point(-27, 2)

TILE_TOOLTIPS["amp_zone2"] = { "Amplifier Field (+2)", "Units that attack from this space will do 2 more damage." }
Location["combat/tile_icon/xen_tile_buff.png"] = Point(-27, 2)

TILE_TOOLTIPS["repair_zone"] = { "Regeneration Field (+1)", "Units that end their turn in this space will be repaired." }
Location["combat/tile_icon/xen_tile_repair.png"] = Point(-27, 2)

TILE_TOOLTIPS["repair_zone2"] = { "Regeneration Field (+2)", "Units that end their turn in this space will be repaired." }
Location["combat/tile_icon/xen_tile_repair.png"] = Point(-27, 2)

TILE_TOOLTIPS["multi_zone_damp_repair"] = { "Dampening & Regen Field", "Units that attack from this space will do less damage. Units that end in this space will be repaired." }
Location["combat/tile_icon/xen_tile_debuff_repair.png"] = Point(-27, 2)

TILE_TOOLTIPS["multi_zone_amp_repair"] = { "Amplifier & Regen Field", "Units that attack from this space will do more damage. Units that end in this space will be repaired." }
Location["combat/tile_icon/xen_tile_buff_repair.png"] = Point(-27, 2)

---ZONE STRENGTHS---
local NullZone_strengthlist = {
	["xen_Passive_NullZone"] = -1,
	["xen_Passive_NullZone_A"] = -2,
	["xen_Passive_NullZone_B"] = -2,
	["xen_Passive_NullZone_AB"] = -3,
}

local AmpZone_strengthlist = {
	["xen_Passive_AmpZone"] = 1,
	["xen_Passive_AmpZone_A"] = 2,
	["xen_Passive_AmpZone_B"] = 2,
	["xen_Passive_AmpZone_AB"] = 3,
}

local RepairZone_strengthlist = {
	["xen_Passive_RepairZone"] = {-1,true},
	["xen_Passive_RepairZone_A"] = {-1,false},
	["xen_Passive_RepairZone_B"] = {-2,true},
	["xen_Passive_RepairZone_AB"] = {-2,false},
}

---CREATE ZONES---
local function Create_NullZone(mission)
	if not mission then return end
	if IsTestMechScenario() then return end
	if IsTipImage() then return end
	local zone = {}
	local strength = 0
	
	local mechs = extract_table(Board:GetPawns(TEAM_MECH))
	for i, id in ipairs(mechs) do
		local curr = id
		local weapons = weaponApi.GetCurrent(curr)
		for j, jd in ipairs(weapons) do
			local s = weapons[j] or nil
			if s ~= nil then
				s = s:sub(1,20)
				if s == "xen_Passive_NullZone" then
					if Board:IsValid(Board:GetPawn(curr):GetSpace()) then
						zone[#zone+1] = Board:GetPawn(curr):GetSpace()
					end
					for dir = DIR_START,DIR_END do
						if Board:IsValid(Board:GetPawn(curr):GetSpace() + DIR_VECTORS[dir]) then
							zone[#zone+1] = Board:GetPawn(curr):GetSpace() + DIR_VECTORS[dir]
						end
					end
					strength = NullZone_strengthlist[weapons[j]]					
				end
			end
		end
	end
	
	if zone == {} then 
		mission.xen_NullZone_Tiles = nil
	return end
	if strength == 0 then 
		mission.xen_NullZone_Strength = nil
	return end
	
	mission.xen_NullZone_Tiles = zone
	mission.xen_NullZone_Strength = strength
	
	if mission.xen_NullZone_Strength == 0 or nil then return end --Don't run if no passive setup
	if mission.xen_NullZone_Tiles == {} or nil then return end
	
	local string = "Dampening Field: " .. strength
	Board:AddAlert(zone[1],string)
	for i,point in pairs(zone) do
		Board:Ping(point, GL_Color(30,40,250))
	end	
end

local function Create_AmpZone(mission)
	if not mission then return end
	if IsTestMechScenario() then return end
	if IsTipImage() then return end
	local zone = {}
	local strength = 0
		
	local mechs = extract_table(Board:GetPawns(TEAM_MECH))
	for i, id in ipairs(mechs) do
		local curr = id
		local weapons = weaponApi.GetCurrent(curr)
		for j, jd in ipairs(weapons) do
			local s = weapons[j] or nil
			if s ~= nil then
				s = s:sub(1,19)
				if s == "xen_Passive_AmpZone" then
					if Board:IsValid(Board:GetPawn(curr):GetSpace()) then
						zone[#zone+1] = Board:GetPawn(curr):GetSpace()
					end
					for dir = DIR_START,DIR_END do
						if Board:IsValid(Board:GetPawn(curr):GetSpace() + DIR_VECTORS[dir]) then
							zone[#zone+1] = Board:GetPawn(curr):GetSpace() + DIR_VECTORS[dir]
						end
					end
					strength = AmpZone_strengthlist[weapons[j]]					
				end
			end
		end
	end

	if zone == {} then 
		mission.xen_AmpZone_Tiles = nil
	return end
	if strength == 0 then 
		mission.xen_AmpZone_Strength = nil
	return end
	
	mission.xen_AmpZone_Tiles = zone
	mission.xen_AmpZone_Strength = strength
	
	if mission.xen_AmpZone_Strength == 0 or nil then return end --Don't run if no passive setup
	if mission.xen_AmpZone_Tiles == {} or nil then return end --Don't run if no passive setup
	
	local string = "Amplifier Field: +" .. strength
	Board:AddAlert(zone[1],string)
	for i,point in pairs(zone) do
		Board:Ping(point, GL_Color(250,40,30))
	end	
end

local function Create_RepairZone(mission)
	if not mission then return end
	if IsTestMechScenario() or IsTipImage() then return end
	
	local zone = {}
	local strength = {}
	
	local mechs = extract_table(Board:GetPawns(TEAM_MECH))
	for i, id in ipairs(mechs) do
		local curr = id
		local weapons = weaponApi.GetCurrent(curr)
		for j, jd in ipairs(weapons) do
			local s = weapons[j] or nil
			if s ~= nil then
				s = s:sub(1,22)
				if s == "xen_Passive_RepairZone" then
					if Board:IsValid(Board:GetPawn(curr):GetSpace()) then
						zone[#zone+1] = Board:GetPawn(curr):GetSpace()
					end
					for dir = DIR_START,DIR_END do
						if Board:IsValid(Board:GetPawn(curr):GetSpace() + DIR_VECTORS[dir]) then
							zone[#zone+1] = Board:GetPawn(curr):GetSpace() + DIR_VECTORS[dir]
						end
					end
					strength = RepairZone_strengthlist[weapons[j]]					
				end
			end
		end
	end
	
	if zone == {} then 
		mission.xen_RepairZone_Tiles = nil
	return end
	if strength == 0 then 
		mission.xen_RepairZone_Strength = nil
		mission.xen_RepairZone_AllyStatus = nil
	return end
	
	mission.xen_RepairZone_Tiles = zone
	mission.xen_RepairZone_Strength = strength[1]
	mission.xen_RepairZone_AllyStatus = strength[2]
	
	if mission.xen_RepairZone_Strength == 0 or nil then return end --Don't run if no passive setup
	if mission.xen_RepairZone_Tiles == {} or nil then return end
	if mission.xen_RepairZone_AllyStatus == nil then return end
	
	strength = strength[1]*(-1)
	local string = "Repair Field: +" .. strength
	Board:AddAlert(zone[1],string)
	for i,point in pairs(zone) do
		Board:Ping(point, GL_Color(30,40,250))
	end	
end

---APPLY ZONE EFFECTS---
local function NullZone_Effect(pawn,se,p1,p2)
	if IsTipImage() or IsTestMechScenario() then return end
	local weps = {"primary","secondary"}
	local modUtils = getModUtils()
	local mission = GetCurrentMission()
	--Testing
	LOG(mission)
	--Testing	
	if not mission then return end
	if mission.xen_NullZone_Strength == 0 then return end --Don't run if no passive setup
	local strength = mission.xen_NullZone_Strength
	
	local zone = mission.xen_NullZone_Tiles
	if not zone then return end
	--LOG("Zone:".. save_table(zone))
	local active = false
	for i, point in pairs(zone) do
		if point == p1 then
			active = true
		end
	end
	if not active then return end
	
	for _, d in ipairs(extract_table(se.effect)) do
		if d.iDamage > 0 and d.iDamage ~= DAMAGE_ZERO and d.iDamage ~= DAMAGE_DEATH then
			d.iDamage = d.iDamage + strength
			if d.iDamage < 0 then --Ensure we don't get negative damage.
				d.iDamage = 0
			end			
		end
	end
	
	for _, d in ipairs(extract_table(se.q_effect)) do
		if d.iDamage > 0 and d.iDamage ~= DAMAGE_ZERO and d.iDamage ~= DAMAGE_DEATH then
			d.iDamage = d.iDamage + strength
			if d.iDamage < 0 then --Ensure we don't get negative damage.
				d.iDamage = 0
			end			
		end
	end
end

local function AmpZone_Effect(pawn,se,p1,p2)
	--TESTING
	--TESTING
	if IsTipImage() or IsTestMechScenario() then return end
	
	local weps = {"primary","secondary"}
	local modUtils = getModUtils()
	local mission = GetCurrentMission()
	if not mission then return end
	if mission.xen_AmpZone_Strength == 0 then return end --Don't run if no passive setup
	local strength = mission.xen_AmpZone_Strength
	
	local zone = mission.xen_AmpZone_Tiles
	if not zone then return end
	local active = false
	for i, point in pairs(zone) do
		if point == p1 then
			active = true
		end
	end
	if not active then return end
	
	for _, d in ipairs(extract_table(se.effect)) do
		if d.iDamage > 0 and d.iDamage ~= DAMAGE_ZERO and d.iDamage ~= DAMAGE_DEATH then
			d.iDamage = d.iDamage + strength
			if d.iDamage < 0 then --Ensure we don't get negative damage.
				d.iDamage = 0
			end			
		end
	end
	
	for _, d in ipairs(extract_table(se.q_effect)) do
		if d.iDamage > 0 and d.iDamage ~= DAMAGE_ZERO and d.iDamage ~= DAMAGE_DEATH then
			d.iDamage = d.iDamage + strength
			if d.iDamage < 0 then --Ensure we don't get negative damage.
				d.iDamage = 0
			end			
		end
	end
end

local function RepairZone_Effect(mission)
	if not mission then return end
	if mission.xen_RepairZone_Strength == 0 or nil then return end --Don't run if no passive setup
	if mission.xen_RepairZone_Tiles == {} or nil then return end
	if mission.xen_RepairZone_AllyStatus == nil then return end
	
	local strength = mission.xen_RepairZone_Strength
	local repairenemy = mission.xen_RepairZone_AllyStatus
	local zone = mission.xen_RepairZone_Tiles
	local fx = SkillEffect()
	for i, point in pairs(zone) do
		if (Board:GetPawnTeam(point) == TEAM_ENEMY and repairenemy == true) or Board:GetPawnTeam(point) == TEAM_PLAYER then
			local repair = SpaceDamage(point, strength)
			repair.iAcid = EFFECT_REMOVE
			repair.iFire = EFFECT_REMOVE
			repair.iFrozen = EFFECT_REMOVE
			fx:AddDamage(repair)
		end
	end
	Board:AddEffect(fx)
end

---MARK ZONES ON GAME BOARD---
local function MultiZone_Mark()
	local mission = GetCurrentMission()
	if not mission then return end
	if IsTestMechScenario() then return end
	
	local nullzone = mission.xen_NullZone_Tiles
	local ampzone = mission.xen_AmpZone_Tiles
	local repairzone = mission.xen_RepairZone_Tiles
	
	local zone = {}
	
	if nullzone ~= nil then
		for i,id in ipairs(nullzone) do
			local string = id:GetString()
			local curr = zone[string]
			if curr == nil then
				curr = {id,mission.xen_NullZone_Strength,0}
			else
				curr[2] = curr[2] + mission.xen_NullZone_Strength
			end
			zone[string] = curr
		end
	end
	
	if ampzone ~= nil then
		for i,id in ipairs(ampzone) do
			local string = id:GetString()
			local curr = zone[string]
			if curr == nil then
				curr = {id,mission.xen_AmpZone_Strength,0}
			else
				curr[2] = curr[2] + mission.xen_AmpZone_Strength
			end
			zone[string] = curr
		end
	end
	
	if repairzone ~= nil then
		for i,id in ipairs(repairzone) do
			local string = id:GetString()
			local curr = zone[string]
			if curr == nil then
				curr = {id,0,mission.xen_RepairZone_Strength}
			else
				curr[3] = curr[3] + mission.xen_RepairZone_Strength
			end
			zone[string] = curr
		end
	end
	
	--LOG(save_table(zone))	
	--Mark tiles
	local markdesc = {
		[-3] = "null_zone3",
		[-2] = "null_zone2",
		[-1] = "null_zone",
		[1] = "amp_zone",
		[2] = "amp_zone2",
		[11] =  "multi_zone_amp_repair",
		[12] =  "multi_zone_amp_repair",
		[21] =  "multi_zone_amp_repair",
		[22] =  "multi_zone_amp_repair",
		[-13] = "multi_zone_damp_repair",
		[-12] = "multi_zone_damp_repair",
		[-11] = "multi_zone_damp_repair",
		[-23] = "multi_zone_damp_repair",
		[-22] = "multi_zone_damp_repair",
		[-21] = "multi_zone_damp_repair",
		[-10] = "repair_zone",
		[-20] = "repair_zone2",
	}
	local markimage = {
		[-3] = "combat/tile_icon/xen_tile_debuff.png",
		[-2] = "combat/tile_icon/xen_tile_debuff.png",
		[-1] = "combat/tile_icon/xen_tile_debuff.png",
		[1] = "combat/tile_icon/xen_tile_buff.png",
		[2] = "combat/tile_icon/xen_tile_buff.png",
		[11] =  "combat/tile_icon/xen_tile_buff_repair.png",
		[12] =  "combat/tile_icon/xen_tile_buff_repair.png",
		[21] =  "combat/tile_icon/xen_tile_buff_repair.png",
		[22] =  "combat/tile_icon/xen_tile_buff_repair.png",
		[-13] = "combat/tile_icon/xen_tile_debuff_repair.png",
		[-12] = "combat/tile_icon/xen_tile_debuff_repair.png",
		[-11] = "combat/tile_icon/xen_tile_debuff_repair.png",
		[-23] = "combat/tile_icon/xen_tile_debuff_repair.png",
		[-22] = "combat/tile_icon/xen_tile_debuff_repair.png",
		[-21] = "combat/tile_icon/xen_tile_debuff_repair.png",
		[-10] = "combat/tile_icon/xen_tile_repair.png",
		[-20] = "combat/tile_icon/xen_tile_repair.png",
	}
	local markcolour = {
		[-3] = {30,40,250},
		[-2] = {30,40,200},
		[-1] = {30,40,150},
		[1] = {150,40,30},
		[2] = {200,40,30},
		[11] =  {150,200,30},
		[12] =  {200,200,30},
		[21] =  {150,250,30},
		[22] =  {200,250,30},
		[-13] = {30,200,250},
		[-12] = {30,200,200},
		[-11] = {30,200,150},
		[-23] = {30,250,250},
		[-22] = {30,250,200},
		[-21] = {30,250,150},
		[-10] = {30,200,40},
		[-20] = {30,250,40},
	}
	
	for i, id in pairs(zone) do
		local curr = id[1]
		local strength = id[2]
		local repair = id[3]
		if curr ~= nil and strength ~= 0 then
			if not Board:IsItem(curr) and not Board:IsEnvironmentDanger(curr) and not Board:IsBuilding(curr) then
				if repair == 0 then
					local colour = markcolour[id[2]]
					Board:MarkSpaceImage(curr, markimage[id[2]], GL_Color(colour[1],colour[2],colour[3]))
					Board:MarkSpaceDesc(curr, markdesc[id[2]])
				elseif repair ~= 0 then
					if strength < 0 then
						repair = repair * 10
					elseif strength > 0 then
						repair = repair * -10
					end
					local index = strength + repair
					--LOG(index)
					local colour = markcolour[index]
					Board:MarkSpaceImage(curr, markimage[index], GL_Color(colour[1],colour[2],colour[3]))
					Board:MarkSpaceDesc(curr, markdesc[index])					
				end
			end
		elseif curr ~= nil and strength == 0 and repair ~= 0 then
			if not Board:IsItem(curr) and not Board:IsEnvironmentDanger(curr) and not Board:IsBuilding(curr) then
				local index = repair * 10
				local colour = markcolour[index]
				Board:MarkSpaceImage(curr, "combat/tile_icon/xen_tile_repair.png", GL_Color(colour[1],colour[2],colour[3]))
				Board:MarkSpaceDesc(curr, markdesc[index])
			end
		end
	end
end

---RESET ZONE PARAMETERS EACH MISSION---
local function ClearMissionData(mission)
	if not mission then return end
	mission.xen_NullZone_Tiles = {}
	mission.xen_NullZone_Strength = 0
	mission.xen_AmpZone_Tiles = {}
	mission.xen_AmpZone_Strength = 0
	mission.xen_RepairZone_Tiles = {}
	mission.xen_RepairZone_Strength = 0
	mission.xen_RepairZone_AllyStatus = nil
end

function this:init(mod)
end

function this:load(modApiExt)
	local this = self
	local modUtils = getModUtils()	
	
	modApi:addMissionStartHook(function(mission)
		ClearMissionData(mission)
	end)
	
	modApi:addNextTurnHook(function(mission)
		if Game:GetTeamTurn() == TEAM_PLAYER then
			Create_NullZone(mission)
			Create_AmpZone(mission)
			Create_RepairZone(mission)
		end
		if Game:GetTeamTurn() == TEAM_ENEMY then
		end
	end)
	
	modApi:addPreEnvironmentHook(function(mission)
			RepairZone_Effect(mission)	
	end)
	
	modUtils:addSkillBuildHook(function(mission,pawn,weaponId,p1,p2,skillEffect)
		AmpZone_Effect(pawn,skillEffect,p1,p2)
		NullZone_Effect(pawn,skillEffect,p1,p2)
	end)
	
	modApi:addMissionUpdateHook(function(mission)
		MultiZone_Mark()
	end)
end

return this
