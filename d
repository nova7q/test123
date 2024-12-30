
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Nova |                Free", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local AimbotTab = Window:MakeTab({
	Name = "Aimbot",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local CarModTab = Window:MakeTab({
	Name = "CarMod",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
	Name = "Teleport",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local EspTab = Window:MakeTab({
	Name = "Esp",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local farmTab = Window:MakeTab({
	Name = "Autofarm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local MiscTab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})


local Section = AimbotTab:AddSection({
	Name = "Aimbot"
})

local Section = CarModTab:AddSection({
	Name = "CarMods"
})

local Section = TeleportTab:AddSection({
	Name = "Teleport"
})

local Section = EspTab:AddSection({
	Name = "Esp"
})

local Section = farmTab:AddSection({
	Name = "Autofarm"
})

local Section = MiscTab:AddSection({
	Name = "Misc"
})


local aimbotEnabled = false
local aimKeybind = Enum.KeyCode.V 
local aimPart = "HumanoidRootPart"
local fov = 100
local teamCheck = true
local knockedCheck = true
local smoothness = 0.44 

local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1.5
FOVring.Radius = fov
FOVring.Transparency = 5
FOVring.Color = Color3.fromRGB(255, 255, 255)
FOVring.Position = workspace.CurrentCamera.ViewportSize / 2

AimbotTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end    
})

AimbotTab:AddBind({
    Name = "Aimbot Keybind",
    Default = Enum.KeyCode.V,
    Hold = false,
    Callback = function()
        aimbotEnabled = not aimbotEnabled
    end    
})

AimbotTab:AddDropdown({
    Name = "Aim Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart"},
    Callback = function(Value)
        aimPart = Value
    end    
})

AimbotTab:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(Value)
        teamCheck = Value
    end    
})

AimbotTab:AddToggle({
    Name = "Knocked Check",
    Default = true,
    Callback = function(Value)
        knockedCheck = Value
    end    
})

AimbotTab:AddToggle({
    Name = "Show FOV Circle",
    Default = false,
    Callback = function(Value)
        FOVring.Visible = Value
    end    
})

AimbotTab:AddSlider({
    Name = "FOV Size",
    Min = 50,
    Max = 300,
    Default = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    ValueName = "FOV",
    Callback = function(Value)
        fov = Value
        FOVring.Radius = fov
    end    
})

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function getClosestTarget()
    local cam = workspace.CurrentCamera
    local closestPlayer = nil
    local closestDistance = fov

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and knockedCheck and humanoid.Health <= 24 then
                continue
            end

            if teamCheck and player.Team == game.Players.LocalPlayer.Team then
                continue
            end

            local targetPos = cam:WorldToScreenPoint(player.Character[aimPart].Position)
            local distance = (Vector2.new(targetPos.X, targetPos.Y) - Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)).Magnitude

            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(aimPart) then
            local cam = workspace.CurrentCamera
            local targetPos = target.Character[aimPart].Position

            -- Berechnung der neuen Kameraausrichtung mit Smoothness
            local currentLookAt = cam.CFrame.LookVector
            local targetLookAt = (targetPos - cam.CFrame.Position).Unit
            local newLookAt = currentLookAt:Lerp(targetLookAt, smoothness)

            -- Kamera aktualisieren, aber mit sanftem Übergang
            cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + newLookAt)
        end
    end
  end)

--CarMod


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local flightEnabled = false
local flightSpeed = 2 -- Default speed
local defaultCharacterParent

-- Function to get the vehicle from a descendant
local function GetVehicleFromDescendant(Descendant)
    return
        Descendant:FindFirstAncestor(LocalPlayer.Name .. "'s Car") or
        (Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent) or
        (Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent) or
        Descendant:FindFirstAncestorWhichIsA("Model")
end

