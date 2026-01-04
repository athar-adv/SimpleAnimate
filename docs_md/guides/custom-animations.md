# Custom Animations Guide

This guide covers how to use custom animations with SimpleAnimate.

## Animation Info Structure

All animations in SimpleAnimate are defined using the `AnimInfo` structure:

```lua
{
    id = "rbxassetid://123456789", -- Animation asset ID
    weight = 10,                    -- Selection weight (default: 10)
    speed = 1,                      -- Playback speed (default: 1)
    fadeTime = 0.1,                 -- Fade in time (default: 0.1)
    stopFadeTime = 0.1             -- Fade out time (optional)
}
```

## Creating Custom Core Animations

### Method 1: Modify Default Animations

Start with default animations and modify them:

```lua
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Get a copy of R15 animations
local coreAnims, emoteAnims = SimpleAnimate.getCopyOfAnims("R15")

-- Replace idle animation
coreAnims.Idle = {
    {
        id = "rbxassetid://YOUR_IDLE_ANIM",
        weight = 10,
        fadeTime = 0.2
    }
}

-- Replace walk animation
coreAnims.Walk = {
    {
        id = "rbxassetid://YOUR_WALK_ANIM",
        weight = 10
    }
}

-- Create controller with custom animations
local controller = SimpleAnimate.new(character, true, coreAnims, emoteAnims)
```

### Method 2: Build From Scratch

Create a complete animation set from scratch:

```lua
local customCoreAnims = {
    Idle = {
        {id = "rbxassetid://123", weight = 10, fadeTime = 0.1}
    },
    Walk = {
        {id = "rbxassetid://124", weight = 10}
    },
    Run = {
        {id = "rbxassetid://125", weight = 10}
    },
    Jump = {
        {id = "rbxassetid://126", weight = 10}
    },
    Fall = {
        {id = "rbxassetid://127", weight = 10}
    },
    Climb = {
        {id = "rbxassetid://128", weight = 10}
    },
    Sit = {
        {id = "rbxassetid://129", weight = 10}
    }
}

local controller = SimpleAnimate.new(character, true, customCoreAnims)
```

## Multiple Animation Variants

Add multiple variants of the same animation with different weights:

```lua
local coreAnims = SimpleAnimate.getCopyOfAnims("R15")

-- Multiple idle animations
coreAnims.Idle = {
    {
        id = "rbxassetid://IDLE_1",
        weight = 10,  -- Common idle
        fadeTime = 0.2
    },
    {
        id = "rbxassetid://IDLE_2",
        weight = 3,   -- Rare idle (stretching)
        fadeTime = 0.3
    },
    {
        id = "rbxassetid://IDLE_3",
        weight = 2,   -- Very rare idle (looking around)
        fadeTime = 0.3
    }
}

-- Multiple run animations
coreAnims.Run = {
    {
        id = "rbxassetid://RUN_NORMAL",
        weight = 10,
        speed = 1.0
    },
    {
        id = "rbxassetid://RUN_URGENT",
        weight = 5,
        speed = 1.2
    }
}
```

## Animation Speed Control

Control playback speed for different effects:

```lua
local coreAnims = SimpleAnimate.getCopyOfAnims("R15")

-- Slow idle for tired character
coreAnims.Idle[1].speed = 0.7

-- Fast run for energetic character
coreAnims.Run[1].speed = 1.3

-- Slow climb for heavy character
coreAnims.Climb[1].speed = 0.8
```

## Fade Time Customization

Control how animations blend together:

```lua
local coreAnims = SimpleAnimate.getCopyOfAnims("R15")

-- Quick transition for responsive movement
coreAnims.Walk[1].fadeTime = 0.05

-- Smooth transition for idle
coreAnims.Idle[1].fadeTime = 0.3
coreAnims.Idle[1].stopFadeTime = 0.3

-- Instant jump
coreAnims.Jump[1].fadeTime = 0
```

## Runtime Animation Changes

Change animations while the game is running:

```lua
-- Change a single animation
controller.Core.PoseController:ChangeCoreAnim(
    "Idle",
    1,
    "rbxassetid://NEW_IDLE_ANIM"
)

-- The new animation will play immediately if character is idle
```

Change with AnimInfo for more control:

```luau
controller.Core.PoseController:ChangeCoreAnim(
    "Run",
    1,
    {
        id = "rbxassetid://NEW_RUN",
        weight = 10,
        speed = 1.2,
        fadeTime = 0.1
    }
)
```

## Character-Specific Animations

Different animations for different character types:

```lua
local function getAnimationsForCharacter(characterType)
    if characterType == "Warrior" then
        return {
            Idle = {{id = "rbxassetid://WARRIOR_IDLE", weight = 10}},
            Walk = {{id = "rbxassetid://WARRIOR_WALK", weight = 10}},
            Run = {{id = "rbxassetid://WARRIOR_RUN", weight = 10}}
        }
    elseif characterType == "Mage" then
        return {
            Idle = {{id = "rbxassetid://MAGE_IDLE", weight = 10}},
            Walk = {{id = "rbxassetid://MAGE_WALK", weight = 10}},
            Run = {{id = "rbxassetid://MAGE_RUN", weight = 10}}
        }
    else
        return SimpleAnimate.getCopyOfAnims("R15")
    end
end

-- Usage
local characterType = player:GetAttribute("CharacterType")
local anims = getAnimationsForCharacter(characterType)
local controller = SimpleAnimate.new(character, true, anims)
```

