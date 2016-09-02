--
-- ease
--
-- Copyright (c) 2016 BearishMushroom
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local *

pi = 3.14159265359

combine = (t1, t2) ->
  for i, v in pairs t2
    t1[i] = v
  t1

class Ease
  _version: "0.1.3"
  _easings:
    linear:      (x) -> x
    quadratic:   (x) -> x * x
    cubic:       (x) -> x * x * x
    quartic:     (x) -> x * x * x * x
    quintic:     (x) -> x * x * x * x * x
    exponential: (x) -> 2 ^ (10 * (x - 1))

  new: =>
    @alive = {}
    @easings = {}
    ins = {i, v for i, v in pairs @_easings}
    outs = {("-"..i), ((x) -> 1 - v 1 - x) for i, v in pairs @_easings}
    inouts = {("+-"..i), ((x) ->
        x = x * 2
        if x < 1
          return .5 * v x
        else
          x = 2 - x
          return .5 * (1 - v x) + .5
      ) for i, v in pairs @_easings}

    @easings = combine @easings, ins
    @easings = combine @easings, outs
    @easings = combine @easings, inouts

  tween: (obj, tweens, time) =>
    @add Tween @, obj, tweens, time

  spring: (obj, springs, damping, freq) =>
    @add Spring @, obj, springs, damping, freq

  add: (t) =>
    table.insert @alive, t
    t

  clear: =>
    @alive = {}

  update: (dt) =>
    for i, v in ipairs @alive
      v\update dt
      if v.dead
        table.remove @alive, i
        i -= 1
        v._on_end! if not v.stopped and v._on_end

class Easing
  wait: (t) =>
    if (type t) != 'number'
      error "Expected numeric delay"
    @delay = t
    @

  on_start: (fn) =>
    @_on_start = switch @_on_start
      when nil
        fn
      else
        old = @_on_start
        ->
          old!
          fn!
    @

  on_update: (fn) =>
    @_on_update = switch @_on_update
      when nil
        fn
      else
        old = @_on_update
        (p) ->
          old p
          fn p
    @

  on_end: (fn) =>
    @_on_end = switch @_on_end
      when nil
        fn
      else
        old = @_on_end
        ->
          old!
          fn!
    @

  tween: (obj, tweens, time) =>
    local t
    if not time
      t = Tween @parent, @obj, obj, tweens
    else
      t = Tween @parent, obj, tweens, time
    @on_end -> @parent\add t
    t

  spring: (obj, springs, damping, freq) =>
    local t
    if not freq
      t = Spring @parent, @obj, obj, springs, damping
    else
      t = Tween @parent, obj, springs, damping, freq
    @on_end -> @parent\add t
    t

  stop: =>
    @stopped = true
    @dead = true

class Spring extends Easing
  new: (parent, obj, springs, damping, freq) =>
    @parent = parent
    @obj = obj
    @delay = 0
    @damping = damping or 0.3
    @freq = freq or 24
    @done = 0
    @count = 0
    @springs = {i, v for i, v in pairs springs}
    for i, v in pairs @springs
      @count += 1
      x = @obj[i]
      @springs[i] =
        velocity: 0
        current: x
        start: x
        target: v

  update: (dt) =>
    if @delay > 0
      @delay -= dt
    else
      if @_on_start
        @_on_start!
        @_on_start = nil

      f = 1 + 2 * dt * @damping * @freq
      oo = @freq * @freq
      hoo = dt * oo
      hhoo = dt * hoo
      detInv = 1.0 / (f + hhoo)

      for j, k in pairs @springs
        detX = f * k.current + dt * k.velocity + hhoo * k.target
        detV = k.velocity + hoo * (k.target - k.current)
        if not ((math.abs (math.abs k.start) - (math.abs k.target)) / 100 >=
          (math.abs (math.abs k.current) - (math.abs k.target)) and math.abs(k.velocity) < 1)
          k.current = detX * detInv
          k.velocity = detV * detInv
          @obj[j] = k.current
        elseif not k.done
          @obj[j] = k.target
          k.done = true
          @done += 1

      if @done >= @count
        @dead = true

      cb = @_on_update
      cb! if cb

class Tween extends Easing
  new: (parent, obj, tweens, time) =>
    @parent = parent
    @obj = obj
    @speed = 1 / time
    @progress = 0
    @delay = 0
    @_type = "-quadratic"
    @type @_type
    @tweens = {i, v for i, v in pairs tweens}
    for i, v in pairs @tweens
      x = @obj[i]
      @tweens[i] =
        start: x
        left: v - x

  type: (fn) =>
    if @parent.easings[fn]
      @_type = fn
      @fn = @parent.easings[fn]
    else
      error "Invalid easing type: " .. fn
    @

  update: (dt) =>
    if @delay > 0
      @delay -= dt
    else
      if @progress >= 1
        @dead = true
        return

      if @_on_start
        @_on_start!
        @_on_start = nil

      @progress += @speed * dt
      p = @progress
      x = p >= 1 and 1 or @parent.easings[@_type] p

      for j, k in pairs @tweens
        @obj[j] = k.start + x * k.left

      cb = @_on_update
      cb p if cb

ins = Ease!
setmetatable {
  :Tween
  :Ease
  :Spring
  tween: ins\tween
  spring: ins\spring
  update: ins\update
  _instance: ins
}, { __call: (...) => ins\tween ... }
