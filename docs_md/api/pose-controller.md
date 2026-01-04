# PoseController API

The PoseController manages pose transitions and core animation playback. It handles switching between different character states like idle, walking, running, jumping, etc.

**Access:** `controller.Core.PoseController`

## Events

### `PoseChanged`

Fires when the character's pose changes.

**Signature:**
```luau
PoseChanged: RBXScriptSignal<PoseType, PoseType, AnimationTrack>
```

**Parameters:**
- `oldPose: PoseType` - The previous pose
- `newPose: PoseType` - The new pose
- `track: AnimationTrack` - The animation track for the new pose

**Examples:**

Basic usage:
```luau
controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    print(string.format("Changed from %s to %s", oldPose, newPose))
end)
```

Track specific transitions:
```luau
controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    if newPose == "Jumping" then
        print("Character jumped!")
        track:AdjustSpeed(1.5) -- Make jump animation faster
    elseif newPose == "Freefall" then
        print("Character is falling!")
    end
end)
```

Create visual effects on pose changes:
```luau
controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    if newPose == "Landed" then
        -- Create dust particle effect
        local dust = dustEffect:Clone()
        dust.Parent = character.HumanoidRootPart
        dust:Emit(20)
        
        task.delay(1, function()
            dust:Destroy()
        end)
    end
end)
```

## Methods

### `:SetCoreActive()`

Sets whether core animations are active.

**Signature:**
```luau
function SetCoreActive(value: boolean): ()
```

**Parameters:**
- `value: boolean` - Enable/disable core animations

**Examples:**

Disable all core animations:
```luau
controller.Core.PoseController:SetCoreActive(false)
-- Character will stop animating automatically
```

Re-enable core animations:
```luau
controller.Core.PoseController:SetCoreActive(true)
```

Temporarily pause during cutscene:
```luau
-- Start cutscene
controller.Core.PoseController:SetCoreActive(false)

-- Play cutscene...
task.wait(5)

-- Resume normal animations
controller.Core.PoseController:SetCoreActive(true)
```

---

### `:GetCoreActive()`

Gets whether core animations are currently active.

**Signature:**
```luau
function GetCoreActive(): boolean
```

**Returns:**
- `boolean` - Whether core animations are active

**Examples:**

```luau
local isActive = controller.Core.PoseController:GetCoreActive()
print("Core animations active:", isActive)
```

Toggle core animations:
```luau
local currentState = controller.Core.PoseController:GetCoreActive()
controller.Core.PoseController:SetCoreActive(not currentState)
```

---

### `:SetCoreCanPlayAnims()`

Controls whether core animations can play. Used internally during emotes.

**Signature:**
```luau
function SetCoreCanPlayAnims(value: boolean): ()
```

**Parameters:**
- `value: boolean` - Whether core animations can play

**Examples:**

```luau
-- Prevent core animations temporarily
controller.Core.PoseController:SetCoreCanPlayAnims(false)

-- Allow core animations
controller.Core.PoseController:SetCoreCanPlayAnims(true)
```

---

### `:GetCoreCanPlayAnims()`

Gets whether core animations can play.

**Signature:**
```luau
function GetCoreCanPlayAnims(): boolean
```

**Returns:**
- `boolean` - Whether core animations can play

---

### `:GetCurrentTrack()`

Gets the currently playing animation track.

**Signature:**
```luau
function GetCurrentTrack(): AnimationTrack
```

**Returns:**
- `AnimationTrack` - The current animation track

**Examples:**

```luau
local track = controller.Core.PoseController:GetCurrentTrack()
print("Current animation:", track.Animation.AnimationId)
print("Current speed:", track.Speed)
print("Is playing:", track.IsPlaying)
```

Adjust current animation speed:
```luau
local track = controller.Core.PoseController:GetCurrentTrack()
track:AdjustSpeed(2) -- Play at 2x speed
```

---

### `:GetPose()`

Gets the current pose type.

**Signature:**
```luau
function GetPose(): PoseType?
```

**Returns:**
- `PoseType?` - The current pose (e.g., "Idle", "Walk", "Run", "Jumping")

**Examples:**

```luau
local currentPose = controller.Core.PoseController:GetPose()
print("Character is:", currentPose)
```

Conditional logic based on pose:
```luau
local pose = controller.Core.PoseController:GetPose()

if pose == "Idle" then
    print("Character is standing still")
elseif pose == "Run" or pose == "Walk" then
    print("Character is moving")
elseif pose == "Freefall" or pose == "Jumping" then
    print("Character is in the air")
end
```

---

### `:SetPoseEnabled()`

Enables or disables a specific pose.

**Signature:**
```luau
function SetPoseEnabled(pose: PoseType, enabled: boolean): ()
```

**Parameters:**
- `pose: PoseType` - The pose to enable/disable
- `enabled: boolean` - Whether the pose should be enabled

**Examples:**

Disable jumping animation:
```luau
controller.Core.PoseController:SetPoseEnabled("Jumping", false)
-- Character can still jump but won't play jump animation
```

Disable multiple poses:
```luau
-- Create a "statue" mode
controller.Core.PoseController:SetPoseEnabled("Walk", false)
controller.Core.PoseController:SetPoseEnabled("Run", false)
controller.Core.PoseController:SetPoseEnabled("Jumping", false)
```