-- Flight logic
RunService.Stepped:Connect(function()
    local Character = LocalPlayer.Character
    if flightEnabled then
        if Character and typeof(Character) == "Instance" then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and SeatPart:IsA("VehicleSeat") then
                    local Vehicle = GetVehicleFromDescendant(SeatPart)
                    if Vehicle and Vehicle:IsA("Model") then
                        Character.Parent = Vehicle
                        if not Vehicle.PrimaryPart then
                            Vehicle.PrimaryPart = SeatPart.Parent == Vehicle and SeatPart or Vehicle:FindFirstChildWhichIsA("BasePart")
                        end
                        local PrimaryPartCFrame = Vehicle:GetPrimaryPartCFrame()
                        Vehicle:SetPrimaryPartCFrame(CFrame.new(PrimaryPartCFrame.Position, PrimaryPartCFrame.Position + workspace.CurrentCamera.CFrame.LookVector) * 
                            (CFrame.new(
                                (UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed or 0) - 
                                (UserInputService:IsKeyDown(Enum.KeyCode.A) and flightSpeed or 0), 
                                (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed / 2 or 0) - 
                                (UserInputService:IsKeyDown(Enum.KeyCode.Q) and flightSpeed / 2 or 0), 
                                (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed or 0) - 
                                (UserInputService:IsKeyDown(Enum.KeyCode.W) and flightSpeed or 0))))
                        SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    else
        if Character and typeof(Character) == "Instance" then
            Character.Parent = defaultCharacterParent or Character.Parent
            defaultCharacterParent = Character.Parent
        end
    end
end)

CarModTab:AddToggle({
    Name = "Toggle Flight",
    Default = false,
    Callback = function(state)
        flightEnabled = state
    end
})


CarModTab:AddBind({
    Name = "Flight Keybind",
    Default = Enum.KeyCode.X,
    Hold = false,
    Callback = function()
        flightEnabled = not flightEnabled
    end
})


CarModTab:AddSlider({
    Name = "Flight Speed",
    Min = 1,
    Max = 5, 
    Default = 2, 
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        flightSpeed = value -- Update flight speed based on the slider value
    end
})

CarModTab:AddButton({
	Name = "Enter Vehicle",
	Callback = function()
      	 local function enterVehicle()
    local player = game.Players.LocalPlayer
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name)

    if vehicle then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid and not humanoid.SeatPart then
            -- Suche den Fahrersitz und setze den Spieler darauf
            local driveSeat = vehicle:FindFirstChild("DriveSeat")
            if driveSeat then
                driveSeat:Sit(humanoid) -- Setzt den Spieler in den Fahrersitz
            end
        end
    end
end

enterVehicle()	
  	end    
})

CarModTab:AddButton({
	Name = "Bring Car",
	Callback = function()
      		local function enterVehicle()
    local player = game.Players.LocalPlayer
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name)

    if vehicle then
        -- Stelle sicher, dass der Spieler einen Humanoid besitzt
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid and not humanoid.SeatPart then
            -- Suche den Fahrersitz und setze den Spieler darauf
            local driveSeat = vehicle:FindFirstChild("DriveSeat")
            if driveSeat then
                driveSeat:Sit(humanoid)
            else
                
            end
        end
    else
        
    end
end

-- Funktion: Fahrzeug an den Ort teleportieren, an dem die Funktion ausgeführt wurde
local function bringCar()
    local player = game.Players.LocalPlayer
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name)
    local character = player.Character

    if vehicle and character then
        -- Position des Spielers speichern, wo die Funktion ausgeführt wurde
        local targetPosition = character.PrimaryPart and character.PrimaryPart.CFrame
        if targetPosition then
            -- Spieler ins Fahrzeug setzen
            enterVehicle()
            wait(0.5) -- Sicherstellen, dass der Spieler im Fahrzeug sitzt

            -- Fahrzeug zur gespeicherten Position teleportieren
            vehicle:SetPrimaryPartCFrame(targetPosition)
        else
            
        end
    else
        
    end
