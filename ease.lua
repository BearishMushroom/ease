local pi, combine, Ease, Easing, Spring, Tween, ins
pi = 3.14159265359
combine = function(t1, t2)
  for i, v in pairs(t2) do
    t1[i] = v
  end
  return t1
end
do
  local _class_0
  local _base_0 = {
    _version = "0.1.3",
    _easings = {
      linear = function(x)
        return x
      end,
      quadratic = function(x)
        return x * x
      end,
      cubic = function(x)
        return x * x * x
      end,
      quartic = function(x)
        return x * x * x * x
      end,
      quintic = function(x)
        return x * x * x * x * x
      end,
      exponential = function(x)
        return 2 ^ (10 * (x - 1))
      end
    },
    tween = function(self, obj, tweens, time)
      return self:add(Tween(self, obj, tweens, time))
    end,
    spring = function(self, obj, springs, damping, freq)
      return self:add(Spring(self, obj, springs, damping, freq))
    end,
    add = function(self, t)
      table.insert(self.alive, t)
      return t
    end,
    clear = function(self)
      self.alive = { }
    end,
    update = function(self, dt)
      for i, v in ipairs(self.alive) do
        v:update(dt)
        if v.dead then
          table.remove(self.alive, i)
          i = i - 1
          if not v.stopped and v._on_end then
            v._on_end()
          end
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.alive = { }
      self.easings = { }
      do
        local _tbl_0 = { }
        for i, v in pairs(self._easings) do
          _tbl_0[i] = v
        end
        ins = _tbl_0
      end
      local outs
      do
        local _tbl_0 = { }
        for i, v in pairs(self._easings) do
          _tbl_0[("-" .. i)] = (function(x)
            return 1 - v(1 - x)
          end)
        end
        outs = _tbl_0
      end
      local inouts
      do
        local _tbl_0 = { }
        for i, v in pairs(self._easings) do
          _tbl_0[("+-" .. i)] = (function(x)
            x = x * 2
            if x < 1 then
              return .5 * v(x)
            else
              x = 2 - x
              return .5 * (1 - v(x)) + .5
            end
          end)
        end
        inouts = _tbl_0
      end
      self.easings = combine(self.easings, ins)
      self.easings = combine(self.easings, outs)
      self.easings = combine(self.easings, inouts)
    end,
    __base = _base_0,
    __name = "Ease"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Ease = _class_0
end
do
  local _class_0
  local _base_0 = {
    wait = function(self, t)
      if (type(t)) ~= 'number' then
        error("Expected numeric delay")
      end
      self.delay = t
      return self
    end,
    on_start = function(self, fn)
      local _exp_0 = self._on_start
      if nil == _exp_0 then
        self._on_start = fn
      else
        local old = self._on_start
        self._on_start = function()
          old()
          return fn()
        end
      end
      return self
    end,
    on_update = function(self, fn)
      local _exp_0 = self._on_update
      if nil == _exp_0 then
        self._on_update = fn
      else
        local old = self._on_update
        self._on_update = function(p)
          old(p)
          return fn(p)
        end
      end
      return self
    end,
    on_end = function(self, fn)
      local _exp_0 = self._on_end
      if nil == _exp_0 then
        self._on_end = fn
      else
        local old = self._on_end
        self._on_end = function()
          old()
          return fn()
        end
      end
      return self
    end,
    tween = function(self, obj, tweens, time)
      local t
      if not time then
        t = Tween(self.parent, self.obj, obj, tweens)
      else
        t = Tween(self.parent, obj, tweens, time)
      end
      self:on_end(function()
        return self.parent:add(t)
      end)
      return t
    end,
    spring = function(self, obj, springs, damping, freq)
      local t
      if not freq then
        t = Spring(self.parent, self.obj, obj, springs, damping)
      else
        t = Tween(self.parent, obj, springs, damping, freq)
      end
      self:on_end(function()
        return self.parent:add(t)
      end)
      return t
    end,
    stop = function(self)
      self.stopped = true
      self.dead = true
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Easing"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Easing = _class_0
end
do
  local _class_0
  local _parent_0 = Easing
  local _base_0 = {
    update = function(self, dt)
      if self.delay > 0 then
        self.delay = self.delay - dt
      else
        if self._on_start then
          self:_on_start()
          self._on_start = nil
        end
        local f = 1 + 2 * dt * self.damping * self.freq
        local oo = self.freq * self.freq
        local hoo = dt * oo
        local hhoo = dt * hoo
        local detInv = 1.0 / (f + hhoo)
        for j, k in pairs(self.springs) do
          local detX = f * k.current + dt * k.velocity + hhoo * k.target
          local detV = k.velocity + hoo * (k.target - k.current)
          if not ((math.abs((math.abs(k.start)) - (math.abs(k.target)))) / 100 >= (math.abs((math.abs(k.current)) - (math.abs(k.target)))) and math.abs(k.velocity) < 1) then
            k.current = detX * detInv
            k.velocity = detV * detInv
            self.obj[j] = k.current
          elseif not k.done then
            self.obj[j] = k.target
            k.done = true
            self.done = self.done + 1
          end
        end
        if self.done >= self.count then
          self.dead = true
        end
        local cb = self._on_update
        if cb then
          return cb()
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, obj, springs, damping, freq)
      self.parent = parent
      self.obj = obj
      self.delay = 0
      self.damping = damping or 0.3
      self.freq = freq or 24
      self.done = 0
      self.count = 0
      do
        local _tbl_0 = { }
        for i, v in pairs(springs) do
          _tbl_0[i] = v
        end
        self.springs = _tbl_0
      end
      for i, v in pairs(self.springs) do
        self.count = self.count + 1
        local x = self.obj[i]
        self.springs[i] = {
          velocity = 0,
          current = x,
          start = x,
          target = v
        }
      end
    end,
    __base = _base_0,
    __name = "Spring",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Spring = _class_0
end
do
  local _class_0
  local _parent_0 = Easing
  local _base_0 = {
    type = function(self, fn)
      if self.parent.easings[fn] then
        self._type = fn
        self.fn = self.parent.easings[fn]
      else
        error("Invalid easing type: " .. fn)
      end
      return self
    end,
    update = function(self, dt)
      if self.delay > 0 then
        self.delay = self.delay - dt
      else
        if self.progress >= 1 then
          self.dead = true
          return 
        end
        if self._on_start then
          self:_on_start()
          self._on_start = nil
        end
        self.progress = self.progress + (self.speed * dt)
        local p = self.progress
        local x = p >= 1 and 1 or self.parent.easings[self._type](p)
        for j, k in pairs(self.tweens) do
          self.obj[j] = k.start + x * k.left
        end
        local cb = self._on_update
        if cb then
          return cb(p)
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, parent, obj, tweens, time)
      self.parent = parent
      self.obj = obj
      self.speed = 1 / time
      self.progress = 0
      self.delay = 0
      self._type = "-quadratic"
      self:type(self._type)
      do
        local _tbl_0 = { }
        for i, v in pairs(tweens) do
          _tbl_0[i] = v
        end
        self.tweens = _tbl_0
      end
      for i, v in pairs(self.tweens) do
        local x = self.obj[i]
        self.tweens[i] = {
          start = x,
          left = v - x
        }
      end
    end,
    __base = _base_0,
    __name = "Tween",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Tween = _class_0
end
ins = Ease()
return setmetatable({
  Tween = Tween,
  Ease = Ease,
  Spring = Spring,
  tween = (function()
    local _base_0 = ins
    local _fn_0 = _base_0.tween
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  spring = (function()
    local _base_0 = ins
    local _fn_0 = _base_0.spring
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  update = (function()
    local _base_0 = ins
    local _fn_0 = _base_0.update
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  _instance = ins
}, {
  __call = function(self, ...)
    return ins:tween(...)
  end
})
