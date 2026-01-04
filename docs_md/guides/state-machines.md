# State Machines Guide

This guide covers how to use custom state machines with SimpleAnimate instead of the default Humanoid.

## What is a State Machine?

A state machine in SimpleAnimate is any object that provides the same events and properties as a Humanoid:

- `Running` event
- `Jumping` event  
- `Climbing` event
- `Swimming` event
- `StateChanged` event
- `WalkSpeed` property

By default, SimpleAnimate uses the character's Humanoid, but you can provide a custom state machine for:
- Custom character controllers
- Non-humanoid characters
- Special movement systems
- Network-replicated animation states

## Required Interface

Your custom state machine must implement:

```lua
type StateMachine = {
    Running: RBXScriptSignal<number>,      -- Fires with speed
    Jumping: RBXScriptSignal<()>,          -- Fires on jump
    Climbing: RBXScriptSignal<number>,     -- Fires with climb speed
    Swimming: RBXScriptSignal<number>,     -- Fires with swim speed
    StateChanged: RBXScriptSignal<Enum.HumanoidStateType, Enum.HumanoidStateType>,
    WalkSpeed: number
}
```

## Basic Custom State Machine

### Simple Implementation

```lua
local Signal = require(game.ReplicatedStorage.Signal) -- Use any signal library

local CustomStateMachine = {}
CustomStateMachine.__index = CustomStateMachine

function CustomStateMachine.new()
    local self = setmetatable({}, CustomStateMachine)
    
    -- Create signals
    self.Running = Signal.new()
    self.Jumping = Signal.new()
    self.Climbing = Signal.new()
    self.Swimming = Signal.new()
    self.StateChanged = Signal.new()
    
    -- Properties
    self.WalkSpeed = 16
    self._currentState = Enum.HumanoidStateType.Running
    
    return self
end

function CustomStateMachine:SetState(newState)
    local oldState = self._currentState
    self._currentState = newState
    self.StateChanged:Fire(oldState, newState)
end

function CustomStateMachine:FireRunning(speed)
    self.Running:Fire(speed)
end

function CustomStateMachine:FireJumping()
    self.Jumping:Fire()
end

return CustomStateMachine
```

### Using with SimpleAnimate

```lua
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)
local CustomStateMachine = require(game.ReplicatedStorage.CustomStateMachine)

-- Create custom state machine
local stateMachine = CustomStateMachine.new()

-- Create controller with custom state machine
local controller = SimpleAnimate.new(
    character,
    true,
    nil,
    nil,
    stateMachine
)

-- Now control animations through your state machine
stateMachine:FireRunning(10) -- Triggers walk animation
stateMachine:FireRunning(20) -- Triggers run animation
stateMachine:FireJumping()   -- Triggers jump animation
```

## Vehicle State Machine

Control character animations while in a vehicle:

```lua
local VehicleStateMachine = {}
VehicleStateMachine.__index = VehicleStateMachine

function VehicleStateMachine.new(vehicle)
    local self = setmetatable({}, VehicleStateMachine)
    
    self.Running = Signal.new()
    self.Jumping = Signal.new()
    self.Climbing = Signal.new()
    self.Swimming = Signal.new()
    self.StateChanged = Signal.new()
    
    self.WalkSpeed = 0
    self._vehicle = vehicle
    self._currentState = Enum.HumanoidStateType.Seated
    
    -- Monitor vehicle speed
    game:GetService("RunService").Heartbeat:Connect(function()
        local velocity = vehicle.AssemblyLinearVelocity
        local speed = velocity.Magnitude
        
        -- Map vehicle speed to animation speed
        if speed > 5 then
            self.Running:Fire(speed)
        else
            self.Running:Fire(0)
        end
    end)
    
    return self
end

return VehicleStateMachine
```

Usage:

```lua
-- When player enters vehicle
local vehicleStateMachine = VehicleStateMachine.new(vehicle)

-- Create controller with vehicle state machine
local controller = SimpleAnimate.new(
    character,
    true,
    drivingAnimations, -- Custom driving animations
    nil,
    vehicleStateMachine
)

-- Animations now respond to vehicle movement
```

## Network-Replicated State Machine

Synchronize animation states across server and clients:

```lua
local ReplicatedStateMachine = {}
ReplicatedStateMachine.__index = ReplicatedStateMachine

function ReplicatedStateMachine.new(character)
    local self = setmetatable({}, ReplicatedStateMachine)
    
    self.Running = Signal.new()
    self.Jumping = Signal.new()
    self.Climbing = Signal.new()
    self.Swimming = Signal.new()
    self.StateChanged = Signal.new()
    
    self.WalkSpeed = 16
    
    -- Create remote events for replication
    local remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "AnimationStates"
    remoteFolder.Parent = character
    
    local runningRemote = Instance.new("RemoteEvent")
    runningRemote.Name = "Running"
    runningRemote.Parent = remoteFolder
    
    local jumpingRemote = Instance.new("RemoteEvent")
    jumpingRemote.Name = "Jumping"
    jumpingRemote.Parent = remoteFolder
    
    -- Server: Fire to clients
    if game:GetService("RunService"):IsServer() then
        self.Running:Connect(function(speed)
            runningRemote:FireAllClients(speed)
        end)
        
        self.Jumping:Connect(function()
            jumpingRemote:FireAllClients()
        end)
    end
    
    -- Client: Listen from server
    if game:GetService("RunService"):IsClient() then
        runningRemote.OnClientEvent:Connect(function(speed)
            self.Running:Fire(speed)
        end)
        
        jumpingRemote.OnClientEvent:Connect(function()
            self.Jumping:Fire()
        end)
    end
    
    return self
end

return ReplicatedStateMachine
```