end

bringCar()
  	end    
})

local Section = CarModTab:AddSection({
	Name = "Options"
})

local Players = game:GetService("Players")
local Players = Players
local LocalPlayer = Players.LocalPlayer
local vehicleName = LocalPlayer.Name
local vehicle = workspace.Parent:GetService("Workspace").Vehicles:FindFirstChild(vehicleName)
local defaultMaxAccelerateForce = vehicle and vehicle:GetAttribute("MaxAccelerateForce") or 0
local defaultMaxBrakeForce = vehicle and vehicle:GetAttribute("MaxBrakeForce") or 0
local defaultMaxSpeed = vehicle and vehicle:GetAttribute("MaxSpeed") or 0
local defaultReverseMaxSpeed = vehicle and vehicle:GetAttribute("ReverseMaxSpeed") or 0


local accelerateSlider = CarModTab:AddSlider({ 
	Name = "Max Accelerate Force",
	Min = 0,
	Max = 10000, 
	Default = defaultMaxAccelerateForce,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "", 
	Callback = function(Value)
		if LocalPlayer.Character.Humanoid.SeatPart then
			LocalPlayer.Character.Humanoid.SeatPart.Parent:SetAttribute("MaxAccelerateForce", Value)
		end
	end    
})

local brakeSlider = CarModTab:AddSlider({ 
	Name = "Max Brake Force",
	Min = 0,
	Max = 10000, 
	Default = defaultMaxBrakeForce,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "", 
	Callback = function(Value)
		if LocalPlayer.Character.Humanoid.SeatPart then
			LocalPlayer.Character.Humanoid.SeatPart.Parent:SetAttribute("MaxBrakeForce", Value)
		end
	end    
})

local speedSlider = CarModTab:AddSlider({ 
	Name = "Max Speed",
	Min = 0,
	Max = 500, 
	Default = defaultMaxSpeed,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "", 
	Callback = function(Value)
		if LocalPlayer.Character.Humanoid.SeatPart then
			LocalPlayer.Character.Humanoid.SeatPart.Parent:SetAttribute("MaxSpeed", Value)
		end
	end    
})

local reverseSpeedSlider = CarModTab:AddSlider({ 
	Name = "Reverse Max Speed",
	Min = 0,
	Max = 500, 
	Default = defaultReverseMaxSpeed,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		if LocalPlayer.Character.Humanoid.SeatPart then
			LocalPlayer.Character.Humanoid.SeatPart.Parent:SetAttribute("ReverseMaxSpeed", Value)
		end
	end    
})

--Teleport


TeleportTab:AddButton({
	Name = "Nearste Dealer",
	Callback = function()
      		local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VehiclesFolder = workspace:WaitForChild("Vehicles")  


local function findNearestDealer()
    local nearestDealer = nil
    local closestDistance = math.huge  

    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("dealer") then  
            
            if obj.PrimaryPart then
               
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - obj.PrimaryPart.Position).magnitude
                
                if distance < closestDistance then
                    nearestDealer = obj
                    closestDistance = distance
                end
            end
        end
    end

    return nearestDealer
end


local function teleportVehicleToDealer()
    local vehicle = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    local dealer = findNearestDealer()  

    
    if vehicle and dealer then
        
        vehicle.PrimaryPart = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("Mass") or vehicle.PrimaryPart
        if not vehicle.PrimaryPart then
            
            return
        end

       
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            if not humanoid.SeatPart then
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    
                    driveSeat:Sit(humanoid)
                    wait(0.1) 
                else
                    
                    return
                end
            end

            
            vehicle:SetPrimaryPartCFrame(CFrame.new(dealer.PrimaryPart.Position))

            
        else
            
        end
    else
       
    end
end

teleportVehicleToDealer()
  	end    
})


