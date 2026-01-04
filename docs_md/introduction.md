# SimpleAnimate API

The top-level SimpleAnimate module provides factory functions for creating and managing animation controllers.

## Functions

### `new()`

Creates a new AnimationController instance.

**Signature:**
```lua
function new(
    rig: Model,
    doPreload: boolean?,
    coreAnimations: AnimationsList?,
    emoteAnimations: AnimationsList?,
    stateMachine: StateMachine?
): AnimationController
```

**Parameters:**
- `rig` - The character model (must contain an Animator)
- `doPreload` - Whether to preload animations (default: `true`)
- `coreAnimations` - Custom core animations (defaults to R15)
- `emoteAnimations` - Custom emote animations (defaults to R15)
- `stateMachine` - Custom state machine (defaults to Humanoid)

**Returns:**
- `AnimationController` - A new controller instance

**Examples:**

Basic usage with defaults:
```lua
local controller = SimpleAnimate.new(character)
```

With custom animations:
```lua
local coreAnims, emoteAnims = SimpleAnimate.getCopyOfAnims("R15")
coreAnims.Idle[1].id = "rbxassetid://123456789"

local controller = SimpleAnimate.new(
    character,
    true,
    coreAnims,
    emoteAnims
)
```

Without preloading (load animations on-demand):
```lua
local controller = SimpleAnimate.new(character, false)
```

With custom state machine:
```lua
local customStateMachine = character:FindFirstChild("CustomHumanoid")
local controller = SimpleAnimate.new(
    character,
    true,
    nil,
    nil,
    customStateMachine
)
```

---

### `fromExisting()`

Gets an existing AnimationController for the specified rig.

**Signature:**
```lua
function fromExisting(rig: Model): AnimationController?
```

**Parameters:**
- `rig` - The character model to get the controller for

**Returns:**
- `AnimationController?` - The existing controller or `nil` if none exists

**Examples:**

```lua
local controller = SimpleAnimate.fromExisting(character)

if controller then
    print("Controller already exists!")
    controller.Core.PoseController:ChangePose("Idle")
else
    print("No controller found, creating new one...")
    controller = SimpleAnimate.new(character)
end
```

Checking multiple characters:
```lua
for _, player in Players:GetPlayers() do
    local char = player.Character
    if char then
        local controller = SimpleAnimate.fromExisting(char)
        if controller then
            print(player.Name, "has a controller")
        end
    end
end
```

---

### `awaitController()`

Waits for an AnimationController to be created for the specified rig. Yields until available or timeout occurs.

**Signature:**
```lua
function awaitController(rig: Model, timeOut: number?): AnimationController?
```

**Parameters:**
- `rig` - The character model to wait for
- `timeOut` - Timeout in seconds (default: `5`)

**Returns:**
- `AnimationController?` - The controller or `nil` on timeout

**Examples:**

Basic usage:
```lua
-- Wait up to 5 seconds for controller
local controller = SimpleAnimate.awaitController(character)

if controller then
    print("Controller ready!")
else
    warn("Controller not found within timeout")
end
```

Custom timeout:
```lua
-- Wait up to 10 seconds
local controller = SimpleAnimate.awaitController(character, 10)
```

Useful in separate scripts:
```lua
-- Script A creates the controller
SimpleAnimate.new(character)

-- Script B (elsewhere) waits for it
local controller = SimpleAnimate.awaitController(character)
controller.Action:PlayAction("wave")
```

---

### `getCopyOfAnimsList()`

Gets a deep copy of a default animation list by name and type.

**Signature:**
```lua
function getCopyOfAnimsList(
    name: "R6" | "R15",
    specifier: "Animations" | "Emotes"
): AnimationsList
```

**Parameters:**
- `name` - The rig type ("R6" or "R15")
- `specifier` - The list type ("Animations" or "Emotes")

**Returns:**
- `AnimationsList` - A deep copy of the requested list

**Examples:**

Get R15 core animations:
```lua
local r15Anims = SimpleAnimate.getCopyOfAnimsList("R15", "Animations")

-- Modify as needed
r15Anims.Idle[1].speed = 0.8
r15Anims.Run[1].id = "rbxassetid://123456789"
```

