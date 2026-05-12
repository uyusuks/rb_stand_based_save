--!nonstrict

local ss = game:GetService("ServerStorage") :: ServerStorage
local ts = game:GetService("TweenService") :: TweenService
local ps = game:GetService("Players") :: Players
local sss = game:GetService("ServerScriptService") :: ServerScriptService

local modules_folder = sss:WaitForChild("modules") :: Folder
local hb = require(modules_folder:WaitForChild("hb")) :: any

local tinfo_summon = TweenInfo.new(2) :: TweenInfo
local tinfo_barrage = TweenInfo.new(1) :: TweenInfo

local stands_folder = ss:WaitForChild("stands") :: Folder

local summon_cd_list = {}
local summon_cd = 5 :: number

local barrage_cd_list = {}
local barrage_cd = 5 :: number

local fist_cd_list = {}
local fist_cd = .1 :: number

local ts_cd_list = {}
local ts_cd = 10 :: number
local ts_t = 5 :: number

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

	summon_cd_list[p_id] = os.clock() :: number

	local find_stand = stands_folder:FindFirstChild(stand) :: Model

	if not find_stand then return end

	local stand_folder = ch:WaitForChild(stand) :: Folder

	local stand = workspace:WaitForChild(p_id .. "_stand") :: Model

	local hrp = ch:WaitForChild("HumanoidRootPart") :: BasePart
	local stand_hrp = stand:WaitForChild("HumanoidRootPart") :: BasePart

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

	local summon_tw = ts:Create(weld, tinfo_summon, {C1 = CFrame.new(-1.5, -1, -2.5)}) :: Tween

	summon_tw:Play()
end

stand.action.default_unsummon = function(p_id:number, ch:Model)

	local hrp = ch:WaitForChild("HumanoidRootPart") :: BasePart

	local weld = hrp:WaitForChild("stand_weld") :: Weld

	local unsummon_tw = ts:Create(weld, tinfo_summon, {C1 = CFrame.new(0, 0, 0)}) :: Tween

	unsummon_tw:Play()
	unsummon_tw.Completed:Wait()

	local stand = workspace:WaitForChild(p_id .. "_stand") :: Model
end

stand.action.default_barrage = function(p_id:number, ch:Model)

	local last_barrage:number = barrage_cd_list[p_id] or 0

	if  os.clock() - last_barrage <= barrage_cd then return end

	barrage_cd_list[p_id] = os.clock() :: number

	local hrp = ch:WaitForChild("HumanoidRootPart") :: BasePart

	local weld = hrp:WaitForChild("stand_weld") :: Weld

	local barrage_tw = ts:Create(weld, tinfo_barrage, {C1 = CFrame.new(0, -1, 3)}) :: Tween

	barrage_tw:Play()

	local params = RaycastParams.new() :: RaycastParams
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {ch}

	local stand = workspace:WaitForChild(p_id .. "_stand") :: Model

	local stand_hb = stand:WaitForChild("hitboxes") :: Attachment

	local hb = hb.new(stand_hb, params) :: any

	hb:HitStart():OnUpdate(function()

		if not hb.RaycastResult then return end

		local last_fist:number = fist_cd_list[p_id] or 0

		if  os.clock() - last_fist <= fist_cd then return end

		fist_cd_list[p_id] = os.clock() :: number

		local hit_part = hb.RaycastResult.Instance :: Part

		local find_hmd = hit_part.Parent:FindFirstChild("Humanoid") :: Humanoid

		if find_hmd then

			local target_hmd = find_hmd :: Humanoid

			target_hmd:TakeDamage(10)
		end
	end)

	task.delay(4, function()

		hb:Destroy()

		local deault_tw = ts:Create(weld, tinfo_barrage, {C1 = CFrame.new(-1.5, -1, -2.5)}) :: Tween

		deault_tw:Play()
	end)
end

stand.action.default_ts = function(ts_user: Player, ch:Model)

--didnt complete
end

return stand
