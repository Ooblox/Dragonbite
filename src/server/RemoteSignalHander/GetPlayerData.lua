
return function(self)
    
    self.Initiate = function(Player, Data)
        return game.ServerScriptService.Signals.PlayerDataInterface:Invoke(Player)
    end
end