TeleportTab:AddButton({
	Name = "Nearste Vending Machine",
	Callback = function()
      	local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Funktion, um die nächste Vending Machine zu finden
local function findNearestVendingMachine()
    local nearestPart = nil
    local closestDistance = math.huge  

    -- Durchlaufe alle Objekte im Workspace, um nach einer Vending Machine zu suchen
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Vending Machine" then  
            for _, part in pairs(obj:GetChildren()) do
                if part:IsA("BasePart") then
                    -- Berechne die Entfernung zur Vending Machine
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).magnitude
                    if distance < closestDistance then
                        nearestPart = part 
                        closestDistance = distance
                    end
                end
            end
        end
    end

    if nearestPart then
        
    else
        
    end

    return nearestPart
end


local function teleportVehicleToVendingMachine()
    local vehicle = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)  
    local vendingMachinePart = findNearestVendingMachine()  

    if not vendingMachinePart then
        
        return
    end

    if vehicle then
        
        vehicle.PrimaryPart = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("Mass") or vehicle.PrimaryPart
        if not vehicle.PrimaryPart then
            
            return
        end

        -- Stelle sicher, dass der Spieler einen Humanoid hat
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
         
            if not humanoid.SeatPart then
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    driveSeat:Sit(humanoid)  
                    wait(0.1)  
                else
                    
                    return
                end
            end

            -- Teleportiere das Fahrzeug zur Vending Machine
            vehicle:SetPrimaryPartCFrame(CFrame.new(vendingMachinePart.Position))
            

            LocalPlayer.Character.HumanoidRootPart.CFrame = vehicle.PrimaryPart.CFrame + Vector3.new(0, 3, 0)  
            
        else
            
        end
    else
       
    end
end

teleportVehicleToVendingMachine()	
  	end    
})

TeleportTab:AddButton({
	Name = "Safe Zone",
	Callback = function()
      	local function teleportToLocation(coordinates)
    local player = game.Players.LocalPlayer
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name)

    if vehicle then
        vehicle.PrimaryPart = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("Mass") or vehicle.PrimaryPart
        if not vehicle.PrimaryPart then return end

        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if not humanoid.SeatPart then
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    driveSeat:Sit(humanoid)
                    wait(0.1)
                end
            end
            vehicle:PivotTo(coordinates)
        end
    else
       
    end
end

-- Trage hier deine Koordinaten ein
local coords = CFrame.new(Vector3.new(-1979.67, 344.99, 3154.49))

-- Hauptprogramm: Teleportiere zur angegebenen Position
teleportToLocation(coords)	
  	end    
})

local Section = TeleportTab:AddSection({
	Name = "Teleport"
})

local function teleportToLocation(coordinates)
    local player = game.Players.LocalPlayer
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name)

    if vehicle then
        vehicle.PrimaryPart = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("Mass") or vehicle.PrimaryPart
        if not vehicle.PrimaryPart then return end

        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if not humanoid.SeatPart then
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    driveSeat:Sit(humanoid)
                    wait(0.1)
                end
            end
            vehicle:PivotTo(coordinates)
        end
    else
        
    end
end

-- Speicher-Variablen für jedes Dropdown
local selectedLocation1
local selectedLocation2
local selectedLocation3
local selectedLocation4

-- Dropdown: Main 1 mit eigenem Teleport-Button
TeleportTab:AddButton({
    Name = "Teleport Main 1",
    Callback = function()
        if selectedLocation1 then
            if selectedLocation1 == "Gasn-Go" then
                teleportToLocation(CFrame.new(-1566.311, 5.25, 3812.591))
            elseif selectedLocation1 == "Osso-Fuel" then
                teleportToLocation(CFrame.new(-33.184, 5.25, -748.875))
            elseif selectedLocation1 == "Jewelry Store" then
                teleportToLocation(CFrame.new(-413.255, 5.5, 3517.947))
            elseif selectedLocation1 == "Bank" then
                teleportToLocation(CFrame.new(-1188.809, 5.5, 3228.133))
            elseif selectedLocation1 == "Ares Tank" then
                teleportToLocation(CFrame.new(-858.118, 5.3, 1514.51))
            end
        else
            warn("Keine Location in Main 1 ausgewählt!")
        end
    end
})


