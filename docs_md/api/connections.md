# Connections API

The Connections module handles humanoid event connections and automatic pose changes based on character state. It responds to movement, jumping, climbing, swimming, and other state changes.

**Access:** `controller.Core.Connections`

## Properties

### Configuration Properties

These properties control animation behavior and speed multipliers:

- `JumpDuration: number` - Duration before falling animation plays (default: `0.2`)
- `SwimIdleAnimationSpeed: number` - Speed for swim idle animation (default: `1`)
- `IdleAnimationSpeed: number` - Speed for idle animation (default: `1`)
- `RunThreshold: number` - Speed threshold between walk and run (default: `15.5`)
- `SwimIdleThreshold: number` - Speed threshold for swim idle vs swimming (default: `2`)
- `MoveAnimationSpeedMultiplier: number` - Multiplier for walk/run animations (default: `1`)
- `ClimbAnimationSpeedMultiplier: number` - Multiplier for climb animations (default: `1`)
- `SwimAnimationSpeedMultiplier: number` - Multiplier for swim animations (default: `1`)
- `WalkSpeed: number` - Reference walk speed (default: humanoid's WalkSpeed)
- `AutoAdjustSpeedMultipliers: boolean` - Automatically adjust multipliers based on WalkSpeed (default: `true`)
- `UseWalkSpeedForAnimSpeed: boolean` - Use WalkSpeed for animation speed calculations (default: `true`)

## Examples

### Adjusting Run Threshold

Control when the character switches from walking to running:

```luau
-- Default is 15.5, lower value = switches to run earlier
controller.Core.Connections.RunThreshold = 10

-- Now character will run at speeds above 10
```

### Custom Animation Speeds

```luau
-- Make idle animation slower for dramatic effect
controller.Core.Connections.IdleAnimationSpeed = 0.7

-- Make running animation faster
controller.Core.Connections.MoveAnimationSpeedMultiplier = 1.5
```

### Adjusting Jump Timing

```luau
-- Make character fall faster (shorter jump animation)
controller.Core.Connections.JumpDuration = 0.1

-- Make character stay in jump animation longer
controller.Core.Connections.JumpDuration = 0.5
```

### Manual Speed Multipliers

Disable auto-adjustment and set custom multipliers:

```luau
local connections = controller.Core.Connections

-- Disable automatic adjustment
connections.AutoAdjustSpeedMultipliers = false

-- Set custom multipliers
connections.MoveAnimationSpeedMultiplier = 2.0   -- Walk/run at 2x speed
connections.ClimbAnimationSpeedMultiplier = 1.5  -- Climb at 1.5x speed
connections.SwimAnimationSpeedMultiplier = 0.8   -- Swim at 0.8x speed
```

### Swimming Configuration

```luau
local connections = controller.Core.Connections

-- Adjust swim idle threshold
connections.SwimIdleThreshold = 3 -- Idle when speed < 3

-- Adjust swim idle animation speed
connections.SwimIdleAnimationSpeed = 0.5 -- Slower treading water

-- Adjust swimming animation speed
connections.SwimAnimationSpeedMultiplier = 1.2
```

### Speed-Based Animation System

Create a system where animation speed matches character speed:

```luau
local connections = controller.Core.Connections

-- Enable speed-based animation
connections.UseWalkSpeedForAnimSpeed = true
connections.AutoAdjustSpeedMultipliers = true

-- Update walk speed reference
local humanoid = character:FindFirstChildWhichIsA("Humanoid")

humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    connections.WalkSpeed = humanoid.WalkSpeed
end)
```

### Custom Speed Zones

Create areas with different animation behaviors:

```luau
local connections = controller.Core.Connections

local slowZone = workspace.SlowZone
local fastZone = workspace.FastZone

slowZone.Touched:Connect(function(hit)
    if hit.Parent == character then
        -- Slow down animations in this zone
        connections.MoveAnimationSpeedMultiplier = 0.5
        connections.ClimbAnimationSpeedMultiplier = 0.5
    end
end)

fastZone.Touched:Connect(function(hit)
    if hit.Parent == character then
        -- Speed up animations in this zone
        connections.MoveAnimationSpeedMultiplier = 2.0
        connections.ClimbAnimationSpeedMultiplier = 2.0
    end
end)
```

### Dynamic Animation Speed

Adjust animation speed based on game state:

```luau
local connections = controller.Core.Connections

-- Normal mode
local function setNormalSpeed()
    connections.MoveAnimationSpeedMultiplier = 1.0
    connections.IdleAnimationSpeed = 1.0
end

-- Combat mode - faster, more alert animations
local function setCombatSpeed()
    connections.MoveAnimationSpeedMultiplier = 1.3
    connections.IdleAnimationSpeed = 1.2
end

-- Exhausted mode - slower animations
local function setExhaustedSpeed()
    connections.MoveAnimationSpeedMultiplier = 0.7
    connections.IdleAnimationSpeed = 0.8
end

-- Switch modes based on stamina
local stamina = 100

game:GetService("RunService").Heartbeat:Connect(function()
    if stamina > 50 then
        setNormalSpeed()
    elseif stamina > 20 then
        setCombatSpeed()
    else
        setExhaustedSpeed()
    end
end)
```

### Disable Auto-Speed Adjustment

For more control, disable automatic speed calculations:

```luau
local connections = controller.Core.Connections

-- Disable auto-adjustment
connections.AutoAdjustSpeedMultipliers = false
connections.UseWalkSpeedForAnimSpeed = false

-- Now multipliers won't change automatically
-- Set them manually as needed
connections.MoveAnimationSpeedMultiplier = 1.5
```

### Custom Thresholds for Different Characters

```luau
-- Heavy character - slower threshold
local heavyConnections = heavyController.Core.Connections
heavyConnections.RunThreshold = 12
heavyConnections.MoveAnimationSpeedMultiplier = 0.8

-- Light character - faster threshold  
local lightConnections = lightController.Core.Connections
lightConnections.RunThreshold = 18
lightConnections.MoveAnimationSpeedMultiplier = 1.2
```

### Monitoring Animation State

```luau
local connections = controller.Core.Connections

-- Check current settings
print("Run Threshold:", connections.RunThreshold)
print("Move Speed Multiplier:", connections.MoveAnimationSpeedMultiplier)
print("Auto Adjust:", connections.AutoAdjustSpeedMultipliers)

-- Monitor changes
task.spawn(function()
    while true do
        task.wait(1)
        print("Current speed multiplier:", connections.MoveAnimationSpeedMultiplier)
    end
end)
```

### Complete Movement System

A comprehensive example combining multiple settings:

```luau
local connections = controller.Core.Connections

-- Configure all movement settings
connections.RunThreshold = 14
connections.SwimIdleThreshold = 2.5
connections.JumpDuration = 0.25

-- Configure animation speeds
connections.IdleAnimationSpeed = 1.0
connections.SwimIdleAnimationSpeed = 0.8

-- Configure multipliers
connections.AutoAdjustSpeedMultipliers = true
connections.UseWalkSpeedForAnimSpeed = true

-- Set base walk speed
connections.WalkSpeed = character.Humanoid.WalkSpeed

-- Create speed boost power-up
local function applySpeedBoost(duration)
    local originalMultiplier = connections.MoveAnimationSpeedMultiplier
    
    connections.MoveAnimationSpeedMultiplier = 2.0
    connections.AutoAdjustSpeedMultipliers = false
    
    task.delay(duration, function()
        connections.MoveAnimationSpeedMultiplier = originalMultiplier
        connections.AutoAdjustSpeedMultipliers = true
    end)
end

-- Use it
applySpeedBoost(5) -- 5 second speed boost
```

## Notes

- The Connections module automatically updates itself based on humanoid events
- Most users won't need to modify these properties unless they want custom animation behavior
- Changes to these properties take effect immediately
- `AutoAdjustSpeedMultipliers` recalculates multipliers every frame based on WalkSpeed
- Setting `AutoAdjustSpeedMultipliers` to `false` gives you full manual control