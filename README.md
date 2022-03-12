# CustomAnimationHandler
A special animation module for replicating &amp; handling animations.

# How to use?

Firstly, create a new animation handler object.

```lua

local AnimationModule = require(path / CustomAnimationHandler)
local AnimationObject = AnimationModule.new(AnimatorObject, yieldTime)

```

Then, you can preload, load, and stop animations easily! The module is fully performance friendly and object oriented.
Current function(s):

```
AnimationObject:PlayAnimation(AnimationName, SettingsTable);
AnimationObject:PreLoadAnimations(AnimationsTable, Callback);
AnimationObject:LoadAnimations(TableOfAnimations);
AnimationObject:StopAnimation(AnimationName, fadeTime)
```

# ⚠️ WARNING

To play an animation, it should be loaded with ```AnimationObject:LoadAnimation()``` function.
Animation module supports STRING ANIMATION IDs and Animation Instances.