TeleportTab:AddDropdown({
    Name = "Main 1",
    Options = {"Gasn-Go", "Osso-Fuel", "Jewelry Store", "Bank", "Ares Tank"},
    Callback = function(selected)
        selectedLocation1 = selected
    end
})

TeleportTab:AddLabel("")

-- Dropdown: Main 2 mit eigenem Teleport-Button
TeleportTab:AddButton({
    Name = "Teleport Main 2",
    Callback = function()
        if selectedLocation2 then
            if selectedLocation2 == "Tool Shop" then
                teleportToLocation(CFrame.new(-750.401, 5.25, 670.062))
            elseif selectedLocation2 == "Farm Shop" then
                teleportToLocation(CFrame.new(-896.206, 4.984, -1165.972))
            elseif selectedLocation2 == "Erwin Club" then
                teleportToLocation(CFrame.new(-1858.259, 5.25, 3023.394))
            elseif selectedLocation2 == "Yellow Container" then
                teleportToLocation(CFrame.new(1118.788, 28.696, 2335.582))
            elseif selectedLocation2 == "Green Container" then
                teleportToLocation(CFrame.new(1169.115, 28.696, 2153.111))
            end
        else
            warn("Keine Location in Main 2 ausgewählt!")
        end
    end
})

TeleportTab:AddDropdown({
    Name = "Main 2",
    Options = {"Tool Shop", "Farm Shop", "Erwin Club", "Yellow Container", "Green Container"},
    Callback = function(selected)
        selectedLocation2 = selected
    end
})

TeleportTab:AddLabel("")

-- Dropdown: Main 3 mit eigenem Teleport-Button
TeleportTab:AddButton({
    Name = "Teleport Main 3",
    Callback = function()
        if selectedLocation3 then
            if selectedLocation3 == "Car Dealer" then
                teleportToLocation(CFrame.new(-1421.418, 5.25, 941.061))
            elseif selectedLocation3 == "Prison In" then
                teleportToLocation(CFrame.new(-573.336, 5.088, 3061.913))
            elseif selectedLocation3 == "Prison Out" then
                teleportToLocation(CFrame.new(-580.354, 5.25, 2839.322))
            elseif selectedLocation3 == "Hospital" then
                teleportToLocation(CFrame.new(-284.98, 5.25, 1108.397))
            elseif selectedLocation3 == "Parking Garage" then
                teleportToLocation(CFrame.new(-1031.08, 5.5, 3899.69))
            end
        else
            warn("Keine Location in Main 3 ausgewählt!")
        end
    end
})

TeleportTab:AddDropdown({
    Name = "Main 3",
    Options = {"Car Dealer", "Prison In", "Prison Out", "Hospital", "Parking Garage"},
    Callback = function(selected)
        selectedLocation3 = selected
    end
})

TeleportTab:AddLabel("")

-- Dropdown: Main 4 mit eigenem Teleport-Button
TeleportTab:AddButton({
    Name = "Teleport Main 4",
    Callback = function()
        if selectedLocation4 then
            if selectedLocation4 == "ADAC" then
                teleportToLocation(CFrame.new(-126.326, 5.25, 431.344))
            elseif selectedLocation4 == "Police Station" then
                teleportToLocation(CFrame.new(-1684.459, 5.25, 2736.004))
            elseif selectedLocation4 == "Fire Station" then
                teleportToLocation(CFrame.new(-1026.58, 5.464, 3899.69))
            elseif selectedLocation4 == "Truck Station" then
                teleportToLocation(CFrame.new(710.446, 5.25, 1481.296))
            elseif selectedLocation4 == "Bus Station" then
                teleportToLocation(CFrame.new(-1676.292, 5.144, -1272.049))
            end
        else
            warn("Keine Location in Main 4 ausgewählt!")
        end
    end
})

