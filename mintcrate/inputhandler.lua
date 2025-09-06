-- -----------------------------------------------------------------------------
-- MintCrate - InputHandler
-- Handles player input and provides abstractions for keyboard inputs.
-- -----------------------------------------------------------------------------

local InputHandler = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Set class's type.
InputHandler.type = "InputHandler"

-- Creates an instance of the InputHandler class.
-- @returns {InputHandler} A new instance of the InputHandler class.
function InputHandler:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o._TYPES = {
    KB = 0,
    GP = 1
  }
  
  o._joystickNumber = 1
  o._inputs = {}
  o._repeatWaitTime = 25
  o._repeatDelay = 3
  o._analogDeadzone = 0.30
  o._triggerDeadzone = 0.30
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for configuration
-- -----------------------------------------------------------------------------

-- Maps an input between the InputHandler instance and the player's keyboard.
-- @param {string} inputName Name of the input (used when getting its state).
-- @param {string} inputCode Keyboard input's scancode.
function InputHandler:mapKeyboardInput(inputName, inputCode)
  local f = 'mapKeyboardInput'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'inputName', inputName, 'string')
  MintCrate.Assert.type(f, 'inputCode', inputCode, 'string')
  
  self:_mapInput(self._TYPES.KB, inputName, inputCode)
end

-- Maps an input between the InputHandler instance and the player's gamepad.
-- @param {string} inputName Name of the input (used when getting its state).
-- @param {string} inputCode Gamepad input button/analog/trigger code.
function InputHandler:mapGamepadInput(inputName, inputCode)
  local f = 'mapGamepadInput'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'inputName', inputName, 'string')
  MintCrate.Assert.type(f, 'inputCode', inputCode, 'string')
  
  self:_mapInput(self._TYPES.GP, inputName, inputCode)
end

-- Handles mapping initialization for both keyboard and gamepad maps.
-- @param {number} inputType Device type (keyboard or gamepad).
-- @param {string} inputName Name of the input (used when getting its state).
-- @param {string} inputCode Device input's scan/button/analog/trigger code.
function InputHandler:_mapInput(inputType, inputName, inputCode)
  inputCode = inputCode
  
  if not self._inputs[inputName] then
    self._inputs[inputName] = {
      codes = {},
      held = false,
      pressed = false,
      released = false,
      repeatTimer = 0
    }
  end
  
  -- Check if input already exists, and effectively flip the entries if it does
  for name, input in pairs(self._inputs) do
    if input.codes[inputType] == inputCode and name ~= inputName then
      input.codes[inputType] = self._inputs[inputName].codes[inputType]
    end
  end
  
  self._inputs[inputName].codes[inputType] = inputCode
end

-- Specifies the joystick to listen to inputs from.
-- @param {number} joystickNumber Joystick index number assigned by the OS.
function InputHandler:setJoystickNumber(joystickNumber)
  local f = 'setJoystickNumber'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'joystickNumber', joystickNumber, 'number')
  
  self._joystickNumber = joystickNumber
end

-- Sets the deadzone value (minimum input threshold) for analog joysticks.
-- @param {number} deadzoneValue Minimum input threshold, between 0 and 1.
function InputHandler:setAnalogDeadzone(deadzoneValue)
  local f = 'setAnalogDeadzone'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'deadzoneValue', deadzoneValue, 'number')
  
  deadzoneValue = MintCrate.MathX.clamp(deadzoneValue, 0, 1)
  
  self._analogDeadzone = deadzoneValue
end

-- Sets the deadzone value (minimum input threshold) for analog triggers.
-- @param {number} deadzoneValue Minimum input threshold, between 0 and 1.
function InputHandler:setTriggerDeadzone(deadzoneValue)
  local f = 'setTriggerDeadzone'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'deadzoneValue', deadzoneValue, 'number')
  
  deadzoneValue = MintCrate.MathX.clamp(deadzoneValue, 0, 1)
  
  self._triggerDeadzone = deadzoneValue
end

-- Specifies the interval on which repeat-toggled inputs should fire.
-- Useful for cursor scrolling in menu systems.
-- @param {number} repeatWaitTime How many frames to wait before repeat firing.
-- @param {number} repeatDelay How long wait between repeat fires.
function InputHandler:setRepeatValues(repeatWaitTime, repeatDelay)
  local f = 'setRepeatValues'
  MintCrate.Assert.self(f, self)
  
  MintCrate.Assert.type(f, 'repeatWaitTime', repeatWaitTime, 'number')
  
  MintCrate.Assert.cond(f,
    'repeatWaitTime',
    (repeatWaitTime >= 0),
    'cannot be a negative value'
  )
  
  MintCrate.Assert.type(f, 'repeatDelay', repeatDelay, 'number')
  
  MintCrate.Assert.cond(f,
    'repeatDelay',
    (repeatDelay >= 0),
    'cannot be a negative value'
  )
  
  self._repeatWaitTime = repeatWaitTime
  self._repeatDelay = repeatDelay
end

-- -----------------------------------------------------------------------------
-- Methods for retrieving input states
-- -----------------------------------------------------------------------------

