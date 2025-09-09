-- -----------------------------------------------------------------------------
-- MintCrate - Room
-- A scene or level in the game (a game state).
-- -----------------------------------------------------------------------------

local Room = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Set class's type.
Room.type = "Room"

-- Creates an instance of the Room class.
-- @param {string} roomName The room's name (identifier for debugging purposes).
-- @param {number} roomWidth The width of the room, in pixels.
-- @param {number} roomHeight The height of the room, in pixels.
-- @returns {Room} A new instance of the Room class.
function Room:new(roomName, roomWidth, roomHeight)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  local f = 'new'
  
  -- Validate: roomName
  MintCrate.Assert.type(f, 'roomName', roomName, 'string')
  
  -- Validate: roomWidth
  MintCrate.Assert.type(f, 'roomWidth', roomWidth, 'number')
  
  MintCrate.Assert.condition(f,
    'roomWidth',
    (roomWidth > 0),
    'must be a value greater than 0'
  )
  
  -- Validate: roomHeight
  MintCrate.Assert.type(f, 'roomHeight', roomHeight, 'number')
  
  MintCrate.Assert.condition(f,
    'roomHeight',
    (roomHeight > 0),
    'must be a value greater than 0'
  )
  
  -- Set room name
  self._roomName = roomName
  
  -- Set room dimensions
  self._roomWidth  = roomWidth
  self._roomHeight = roomHeight
  
  -- Initialize background color (clear color)
  self._backgroundColor = {r = 0, g = 0, b = 0}
  
  -- Initialize fade in/out settings
  self._fadeLevel   = 100
  self._currentFade = "fadeIn"
  self._fadeConf    = {
    fadeIn  = {enabled = false},
    fadeOut = {enabled = false}
  }
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for getting information about the room
-- -----------------------------------------------------------------------------

-- Returns the room's name.
-- @returns {string} Room's name.
function Room:getRoomName()
  local f = 'getRoomName'
  
  MintCrate.Assert.self(f, self)
  
  return self._roomName
end

-- Returns the width of the room.
-- @returns {number} Room's width.
function Room:getRoomWidth()
  local f = 'getRoomWidth'
  
  MintCrate.Assert.self(f, self)
  
  return self._roomWidth
end

-- Returns the width of the room.
-- @returns {number} Room's height.
function Room:getRoomHeight()
  local f = 'getRoomHeight'
  
  MintCrate.Assert.self(f, self)
  
  return self._roomHeight
end

-- -----------------------------------------------------------------------------
-- Methods for configuring the room's fade in/out settings
-- -----------------------------------------------------------------------------

-- Sets the fade-in effect when the room is changed to.
-- @param {number} fadeDuration The length of the fade, in frames.
-- @param {number} pauseDuration How long until the fade starts, in frames.
-- @param {table} color The color of the fade, as a keyed RGB table, 0-255.
function Room:configureRoomFadeIn(fadeDuration, pauseDuration, color)
  local f = 'configureRoomFadeIn'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (pauseDuration == nil) then pauseDuration = 0 end
  if (color         == nil) then color = {}        end
  if (color.r       == nil) then color.r = 0       end
  if (color.g       == nil) then color.g = 0       end
  if (color.b       == nil) then color.b = 0       end
  
  -- Validate: fadeDuration
  MintCrate.Assert.type(f, 'fadeDuration', fadeDuration, 'number')
  
  MintCrate.Assert.condition(f,
    'fadeDuration',
    (fadeDuration >= 0),
    'cannot be a negative value'
  )
  
  -- Validate: pauseDuration
  MintCrate.Assert.type(f, 'pauseDuration', pauseDuration, 'number')
  
  MintCrate.Assert.condition(f,
    'pauseDuration',
    (pauseDuration >= 0),
    'cannot be a negative value'
  )
  
  -- Validate: color
  MintCrate.Assert.type(f, 'color', color, 'table')
  
  -- Validate: color.r
  MintCrate.Assert.type(f, 'color.r', color.r, 'number' )
  
  -- Validate: color.g
  MintCrate.Assert.type(f, 'color.g', color.g, 'number')
  
  -- Validate: color.b
  MintCrate.Assert.type(f, 'color.b', color.b, 'number')
  
  -- Constrain color values
  color.r = MintCrate.MathX.clamp(color.r, 0, 255)
  color.g = MintCrate.MathX.clamp(color.g, 0, 255)
  color.b = MintCrate.MathX.clamp(color.b, 0, 255)
  
  -- Convert 8-bit 0-255 values to floating point 0.0-1.0 values
  local r, g, b = love.math.colorFromBytes(color.r, color.g, color.b)
  
  -- Save fade-in configuration
  self._fadeConf.fadeIn = {
    enabled     = true,
    fadeFrames  = fadeDuration,
    pauseFrames = pauseDuration,
    fadeValue   = 100 / fadeDuration,
    fadeColor   = {r = r, g = g, b = b}
  }
  
  -- Set initial fade level to fully opaque since the room will be fading in
  self._fadeLevel = 0 - (self._fadeConf.fadeIn.fadeValue * pauseDuration)