TeleportTab:AddDropdown({
    Name = "Main 4",
    Options = {"ADAC", "Police Station", "Fire Station", "Truck Station", "Bus Station"},
    Callback = function(selected)
        selectedLocation4 = selected
    end
})

--Esp


local showNameESP = false
local showDistanceESP = false
local espDistance = 750  -- Default max ESP distance
local teamCheck = false
local activeESP = {}

-- Function to create or update ESP for a player
local function updateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
    
    -- Check if distance is within the specified range
    if distance <= espDistance then
        local billboard = activeESP[player] or Instance.new("BillboardGui")
        
        if not activeESP[player] then
            -- Setup BillboardGui
            billboard.Size = UDim2.new(0, 150, 0, 40)  -- Adjusted height for larger name label
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            
            -- Main name label
            local nameLabel = Instance.new("TextLabel", billboard)
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
            nameLabel.BackgroundTransparency = 1  -- Transparent background
            nameLabel.TextScaled = true
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White by default
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Text = player.Name
            nameLabel.Visible = showNameESP

            -- Distance Label (styled in brackets)
            local distanceLabel = Instance.new("TextLabel", billboard)
            distanceLabel.Name = "DistanceLabel"
            distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
            distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextScaled = true
            distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)  -- Light grey by default
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.Visible = showDistanceESP

            billboard.Parent = player.Character.HumanoidRootPart
            activeESP[player] = {billboard, nameLabel, distanceLabel}
        end
        
        -- Update distance label with current distance in brackets, e.g., "[78m]"
        local distanceLabel = activeESP[player][3]
        distanceLabel.Text = "[" .. math.floor(distance) .. "m]"

        -- Toggle visibility based on user settings
        activeESP[player][2].Visible = showNameESP  -- Name label visibility
        distanceLabel.Visible = showDistanceESP     -- Distance label visibility

        -- Apply team color if Team Check is enabled
        if teamCheck then
            local teamColor = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 0, 0)  -- Default to red
            activeESP[player][2].TextColor3 = teamColor  -- Apply team color to name label
            distanceLabel.TextColor3 = teamColor         -- Apply team color to distance label
        else
            -- Default color when Team Check is disabled
            activeESP[player][2].TextColor3 = Color3.fromRGB(255, 255, 255)  -- White for name
            distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)         -- Light grey for distance
        end
    elseif activeESP[player] then
        -- Remove ESP if player is out of range
        activeESP[player][1]:Destroy()
        activeESP[player] = nil
    end
end

-- Function to toggle ESP for all players
local function toggleESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            updateESP(player)
        end
    end
end


-- Toggle for Name ESP
EspTab:AddToggle({
    Name = "Name ESP",
    Default = false,
    Callback = function(value)
        showNameESP = value
        toggleESP()  
    end
})

-- Toggle for Distance ESP
EspTab:AddToggle({
    Name = "Distance ESP",
    Default = false,
    Callback = function(value)
        showDistanceESP = value
        toggleESP()  
    end
})

-- Toggle for Team Check
EspTab:AddToggle({
    Name = "Team Check",
    Default = false,
    Callback = function(value)
        teamCheck = value
        toggleESP() 
    end
})


EspTab:AddSlider({
    Name = "ESP Distance",
    Min = 0,
    Max = 2000,  
    Default = 500,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "m",
    Callback = function(value)
        espDistance = value
        toggleESP()  -- Update ESP for all players based on new distance
    end
})

-- Update ESP when players join
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        updateESP(player)
    end)
end)

-- Update ESP each frame for dynamic positioning
game:GetService("RunService").RenderStepped:Connect(function()
    toggleESP()
end)