## Conditional Animation System

Change animations based on game state:

```luau
local controller = SimpleAnimate.new(character)

-- Normal animations
local normalAnims = {
    Idle = {{id = "rbxassetid://NORMAL_IDLE", weight = 10}},
    Walk = {{id = "rbxassetid://NORMAL_WALK", weight = 10}}
}

-- Combat animations
local combatAnims = {
    Idle = {{id = "rbxassetid://COMBAT_IDLE", weight = 10}},
    Walk = {{id = "rbxassetid://COMBAT_WALK", weight = 10}}
}

-- Switch to combat mode
local function enterCombat()
    for pose, anims in combatAnims do
        controller.Core.PoseController:ChangeCoreAnim(pose, 1, anims[1])
    end
end

-- Switch to normal mode
local function exitCombat()
    for pose, anims in normalAnims do
        controller.Core.PoseController:ChangeCoreAnim(pose, 1, anims[1])
    end
end

-- Use in game
player:GetAttributeChangedSignal("InCombat"):Connect(function()
    if player:GetAttribute("InCombat") then
        enterCombat()
    else
        exitCombat()
    end
end)
```

## Animation Sets System

Create a reusable animation sets system:

```luau
local AnimationSets = {}

AnimationSets.Default = SimpleAnimate.getCopyOfAnims("R15")

AnimationSets.Zombie = {
    Idle = {{id = "rbxassetid://ZOMBIE_IDLE", weight = 10, speed = 0.7}},
    Walk = {{id = "rbxassetid://ZOMBIE_WALK", weight = 10, speed = 0.6}},
    Run = {{id = "rbxassetid://ZOMBIE_RUN", weight = 10, speed = 0.8}}
}

AnimationSets.Robot = {
    Idle = {{id = "rbxassetid://ROBOT_IDLE", weight = 10}},
    Walk = {{id = "rbxassetid://ROBOT_WALK", weight = 10, speed = 1.1}},
    Run = {{id = "rbxassetid://ROBOT_RUN", weight = 10, speed = 1.2}}
}

-- Apply animation set
local function applyAnimationSet(controller, setName)
    local animSet = AnimationSets[setName]
    
    for pose, anims in animSet do
        controller.Core.PoseController:ChangeCoreAnim(pose, 1, anims[1])
    end
end

-- Usage
local controller = SimpleAnimate.new(character)
applyAnimationSet(controller, "Zombie")
```

## Mixing Player and Custom Animations

Use player's animations but override specific poses:

```luau
-- Get player's animations
local playerAnims = SimpleAnimate.getAnimPackageAsync(player)

-- Override specific animations with custom ones
playerAnims.Idle = {
    {id = "rbxassetid://CUSTOM_IDLE", weight = 10}
}

playerAnims.Run = {
    {id = "rbxassetid://CUSTOM_RUN", weight = 10}
}

-- Create controller with mixed animations
local controller = SimpleAnimate.new(character, true, playerAnims)
```

## Animation Preloading

Control when animations are loaded:

```luau
-- Preload immediately (default)
local controller1 = SimpleAnimate.new(character, true, customAnims)

-- Don't preload (load on-demand)
local controller2 = SimpleAnimate.new(character, false, customAnims)

-- Manual preloading
local animator = character:FindFirstChildWhichIsA("Animator", true)
local preloadedAnims = SimpleAnimate.Preload.preloadAnimList(
    animator,
    customAnims,
    "core",
    Enum.AnimationPriority.Core,
    true
)

local controller3 = SimpleAnimate.new(character, false, preloadedAnims)
```

## Best Practices

1. **Always provide fallbacks**: Include all required poses even if using defaults
2. **Test weight distributions**: Higher weights = more frequent selection
3. **Consider fade times**: Smooth transitions improve animation quality
4. **Use appropriate speeds**: Match animation speed to character movement
5. **Organize animation IDs**: Keep animation IDs in a centralized configuration
6. **Test variants**: Multiple animation variants add life to characters
7. **Profile performance**: Too many variants can impact performance

## Example: Complete Custom System

```luau
local AnimationConfig = {
    HeavyWarrior = {
        Idle = {
            {id = "rbxassetid://001", weight = 10, speed = 0.8, fadeTime = 0.3}
        },
        Walk = {
            {id = "rbxassetid://002", weight = 10, speed = 0.9}
        },
        Run = {
            {id = "rbxassetid://003", weight = 10, speed = 0.85}
        },
        Jump = {
            {id = "rbxassetid://004", weight = 10, speed = 0.7}
        }
    },
    LightRogue = {
        Idle = {
            {id = "rbxassetid://101", weight = 8, speed = 1.1},
            {id = "rbxassetid://102", weight = 2, speed = 1.0} -- Rare variant
        },
        Walk = {
            {id = "rbxassetid://103", weight = 10, speed = 1.2}
        },
        Run = {
            {id = "rbxassetid://104", weight = 10, speed = 1.3}
        },
        Jump = {
            {id = "rbxassetid://105", weight = 10, speed = 1.2}
        }
    }
}

-- Create character with appropriate animations
local function createCharacter(player, class)
    player.CharacterAdded:Connect(function(character)
        local anims = AnimationConfig[class]
        local controller = SimpleAnimate.new(character, true, anims)
        
        print(player.Name, "loaded as", class)
    end)
end

createCharacter(player, "HeavyWarrior")
```