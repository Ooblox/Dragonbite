
local CreateClass = require(script.Parent.CreateClass)

local DataBaseClass = CreateClass(function(self)
	self.List = {
		Raft = {
			Instance = game.ReplicatedStorage.Boats.Raft,
		},

	}

	self.GetData = function(Name)
		return self.List[Name]
	end
end)

local DataBase = DataBaseClass.new()
return DataBase