--AutoFarm

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VehiclesFolder = workspace:WaitForChild("Vehicles")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local FARMPos
local FARMLastPos
local FARMcooldown = false
local FARMheight = 400
local FARMspeed = 100
local FARMcurrentTween = nil
local FARMstopFarm = false
local autoFarmToggle = false


-- Autofarm Toggle
farmTab:AddToggle({
    Name = "Autofarm",
    Default = false,
    Callback = function(Value)
        autoFarmToggle = Value
        if FARMLastPos then
            FARMLastPos = nil
        end
        if FARMcurrentTween then
            FARMcurrentTween:Cancel()
            FARMstopFarm = true
            task.wait(0.5)  -- Reduzierte Wartezeit
            FARMstopFarm = false
        end
    end    
})

-- Funktion: Sicherstellen, dass Spieler im Fahrzeug bleibt
local function ensurePlayerInVehicle()
    -- Überprüfen, ob der Spieler im richtigen Team ist
    if game.Players.LocalPlayer.Team == game:GetService("Teams").TruckCompany or game.Players.LocalPlayer.Team == game:GetService("Teams").BusCompany then
        local vehicle = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
        if vehicle and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and not humanoid.SeatPart then
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    driveSeat:Sit(humanoid)
                end
            end
        end
    end
end

-- Zielpunkte finden
local function partfind()
    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v:IsA("BillboardGui") and v.Adornee then
            if v.Adornee.CFrame then
                return v.Adornee.CFrame
            end
        end
    end
    return nil
end

local function destination()
    for _, v in pairs(workspace.BusStops:GetDescendants()) do
        if v.Name == "SelectionBox" and v.Visible and v.Transparency ~= 1 then
            return v.Parent.CFrame
        end
    end
    for _, v in pairs(workspace.DeliveryDestinations:GetDescendants()) do
        if v.Name == "SelectionBox" and v.Visible and v.Transparency ~= 1 then
            return v.Parent.CFrame
        end
    end
    return nil
end

-- Tween-Funktion für Fahrzeugbewegung
local function tweenModel(model, targetCFrame, duration)
    if FARMcurrentTween then
        FARMcurrentTween:Cancel()
        FARMcurrentTween = nil
    end

    local info = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )

    local CFrameValue = Instance.new("CFrameValue")
    CFrameValue.Value = model:GetPrimaryPartCFrame()

    CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
        model:SetPrimaryPartCFrame(CFrameValue.Value)
        model.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
    end)

    local tween = TweenService:Create(CFrameValue, info, { Value = targetCFrame })
    tween:Play()

    local tweenCompleted = false
    tween.Completed:Connect(function()
        CFrameValue:Destroy()
        tweenCompleted = true
    end)

    FARMcurrentTween = tween

    repeat task.wait(0.5) until tweenCompleted or FARMstopFarm  -- Beschleunigte Wartezeit

    return tweenCompleted
end

-- Bewegung der Fahrzeuge
local function tweenFunction()
    local vehicle = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    if not vehicle then
        FARMLastPos = nil
        return
    end
    if vehicle.PrimaryPart == nil or not vehicle.PrimaryPart then
        vehicle.PrimaryPart = vehicle:FindFirstChild("Mass", true)
    end
    local _, size = vehicle:GetBoundingBox()

    if FARMPos then
        local currentPosition = vehicle.PrimaryPart.CFrame
        local upwardPosition = CFrame.new(currentPosition.Position.X, FARMheight, currentPosition.Position.Z)
        if not FARMstopFarm then
            if not tweenModel(vehicle, upwardPosition, FARMheight / FARMspeed) then return end
        end

        if not FARMstopFarm then
            local adjustedPosition = FARMPos * CFrame.new(0, FARMheight, 0)
            if not tweenModel(vehicle, adjustedPosition, (adjustedPosition.Position - upwardPosition.Position).Magnitude / FARMspeed) then return end
        end

        if not FARMstopFarm then
            -- Schnellerer Abstieg: Dauer auf 3 Sekunden verringert
            tweenModel(vehicle, (FARMPos * CFrame.new(0, size.Y / 2, 0)), FARMheight / (FARMspeed * 2))  -- Beschleunigte Abwärtsbewegung

            -- Eventuell mit der Wartedauer nach dem Abstieg
            if game.Players.LocalPlayer.Team == game:GetService("Teams").TruckCompany then
                task.wait(4)  -- Kürzere Wartezeit nach dem Erreichen der Position
                for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if v:IsA("ImageButton") and v.ImageColor3 == Color3.fromRGB(39, 174, 96) then
                        if v.Parent ~= nil then
                            local buttonCenter = v.AbsolutePosition + (v.AbsoluteSize / 2)
                            VirtualUser:ClickButton1(Vector2.new(buttonCenter.X, buttonCenter.Y))
                        end
                    end
                end
            end
        end
    else
        FARMLastPos = nil
    end
