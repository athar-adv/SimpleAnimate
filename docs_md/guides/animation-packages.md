# Animation Packages Guide

This guide covers how to work with Roblox animation packages and player-equipped animations in SimpleAnimate.

## What are Animation Packages?

Animation packages are collections of animations that players can equip from the Roblox catalog. They include:
- Movement animations (idle, walk, run, jump)
- Emote animations (wave, dance, laugh, etc.)
- Custom character animations based on player preferences

SimpleAnimate can automatically load these player-equipped animations.

## Loading Player Animations

### Server-Side Loading

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Wait for animator
        local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
        
        -- Load player's animation package
        local coreAnims = SimpleAnimate.getAnimPackageAsync(player)
        local emoteAnims = SimpleAnimate.getEmotePackageAsync(player)
        
        -- Create controller with player's animations
        local controller = SimpleAnimate.new(
            character,
            true,
            coreAnims,
            emoteAnims
        )
        
        print(player.Name, "loaded with custom animations")
    end)
end)
```

### Client-Side Loading

```lua
-- LocalScript in StarterPlayer.StarterCharacterScripts
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)
local character = script.Parent

-- Get local player's animations (no player parameter needed on client)
local coreAnims = SimpleAnimate.getAnimPackageAsync()
local emoteAnims = SimpleAnimate.getEmotePackageAsync()

-- Create controller
local controller = SimpleAnimate.new(
    character,
    true,
    coreAnims,
    emoteAnims
)
```

## Fallback Animations

When loading animation packages, provide fallbacks for missing animations:

### Using Default Fallbacks

```lua
-- If player doesn't have custom animations, R15 defaults are used
local coreAnims = SimpleAnimate.getAnimPackageAsync(player)
-- Missing animations automatically filled with R15 defaults
```

### Custom Fallbacks

```lua
-- Define your custom fallback animations
local customDefaults = {
    Idle = {{id = "rbxassetid://YOUR_IDLE", weight = 10}},
    Walk = {{id = "rbxassetid://YOUR_WALK", weight = 10}},
    Run = {{id = "rbxassetid://YOUR_RUN", weight = 10}}
}

-- Use custom fallbacks
local coreAnims = SimpleAnimate.getAnimPackageAsync(player, customDefaults)

-- Now if player doesn't have custom animations, your defaults are used
```

### Selective Fallbacks

```lua
-- Get player's animations
local coreAnims = SimpleAnimate.getAnimPackageAsync(player)

-- Override specific animations with your own
coreAnims.Idle = {{id = "rbxassetid://YOUR_SPECIAL_IDLE", weight = 10}}

-- Keep player's other animations, but force your idle
local controller = SimpleAnimate.new(character, true, coreAnims)
```

## Mixing Player and Custom Animations

### Player Animations with Custom Emotes

```lua
-- Use player's movement animations
local coreAnims = SimpleAnimate.getAnimPackageAsync(player)

-- But use your custom emotes
local customEmotes = {
    wave = {{id = "rbxassetid://CUSTOM_WAVE", weight = 10}},
    dance = {{id = "rbxassetid://CUSTOM_DANCE", weight = 10}},
    cheer = {{id = "rbxassetid://CUSTOM_CHEER", weight = 10}}
}

local controller = SimpleAnimate.new(
    character,
    true,
    coreAnims,
    customEmotes
)
```

### Custom Animations with Player Emotes

```lua
-- Use your custom movement animations
local customCore = {
    Idle = {{id = "rbxassetid://YOUR_IDLE", weight = 10}},
    Walk = {{id = "rbxassetid://YOUR_WALK", weight = 10}},
    Run = {{id = "rbxassetid://YOUR_RUN", weight = 10}}
}

-- But keep player's emotes
local emoteAnims = SimpleAnimate.getEmotePackageAsync(player)

local controller = SimpleAnimate.new(
    character,
    true,
    customCore,
    emoteAnims
)
```

## Handling Different Rig Types

### R6 vs R15 Detection

```lua
local function getRigType(character)
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        return humanoid.RigType == Enum.HumanoidRigType.R6 and "R6" or "R15"
    end
    return "R15" -- Default
end