Re-enable poses:
```luau
controller.Core.PoseController:SetPoseEnabled("Jumping", true)
```

---

### `:GetCoreAnimInfos()`

Gets the animation information array for a specific pose.

**Signature:**
```luau
function GetCoreAnimInfos(pose: PoseType): {AnimInfo}
```

**Parameters:**
- `pose: PoseType` - The pose to get animations for

**Returns:**
- `{AnimInfo}` - Array of animation info structures

**Examples:**

```luau
local idleAnims = controller.Core.PoseController:GetCoreAnimInfos("Idle")

for i, info in idleAnims do
    print(string.format("Idle anim %d: %s (weight: %d)", i, info.id, info.weight))
end
```

Check how many walk animations exist:
```luau
local walkAnims = controller.Core.PoseController:GetCoreAnimInfos("Walk")
print("Number of walk animations:", #walkAnims)
```

---

### `:ChangeCoreAnim()`

Changes a core animation for a specific pose.

**Signature:**
```luau
function ChangeCoreAnim(
    pose: PoseType,
    index: number,
    new: Animation | string | AnimationTrack | AnimInfo
): AnimationTrack
```

**Parameters:**
- `pose: PoseType` - The pose to change
- `index: number` - The index of the animation to change (1-based)
- `new` - The new animation (can be AnimInfo table, AnimationId string, Animation instance, or AnimationTrack)

**Returns:**
- `AnimationTrack` - The new animation track

**Examples:**

Change using animation ID:
```luau
controller.Core.PoseController:ChangeCoreAnim(
    "Idle",
    1,
    "rbxassetid://123456789"
)
```

Change using Animation instance:
```luau
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://123456789"

controller.Core.PoseController:ChangeCoreAnim("Run", 1, anim)
```

Change using AnimInfo table:
```luau
local newAnimInfo = {
    id = "rbxassetid://123456789",
    weight = 15,
    speed = 1.2,
    fadeTime = 0.3
}

controller.Core.PoseController:ChangeCoreAnim("Walk", 1, newAnimInfo)
```

Change multiple animations:
```luau
-- Replace all idle animations
local idleAnims = {
    "rbxassetid://111111",
    "rbxassetid://222222",
    "rbxassetid://333333"
}

for i, animId in idleAnims do
    controller.Core.PoseController:ChangeCoreAnim("Idle", i, animId)
end
```

---

### `:GetRandomCoreAnim()`

Gets a random animation track for the specified pose, weighted by animation weights.

**Signature:**
```luau
function GetRandomCoreAnim(pose: PoseType): AnimationTrack
```

**Parameters:**
- `pose: PoseType` - The pose to get an animation for

**Returns:**
- `AnimationTrack` - A randomly selected animation track

**Examples:**

```luau
local randomIdle = controller.Core.PoseController:GetRandomCoreAnim("Idle")
print("Selected idle animation:", randomIdle.Animation.AnimationId)
```

---

### `:StopCoreAnimations()`

Stops all currently playing core animations.

**Signature:**
```luau
function StopCoreAnimations(fadeTime: number?): ()
```

**Parameters:**
- `fadeTime: number?` - Optional fade time for stopping animations (default: instant)

**Examples:**

Stop immediately:
```luau
controller.Core.PoseController:StopCoreAnimations()
```

Stop with fade:
```luau
controller.Core.PoseController:StopCoreAnimations(0.5) -- Fade out over 0.5 seconds
```

Use before playing custom animation:
```luau
-- Stop all core animations before custom sequence
controller.Core.PoseController:StopCoreAnimations(0.2)

local customTrack = animator:LoadAnimation(customAnimation)
customTrack:Play()
```

---

### `:PlayCoreAnimation()`

Plays an animation for the specified pose.

**Signature:**
```luau
function PlayCoreAnimation(
    pose: PoseType,
    looped: boolean?,
    speed: number?,
    fadeTime: number?
): AnimInfo
```

**Parameters:**
- `pose: PoseType` - The pose to play
- `looped: boolean?` - Whether to loop (default: `true`)
- `speed: number?` - Playback speed (default: `1`)
- `fadeTime: number?` - Fade time for transition (default: `0.1`)

**Returns:**
- `AnimInfo` - The animation info that was played

**Examples:**

Play idle animation:
```luau
controller.Core.PoseController:PlayCoreAnimation("Idle")
```

Play with custom speed:
```luau
controller.Core.PoseController:PlayCoreAnimation("Run", true, 1.5)
```

Play non-looping:
```luau
controller.Core.PoseController:PlayCoreAnimation("Jumping", false, 1, 0.1)
```

---

### `:ChangePose()`

Changes the character's pose.

**Signature:**
```luau
function ChangePose(pose: PoseType, speed: number?, isCore: boolean?): ()
```

**Parameters:**
- `pose: PoseType` - The pose to change to
- `speed: number?` - Optional playback speed (default: `1`)
- `isCore: boolean?` - Whether this is a core pose change (default: `false`)

**Examples:**

Force character to idle:
```luau
controller.Core.PoseController:ChangePose("Idle")
```

Change pose with custom speed:
```luau
controller.Core.PoseController:ChangePose("Walk", 1.5)
```

**Note:** Usually you don't need to call this manually as the Connections module handles pose changes automatically based on humanoid state.