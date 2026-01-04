# Action API

The Action module manages emotes and custom action animations. It handles one-off animations that interrupt core animations temporarily.

**Access:** `controller.Action`

## Methods

### `:CreateAction()`

Creates a new action animation and adds it to the actions collection.

**Signature:**
```lua
function CreateAction(
    key: any,
    template: {AnimInfo},
    doPreload: boolean?,
    priority: Enum.AnimationPriority?,
    looped: boolean?
): {AnimInfo}
```

**Parameters:**
- `key: any` - The key identifier for the action (can be string, number, etc.)
- `template: {AnimInfo}` - Array of animation info structures
- `doPreload: boolean?` - Whether to preload animations (default: `true`)
- `priority: Enum.AnimationPriority?` - Animation priority (default: `Enum.AnimationPriority.Action`)
- `looped: boolean?` - Whether animations loop (default: `false`)

**Returns:**
- `{AnimInfo}` - The preloaded/created animation info array

**Examples:**

Create a simple action:
```lua
local waveAction = {
    {
        id = "rbxassetid://123456789",
        weight = 10,
        speed = 1,
        fadeTime = 0.2
    }
}

controller.Action:CreateAction("customWave", waveAction)
```

Create action with multiple variants:
```lua
local danceAction = {
    {
        id = "rbxassetid://111111111",
        weight = 10,
        speed = 1
    },
    {
        id = "rbxassetid://222222222",
        weight = 5, -- Less likely to be selected
        speed = 1.2
    },
    {
        id = "rbxassetid://333333333",
        weight = 15, -- Most likely to be selected
        speed = 0.9
    }
}

controller.Action:CreateAction("dance", danceAction)
```

Create with custom priority:
```lua
controller.Action:CreateAction(
    "importantAction",
    actionTemplate,
    true,
    Enum.AnimationPriority.Action4 -- Higher priority
)
```

Create looped action:
```lua
local sitAction = {
    {
        id = "rbxassetid://987654321",
        weight = 10
    }
}

controller.Action:CreateAction("sit", sitAction, true, nil, true) -- Looped
```

---

### `:BulkCreateAction()`

Creates multiple actions at once from an animations list.

**Signature:**
```lua
function BulkCreateAction(
    animsList: AnimationsList,
    doPreload: boolean?,
    priority: Enum.AnimationPriority?
): AnimationsList
```

**Parameters:**
- `animsList: AnimationsList` - Dictionary of action names to animation arrays
- `doPreload: boolean?` - Whether to preload animations (default: `true`)
- `priority: Enum.AnimationPriority?` - Animation priority (default: `Enum.AnimationPriority.Action`)

**Returns:**
- `AnimationsList` - The created animations list

**Examples:**

Create multiple actions at once:
```lua
local customActions = {
    wave = {
        {id = "rbxassetid://111", weight = 10}
    },
    dance = {
        {id = "rbxassetid://222", weight = 10},
        {id = "rbxassetid://333", weight = 5}
    },
    point = {
        {id = "rbxassetid://444", weight = 10}
    }
}

controller.Action:BulkCreateAction(customActions)

-- Now you can play any of them
controller.Action:PlayAction("wave")
controller.Action:PlayAction("dance")
controller.Action:PlayAction("point")
```

---

### `:RemoveAction()`

Removes and destroys an action by key.

**Signature:**
```lua
function RemoveAction(key: any): ()
```

**Parameters:**
- `key: any` - The key of the action to remove

**Examples:**

```lua
-- Remove an action
controller.Action:RemoveAction("customWave")

-- Action is now destroyed and can't be played
```

Remove multiple actions:
```lua
local actionsToRemove = {"action1", "action2", "action3"}

for _, actionKey in actionsToRemove do
    controller.Action:RemoveAction(actionKey)
end
```

---

### `:StopAllActions()`

Stops all currently playing animations for a specific action.

**Signature:**
```lua
function StopAllActions(key: any): ()
```

**Parameters:**
- `key: any` - The key of the action to stop

**Examples:**

```lua
-- Stop all dance animations
controller.Action:StopAllActions("dance")
```

Stop action after delay:
```lua
controller.Action:PlayAction("dance")

task.delay(3, function()
    controller.Action:StopAllActions("dance")
end)
```

---

### `:GetAction()`

Gets an action's animation info array by key.

**Signature:**
```lua
function GetAction(key: any): {AnimInfo}?
```

**Parameters:**
- `key: any` - The key of the action to get

**Returns:**
- `{AnimInfo}?` - The animation info array or `nil` if not found

**Examples:**

```lua
local waveInfo = controller.Action:GetAction("wave")

if waveInfo then
    print("Wave action has", #waveInfo, "animations")
    
    for i, info in waveInfo do
        print(string.format("Animation %d: %s (weight: %d)", i, info.id, info.weight))
    end
end
```

