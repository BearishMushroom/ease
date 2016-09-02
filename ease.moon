--
-- ease
--
-- Copyright (c) 2016 BearishMushroom
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local *

combine = (t1, t2) ->
  for i, v in pairs t2
    t1[i] = v
  t1

class Ease
  _version: "0.1.0"
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

  add: (t) =>
    table.insert @alive, t
    t

  clear: =>
    @alive = {}

  update: (dt) =>
    for i, v in ipairs @alive
      v\update dt
      if v.progress >= 1
        table.remove @alive, i
        i -= 1
        v._on_end! if not v.dead and v._on_end

class Tween
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
        ->
          old!
          fn!
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

  stop: =>
    @progress = 1
    @dead = true

  update: (dt) =>
    if @delay > 0
      @delay -= dt
    else
      if @_on_start
        @_on_start!
        @_on_start = nil

      @progress += @speed * dt
      p = @progress
      x = p >= 1 and 1 or @parent.easings[@_type] p

      for j, k in pairs @tweens
        @obj[j] = k.start + x * k.left

      @_on_update @progress if @_on_update

ins = Ease!
setmetatable {
  :Tween
  :Ease
  tween: ins\tween
  update: ins\update
  _instance: ins
}, { __call: (...) => ins\tween ... }
