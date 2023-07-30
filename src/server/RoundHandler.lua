local Ts = game:GetService("TweenService")

local CreateClass = require(game.ReplicatedStorage.CreateClass)

local DragonClass = CreateClass(require(script.Parent.Dragon))

return (function(self)
	self.MINIMUM_PLAYERS = 1
	self.SURVIVOR_TEETH_AWARD = 2
	self.DRAGON_TEETH_AWARD_PER_PLAYER = 1
	
	self.Players = {
		Survivors = {},
		Dragon = {},
	}
	
	self.StartingSurvivors = 0
	
	self.GamePhase = "WaitingForPlayers"
	
	self.StartGame = function()
		self.StartingSurvivors = 0
		
		for i = 20, 1, -1 do
			if #game.Players:GetChildren() < self.MINIMUM_PLAYERS then
				self.EndGame()
				return
			end

			for _, v in pairs(game.Players:GetChildren()) do
				v.PlayerGui:WaitForChild("MenuGui").Intermission.Visible = true
				v.PlayerGui:WaitForChild("MenuGui").Intermission.TextLabel.Timer.Text = i
			end

			wait(1)
		end

		for i, v in pairs(game.Players:GetChildren()) do 
			v.PlayerGui:WaitForChild("MenuGui").Intermission.Visible = false
		end

		if #game.Players:GetChildren() < self.MINIMUM_PLAYERS then 
			self.EndGame()
			return
		end

		-- Choose dragon

		self.GamePhase = "ChoosingDragon"
		game.ReplicatedStorage.ServerStatus.Value = self.GamePhase
		
		local Dragon 
		local Index = 0
		local RanNum = math.random(0, 100)

		for i, v in pairs(game.Players:GetChildren()) do
			local Chance = game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(v).DragonChance
			
			if RanNum >= Index and RanNum <= Chance + Index then
				Dragon = v
				break
			end
			
			Index += Chance
		end

		
		for _, p in pairs(game.Players:GetChildren()) do
			p.PlayerGui.MenuGui.ChooseDragon.Visible = true
		end

		local Iterations = (#game.Players:GetChildren() * 4)
		local PlayerList = game.Players:GetChildren()
		 
		local Counter = 1
		
		for i = 1, Iterations do
			Counter += 1

			if Counter > #PlayerList then
				Counter = 1
			end

			local Player = PlayerList[Counter]		

			for _, p in pairs(game.Players:GetChildren()) do
				p.PlayerGui.MenuGui.ChooseDragon.Dragon.Text = Player.Name
			end
			
			if Iterations == 4 and Player == Dragon then
				break
			end

			wait(0.1)
		end
		
		Dragon:SetAttribute("Team", "Dragon")
		table.insert(self.Players.Dragon, Dragon)
		
		local NewProbability = (100/#game.Players:GetChildren()) / (#game.Players:GetChildren() > 1 and 4 or 1)
		local OtherPlayersAdd = (game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(self.Players.Dragon[1]).DragonChance - NewProbability) / (#game.Players:GetChildren() - 1)
		
		game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(self.Players.Dragon[1], {DragonChance = NewProbability}, "Replace")

		for i, v in pairs(self.Players.Survivors) do
			game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(v, {DragonChance = -OtherPlayersAdd}, "Add")
		end
		
		wait(5)

		for _, p in pairs(game.Players:GetChildren()) do
			p.PlayerGui.MenuGui.ChooseDragon.Visible = false
		end

		-- Choose Boats

		for _, p in pairs(game.Players:GetChildren()) do
			if p ~= Dragon then
				p.PlayerGui.MenuGui.ChooseBoat.Visible = true
			end
		end 

		for i = 20, 1, -1 do
			for _, p in pairs(game.Players:GetChildren()) do
				p.PlayerGui:WaitForChild("MenuGui").ChooseBoat.Timer.Text = i
			end

			wait(1)
		end

		-- Start game

		for i, v in pairs(game.Players:GetChildren()) do
			if  game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(v).Team ~= "Dragon" then
				table.insert(self.Players.Survivors, v)
				game.ServerScriptService.Signals.SpawnPlayer:Invoke(v)
				v:SetAttribute("Team", "Survivor")
				
				v.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function(Amount)
					if Amount == 0 then
						table.remove(self.Players.Survivors, table.find(self.Players.Survivors, v))
					end
				end)
			end

		end

		self.GamePhase = "InGame"
		game.ReplicatedStorage.ServerStatus.Value = self.GamePhase

		for _, p in pairs(game.Players:GetChildren()) do
			p.PlayerGui.GameGui.Top.Visible = false
			p.PlayerGui.GameGui.Enabled = true
			p.PlayerGui.GameGui.Timer.Visible = true

			p.PlayerGui.MenuGui.Enabled = false	

			if  game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(p).Team == "Dragon" then
				p.PlayerGui.GameGui.Bow.Visible = false
			end
		end

		for i = 10, 1, -1 do
			for _, v in pairs(game.Players:GetChildren()) do
				v.PlayerGui.GameGui.Timer.Text = i

				v.PlayerGui.GameGui.Timer.Size = UDim2.fromScale(0, 0)

				Ts:Create(v.PlayerGui.GameGui.Timer, TweenInfo.new(0.25),{Size = UDim2.fromScale(0.2, 0.2)}):Play()
			end	

			wait(1)
		end

		for _, p in pairs(game.Players:GetChildren()) do
			p.PlayerGui.GameGui.Timer.Visible = false
			p.PlayerGui.GameGui.Top.Visible = true
			p.PlayerGui.GameGui.Enabled = true
		end
		
		local DragonObj = DragonClass.new()
		DragonObj.Player = Dragon
		DragonObj.Instance = game.ReplicatedStorage.Dragon

		self.StartingSurvivors = #game.Players:GetChildren() - 1
		
		for i = 300, 1, -1 do
			for _, v in pairs(game.Players:GetChildren()) do
				v.PlayerGui:WaitForChild("GameGui").Top.Timer.Text = i
			end

			wait(1)

			if #self.Players.Survivors < 0 or game.Workspace.Dragon:FindFirstChildWhichIsA("Model").Health.Value <= 0 then
				self.EndGame()
				return
			end
		end

		self.EndGame()
	end
	
	self.EndGame = function()
		
		if #self.Players.Survivors == 0 then
			game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(self.Players.Dragon, {Currency = self.StartingSurvivors * 2}, "Add")
		else
			for i, v in pairs(self.Players.Survivors) do
				game.ReplicatedStorage.Signals.PlayerInfoInterface:Invoke(v, {Currency = 5}, "Add")
			end
		end
		
		game.Workspace.Dragon:ClearAllChildren()
		
		self.Players = {
			Survivors = {},
			Dragon = {},
		}
		
		for i, v in pairs(game.Players:GetChildren()) do
			coroutine.wrap(function()
				v:SetAttribute("Team", "")
				v:LoadCharacter()
				v.PlayerGui.GameGui.Enabled = false
				v.PlayerGui.EndOfGameGui.Enabled = true
				v.PlayerGui:WaitForChild("MenuGui").Enabled = false
				
				v.PlayerGui.EndOfGameGui.RemoteEvent:FireClient(v, self.Players.Survivors)
				
				wait(10)
				
				v.PlayerGui.EndOfGameGui.RemoteEvent:FireClient(v)

				v.PlayerGui.EndOfGameGui.Enabled = false
				v.PlayerGui:WaitForChild("MenuGui").Enabled = true
			end)()
		end
				
		self.GamePhase = "WaitingForPlayers"
		game.ReplicatedStorage.ServerStatus.Value = self.GamePhase
		
		wait(10)

		self.WaitForPlayers()
	end
	
	self.WaitForPlayers = function()
		local function Check(Player)
			if #game.Players:GetChildren() >= self.MINIMUM_PLAYERS and self.GamePhase == "WaitingForPlayers" then
				self.GamePhase = "Intermission"
				game.ReplicatedStorage.ServerStatus.Value = self.GamePhase

				Player:WaitForChild("PlayerGui"):WaitForChild("MenuGui").Waiting.Visible = false
				self.StartGame()
			end

			if #game.Players:GetChildren() < self.MINIMUM_PLAYERS then
				Player:WaitForChild("PlayerGui"):WaitForChild("MenuGui").Waiting.TextLabel.Text = "Waiting for " .. self.MINIMUM_PLAYERS .. " players to start the game..."
				Player:WaitForChild("PlayerGui"):WaitForChild("MenuGui").Waiting.Visible = true
			end
		end
		
		for i, v in pairs(game.Players:GetChildren()) do
			Check(v)
		end
		
		
		game.Players.PlayerAdded:Connect(function(Player)		
			Check(Player)
		end)
	end
	
	self.ServerStarted = function()
		self.WaitForPlayers()
	end
end)