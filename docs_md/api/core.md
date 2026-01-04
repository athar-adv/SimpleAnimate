# Core API

The Core module manages core character animations and automatic behavior in response to humanoid state changes. It consists of two main components: PoseController and Connections.

**Access:** `controller.Core`

## Overview

The Core system handles:
- Automatic animation playback based on character movement
- Pose transitions (idle, walk, run, jump, etc.)
- Animation speed adjustments based on movement speed
- State machine event handling
- Customizable animation behavior

## Properties

### `PoseController`

The pose controller manages animation playback and pose transitions.

**Type:** `PoseController`

**Purpose:** Controls which animations play based on the character's current state/pose

**See:** [PoseController API](./pose-controller.md)

**Examples:**

Get current pose:
```luau
local core = controller.Core
local pose = core.PoseController:GetPose()
print("Current pose:", pose) -- "Idle", "Walk", "Run", etc.
```

Change pose manually:
```luau
core.PoseController:ChangePose("Idle")
```

Listen for pose changes:
```luau
core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    print(string.format("Changed from %s to %s", oldPose, newPose))
    print("Animation ID:", track.Animation.AnimationId)
end)
```

---

### `Connections`

Manages humanoid event connections and animation behavior settings.

**Type:** `Connections`

**Purpose:** Handles automatic pose changes based on humanoid events (running, jumping, etc.) and provides configuration options for animation behavior

**See:** [Connections API](./connections.md)

**Examples:**

Configure run threshold:
```luau
local core = controller.Core

-- Character runs at speeds above 12
core.Connections.RunThreshold = 12
```

Adjust animation speeds:
```luau
-- Make all animations play faster
core.Connections.MoveAnimationSpeedMultiplier = 1.5

-- Make climbing animations slower
core.Connections.ClimbAnimationSpeedMultiplier = 0.7
```

Configure jump timing:
```luau
-- Stay in jump animation longer before falling
core.Connections.JumpDuration = 0.3
```

## Methods

### `:Destroy()`

Destroys the Core instance and cleans up resources.

**Signature:**
```luau
function Destroy(): ()
```

**Behavior:**
- Destroys the PoseController
- Destroys the Connections module
- Disconnects all event connections
- Cleans up all references

**Note:** This is automatically called when the AnimationController is destroyed. You should not need to call this directly.

## Complete Examples

### Basic Core Usage

```luau
local controller = SimpleAnimate.new(character)
local core = controller.Core

-- Get current state
local pose = core.PoseController:GetPose()
local track = core.PoseController:GetCurrentTrack()
local isActive = core.PoseController:GetCoreActive()

print("Pose:", pose)
print("Animation:", track.Animation.AnimationId)
print("Active:", isActive)

-- Configure behavior
core.Connections.RunThreshold = 15
core.Connections.MoveAnimationSpeedMultiplier = 1.2
```

### Monitoring Character State

```luau
local core = controller.Core

-- Monitor pose changes
core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    print(string.format("[%s] %s -> %s", 
        os.date("%X"), oldPose, newPose))
end)

-- Get current state every second
while true do
    task.wait(1)
    
    local pose = core.PoseController:GetPose()
    local track = core.PoseController:GetCurrentTrack()
    
    print(string.format("State: %s (Speed: %.2f)", pose, track.Speed))
end
```

### Custom Movement Behavior

```luau
local core = controller.Core

-- Configure for heavy character
core.Connections.RunThreshold = 12  -- Runs at lower speed
core.Connections.MoveAnimationSpeedMultiplier = 0.8  -- Slower animations
core.Connections.ClimbAnimationSpeedMultiplier = 0.6  -- Much slower climbing
core.Connections.JumpDuration = 0.15  -- Shorter jump

-- Configure animation speeds
core.Connections.IdleAnimationSpeed = 0.9
core.Connections.SwimIdleAnimationSpeed = 0.7
```

### Dynamic Speed Adjustment

```luau
local core = controller.Core
local humanoid = character:FindFirstChildWhichIsA("Humanoid")

-- Adjust animations based on health
humanoid.HealthChanged:Connect(function(health)
    local healthPercent = health / humanoid.MaxHealth
    
    if healthPercent > 0.7 then
        -- Healthy: Normal speed
        core.Connections.MoveAnimationSpeedMultiplier = 1.0
        core.Connections.RunThreshold = 15
    elseif healthPercent > 0.3 then
        -- Injured: Slower
        core.Connections.MoveAnimationSpeedMultiplier = 0.7
        core.Connections.RunThreshold = 12
    else
        -- Critical: Very slow
        core.Connections.MoveAnimationSpeedMultiplier = 0.5
        core.Connections.RunThreshold = 10
    end
end)
```

### Temporary Animation Override