Check if action exists:
```lua
if controller.Action:GetAction("customAction") then
    print("Custom action exists!")
else
    print("Custom action not found")
end
```

---

### `:GetRandomActionAnim()`

Gets a random animation track from an action's animations using weighted selection.

**Signature:**
```lua
function GetRandomActionAnim(key: any): AnimationTrack
```

**Parameters:**
- `key: any` - The key of the action

**Returns:**
- `AnimationTrack` - A randomly selected animation track

**Examples:**

```lua
local danceTrack = controller.Action:GetRandomActionAnim("dance")
print("Selected animation:", danceTrack.Animation.AnimationId)

-- Play it manually
danceTrack:Play()
```

---

### `:PlayRandomActionAnim()`

Plays a random animation from an action and returns the track.

**Signature:**
```lua
function PlayRandomActionAnim(key: any): AnimationTrack
```

**Parameters:**
- `key: any` - The key of the action to play

**Returns:**
- `AnimationTrack` - The animation track that was played

**Examples:**

Basic usage:
```lua
local track = controller.Action:PlayRandomActionAnim("wave")
```

Wait for animation to finish:
```lua
local track = controller.Action:PlayRandomActionAnim("dance")

track.Stopped:Wait()
print("Dance finished!")
```

Play with custom adjustments:
```lua
local track = controller.Action:PlayRandomActionAnim("emote")
track:AdjustSpeed(1.5) -- Speed up
track:AdjustWeight(2)  -- Increase weight
```

Chain animations:
```lua
local function playEmoteSequence()
    local wave = controller.Action:PlayRandomActionAnim("wave")
    wave.Stopped:Wait()
    
    task.wait(0.5)
    
    local dance = controller.Action:PlayRandomActionAnim("dance")
    dance.Stopped:Wait()
    
    task.wait(0.5)
    
    local point = controller.Action:PlayRandomActionAnim("point")
end

playEmoteSequence()
```

---

### `:PlayAction()`

Shorter alias for `:PlayRandomActionAnim()`.

**Signature:**
```lua
function PlayAction(key: any): AnimationTrack
```

**Parameters:**
- `key: any` - The key of the action to play

**Returns:**
- `AnimationTrack` - The animation track that was played

**Examples:**

```lua
-- These are equivalent
local track1 = controller.Action:PlayAction("wave")
local track2 = controller.Action:PlayRandomActionAnim("wave")
```

Quick emote playing:
```lua
-- Play various emotes
controller.Action:PlayAction("wave")
task.wait(2)
controller.Action:PlayAction("dance")
task.wait(2)
controller.Action:PlayAction("point")
```

---

### `:SetEmoteBindable()`

Sets up the emote bindable function for handling emote requests. This is used internally to connect with Roblox's emote system.

**Signature:**
```lua
function SetEmoteBindable(e: BindableFunction): ()
```

**Parameters:**
- `e: BindableFunction` - The bindable function to set up

**Examples:**

```lua
local emoteBindable = Instance.new("BindableFunction")
controller.Action:SetEmoteBindable(emoteBindable)

-- Now the emote system is connected
-- Players can use the emote menu to trigger animations
```

Custom emote handler:
```lua
local emoteBindable = Instance.new("BindableFunction")
controller.Action:SetEmoteBindable(emoteBindable)

-- Monitor emote usage
local originalInvoke = emoteBindable.OnInvoke

function emoteBindable.OnInvoke(emoteName)
    print(player.Name, "played emote:", emoteName)
    return originalInvoke(emoteName)
end
```

## Complete Examples

### Custom Emote System

```lua
-- Define custom emotes
local customEmotes = {
    wave = {
        {id = "rbxassetid://111", weight = 10, fadeTime = 0.2}
    },
    dance1 = {
        {id = "rbxassetid://222", weight = 10, fadeTime = 0.3}
    },
    dance2 = {
        {id = "rbxassetid://333", weight = 10, fadeTime = 0.3}
    },
    sit = {
        {id = "rbxassetid://444", weight = 10, fadeTime = 0.5}
    }
}

-- Create all emotes
controller.Action:BulkCreateAction(customEmotes)

-- Create UI buttons to trigger emotes
local function createEmoteButton(emoteName)
    local button = Instance.new("TextButton")
    button.Text = emoteName
    button.MouseButton1Click:Connect(function()
        controller.Action:PlayAction(emoteName)
    end)
    return button
end

for emoteName in customEmotes do
    local button = createEmoteButton(emoteName)
    button.Parent = emoteGui
end
```

### Timed Actions

```luau
-- Create a timed buff action
local buffAction = {
    {id = "rbxassetid://555", weight = 10}
}

controller.Action:CreateAction("buff", buffAction, true, nil, true) -- Looped

-- Play buff animation for 10 seconds
controller.Action:PlayAction("buff")

task.delay(10, function()
    controller.Action:StopAction("buff")
end)
```