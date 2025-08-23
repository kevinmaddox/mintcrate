-- -----------------------------------------------------------------------------
-- MintCrate - Room
-- A scene or level in the game (a game state).
-- -----------------------------------------------------------------------------

local Room = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the Room class.
-- @param {string} roomName The room's name (identifier for debugging purposes).
-- @param {number} roomWidth The width of the room, in pixels.
-- @param {number} roomHeight The height of the room, in pixels.
-- @returns {Room} A new instance of the Room class.
function Room:new(roomName, roomWidth, roomHeight)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  -- Set room name
  self._roomName = roomName
  
  -- Set room dimensions
  self._roomWidth = roomWidth
  self._roomHeight = roomHeight
  
  -- Background color (clear color)
  self._backgroundColor = {r = 0, g = 0, b = 0}
  
  -- Fade in/out settings
  self._fadeLevel = 100
  self._currentFade = "fadeIn"
  self._fadeConf = {
    fadeIn = {enabled = false},
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
  return self._roomName
end

-- Returns the width of the room.
-- @returns {number} Room's width.
function Room:getRoomWidth()
  return self._roomWidth
end

-- Returns the width of the room.
-- @returns {number} Room's height.
function Room:getRoomHeight()
  return self._roomHeight
end

-- -----------------------------------------------------------------------------
-- Methods for configuring the room's fade in/out settings
-- -----------------------------------------------------------------------------

function Room:persistMusicOnLeave(enabled)
  -- TODO: This
end

function Room:persistSoundsOnLeave(enabled)
  -- TODO: This
end

function Room:configureFadeIn(fadeDuration, pauseDuration, color)
  local pauseDuration = pauseDuration or 0
  local color = color or {r=0, g=0, b=0}
  local r, g, b = love.math.colorFromBytes(color.r, color.g, color.b)
  
  self._fadeConf.fadeIn = {
    enabled = true,
    fadeFrames = fadeDuration,
    pauseFrames = pauseDuration,
    fadeValue = 100 / fadeDuration,
    fadeColor = {r=r, g=g, b=b}
  }
  
  self._fadeLevel = 0 - (self._fadeConf.fadeIn.fadeValue * pauseDuration)
end

function Room:configureFadeOut(fadeDuration, pauseDuration, color)
  local pauseDuration = pauseDuration or 0
  local color = color or {r=0, g=0, b=0}
  local r, g, b = love.math.colorFromBytes(color.r, color.g, color.b)
  
  self._fadeConf.fadeOut = {
    enabled = true,
    fadeFrames = fadeDuration,
    pauseFrames = pauseDuration,
    fadeValue = -100 / fadeDuration,
    fadeColor = {r=r, g=g, b=b}
  }
end

-- -----------------------------------------------------------------------------
-- Methods for managing the room's active tilemap
-- -----------------------------------------------------------------------------

-- Returns the full name of the currently-set tilemap graphic/layout pair.
-- @returns {string} Tilemap's full name.
function Room:_getTilemapLayoutName()
  return self._tilemapFullName
end

-- Returns the name of the currently-set tilemap graphic.
-- @returns {string} Tilemap graphic's name.
function Room:_getTilemapName()
  return self._tilemapName
end

-- Returns the name of the currently-set tilemap layout.
-- @returns {string} Tilemap layout's name.
function Room:_getLayoutName()
  return self._layoutName
end

-- Sets the tilemap graphic/layout for the room.
-- @param {string} tilemapLayoutName The full name of the tilemap.
function Room:setTilemap(tilemapLayoutName)
  self._tilemapFullName = tilemapLayoutName
  self._tilemapName = MintCrate.Util.string.split(tilemapLayoutName, '_')[1]
  self._layoutName = MintCrate.Util.string.split(tilemapLayoutName, '_')[2]
end

-- -----------------------------------------------------------------------------
-- Methods for changing room visuals
-- -----------------------------------------------------------------------------

-- Changes the room's background color.
-- @param {number} r The color's red value (0 - 255).
-- @param {number} g The color's green value (0 - 255).
-- @param {number} b The color's blue value (0 - 255).
function Room:setBackgroundColor(r, g, b)
  local r, g, b = love.math.colorFromBytes(r, g, b)
  self._backgroundColor = {r = r, g = g, b = b}
end

function Room:_getBackgroundColor()
  return
    self._backgroundColor.r,
    self._backgroundColor.g,
    self._backgroundColor.b
end

-- -----------------------------------------------------------------------------

return Room