Get R6 emotes:
```lua
local r6Emotes = SimpleAnimate.getCopyOfAnimsList("R6", "Emotes")

-- Add custom emote
r6Emotes.customWave = {
    {
        id = "rbxassetid://987654321",
        weight = 10
    }
}
```

---

### `getCopyOfAnims()`

Gets deep copies of both default animation lists (Animations and Emotes).

**Signature:**
```lua
function getCopyOfAnims(name: "R6" | "R15"): (AnimationsList, AnimationsList)
```

**Parameters:**
- `name` - The rig type ("R6" or "R15")

**Returns:**
- `AnimationsList` - Core animations
- `AnimationsList` - Emote animations

**Examples:**

Get both R15 lists:
```lua
local coreAnims, emoteAnims = SimpleAnimate.getCopyOfAnims("R15")

-- Customize both
coreAnims.Walk[1].speed = 1.2
emoteAnims.wave[1].fadeTime = 0.3

local controller = SimpleAnimate.new(character, true, coreAnims, emoteAnims)
```

Get R6 lists:
```lua
local coreAnims, emoteAnims = SimpleAnimate.getCopyOfAnims("R6")
```

---

### `getAnimPackageAsync()`

Gets a player's equipped animation package asynchronously. Fills in missing animations with defaults.

**Signature:**
```lua
function getAnimPackageAsync(
    player: Player?,
    defaultPoseSourceIfUnavailable: AnimationsList?
): AnimationsList?
```

**Parameters:**
- `player` - The player (required when called from server, optional on client)
- `defaultPoseSourceIfUnavailable` - Fallback animations (defaults to R15)

**Returns:**
- `AnimationsList?` - The player's animation package with defaults filled in

**Examples:**

Server-side:
```lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Get player's equipped animations
        local anims = SimpleAnimate.getAnimPackageAsync(player)
        
        local controller = SimpleAnimate.new(character, true, anims)
    end)
end)
```

Client-side:
```lua
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Get local player's animations (no player parameter needed)
local anims = SimpleAnimate.getAnimPackageAsync()

local controller = SimpleAnimate.new(character, true, anims)
```

With custom fallbacks:
```lua
local customDefaults = SimpleAnimate.getCopyOfAnimsList("R15", "Animations")
customDefaults.Idle[1].id = "rbxassetid://123456789"

local anims = SimpleAnimate.getAnimPackageAsync(player, customDefaults)
```

---

### `getEmotePackageAsync()`

Gets a player's equipped emote package asynchronously.

**Signature:**
```lua
function getEmotePackageAsync(
    player: Player?,
    defaultEmoteSourceIfUnavailable: AnimationsList?
): AnimationsList?
```

**Parameters:**
- `player` - The player (required when called from server)
- `defaultEmoteSourceIfUnavailable` - Fallback emotes (defaults to R15)

**Returns:**
- `AnimationsList?` - The player's emote package

**Examples:**

Server-side:
```lua
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local anims = SimpleAnimate.getAnimPackageAsync(player)
        local emotes = SimpleAnimate.getEmotePackageAsync(player)
        
        local controller = SimpleAnimate.new(
            character,
            true,
            anims,
            emotes
        )
    end)
end)
```

Client-side:
```lua
local emotes = SimpleAnimate.getEmotePackageAsync()
```

## Properties

### `Preload`

Reference to the Preload utility module.

**Example:**
```lua
local animator = character:FindFirstChildWhichIsA("Animator", true)
local animList = {
    Idle = {{id = "rbxassetid://123", weight = 10}}
}

local preloaded = SimpleAnimate.Preload.preloadAnimList(
    animator,
    animList,
    "core",
    Enum.AnimationPriority.Core,
    true
)
```

---

### `default`

Reference to default animation lists (DefaultAnims module).

**Example:**
```lua
-- Access default R15 animations directly
local defaultR15 = SimpleAnimate.default.R15

print(defaultR15.Animations.Idle[1].id)
print(defaultR15.Emotes.wave[1].id)
```