local function setupCharacter(player, character)
    local rigType = getRigType(character)
    
    -- Get appropriate defaults
    local defaultCore, defaultEmotes = SimpleAnimate.getCopyOfAnims(rigType)
    
    -- Load player's animations with appropriate fallbacks
    local coreAnims = SimpleAnimate.getAnimPackageAsync(player, defaultCore)
    local emoteAnims = SimpleAnimate.getEmotePackageAsync(player, defaultEmotes)
    
    local controller = SimpleAnimate.new(character, true, coreAnims, emoteAnims)
end
```

### Force Specific Rig Type

```lua
-- Always use R15 animations regardless of player's equipped package
local r15Core, r15Emotes = SimpleAnimate.getCopyOfAnims("R15")

local controller = SimpleAnimate.new(
    character,
    true,
    r15Core,
    r15Emotes
)
```

## Caching Animation Packages

Cache player animation packages to avoid repeated API calls:

```lua
local Players = game:GetService("Players")
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Cache player animations
local playerAnimCache = {}

local function getPlayerAnimations(player)
    -- Check cache first
    if playerAnimCache[player.UserId] then
        return playerAnimCache[player.UserId]
    end
    
    -- Load from API
    local coreAnims = SimpleAnimate.getAnimPackageAsync(player)
    local emoteAnims = SimpleAnimate.getEmotePackageAsync(player)
    
    -- Cache for future use
    playerAnimCache[player.UserId] = {
        core = coreAnims,
        emotes = emoteAnims
    }
    
    return playerAnimCache[player.UserId]
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local anims = getPlayerAnimations(player)
        
        local controller = SimpleAnimate.new(
            character,
            true,
            anims.core,
            anims.emotes
        )
    end)
end)

-- Clear cache when player leaves
Players.PlayerRemoving:Connect(function(player)
    playerAnimCache[player.UserId] = nil
end)
```

## Validating Animation Packages

Check if animations loaded successfully:

```lua
local function validateAnimationPackage(anims, packageName)
    local requiredPoses = {"Idle", "Walk", "Run", "Jump"}
    
    for _, pose in requiredPoses do
        if not anims[pose] or #anims[pose] == 0 then
            warn(packageName, "missing", pose, "animation")
            return false
        end
    end
    
    return true
end

-- Usage
local coreAnims = SimpleAnimate.getAnimPackageAsync(player)

if validateAnimationPackage(coreAnims, "Core Animations") then
    print("Animation package valid")
else
    -- Use defaults instead
    coreAnims = SimpleAnimate.getCopyOfAnimsList("R15", "Animations")
end
```

## Overriding Specific Animations

### Keep Player Package, Override One Pose

```lua
local coreAnims = SimpleAnimate.getAnimPackageAsync(player)

-- Player has custom animations, but we want a special idle
coreAnims.Idle = {
    {
        id = "rbxassetid://SPECIAL_IDLE",
        weight = 10,
        speed = 0.8,
        fadeTime = 0.3
    }
}

local controller = SimpleAnimate.new(character, true, coreAnims)
```

### Blend Custom with Player Animations

```lua
local coreAnims = SimpleAnimate.getAnimPackageAsync(player)

-- Add variants to player's animations
table.insert(coreAnims.Idle, {
    id = "rbxassetid://EXTRA_IDLE_VARIANT",
    weight = 3, -- Lower weight = less common
    fadeTime = 0.3
})

-- Now player has their animations PLUS your variant
local controller = SimpleAnimate.new(character, true, coreAnims)
```

## Animation Package Metadata

Store and retrieve animation package information:

```lua
local AnimationPackages = {
    Stylish = {
        name = "Stylish",
        description = "Cool and modern animations",
        animations = {
            Idle = {{id = "rbxassetid://001", weight = 10}},
            Walk = {{id = "rbxassetid://002", weight = 10}},
            Run = {{id = "rbxassetid://003", weight = 10}}
        }
    },
    Classic = {
        name = "Classic",
        description = "Traditional Roblox animations",
        animations = SimpleAnimate.getCopyOfAnims("R15")
    }
}

local function applyPackage(player, packageName)
    local package = AnimationPackages[packageName]
    
    if not package then
        warn("Package not found:", packageName)
        return
    end
    
    player.CharacterAdded:Connect(function(character)
        local controller = SimpleAnimate.new(
            character,
            true,
            package.animations
        )
        
        print("Applied", package.name, "to", player.Name)
    end)
end

-- Usage
applyPackage(player, "Stylish")
```

## Dynamic Package Switching

Allow players to switch animation packages at runtime:

```lua
local currentControllers = {}

