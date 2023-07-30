

return function(self)
	self.Player = nil
	self.Instance = nil

    self.Spawn = function()
        self.Player.PlayerGui.GameGui.Enabled = true
        self.Player.PlayerGui.GameGui.Balloons.Visible = false
        self.Player.PlayerGui.GameGui.Bow.Visible = false
        self.Player.PlayerGui.GameGui.Timer.Visible = false

        game.ReplicatedStorage.Dragon:Clone().Parent = workspace.Dragon
        
        self.DamageOnTouch()
        
        while self.Player and game.ServerScriptService.Signals.PlayerInfoInterface:Invoke(self.Player).Team == "Dragon" and game.ServerScriptService.ServerStatus.Value == "InGame"  do
            local MouseHit, CameraDirection = game.ReplicatedStorage.Signals.DragonPos:InvokeClient(self.Player)

            game.Workspace.Dragon.Dragon.HumanoidRootPart.BodyGyro.CFrame = CFrame.new(game.Workspace.Dragon.Dragon.HumanoidRootPart.Position, MouseHit)
            game.Workspace.Dragon.Dragon.HumanoidRootPart.BodyPosition.Position = game.Workspace.Dragon.Dragon.HumanoidRootPart.Position + CameraDirection * 100

            wait()
        end
    end

	self.DamageOnTouch = function()
		for i, v in pairs(self.Instance:GetChildren()) do
			if v:IsA("BasePart") then
				v.Touched:Connect(function(Hit)
					local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
					local Boat = game.Workspace.Boats:FindFirstChild(Hit.Parent.Name)

					if Player then 
						Player.Character.Humanoid.Health = 0
					elseif Boat then
						for i, v in pairs(Boat:GetDescendants()) do
							if v:IsA("Seat") then
								v:Destroy()
								continue
							end

							if v:IsA("WeldConstraint") or v:IsA("ManualWeld") then
								v:Destroy()

								local Force = Instance.new("BodyVelocity", v.Parent)
								local Direction = CFrame.new(Boat.PrimaryPart.Position, v.Parent.Position).LookVector
								Force.Velocity = Direction * 10

								coroutine.wrap(function()
									wait(1)

									Force:Destroy()
								end)()
							end
						end
					end
				end)
			end
		end
	end

	self.Initiate = function()
		self.Spawn()
	end
end

