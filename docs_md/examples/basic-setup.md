# Basic Character Setup

## Simple Setup (Server)

The most basic setup for handling all players:

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Wait for animator to load
        local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
        
        -- Create controller
        local controller = SimpleAnimate.new(character)
        
        print(player.Name, "animation controller ready!")
    end)
end)
```

## With Player Animation Packages

Load each player's equipped animations:

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
        
        -- Get player's animation package
        local coreAnims = SimpleAnimate.getAnimPackageAsync(player)
        local emoteAnims = SimpleAnimate.getEmotePackageAsync(player)
        
        -- Create controller with player's animations
        local controller = SimpleAnimate.new(
            character,
            true,
            coreAnims,
            emoteAnims
        )
    end)
end)
```

## Client-Side Setup

Setup on the client for the local player:

```lua
-- LocalScript in StarterPlayer.StarterCharacterScripts
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)
local character = script.Parent

-- Create controller
local controller = SimpleAnimate.new(character)

-- Listen for pose changes
controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose)
    print("Pose changed:", oldPose, "->", newPose)
end)
```

## With Custom Default Animations

Replace default animations with your own:

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Define custom animations
local customAnims = {
    Idle = {
        {id = "rbxassetid://123456789", weight = 10, fadeTime = 0.1}
    },
    Walk = {
        {id = "rbxassetid://111111111", weight = 10}
    },
    Run = {
        {id = "rbxassetid://222222222", weight = 10}
    },
    Jump = {
        {id = "rbxassetid://333333333", weight = 10}
    },
    -- Add more poses...
}

local customEmotes = {
    wave = {
        {id = "rbxassetid://444444444", weight = 10}
    },
    dance = {
        {id = "rbxassetid://555555555", weight = 10}
    }
}

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
        
        local controller = SimpleAnimate.new(
            character,
            true,
            customAnims,
            customEmotes
        )
    end)
end)
```

## With Emote Menu Integration

Set up the emote menu to work with SimpleAnimate:

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
        local humanoid = character:WaitForChild("Humanoid")
        
        local controller = SimpleAnimate.new(character)
        
        -- Hook up emote bindable
        local emoteBindable = Instance.new("BindableFunction")
        emoteBindable.Parent = character
        
        controller.Action:SetEmoteBindable(emoteBindable)
        
        -- Set the humanoid's emote bindable
        humanoid:SetEmoteBindableFunction(emoteBindable)
    end)
end)
```

## Character Respawn Handling

Properly handle character respawns:

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

local playerControllers = {}

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Clean up old controller if it exists
        if playerControllers[player] then
            playerControllers[player]:Destroy()
        end
        
        local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
        
        -- Create new controller
        local controller = SimpleAnimate.new(character)
        playerControllers[player] = controller
    end)
    
    player.CharacterRemoving:Connect(function()
        if playerControllers[player] then
            playerControllers[player]:Destroy()
            playerControllers[player] = nil
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    playerControllers[player] = nil
end)
```

## With Animation Preloading Disabled

Disable preloading if you want animations to load on-demand:

```lua
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Preloading disabled (3rd parameter = false)
local controller = SimpleAnimate.new(
    character,
    false -- Don't preload
)

-- Animations will load when first played
```

## Multiple Characters (NPCs)

Set up animation controllers for NPC characters:

```lua
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

local function setupNPC(npc)
    local animator = npc:WaitForChild("Humanoid"):WaitForChild("Animator")
    
    -- Create controller for NPC
    local controller = SimpleAnimate.new(npc)
    
    -- Store reference if needed
    npc:SetAttribute("HasAnimController", true)
    
    return controller
end

-- Setup all NPCs in workspace
for _, npc in workspace.NPCs:GetChildren() do
    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
        setupNPC(npc)
    end
end

-- Setup new NPCs as they're added
workspace.NPCs.ChildAdded:Connect(function(npc)
    if npc:IsA("Model") then
        npc:WaitForChild("Humanoid")
        setupNPC(npc)
    end
end)
```

## With Pose Change Monitoring

Monitor and log all pose changes:

```lua
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

local character = player.Character or player.CharacterAdded:Wait()
local controller = SimpleAnimate.new(character)

-- Track pose changes
local poseHistory = {}

controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    table.insert(poseHistory, {
        from = oldPose,
        to = newPose,
        time = tick(),
        animationId = track.Animation.AnimationId
    })
    
    print(string.format("[%.2f] %s -> %s", tick(), oldPose, newPose))
end)

-- Function to get pose statistics
local function getPoseStats()
    local stats = {}
    
    for _, entry in poseHistory do
        stats[entry.to] = (stats[entry.to] or 0) + 1
    end
    
    return stats
end
```

## Error Handling

Robust error handling for animation setup:

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local success, controller = pcall(function()
            local animator = character:WaitForChild("Humanoid", 5):WaitForChild("Animator", 5)
            return SimpleAnimate.new(character)
        end)
        
        if success then
            print(player.Name, "animation controller created successfully")
        else
            warn(player.Name, "failed to create animation controller:", controller)
        end
    end)
end)
```

## Waiting for Existing Controllers

Use `awaitController` in other scripts:

```lua
-- Script A: Creates controller
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)
local controller = SimpleAnimate.new(character)

-- Script B: Waits for controller
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

local controller = SimpleAnimate.awaitController(character, 10)

if controller then
    print("Got controller!")
    controller.Action:PlayAction("wave")
else
    warn("Controller not found within timeout")
end
```