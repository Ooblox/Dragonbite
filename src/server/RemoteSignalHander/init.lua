
local CreateClass = require(game.ReplicatedStorage.Shared.CreateClass)

local Modules = {
	GetPlayerDataClass = CreateClass(require(script.Parent.GetPlayerData)),
}

local RemoteSignalHandlerClass = CreateClass(function(self)
	self.DetectSignals = function()
		game.ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(Player, ActionName, Data)
			local ActionHandler = Modules[ActionName .. "Class"].new()
			ActionHandler.Initiate(Player, Data)
		end)
	end
end)

local RemoteSignalHandler = RemoteSignalHandlerClass.new()
RemoteSignalHandler.DetectSignals()