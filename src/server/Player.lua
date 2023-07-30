local Dss = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Ds = Dss:GetDataStore("Players")

local CreateClass = require(game.ReplicatedStorage.Shared.CreateClass)

return function(self)
    self.USE_SAVED_DATA = false
    self.Instance = nil
    self.Character = nil
    self.Data = {
		Team = "",
		DragonChance = 0,
		Currency = 0,
		EquippedBoat = "Raft",
		Ships = {
			"Raft",
		},
    }

    self.SaveData = function()
        if self.USE_SAVED_DATA then
            Ds:SetAsync(self.Instance.UserId, self.Data)
        end
    end

    self.LoadData = function()
        local SavedData = Ds:GetAsync(self.Instance.UserId)

        if self.USE_SAVED_DATA then
            if SavedData then
                for i, v in pairs(SavedData) do
                    self.Data[i] = v
                end
            end
        end

        game.ServerScriptService.Signals.PlayerDataChange:Fire(self.Instance)
        game.ReplicatedStorage.Signals.PlayerDataChange:FireClient(self.Instance)
    end

    self.OnJoin = function(PlrInstance)
        self.Instance = PlrInstance
        self.LoadData()
        self.Character = self.Instance.Character or self.Instance.CharacterAdded:Wait()
    end

    self.OnLeave = function()
        self.SaveData()
    end

    self.Spawn = function()
        self.Instance.PlayerGui.MenuGui.Enabled = false	
	
        if game.ServerScriptService.Signals.PlayerInfoInterface:Invoke(self.Instance).OtherBoat == "" then
            local Boat = game.ReplicatedStorage.Boats[game.ServerScriptService.Signals.PlayerInfoInterface:Invoke(self.Instance).EquippedBoat]:Clone()
    
            local RandomPos = game.ServerStorage.Spawns:GetChildren()[math.random(1, #game.ServerStorage.Spawns:GetChildren())]
    
            Boat:SetPrimaryPartCFrame(RandomPos.CFrame)
            Boat.Drive.BodyPosition.Position = RandomPos.Position
    
            Boat.Parent = game.Workspace.Boats
    
            Boat.Drive:Sit(self.Instance.Character.Humanoid)
    
            Boat.Name = self.Instance.Name
        else
            local Boat = game.Workspace.Boats:WaitForChild(game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(self.Instance).OtherBoat)
            
            self.Instance:MoveTo(Boat.PrimaryPart.Position)
        end
    end
end