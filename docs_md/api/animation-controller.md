# AnimationController API

The AnimationController is the main instance returned by `SimpleAnimate.new()`. It provides access to both core animation systems and action/emote systems.

**Created by:** `SimpleAnimate.new()`

## Properties

### `Core`

Access to the core animation system.

**Type:** `Core`

**Contains:**
- `PoseController` - Controls pose transitions and animation playback
- `Connections` - Manages humanoid event connections

**Examples:**

Access PoseController:
```luau
local controller = SimpleAnimate.new(character)

-- Get current pose
local pose = controller.Core.PoseController:GetPose()
print("Current pose:", pose)

-- Listen for pose changes
controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose)
    print("Pose changed:", oldPose, "->", newPose)
end)
```

Access Connections configuration:
```luau
local controller = SimpleAnimate.new(character)

-- Adjust run threshold
controller.Core.Connections.RunThreshold = 12

-- Modify animation speed
controller.Core.Connections.MoveAnimationSpeedMultiplier = 1.5
```

---

### `Action`

Access to the action/emote animation system.

**Type:** `Actions`

**Methods:**
- `CreateAction()` - Create a new action
- `PlayAction()` - Play an action
- `RemoveAction()` - Remove an action
- And more (see [Action API](./action.md))

**Examples:**

Play emotes:
```luau
local controller = SimpleAnimate.new(character)

-- Play a wave emote
controller.Action:PlayAction("wave")

-- Create custom action
controller.Action:CreateAction("celebrate", {
    {id = "rbxassetid://123456", weight = 10}
})

-- Play it
controller.Action:PlayAction("celebrate")
```

## Methods

### `:Destroy()`

Destroys the AnimationController and cleans up all resources.

**Signature:**
```luau
function Destroy(): ()
```

**Behavior:**
- Destroys the Core system (PoseController and Connections)
- Destroys the Action system
- Disconnects all event connections
- Removes the controller from the global registry
- Cleans up all internal references

**Examples:**

Manual cleanup:
```luau
local controller = SimpleAnimate.new(character)

-- Later...
controller:Destroy()
```

Cleanup on character removal:
```luau
local controller = SimpleAnimate.new(character)

character.Destroying:Connect(function()
    controller:Destroy()
end)
```

**Note:** The controller automatically destroys itself when the character is destroyed, so manual cleanup is usually not necessary.

Cleanup before respawn:
```luau
local Players = game:GetService("Players")
local controllers = {}

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Clean up old controller if exists
        if controllers[player] then
            controllers[player]:Destroy()
        end
        
        -- Create new controller
        controllers[player] = SimpleAnimate.new(character)
    end)
    
    player.CharacterRemoving:Connect(function()
        if controllers[player] then
            controllers[player]:Destroy()
            controllers[player] = nil
        end
    end)
end)
```

## Complete Examples

### Basic Character Setup

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Create controller
local controller = SimpleAnimate.new(character)

-- Access core animations
print("Current pose:", controller.Core.PoseController:GetPose())

-- Play emote
controller.Action:PlayAction("wave")

-- Cleanup (automatic, but can be manual)
character.Destroying:Connect(function()
    controller:Destroy()
end)
```

### Custom Animation System

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Get custom animations
local coreAnims, emoteAnims = SimpleAnimate.getCopyOfAnims("R15")

-- Customize
coreAnims.Idle[1].id = "rbxassetid://CUSTOM_IDLE"
emoteAnims.wave[1].id = "rbxassetid://CUSTOM_WAVE"

-- Create controller
local controller = SimpleAnimate.new(
    character,
    true,
    coreAnims,
    emoteAnims
)

-- Configure behavior
controller.Core.Connections.RunThreshold = 14
controller.Core.Connections.MoveAnimationSpeedMultiplier = 1.2

-- Add custom actions
controller.Action:CreateAction("customEmote", {
    {id = "rbxassetid://123", weight = 10}
})
```

### Multiple Controllers (NPCs)

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)
local npcControllers = {}

