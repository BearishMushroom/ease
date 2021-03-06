# ease
A minimal easing library for Moonscript and Lua.

![alt text](https://github.com/BearishMushroom/ease/blob/master/GIF.gif)

### Usage
Drop either `ease.moon` or `ease.lua` into your project and require it.
```lua
ease = require "ease"
```
Then call `update()` with the time passed since the last frame at the start of every frame to apply all the active easings.

Moonscript:
 ```moonscript
ease.update dt
```
Lua:
```lua
ease.update(dt)
```

You can now start easing any number of numeric values in a table by calling `ease.tween()`, or just `ease()`.

`ease()` takes in 3 arguments:
* The "source" table that the easing will be applied to.
* A table with all the desired end values for the source.
* How long the ease should take, measured in seconds.

Moonscript:
```moonscript
-- Move and rotate the 'player' table over 0.5 seconds.
ease player, {x: 200, y: 300, rot: 180}, 0.5
```
Lua:
```lua
-- Move and rotate the 'player' table over 0.5 seconds.
ease(player, {x = 200, y = 300, rot = 180}, 0.5)
```
### Tween
Calling `ease()` or `ease.tween()` will result in a `Tween` object.
The `Tween` object contains a few methods that allow you to change the behaviour of your ease.

#### `\wait(time)`
Causes the tween to wait `time` seconds before starting. The default value for this is `0`.

#### `\type(fn)`
Describes the function that should be used for easing. The valid functions are:

`linear` `quadratic` `cubic` `quartic` `quintic` `exponential`

`-quadratic` `-cubic` `-quartic` `-quintic` `-exponential`

`+-quadratic` `+-cubic` `+-quartic` `+-quintic` `+-exponential`

The - prefix means that the function is inverted. (Fast start, slow end.)

The +- prefix means that the function is centered. (Fast middle, slow ends.)

The default value for this is `-quadratic`.

Moonscript:
```moonscript
-- Move the player at a constant speed over 2 seconds.
tween = ease player, {x: 300}, 2
tween\type "linear"
```
Lua:
```lua
-- Move the player at a constant speed over 2 seconds.
local tween = ease(player, {x = 300}, 2)
tween:type("linear")
```

#### `\stop()`
Calling this will stop the tween, and it will stop being updated. Any tween that's been stopped should be considered destroyed.

#### `\update(dt)`
Calling this will progress the tween by `dt` seconds. Note that the library will call this on it's own, and calling it manually can lead to some problems.

#### `\tween([object,] tweens, time)`
Calling `tween()` will set up a new tween that will start once the current tween has finished.

If the `object` argument isn't supplied, the new tween will use the same object as the current tween.

This function will return the new tween, and not the current one.
Calling this function multiple times on the same tween will start all the chains at the same time.

Moonscript:
```moonscript
-- Move the player first on the x-axis, and then on y
tween = ease player, {x: 300}, 1
tween\tween {y: 500}, 2
```
Lua:
```lua
-- Move the player first on the x-axis, and then on y
local tween = ease(player, {x = 300}, 1)
tween:tween({y = 500}, 2)
```

#### `\spring([object,] springs [, damping, frequency])`
Calling `spring()` will set up a new spring that will start once the current tween has finished.

#### `\on_start(fn)`
Calls function `fn` once the tween starts, calling `on_start()` multiple times will add multiple callbacks.

#### `\on_update(fn)`
Calls function `fn` every time the tween updates, calling `on_update()` multiple times will add multiple callbacks.
This also passes the tween's progress in the range of `0-1`.

#### `\on_end(fn)`
Calls function `fn` once the tween ends, calling `on_end()` multiple times will add multiple callbacks.

### Chaining:
As all of `Tween`'s methods return the callee, they can be chained in a conventient manner.

Moonscript:
```moonscript
-- Move the player at a constant speed on x, wait one second, and then move on y
ease(player, {x: 300}, 5)\type("linear")\tween({y: 400}, 2)\wait 1
```
Lua:
```lua
-- Move the player at a constant speed on x, wait one second, and then move on y
ease(player, {x = 300}, 5):type("linear"):tween({y = 400}, 2):wait(1)
```
Moonscript's `with` blocks can also be used for a more readable syntax.
```moonscript
with ease player, {x: 300}, 5
  \type "linear"
  with \tween {y: 400}, 2
    \wait 1
```

### Spring
Calling `ease.spring()` will generate a `Spring` object.
A spring offers a different type of easing.
There are also many methods that can be used to alter your spring.

`ease.spring()` takes in up to 4 arguments:
* The 'source' table that the springing will be applied to.
* A table containing the target values for all springed fields.
* An optional damping factor for the algorithm. (default: `0.3`)
* An optional frequency for the springing oscillations. (default: `24`)

#### `\wait(time)`
Causes the spring to wait `time` seconds before starting. The default value for this is `0`.

#### `\stop()`
Calling this will stop the spring, and it will stop being updated. Any spring that's been stopped should be considered destroyed.

#### `\update(dt)`
Calling this will progress the spring by `dt` seconds. Note that the library will call this on it's own, and calling it manually can lead to some problems.

#### `\tween([object,] tweens, time)`
Calling `tween()` will set up a new tween that will start once the current spring has finished.

#### `\spring([object,] springs [, damping, frequency])`
Calling `spring()` will set up a new spring that will start once the current spring has finished.

#### `\on_start(fn)`
Calls function `fn` once the spring starts, calling `on_start()` multiple times will add multiple callbacks.

#### `\on_update(fn)`
Calls function `fn` every time the spring updates, calling `on_update()` multiple times will add multiple callbacks.

#### `\on_end(fn)`
Calls function `fn` once the spring ends, calling `on_end()` multiple times will add multiple callbacks.

### Chaining:
As all of `Spring`'s methods return the callee, they can be chained in a conventient manner.
You can also chain combinations of springs and tweens.

Moonscript:
```moonscript
-- Move the player at a constant speed on x, wait one second, and then move on y
ease.spring(player, {x: 300})\wait(0.1)\tween({y: 400}, 2)\wait 1
```
Lua:
```lua
-- Move the player at a constant speed on x, wait one second, and then move on y
ease.spring(player, {x = 300}):wait(0.1):tween({y = 400}, 2):wait(1)
```

### Lisence
This library is free software; you can redistribute it and/or modify it under the terms of the MIT license. See LICENSE for details.