-- Checks whether an input was pressed on the current frame.
-- @param {string} inputName string The name of the input.
-- @param {boolean} enableRepeat boolean Whether the input should repeat fire.
-- @returns {boolean} Whether the input was pressed.
function InputHandler:pressed(inputName, enableRepeat)
  local f = 'pressed'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'inputName', inputName, 'string')
  
  if (enableRepeat == nil) then enableRepeat = false end
  
  MintCrate.Assert.type(f, 'enableRepeat', enableRepeat, 'boolean')
  
  inputName = tostring(inputName)
  local state = false
  local input = self._inputs[inputName]
  
  if
    input.pressed or
    (enableRepeat and input.repeatTimer == self._repeatWaitTime)
  then
    state = true
  end
  
  return state
end

-- Checks whether an input was released on the current frame.
-- @param {string} inputName The name of the input.
-- @returns {boolean} Whether the input was released.
function InputHandler:released(inputName)
  local f = 'released'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'inputName', inputName, 'string')
  
  inputName = tostring(inputName)
  return self._inputs[inputName].released
end

-- Checks whether an input is being held down.
-- @param {string} inputName The name of the input.
-- @returns {boolean} Whether the input is being held.
function InputHandler:held(inputName)
  local f = 'held'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'inputName', inputName, 'string')
  
  inputName = tostring(inputName)
  return self._inputs[inputName].held
end

-- Retrieves data regarding the states of analog joysticks and triggers.
-- @returns {table} Analog joystick/trigger axis values.
function InputHandler:getAxes()
  local f = 'getAxes'
  MintCrate.Assert.self(f, self)
  
  local axes = {
    left    = {x = 0, y = 0},
    right   = {x = 0, y = 0},
    trigger = {left = 0, right = 0}
  }
  
  local joystick = love.joystick.getJoysticks()[self._joystickNumber]
  
  if joystick then
    for _, set in ipairs({
      {"left",    "x",     self._analogDeadzone},
      {"left",    "y",     self._analogDeadzone},
      {"right",   "x",     self._analogDeadzone},
      {"right",   "y",     self._analogDeadzone},
      {"trigger", "left",  self._triggerDeadzone},
      {"trigger", "right", self._triggerDeadzone},
    }) do
      local input = set[1]
      local axis = set[2]
      local deadzone = set[3]
      local val = joystick:getGamepadAxis(input..axis)
      
    -- Threshold deadzones
      if val > 0 then
        val = MintCrate.MathX.thresholdAbove(val, deadzone, 0)
      elseif val < 0 then
        val = MintCrate.MathX.thresholdBelow(val, -deadzone, 0)
      end
      
      axes[input][axis] = val
    end
  end
  
  return axes
end

-- -----------------------------------------------------------------------------
-- Methods for updating
-- -----------------------------------------------------------------------------

-- Updates the Input Handler.
-- @param {table} keystates The raw on/off state of keyboard keys.
-- @param {table} joystates The raw on/off state of joystick buttons.
function InputHandler:_update(keystates, joystates)
  local joystick = love.joystick.getJoysticks()[self._joystickNumber]
  local ax = self:getAxes()
  
  for _, input in pairs(self._inputs) do
    input.pressed = false
    input.released = false
    
    local down = false
    
    -- Keyboard keys
    local kbCode = input.codes[self._TYPES.KB]
    if kbCode and keystates[kbCode] and keystates[kbCode].held then
      down = true
    end
    
    -- Joysticks
    local gpCode = input.codes[self._TYPES.GP]
    if gpCode and joystick then
      local joystickId = joystick:getID()
      -- Standard button press
      if joystates[joystickId] and joystates[joystickId][gpCode] then
        down = true
      end
      
      -- Special handling for triggers/analogs.
      -- This is so you can register them as digital inputs if desired.
      if
        (gpCode=='triggerleft'   and ax.trigger.left>=self._triggerDeadzone)  or
        (gpCode=='triggerright'  and ax.trigger.right>=self._triggerDeadzone) or
        (gpCode=='analogleftx+'  and ax.left.x>=self._analogDeadzone)         or
        (gpCode=='analogleftx-'  and ax.left.x<=-self._analogDeadzone)        or
        (gpCode=='analoglefty+'  and ax.left.y>=self._analogDeadzone)         or
        (gpCode=='analoglefty-'  and ax.left.y<=-self._analogDeadzone)        or
        (gpCode=='analogrightx+' and ax.left.x>=self._analogDeadzone)         or
        (gpCode=='analogrightx-' and ax.left.x<=-self._analogDeadzone)        or
        (gpCode=='analogrighty+' and ax.left.y>=self._analogDeadzone)         or
        (gpCode=='analogrighty-' and ax.left.y<=-self._analogDeadzone)
      then
        down = true
      end
    end
    
    -- Handle setting held/pressed/released values.
    if down then
      if not input.held then
        input.pressed = true
        input.repeatTimer = 0
      end
      input.held = true
    else
      if input.held then
        input.released = true
        input.repeatTimer = 0
      end
      input.held = false
    end
    
    -- Handle press & release timer & state
    if input.held then
      if input.repeatTimer >= self._repeatWaitTime then
        input.repeatTimer = input.repeatTimer - self._repeatDelay
      end
      
      input.repeatTimer = input.repeatTimer + 1
    end
  end
end

-- -----------------------------------------------------------------------------

return InputHandler