```luau
local core = controller.Core

-- Save original settings
local originalRunThreshold = core.Connections.RunThreshold
local originalSpeedMult = core.Connections.MoveAnimationSpeedMultiplier

-- Apply temporary boost
local function applySpeedBoost(duration)
    -- Stop core animations temporarily
    core.PoseController:SetCoreActive(false)
    core.PoseController:StopCoreAnimations(0.1)
    
    -- Play boost animation
    local boostAnim = animator:LoadAnimation(boostAnimation)
    boostAnim:Play()
    
    task.wait(0.5)
    
    -- Resume with boosted settings
    core.PoseController:SetCoreActive(true)
    core.Connections.RunThreshold = 20
    core.Connections.MoveAnimationSpeedMultiplier = 2.0
    
    -- Restore after duration
    task.delay(duration, function()
        core.Connections.RunThreshold = originalRunThreshold
        core.Connections.MoveAnimationSpeedMultiplier = originalSpeedMult
    end)
end

applySpeedBoost(5) -- 5 second boost
```

### Conditional Animation System

```luau
local core = controller.Core

-- Different settings for different areas
local zones = {
    Normal = {
        RunThreshold = 15,
        SpeedMult = 1.0
    },
    SlowZone = {
        RunThreshold = 10,
        SpeedMult = 0.6
    },
    FastZone = {
        RunThreshold = 20,
        SpeedMult = 1.5
    }
}

local function enterZone(zoneName)
    local settings = zones[zoneName]
    if not settings then return end
    
    core.Connections.RunThreshold = settings.RunThreshold
    core.Connections.MoveAnimationSpeedMultiplier = settings.SpeedMult
    
    print("Entered", zoneName)
end

-- Detect zones
local currentZone = "Normal"

workspace.SlowZone.Touched:Connect(function(hit)
    if hit.Parent == character then
        enterZone("SlowZone")
    end
end)

workspace.FastZone.Touched:Connect(function(hit)
    if hit.Parent == character then
        enterZone("FastZone")
    end
end)
```

### State-Based Animation Control

```luau
local core = controller.Core

-- Game states
local states = {
    Exploring = {
        active = true,
        runThreshold = 15,
        speedMult = 1.0
    },
    Combat = {
        active = true,
        runThreshold = 12,
        speedMult = 1.2
    },
    Cutscene = {
        active = false,  -- Disable core animations
        runThreshold = 0,
        speedMult = 0
    },
    Stunned = {
        active = false,
        runThreshold = 0,
        speedMult = 0
    }
}

local function setState(stateName)
    local state = states[stateName]
    if not state then return end
    
    -- Apply state settings
    core.PoseController:SetCoreActive(state.active)
    core.Connections.RunThreshold = state.runThreshold
    core.Connections.MoveAnimationSpeedMultiplier = state.speedMult
    
    -- Stop animations if not active
    if not state.active then
        core.PoseController:StopCoreAnimations(0.2)
    end
    
    print("State changed to:", stateName)
end

-- Usage
setState("Exploring")  -- Normal gameplay
setState("Combat")     -- Combat mode
setState("Cutscene")   -- During cutscene
setState("Stunned")    -- Character stunned
```

### Pose-Specific Behavior

```luau
local core = controller.Core

-- Track time in each pose
local poseTimers = {}

core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    -- Record time entering pose
    poseTimers[newPose] = tick()
    
    -- Special behavior for specific poses
    if newPose == "Jumping" then
        print("Character jumped!")
        -- Play jump sound, create particle effect, etc.
        
    elseif newPose == "Freefall" then
        print("Character is falling!")
        -- Start fall damage calculation
        
    elseif newPose == "Landed" then
        print("Character landed!")
        
        -- Calculate fall time
        local fallTime = tick() - (poseTimers.Freefall or tick())
        if fallTime > 1 then
            print("Long fall! Time:", fallTime)
            -- Apply fall damage, dust effect, etc.
        end
        
    elseif newPose == "Swimming" then
        print("Character entered water!")
        -- Play splash effect
        
    elseif newPose == "Climbing" then
        print("Character started climbing!")
        -- Play climb sound
    end
end)
```

### Animation Speed Based on Status

```luau
local core = controller.Core
local statusEffects = {}

-- Status effect system
local function addStatusEffect(effectName, settings)
    statusEffects[effectName] = settings
    updateAnimationSpeed()
end

local function removeStatusEffect(effectName)
    statusEffects[effectName] = nil
    updateAnimationSpeed()
end

function updateAnimationSpeed()
    local totalSpeedMult = 1.0
    local totalThresholdMult = 1.0
    
    -- Apply all active status effects
    for _, effect in statusEffects do
        totalSpeedMult = totalSpeedMult * effect.speedMult
        totalThresholdMult = totalThresholdMult * effect.thresholdMult
    end
    
    -- Apply to core
    core.Connections.MoveAnimationSpeedMultiplier = totalSpeedMult
    core.Connections.RunThreshold = 15 * totalThresholdMult
    
    print(string.format("Speed: %.2fx, Threshold: %.1f", 
        totalSpeedMult, core.Connections.RunThreshold))
end

-- Usage
addStatusEffect("SpeedBoost", {speedMult = 1.5, thresholdMult = 1.2})
addStatusEffect("Slow", {speedMult = 0.6, thresholdMult = 0.8})

task.delay(5, function()
    removeStatusEffect("SpeedBoost")
end)
```

