-- -----------------------------------------------------------------------------
-- MintCrate - Backdrop
-- A static entity intended for background visuals.
-- -----------------------------------------------------------------------------

local Backdrop = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the Backdrop class.
-- @param {table} instances List of all Backdrops being managed by the engine.
-- @param {string} name Name of the Backdrop, for definition & instantiation.
-- @param {number} x Backdrop's starting X position.
-- @param {number} y Backdrop's starting X position.
-- @param {number} width Width of the Backdrop, in pixels.
-- @param {number} height Height of the Backdrop, in pixels.
-- @param {Quad} quad Specifications for tiling Backdrops.
-- @param {number} scaleX Used to scale non-mosaic Backdrops correctly.
-- @param {number} scaleY Used to scale non-mosaic Backdrops correctly.
-- @returns {Backdrop} A new instance of the Backdrop class.
function Backdrop:new(instances, name, x, y, width, height, quad,
  scaleX, scaleY
)
  local o = MintCrate.Entity:new()
  setmetatable(self, {__index = MintCrate.Entity})
  setmetatable(o, self)
  self.__index = self
  
  o._instances = instances
  o._name = name
  o._x = x
  o._y = y
  o._width = width
  o._height = height
  o._quad = quad
  o._scaleX = scaleX
  o._scaleY = scaleY
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for retrieving data about the Backdrop
-- -----------------------------------------------------------------------------

-- Returns the full Backdrop width.
-- @returns {number} Backdrop width.
function Backdrop:getWidth()
  return self._width
end

-- Returns the full Backdrop height.
-- @returns {number} Backdrop height.
function Backdrop:getHeight()
  return self._height
end

-- Returns the width of only the backdrop texture.
-- @returns {number} Backdrop texture width.
function Backdrop:getTextureWidth()
  local w, h = self._quad:getTextureDimensions()
  return w
end

-- Returns the height of only the backdrop texture.
-- @returns {number} Backdrop texture height.
function Backdrop:getTextureHeight()
  local w, h = self._quad:getTextureDimensions()
  return h
end

-- -----------------------------------------------------------------------------

return Backdrop