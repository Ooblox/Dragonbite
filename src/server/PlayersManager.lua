local TextService = game:GetService("TextService")
local CreateClass = require(game.ReplicatedStorage.Shared.CreateClass)
local PlayerClass = CreateClass(require(script.Parent.Player))

return function(self)
    self.CurrentPlayerObjects = {}

    self.PlayerRemovingManager = function()
        game.Players.PlayerRemoving:Connect(function(Player)
            for i, v in pairs(self.CurrentPlayerObjects) do
                if v.Instance == Player then
                    v.OnLeave()
                    table.remove(self.CurrentPlayerObjects, table.find(self.CurrentPlayerObjects, v))
                end
            end
        end)
    end

    self.PlayerJoiningManager = function()
        game.Players.PlayerAdded:Connect(function(Player)
            local PlayerObj = PlayerClass.new()
            PlayerObj.OnJoin(Player)

            table.insert(self.CurrentPlayerObjects, PlayerObj)    
        end)
    end
    
    self.GetPlayerObjFromInst = function(Inst)
        for i, v in pairs(self.CurrentPlayerObjects) do
            if v.Instance == Inst then
                return v
            end
        end
    end

    self.PlayerDataInterface = function(PlayerInst, Data, Type)
        game.ServerScriptService.Signals.PlayerDataInterface.OnInvoke = function(PlayerInst, Data, Type)
            local PlayerObj = self.GetPlayerObjFromInst(PlayerInst)
            if Data then
                if Type == "Replace" then
                    for i, v in pairs(Data) do
                        PlayerObj.Data[i] = v
                    end
                elseif Type == "Add" then
                    for i, v in pairs(Data) do
                        PlayerObj.Data[i] += v
                    end                      
                end

                game.ReplicatedStorage.LocalSignals.PlayerDataChange:Fire(self.Instance)
                game.ReplicatedStorage.RemoteSignals.PlayerDataChange:FireClient(self.Instance)
            end
                    
            return PlayerObj.Data
        end
    end

    self.PlayerSpawnHandler = function()
        game.ServerScriptService.Signals.SpawnPlayer.OnInvoke = function(PlayerInst)
            local PlayerObj = self.GetPlayerObjFromInst(PlayerInst)
            PlayerObj.Spawn()
        end
    end

    self.Initiate = function()
        self.PlayerJoiningManager()
        self.PlayerRemovingManager()
        self.PlayerDataInterface()
    end
end