## Custom Movement Controller

Integrate with a custom character controller:

```lua
local CustomController = {}
CustomController.__index = CustomController

function CustomController.new(character)
    local self = setmetatable({}, CustomController)
    
    self.Character = character
    self.StateMachine = {
        Running = Signal.new(),
        Jumping = Signal.new(),
        Climbing = Signal.new(),
        Swimming = Signal.new(),
        StateChanged = Signal.new(),
        WalkSpeed = 16
    }
    
    self._velocity = Vector3.zero
    self._isJumping = false
    
    return self
end

function CustomController:Update(dt)
    -- Custom movement logic
    local moveDirection = self:GetMoveDirection()
    self._velocity = moveDirection * self.StateMachine.WalkSpeed
    
    -- Update character position
    local hrp = self.Character.HumanoidRootPart
    hrp.CFrame += self._velocity * dt
    
    -- Fire running event with speed
    local speed = self._velocity.Magnitude
    self.StateMachine.Running:Fire(speed)
end

function CustomController:Jump()
    if not self._isJumping then
        self._isJumping = true
        self.StateMachine.Jumping:Fire()
        
        task.delay(0.5, function()
            self._isJumping = false
        end)
    end
end

function CustomController:GetMoveDirection()
    -- Your input handling here
    return Vector3.zero
end

return CustomController
```

Usage:

```lua
local CustomController = require(game.ReplicatedStorage.CustomController)
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Create custom controller
local controller = CustomController.new(character)

-- Create animation controller with custom state machine
local animController = SimpleAnimate.new(
    character,
    true,
    nil,
    nil,
    controller.StateMachine
)

-- Update loop
game:GetService("RunService").Heartbeat:Connect(function(dt)
    controller:Update(dt)
end)
```

## Swimming State Machine

Custom swimming mechanics with state machine:

```lua
local SwimStateMachine = {}
SwimStateMachine.__index = SwimStateMachine

function SwimStateMachine.new(character)
    local self = setmetatable({}, SwimStateMachine)
    
    self.Running = Signal.new()
    self.Jumping = Signal.new()
    self.Climbing = Signal.new()
    self.Swimming = Signal.new()
    self.StateChanged = Signal.new()
    
    self.WalkSpeed = 16
    self._inWater = false
    self._swimSpeed = 0
    
    -- Detect water regions
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    hrp.Touched:Connect(function(hit)
        if hit:IsA("Part") and hit.Name == "Water" then
            self._inWater = true
            self:SetState(Enum.HumanoidStateType.Swimming)
        end
    end)
    
    hrp.TouchEnded:Connect(function(hit)
        if hit:IsA("Part") and hit.Name == "Water" then
            self._inWater = false
            self:SetState(Enum.HumanoidStateType.Running)
        end
    end)
    
    return self
end

function SwimStateMachine:SetState(state)
    self.StateChanged:Fire(self._currentState or state, state)
    self._currentState = state
end

function SwimStateMachine:Update(velocity)
    if self._inWater then
        self._swimSpeed = velocity.Magnitude
        self.Swimming:Fire(self._swimSpeed)
    else
        self.Running:Fire(velocity.Magnitude)
    end
end

return SwimStateMachine
```

## Flying State Machine

For characters that can fly:

```lua
local FlyStateMachine = {}
FlyStateMachine.__index = FlyStateMachine

function FlyStateMachine.new()
    local self = setmetatable({}, FlyStateMachine)
    
    self.Running = Signal.new()
    self.Jumping = Signal.new()
    self.Climbing = Signal.new()
    self.Swimming = Signal.new()
    self.StateChanged = Signal.new()
    
    self.WalkSpeed = 16
    self._isFlying = false
    self._flySpeed = 0
    
    return self
end

function FlyStateMachine:StartFlying()
    self._isFlying = true
    self.StateChanged:Fire(
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.Flying
    )
end

function FlyStateMachine:StopFlying()
    self._isFlying = false
    self.StateChanged:Fire(
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall
    )
end

function FlyStateMachine:UpdateFlySpeed(speed)
    if self._isFlying then
        self._flySpeed = speed
        self.Swimming:Fire(speed) -- Reuse swimming for flying
    else
        self.Running:Fire(speed)
    end
end

return FlyStateMachine
```

## AI State Machine

For NPC characters with AI:

