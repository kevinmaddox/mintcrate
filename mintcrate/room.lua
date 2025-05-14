-- -----------------------------------------------------------------------------
-- MintCrate - Room
-- A scene or level in the game (a game state).
-- -----------------------------------------------------------------------------

local Room = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the Room class.
-- @param {number} roomWidth The width of the room, in pixels.
-- @param {number} roomHeight The height of the room, in pixels.
-- @returns {Room} A new instance of the Room class.
function Room:new(roomWidth, roomHeight)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  -- Set room dimensions
  self._roomWidth = roomWidth
  self._roomHeight = roomHeight
  
  -- Background color (clear color)
  love.graphics.setBackgroundColor(0, 0, 0)
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for getting information about the room
-- -----------------------------------------------------------------------------

-- Returns the width of the room.
-- @returns {number} Room's width.
function Room:getWidth()
  return self._roomWidth
end

-- Returns the width of the room.
-- @returns {number} Room's height.
function Room:getHeight()
  return self._roomHeight
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
  love.graphics.setBackgroundColor(love.math.colorFromBytes(r, g, b))
end

-- -----------------------------------------------------------------------------

return Room