### Swimming System Integration

```luau
local core = controller.Core

-- Custom swimming configuration
core.Connections.SwimIdleThreshold = 2.5
core.Connections.SwimIdleAnimationSpeed = 0.8
core.Connections.SwimAnimationSpeedMultiplier = 1.1

-- Monitor swimming state
local inWater = false

core.PoseController.PoseChanged:Connect(function(oldPose, newPose)
    if newPose == "Swimming" or newPose == "SwimIdle" then
        if not inWater then
            inWater = true
            print("Entered water")
            
            -- Play splash effect
            local splash = splashEffect:Clone()
            splash.Parent = character.HumanoidRootPart
            splash:Emit(20)
            
            -- Play splash sound
            local sound = splashSound:Clone()
            sound.Parent = character.HumanoidRootPart
            sound:Play()
        end
    else
        if inWater then
            inWater = false
            print("Exited water")
            
            -- Play exit splash
        end
    end
end)
```

### Performance Monitoring

```luau
local core = controller.Core
local RunService = game:GetService("RunService")

-- Track animation performance
local animStats = {
    poseChanges = 0,
    lastPoseChange = 0,
    averageFPS = 60
}

core.PoseController.PoseChanged:Connect(function()
    animStats.poseChanges = animStats.poseChanges + 1
    animStats.lastPoseChange = tick()
end)

-- Monitor performance
RunService.Heartbeat:Connect(function()
    animStats.averageFPS = 1 / RunService.Heartbeat:Wait()
    
    -- If performance is poor, reduce animation quality
    if animStats.averageFPS < 30 then
        core.Connections.MoveAnimationSpeedMultiplier = 0.5
        warn("Low FPS, reducing animation quality")
    end
end)

-- Print stats
task.spawn(function()
    while true do
        task.wait(5)
        print("Animation Stats:")
        print("  Pose Changes:", animStats.poseChanges)
        print("  Last Change:", tick() - animStats.lastPoseChange, "seconds ago")
        print("  Average FPS:", math.floor(animStats.averageFPS))
    end
end)
```

### Character Class System

```luau
local core = controller.Core

-- Define character classes
local classes = {
    Warrior = {
        runThreshold = 14,
        speedMult = 1.0,
        jumpDuration = 0.2
    },
    Rogue = {
        runThreshold = 16,
        speedMult = 1.3,
        jumpDuration = 0.25
    },
    Mage = {
        runThreshold = 13,
        speedMult = 0.9,
        jumpDuration = 0.18
    },
    Tank = {
        runThreshold = 12,
        speedMult = 0.7,
        jumpDuration = 0.15
    }
}

local function applyClass(className)
    local class = classes[className]
    if not class then return end
    
    core.Connections.RunThreshold = class.runThreshold
    core.Connections.MoveAnimationSpeedMultiplier = class.speedMult
    core.Connections.JumpDuration = class.jumpDuration
    
    print("Applied class:", className)
end

-- Usage
local playerClass = player:GetAttribute("Class") or "Warrior"
applyClass(playerClass)
```

## Best Practices

1. **Access through controller**: Always access Core via `controller.Core`
2. **Configure once**: Set Connections properties during initialization
3. **Monitor pose changes**: Use PoseChanged event for state-dependent behavior
4. **Don't over-configure**: Default settings work well for most cases
5. **Test thoroughly**: Animation timing affects gameplay feel
6. **Consider performance**: Frequent configuration changes can impact performance
7. **Use meaningful values**: Base thresholds and multipliers on game design needs

## Common Use Cases

- **Heavy character**: Lower RunThreshold, slower SpeedMult
- **Fast character**: Higher RunThreshold, faster SpeedMult
- **Injured state**: Reduce SpeedMult, lower RunThreshold
- **Speed boost**: Temporarily increase SpeedMult
- **Cutscenes**: Disable core animations with SetCoreActive(false)
- **Swimming areas**: Configure swim thresholds and speeds
- **Climbing challenges**: Adjust climb animation speed

## Related APIs

- [PoseController API](./pose-controller.md) - Detailed pose control
- [Connections API](./connections.md) - Configuration options
- [AnimationController API](./animation-controller.md) - Main controller