# Quick Start

## Basic Setup

The simplest way to get started with SimpleAnimate:

```lua
local SimpleAnimate = require(path.to.SimpleAnimate)

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()

-- Create controller with default R15 animations
local controller = SimpleAnimate.new(character)
```

That's it! The controller will automatically handle all character animations based on humanoid state changes.

## Playing an Emote

```lua
-- Play a random animation from the "wave" emote
local track = controller.Action:PlayAction("wave")

-- Wait for it to finish
track.Stopped:Wait()
print("Wave animation completed!")
```

## Changing a Core Animation

```lua
-- Change the idle animation
controller.Core.PoseController:ChangeCoreAnim(
    "Idle",
    1,
    "rbxassetid://YOUR_ANIMATION_ID"
)
```

## Listening to Pose Changes

```lua
controller.Core.PoseController.PoseChanged:Connect(function(oldPose, newPose, track)
    print(string.format("Pose changed: %s -> %s", oldPose, newPose))
end)
```

## Getting Current State

```lua
-- Get current pose
local currentPose = controller.Core.PoseController:GetPose()
print("Current pose:", currentPose) -- "Idle", "Walk", "Run", etc.

-- Get current animation track
local currentTrack = controller.Core.PoseController:GetCurrentTrack()
print("Current speed:", currentTrack.Speed)
```

## Creating Custom Actions

```lua
-- Define a custom action
local customAction = {
    {
        id = "rbxassetid://123456789",
        weight = 10,
        speed = 1,
        fadeTime = 0.2
    }
}

-- Add it to the controller
controller.Action:CreateAction("myCustomAction", customAction)

-- Play it
controller.Action:PlayAction("myCustomAction")
```

## Cleanup

Always destroy the controller when done:

```lua
-- Cleanup (automatically called when character is destroyed)
controller:Destroy()
```

## Next Steps

- Learn about [Custom Animations](../guides/custom-animations.md)
- Explore the [API Reference](../api/simpleanimate.md)
- Check out more [Examples](../examples/basic-setup.md)