local Dss = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Ds = Dss:GetDataStore("Players")

local CreateClass = require(game.ReplicatedStorage.Shared.CreateClass)

return function(self)
    self.USE_SAVED_DATA = false
    self.Instance = nil
    self.Character = nil
    self.Data = {

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
end