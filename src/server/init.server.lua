

local CreateClass = require(game.ReplicatedStorage.Shared.CreateClass)

local PlayersManagerClass = CreateClass(require(script.PlayersManager))
local RoundHandlerClass = CreateClass(require(script.RoundHandler))
local RemoteSignalHandlerClass = CreateClass(require(script.RemoteSignalHandler))


local PlayersManager = PlayersManagerClass.new()
PlayersManager.Initiate()
local RoundHandler = RoundHandlerClass.new()
RoundHandler.Initiate()
local RemoteSignalHandler = RemoteSignalHandlerClass.new()
RemoteSignalHandler.Initiate()