local function setupNPC(npc)
    local controller = SimpleAnimate.new(npc)
    
    -- Store reference
    npcControllers[npc] = controller
    
    -- Configure NPC-specific settings
    controller.Core.Connections.RunThreshold = 10
    controller.Core.Connections.MoveAnimationSpeedMultiplier = 0.8
    
    return controller
end

-- Setup all NPCs
for _, npc in workspace.NPCs:GetChildren() do
    setupNPC(npc)
end

-- Cleanup when NPC is removed
workspace.NPCs.ChildRemoved:Connect(function(npc)
    if npcControllers[npc] then
        npcControllers[npc]:Destroy()
        npcControllers[npc] = nil
    end
end)
```

### Controller with Monitoring

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Create controller
local controller = SimpleAnimate.new(character)

-- Monitor pose changes
controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    print(string.format(
        "[%s] Pose: %s -> %s (Speed: %.2f)",
        character.Name,
        oldPose,
        newPose,
        track.Speed
    ))
end)

-- Monitor animation speed
game:GetService("RunService").Heartbeat:Connect(function()
    local track = controller.Core.PoseController:GetCurrentTrack()
    if track then
        -- Log or display animation info
        print("Current animation speed:", track.Speed)
    end
end)
```

### Dynamic Animation Switching

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

local controller = SimpleAnimate.new(character)

-- Normal animations
local normalAnims = {
    Idle = {{id = "rbxassetid://NORMAL_IDLE", weight = 10}},
    Walk = {{id = "rbxassetid://NORMAL_WALK", weight = 10}},
    Run = {{id = "rbxassetid://NORMAL_RUN", weight = 10}}
}

-- Combat animations
local combatAnims = {
    Idle = {{id = "rbxassetid://COMBAT_IDLE", weight = 10}},
    Walk = {{id = "rbxassetid://COMBAT_WALK", weight = 10}},
    Run = {{id = "rbxassetid://COMBAT_RUN", weight = 10}}
}

-- Switch to combat mode
local function enterCombatMode()
    for pose, animInfos in combatAnims do
        controller.Core.PoseController:ChangeCoreAnim(pose, 1, animInfos[1])
    end
    print("Entered combat mode")
end

-- Switch to normal mode
local function exitCombatMode()
    for pose, animInfos in normalAnims do
        controller.Core.PoseController:ChangeCoreAnim(pose, 1, animInfos[1])
    end
    print("Exited combat mode")
end

-- Listen for combat state changes
character:GetAttributeChangedSignal("InCombat"):Connect(function()
    if character:GetAttribute("InCombat") then
        enterCombatMode()
    else
        exitCombatMode()
    end
end)
```

### Controller with Custom State Machine

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)
local CustomStateMachine = require(game.ReplicatedStorage.CustomStateMachine)

-- Create custom state machine
local stateMachine = CustomStateMachine.new(character)

-- Create controller with custom state machine
local controller = SimpleAnimate.new(
    character,
    true,
    nil,
    nil,
    stateMachine
)

-- Control animations through state machine
stateMachine:FireRunning(10)  -- Walk
stateMachine:FireRunning(20)  -- Run
stateMachine:FireJumping()    -- Jump
```

### Controller with Error Handling

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

local function safeCreateController(character)
    local success, controller = pcall(function()
        return SimpleAnimate.new(character)
    end)
    
    if success then
        print("Controller created for", character.Name)
        
        -- Setup monitoring
        controller.Core.PoseController.PoseChanged:Connect(function(old, new)
            print("Pose changed:", old, "->", new)
        end)
        
        return controller
    else
        warn("Failed to create controller:", controller)
        return nil
    end
end

-- Usage
local controller = safeCreateController(character)

if controller then
    -- Controller ready
    controller.Action:PlayAction("wave")
else
    -- Fallback behavior
    warn("Using fallback animation system")