end

-- RenderStepped-Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if autoFarmToggle == true then
        ensurePlayerInVehicle() -- Spieler bleibt im Fahrzeug
        if game.Players.LocalPlayer.Team == game:GetService("Teams").TruckCompany or game.Players.LocalPlayer.Team == game:GetService("Teams").BusCompany then
            FARMPos = destination() or partfind()
            if not FARMcooldown then
                if not workspace.Vehicles:FindFirstChild(LocalPlayer.Name) then
                    FARMcooldown = true
                    OrionLib:MakeNotification({
                        Name = "Autofarm Error",
                        Content = "Please spawn the first vehicle.",
                        Image = "",
                        Time = 3
                    })
                    task.wait(3)  -- Verkürzte Wartezeit
                    FARMcooldown = false
                    return
                end
                FARMcooldown = true
                FARMPos = destination() or partfind()

                if FARMPos and (not FARMLastPos or FARMPos ~= FARMLastPos) then
                    if FARMcurrentTween then
                        FARMcurrentTween:Cancel()
                    end
                    FARMstopFarm = true
                    task.wait(0.5)  -- Kürzere Wartezeit
                    FARMstopFarm = false
                    FARMLastPos = FARMPos
                    tweenFunction()
                end

                task.wait(0.5)  -- Verkürzte Wartezeit
                FARMcooldown = false
            end
        else
            if FARMcooldown == false then
                FARMcooldown = true
                -- Roblox Notification, wenn der Spieler nicht im richtigen Job ist
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Join a Job",
                    Text = "Please join the Bus or Truck job to use Autofarm.",
                    Icon = "",
                    Duration = 3
                })
                task.wait(5)  -- Verkürzte Wartezeit
                FARMcooldown = false
                return
            end
        end
    end
end)


local function teleport(location, coordinates)
    local player = game.Players.LocalPlayer
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name)

    if vehicle then
        -- Set PrimaryPart if it exists in vehicle's Body
        vehicle.PrimaryPart = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("Mass") or vehicle.PrimaryPart
        if not vehicle.PrimaryPart then return end

        -- Check if player has a Humanoid and seat the player if necessary
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if not humanoid.SeatPart then
                local driveSeat = vehicle:FindFirstChild("DriveSeat")
                if driveSeat then
                    driveSeat:Sit(humanoid)
                    wait(0.1)  -- Brief delay to ensure seating
                end
            end

            -- Move the vehicle to the specified coordinates
            vehicle:PivotTo(coordinates)
        end
    end
end

farmTab:AddDropdown({
    Name = "Places",
    Options = {"Truck Station", "Bus Station",},
    Callback = function(selected)
        if selected == "Truck Station" then
            teleport("Truck Station", CFrame.new(710.446, 5.25, 1481.296))
        elseif selected == "Bus Station" then
            teleport("Bus Station", CFrame.new(-1676.292, 5.144, -1272.049))
        end
    end
})
