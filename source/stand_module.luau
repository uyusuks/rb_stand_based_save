--!nonstrict

local ss: ServerStorage = game:GetService("ServerStorage")
local ts: TweenService = game:GetService("TweenService")
local ps: Players = game:GetService("Players")
local sss: ServerScriptService = game:GetService("ServerScriptService")

local modules_folder: Folder = sss:WaitForChild("modules")
local hb: ModuleScript = require(modules_folder:WaitForChild("hb"))

local tinfo_summon: TweenInfo = TweenInfo.new(2)
local tinfo_barrage: TweenInfo = TweenInfo.new(1)

local stands_folder: Folder = ss:WaitForChild("stands")

local summon_cd_list = {}
local summon_cd: number = 5

local barrage_cd_list = {}
local barrage_cd: number = 5

local fist_cd_list = {}
local fist_cd: number = .1

local ts_cd_list = {}
local ts_cd: number = 10
local ts_t: number = 5

local movement_save = {}

local stand = {}

export type default_type = (boolean, Model) -> ()

export type action = {
	
	default_summon: (boolean, Model, Model?) -> (),
	default_unsummon: default_type,
	default_barrage: default_type,
	default_ts: (Player, Model) -> ()
}

stand.action = {} :: action

stand.action.default_summon = function(p_id: boolean, ch: Model, stand: Model)

	local last_summon: number = summon_cd_list[p_id] or 0

	if  os.clock() - last_summon <= summon_cd then return end

	summon_cd_list[p_id] = os.clock()

	local find_stand: Model = stands_folder:FindFirstChild(stand)

	if not find_stand then return end

	local stand_folder: Folder = ch:WaitForChild(stand)

	local stand: Model = workspace:WaitForChild(p_id .. "_stand")

	local hrp: BasePart = ch:WaitForChild("HumanoidRootPart")
	local stand_hrp: BasePart = stand:WaitForChild("HumanoidRootPart")

	local weld: Weld

	if hrp:FindFirstChild("stand_weld") then

		weld = hrp:WaitForChild("stand_weld")
	else

		weld = Instance.new("Weld")

		weld.Name = "stand_weld"
		weld.Parent = hrp

		weld.Part0 = hrp
		weld.Part1 = stand_hrp
	end

	stand_hrp.Anchored = false

	local summon_tw: Tween = ts:Create(weld, tinfo_summon, {C1 = CFrame.new(-1.5, -1, -2.5)})

	summon_tw:Play()
end

stand.action.default_unsummon = function(p_id:number, ch:Model)

	local hrp: BasePart = ch:WaitForChild("HumanoidRootPart")

	local weld: Weld = hrp:WaitForChild("stand_weld")

	local unsummon_tw: Tween = ts:Create(weld, tinfo_summon, {C1 = CFrame.new(0, 0, 0)})

	unsummon_tw:Play()
	unsummon_tw.Completed:Wait()

	local stand: Model = workspace:WaitForChild(p_id .. "_stand")
end

stand.action.default_barrage = function(p_id:number, ch:Model)

	local last_barrage: number = barrage_cd_list[p_id] or 0

	if  os.clock() - last_barrage <= barrage_cd then return end

	barrage_cd_list[p_id] = os.clock()

	local hrp: BasePart = ch:WaitForChild("HumanoidRootPart")

	local weld: Weld = hrp:WaitForChild("stand_weld")

	local barrage_tw: Tween = ts:Create(weld, tinfo_barrage, {C1 = CFrame.new(0, -1, 3)})

	barrage_tw:Play()

	local params: RaycastParams = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {ch}

	local stand: Model = workspace:WaitForChild(p_id .. "_stand")

	local stand_hb: Folder = stand:WaitForChild("hitboxes")

	local hb = hb.new(stand_hb, params)

	hb:HitStart():OnUpdate(function()

		if not hb.RaycastResult then return end

		local last_fist: number = fist_cd_list[p_id] or 0

		if  os.clock() - last_fist <= fist_cd then return end

		fist_cd_list[p_id] = os.clock()

		local hit_part: BasePart = hb.RaycastResult.Instance

		local find_hmd: Humanoid = hit_part.Parent:FindFirstChild("Humanoid")

		if find_hmd then

			local target_hmd: Humanoid = find_hmd

			target_hmd:TakeDamage(10)
		end
	end)

	task.delay(4, function()

		hb:Destroy()

		local deault_tw: Tween = ts:Create(weld, tinfo_barrage, {C1 = CFrame.new(-1.5, -1, -2.5)})

		deault_tw:Play()
	end)
end

stand.action.default_ts = function(ts_user: Player, ch:Model)

	local ts_user_id: number = ts_user.UserId

	local last_ts: number = ts_cd_list[ts_user_id .. "_ts"] or 0

	if os.clock() - last_ts <= 3 then return end

	local last_ts: number = os.clock()

	for _, p: Player in pairs(ps:GetChildren()) do

		if p == ts_user then continue end

		local ch: Model = p.Character or p.CharacterAdded:Wait()

		local hrp: BasePart = ch:WaitForChild("HumanoidRootPart")
		local hmd: Humanoid = ch:WaitForChild("Humanoid")

		local p_id: number = p.UserId

		movement_save[p_id .. "_ws"] = hmd.WalkSpeed

		hmd.WalkSpeed = 0
		hrp.Anchored = true
	end

	--task.wait(ts_t) cd

	for _, p: Player in pairs(ps:GetChildren()) do

		if p == ts_user then continue end

		local ch: Model = p.Character or p.CharacterAdded:Wait()

		local hrp: BasePart = ch:WaitForChild("HumanoidRootPart")
		local hmd: Humanoid = ch:WaitForChild("Humanoid")

		local p_id: number = p.UserId

		hmd.WalkSpeed =  movement_save[p_id .. "_ws"]
		hrp.Anchored = false
	end
end

return stand