```lua
local AIStateMachine = {}
AIStateMachine.__index = AIStateMachine

function AIStateMachine.new(npc)
    local self = setmetatable({}, AIStateMachine)
    
    self.Running = Signal.new()
    self.Jumping = Signal.new()
    self.Climbing = Signal.new()
    self.Swimming = Signal.new()
    self.StateChanged = Signal.new()
    
    self.WalkSpeed = 16
    self._npc = npc
    self._currentBehavior = "idle"
    
    return self
end

function AIStateMachine:SetBehavior(behavior)
    self._currentBehavior = behavior
    
    if behavior == "patrol" then
        self:StartPatrol()
    elseif behavior == "chase" then
        self:StartChase()
    elseif behavior == "idle" then
        self:StopMovement()
    end
end

function AIStateMachine:StartPatrol()
    self.Running:Fire(8) -- Walk speed
end

function AIStateMachine:StartChase()
    self.Running:Fire(20) -- Run speed
end

function AIStateMachine:StopMovement()
    self.Running:Fire(0)
end

function AIStateMachine:DoAction(action)
    if action == "jump" then
        self.Jumping:Fire()
    end
end

return AIStateMachine
```

Usage with AI:

```lua
local aiStateMachine = AIStateMachine.new(npc)
local controller = SimpleAnimate.new(npc, true, nil, nil, aiStateMachine)

-- AI behavior
while true do
    task.wait(5)
    
    local player = findNearestPlayer(npc)
    
    if player and (player.Character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude < 50 then
        aiStateMachine:SetBehavior("chase")
    else
        aiStateMachine:SetBehavior("patrol")
    end
end
```

## State Machine Debugging

Helper to debug state machine events:

```lua
local function debugStateMachine(stateMachine, name)
    print("=== Debugging State Machine:", name, "===")
    
    stateMachine.Running:Connect(function(speed)
        print("[Running]", speed)
    end)
    
    stateMachine.Jumping:Connect(function()
        print("[Jumping]")
    end)
    
    stateMachine.Climbing:Connect(function(speed)
        print("[Climbing]", speed)
    end)
    
    stateMachine.Swimming:Connect(function(speed)
        print("[Swimming]", speed)
    end)
    
    stateMachine.StateChanged:Connect(function(old, new)
        print("[StateChanged]", old.Name, "->", new.Name)
    end)
end

-- Usage
debugStateMachine(customStateMachine, "CustomController")
```

## Best Practices

1. **Implement all required events**: Even if unused, provide them for compatibility
2. **Fire events consistently**: Match Humanoid behavior for predictable results
3. **Handle edge cases**: Test state transitions thoroughly
4. **Provide sensible defaults**: Set reasonable default values
5. **Document your interface**: Clearly document what your state machine does
6. **Test with SimpleAnimate**: Ensure animations trigger as expected
7. **Consider replication**: Decide if states need to sync across network

## Common Pitfalls

### Missing Events

```lua
-- ❌ BAD: Missing events
local stateMachine = {
    Running = Signal.new(),
    WalkSpeed = 16
}
-- Will error when SimpleAnimate tries to connect to missing events

-- ✅ GOOD: All events present
local stateMachine = {
    Running = Signal.new(),
    Jumping = Signal.new(),
    Climbing = Signal.new(),
    Swimming = Signal.new(),
    StateChanged = Signal.new(),
    WalkSpeed = 16
}
```

### Wrong Signal Signatures

```lua
-- ❌ BAD: Wrong signature
self.Running:Fire() -- Missing speed parameter

-- ✅ GOOD: Correct signature
self.Running:Fire(16) -- Includes speed
```

### Not Updating WalkSpeed

```lua
-- ❌ BAD: Static WalkSpeed
self.WalkSpeed = 16 -- Never changes

-- ✅ GOOD: Dynamic WalkSpeed
function StateMachine:SetSpeed(speed)
    self.WalkSpeed = speed
    self.Running:Fire(speed)
end
```

## Complete Example

Full custom state machine implementation:

```lua
local Signal = require(game.ReplicatedStorage.Signal)

local CustomStateMachine = {}
CustomStateMachine.__index = CustomStateMachine

function CustomStateMachine.new(character)
    local self = setmetatable({}, CustomStateMachine)
    
    -- Required signals
    self.Running = Signal.new()
    self.Jumping = Signal.new()
    self.Climbing = Signal.new()
    self.Swimming = Signal.new()
    self.StateChanged = Signal.new()
    
    -- Required properties
    self.WalkSpeed = 16
    
    -- Internal state
    self._character = character
    self._currentState = Enum.HumanoidStateType.Running
    self._velocity = Vector3.zero
    
    return self
end

function CustomStateMachine:Update(dt)
    -- Update movement and fire events
    local speed = self._velocity.Magnitude
    self.Running:Fire(speed)
end

function CustomStateMachine:Jump()
    self.Jumping:Fire()
    self:SetState(Enum.HumanoidStateType.Jumping)
end

function CustomStateMachine:SetState(newState)
    local oldState = self._currentState
    self._currentState = newState
    self.StateChanged:Fire(oldState, newState)
end

function CustomStateMachine:SetVelocity(velocity)
    self._velocity = velocity
end

return CustomStateMachine
```