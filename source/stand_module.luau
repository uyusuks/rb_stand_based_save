local ss = game:GetService("ServerStorage")
local ts = game:GetService("TweenService")
local sss = game:GetService("ServerScriptService")

local modules_folder = sss:WaitForChild("modules")
local hb = require(modules_folder:WaitForChild("hb"))

local tinfo_summon = TweenInfo.new(2)
local tinfo_barrage = TweenInfo.new(1)

local stands_folder = ss:WaitForChild("stands")

local stand = {}

local summon_cd_list = {}
local summon_cd = 5

local barrage_cd_list = {}
local barrage_cd = 5

local fist_cd_list = {}
local fist_cd = .1

stand.default_summon = function(p, stand)
	
	local last_summon = summon_cd_list[p] or 0
	
	if  os.clock() - last_summon <= summon_cd then return end
	
	summon_cd_list[p] = os.clock()
	
	local ch = p.Character or p.CharacterAdded:Wait()

	local find_stand = stands_folder:FindFirstChild(stand)
	
	if not find_stand then return end
	
	local stand_folder = ch:WaitForChild(stand)
	
	local stand = workspace:WaitForChild(p.Name .. "_stand")
	
	local hrp = ch:WaitForChild("HumanoidRootPart")
	local stand_hrp = stand:WaitForChild("HumanoidRootPart")
	
	local weld
	
	if hrp:FindFirstChild("stand_m6d") then
		
		weld = hrp:WaitForChild("stand_weld")
	else
		
		weld = Instance.new("Weld")

		weld.Name = "stand_weld"
		weld.Parent = hrp

		weld.Part0 = hrp
		weld.Part1 = stand_hrp
	end
	
	stand_hrp.Anchored = false
	
	for _, thing in pairs(stand:GetChildren()) do if thing:IsA("Part") then thing.Transparency = 0 end end
	
	local summon_tw = ts:Create(weld, tinfo_summon, {C1 = CFrame.new(-1.5, -1, -2.5)})
	
	summon_tw:Play()
end

stand.default_unsummon = function(p, stand)
	
	local ch = p.Character or p.CharacterAdded:Wait()
	local hrp = ch:WaitForChild("HumanoidRootPart")
	
	local weld = hrp:WaitForChild("stand_weld")
	
	local unsummon_tw = ts:Create(weld, tinfo_summon, {C1 = CFrame.new(0, 0, 0)})

	unsummon_tw:Play()
	unsummon_tw.Completed:Wait()

	local stand = workspace:WaitForChild(p.Name .. "_stand")
	
	for _, thing in pairs(stand:GetChildren()) do if thing:IsA("Part") then thing.Transparency = 1 end end
end

stand.default_barrage = function(p)
	
	local last_barrage = barrage_cd_list[p] or 0

	if  os.clock() - last_barrage <= barrage_cd then return end

	barrage_cd_list[p] = os.clock()
	
	local ch = p.Character or p.CharacterAdded:Wait()
	local hrp = ch:WaitForChild("HumanoidRootPart")

	local weld = hrp:WaitForChild("stand_weld")
	
	local barrage_tw = ts:Create(weld, tinfo_barrage, {C1 = CFrame.new(0, -1, 3)})

	barrage_tw:Play()
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {ch}
	
	local stand = workspace:WaitForChild(p.Name .. "_stand")
	
	local stand_hb = stand:WaitForChild("hitboxes")
	
	local hb = hb.new(stand_hb, params)
	
	hb:HitStart():OnUpdate(function()
		
		if not hb.RaycastResult then return end
		
		local last_fist = fist_cd_list[p] or 0

		if  os.clock() - last_fist <= fist_cd then return end

		fist_cd_list[p] = os.clock()

		local hit_part = hb.RaycastResult.Instance
		
		local find_hmd = hit_part.Parent:FindFirstChild("Humanoid")
		
		if find_hmd then
			
			local target_hmd = find_hmd
			
			target_hmd:TakeDamage(10)
		end
	end)
	
	task.delay(4, function()
		
		hb:Destroy()
		
		local deault_tw = ts:Create(weld, tinfo_barrage, {C1 = CFrame.new(-1.5, -1, -2.5)})
		
		deault_tw:Play()
	end)
end

return stand