end

-- Sets the fade-out effect when the room is changed from.
-- @param {number} fadeDuration The length of the fade, in frames.
-- @param {number} pauseDuration How long to pause after fade, in frames.
-- @param {table} color The color of the fade, as a keyed RGB table, 0-255.
function Room:configureRoomFadeOut(fadeDuration, pauseDuration, color)
  local f = 'configureRoomFadeOut'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (pauseDuration == nil) then pauseDuration = 0 end
  if (color         == nil) then color = {}        end
  if (color.r       == nil) then color.r = 0       end
  if (color.g       == nil) then color.g = 0       end
  if (color.b       == nil) then color.b = 0       end
  
  -- Validate: fadeDuration
  MintCrate.Assert.type(f, 'fadeDuration', fadeDuration, 'number')
  
  MintCrate.Assert.condition(f,
    'fadeDuration',
    (fadeDuration >= 0),
    'cannot be a negative value'
  )
  
  -- Validation: pauseDuration
  MintCrate.Assert.type(f, 'pauseDuration', pauseDuration, 'number')
  
  MintCrate.Assert.condition(f,
    'pauseDuration',
    (pauseDuration >= 0),
    'cannot be a negative value'
  )
  
  -- Validation: color
  MintCrate.Assert.type(f, 'color', color, 'table')
  
  
  -- Validation: color.r
  MintCrate.Assert.type(f, 'color.r', color.r, 'number')
  
  -- Validation: color.g
  MintCrate.Assert.type(f, 'color.g', color.g, 'number')
  
  -- Validation: color.b
  MintCrate.Assert.type(f, 'color.b', color.b, 'number')
  
  -- Constrain color values
  color.r = MintCrate.MathX.clamp(color.r, 0, 255)
  color.g = MintCrate.MathX.clamp(color.g, 0, 255)
  color.b = MintCrate.MathX.clamp(color.b, 0, 255)
  
  -- Convert 8-bit 0-255 values to floating point 0.0-1.0 values
  local r, g, b = love.math.colorFromBytes(color.r, color.g, color.b)
  
  -- Save fade-out configuration
  self._fadeConf.fadeOut = {
    enabled     = true,
    fadeFrames  = fadeDuration,
    pauseFrames = pauseDuration,
    fadeValue   = -100 / fadeDuration,
    fadeColor   = {r = r, g = g, b = b}
  }
end

-- -----------------------------------------------------------------------------
-- Methods for changing room visuals
-- -----------------------------------------------------------------------------

-- Changes the room's background color.
-- @param {number} r The color's red value (0 - 255).
-- @param {number} g The color's green value (0 - 255).
-- @param {number} b The color's blue value (0 - 255).
function Room:setRoomBackgroundColor(r, g, b)
  local f = 'setBackgroundColor'
  MintCrate.Assert.self(f, self)
  
  -- Validate: r
  MintCrate.Assert.type(f, 'r', r, 'number')
  
  -- Validate: g
  MintCrate.Assert.type(f, 'g', g, 'number')
  
  -- Validate: b
  MintCrate.Assert.type(f, 'b', b, 'number')
  
  -- Constrain color values
  r = MintCrate.MathX.clamp(r, 0, 255)
  g = MintCrate.MathX.clamp(g, 0, 255)
  b = MintCrate.MathX.clamp(b, 0, 255)
  
  -- Convert 8-bit 0-255 values to floating point 0.0-1.0 values
  r, g, b = love.math.colorFromBytes(r, g, b)
  
  -- Set background clear color
  self._backgroundColor = {r = r, g = g, b = b}
end

function Room:_getRoomBackgroundColor()
  return
    self._backgroundColor.r,
    self._backgroundColor.g,
    self._backgroundColor.b
end

-- -----------------------------------------------------------------------------

return Room