end
```

### Controller Pool System

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)
local Players = game:GetService("Players")

local ControllerPool = {}
ControllerPool.__index = ControllerPool

function ControllerPool.new()
    local self = setmetatable({}, ControllerPool)
    self._controllers = {}
    return self
end

function ControllerPool:Add(player, character)
    -- Remove old controller if exists
    self:Remove(player)
    
    -- Create new controller
    local controller = SimpleAnimate.new(character)
    self._controllers[player.UserId] = {
        player = player,
        character = character,
        controller = controller
    }
    
    return controller
end

function ControllerPool:Get(player)
    local entry = self._controllers[player.UserId]
    return entry and entry.controller
end

function ControllerPool:Remove(player)
    local entry = self._controllers[player.UserId]
    if entry then
        entry.controller:Destroy()
        self._controllers[player.UserId] = nil
    end
end

function ControllerPool:GetAll()
    local controllers = {}
    for _, entry in self._controllers do
        table.insert(controllers, entry.controller)
    end
    return controllers
end

-- Usage
local pool = ControllerPool.new()

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        pool:Add(player, character)
    end)
    
    player.CharacterRemoving:Connect(function()
        pool:Remove(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    pool:Remove(player)
end)

-- Get a specific controller
local controller = pool:Get(player)

-- Get all controllers
local allControllers = pool:GetAll()
for _, controller in allControllers do
    -- Do something with each controller
    controller.Core.Connections.RunThreshold = 15
end
```

## Accessing Existing Controllers

### Using `fromExisting()`

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- In Script A: Create controller
local controller = SimpleAnimate.new(character)

-- In Script B: Get existing controller
local controller = SimpleAnimate.fromExisting(character)

if controller then
    -- Controller exists, use it
    controller.Action:PlayAction("wave")
else
    -- Controller doesn't exist
    warn("No controller found for", character.Name)
end
```

### Using `awaitController()`

```luau
local SimpleAnimate = require(game.ReplicatedStorage.SimpleAnimate)

-- Wait for controller to be created (with timeout)
local controller = SimpleAnimate.awaitController(character, 5)

if controller then
    print("Controller ready!")
    controller.Action:PlayAction("dance")
else
    warn("Controller not found within 5 seconds")
end
```

## Best Practices

1. **Let it auto-cleanup**: The controller automatically destroys itself when the character is destroyed
2. **One controller per character**: Don't create multiple controllers for the same character
3. **Use fromExisting()**: Check for existing controllers before creating new ones
4. **Store references**: Keep references to controllers you need to access later
5. **Handle errors**: Use pcall when creating controllers for robustness
6. **Clean up properly**: If you manually destroy, ensure you also clean up your references
7. **Don't over-configure**: Default settings work well for most use cases

## Common Patterns

### Lazy Controller Creation

```luau
local controllers = {}

local function getOrCreateController(character)
    if controllers[character] then
        return controllers[character]
    end
    
    local controller = SimpleAnimate.new(character)
    controllers[character] = controller
    
    character.Destroying:Connect(function()
        controllers[character] = nil
    end)
    
    return controller
end

-- Usage
local controller = getOrCreateController(character)
```

### Controller with Lifecycle Hooks

```luau
local function createControllerWithHooks(character, options)
    options = options or {}
    
    -- onCreate hook
    if options.onCreate then
        options.onCreate(character)
    end
    
    -- Create controller
    local controller = SimpleAnimate.new(character)
    
    -- onReady hook
    if options.onReady then
        options.onReady(controller)
    end
    
    -- onDestroy hook
    character.Destroying:Connect(function()
        if options.onDestroy then
            options.onDestroy(controller)
        end
    end)
    
    return controller
end

-- Usage
local controller = createControllerWithHooks(character, {
    onCreate = function(char)
        print("Creating controller for", char.Name)
    end,
    onReady = function(ctrl)
        print("Controller ready!")
        ctrl.Action:PlayAction("wave")
    end,
    onDestroy = function(ctrl)
        print("Controller destroyed")
    end
})
```

## Related APIs

- [Core API](./core.md) - Core animation system
- [PoseController API](./pose-controller.md) - Pose management
- [Connections API](./connections.md) - Event handling configuration
- [Action API](./action.md) - Emote and action system