local function switchAnimationPackage(player, packageName)
    local character = player.Character
    if not character then return end
    
    -- Destroy old controller
    if currentControllers[player] then
        currentControllers[player]:Destroy()
    end
    
    -- Get new package
    local package = AnimationPackages[packageName]
    
    -- Create new controller
    local controller = SimpleAnimate.new(
        character,
        true,
        package.animations
    )
    
    currentControllers[player] = controller
    
    print(player.Name, "switched to", packageName)
end

-- Remote event for switching
local switchPackageRemote = game.ReplicatedStorage.SwitchAnimPackage

switchPackageRemote.OnServerEvent:Connect(function(player, packageName)
    switchAnimationPackage(player, packageName)
end)
```

## Error Handling

Robust error handling for animation package loading:

```lua
local function safeLoadAnimations(player)
    local success, coreAnims = pcall(function()
        return SimpleAnimate.getAnimPackageAsync(player)
    end)
    
    if not success then
        warn("Failed to load player animations:", coreAnims)
        -- Use defaults
        coreAnims = SimpleAnimate.getCopyOfAnimsList("R15", "Animations")
    end
    
    local success2, emoteAnims = pcall(function()
        return SimpleAnimate.getEmotePackageAsync(player)
    end)
    
    if not success2 then
        warn("Failed to load player emotes:", emoteAnims)
        emoteAnims = SimpleAnimate.getCopyOfAnimsList("R15", "Emotes")
    end
    
    return coreAnims, emoteAnims
end

-- Usage
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local coreAnims, emoteAnims = safeLoadAnimations(player)
        
        local controller = SimpleAnimate.new(
            character,
            true,
            coreAnims,
            emoteAnims
        )
    end)
end)
```

## Package Selection UI

Create a UI for players to choose animation packages:

```lua
-- Client Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.Parent = screenGui

-- List of packages
local packages = {"Default", "Stylish", "Athletic", "Ninja", "Robot"}

for i, packageName in packages do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 50)
    button.Position = UDim2.new(0, 10, 0, (i - 1) * 60 + 10)
    button.Text = packageName
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        -- Request package change
        ReplicatedStorage.SwitchAnimPackage:FireServer(packageName)
    end)
end
```

## Pre-Loading Animation Packages

Pre-load animation packages before character spawns:

```lua
local loadedPackages = {}

-- Pre-load all packages on server start
local function preLoadPackages()
    for name, package in AnimationPackages do
        print("Pre-loading package:", name)
        loadedPackages[name] = package.animations
    end
end

preLoadPackages()

-- Instant assignment when player spawns
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local packageName = player:GetAttribute("AnimPackage") or "Default"
        local anims = loadedPackages[packageName]
        
        local controller = SimpleAnimate.new(character, true, anims)
    end)
end)
```

## Best Practices

1. **Always provide fallbacks**: Handle cases where player animations fail to load
2. **Cache when possible**: Avoid repeated API calls for the same player
3. **Validate packages**: Check that required animations exist
4. **Handle errors gracefully**: Use pcall for API calls
5. **Test with different rigs**: Ensure compatibility with R6 and R15
6. **Consider performance**: Pre-load packages when possible
7. **Respect player choice**: Let players use their equipped animations when appropriate
8. **Provide options**: Give players ability to override with custom packages

## Common Issues

### Animations Not Loading

```lua
-- ❌ Problem: Server call without player parameter
local anims = SimpleAnimate.getAnimPackageAsync() -- Error on server!

-- ✅ Solution: Always pass player on server
local anims = SimpleAnimate.getAnimPackageAsync(player)
```

### Missing Animations

```lua
-- ❌ Problem: Not providing fallbacks
local anims = SimpleAnimate.getAnimPackageAsync(player)
-- Some poses might be missing

-- ✅ Solution: Provide fallbacks
local defaults = SimpleAnimate.getCopyOfAnims("R15")
local anims = SimpleAnimate.getAnimPackageAsync(player, defaults)
```

### Repeated Loading

```lua
-- ❌ Problem: Loading on every character spawn
player.CharacterAdded:Connect(function(character)
    local anims = SimpleAnimate.getAnimPackageAsync(player) -- Loads every time
end)

-- ✅ Solution: Cache the results
local playerAnims = SimpleAnimate.getAnimPackageAsync(player)

player.CharacterAdded:Connect(function(character)
    local controller = SimpleAnimate.new(character, true, playerAnims)
end)
```