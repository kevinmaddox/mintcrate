-- -----------------------------------------------------------------------------
-- MintCrate - Backdrop
-- A static entity intended for background visuals.
-- -----------------------------------------------------------------------------

local Backdrop = MintCrate.Entity:new()

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
-- @returns {Backdrop} A new instance of the Backdrop class.
function Backdrop:new(instances, name, x, y, width, height, quad)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o._instances = instances
  o._name = name
  o._x = x
  o._y = y
  o._width = width
  o._height = height
  o._quad = quad
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for retrieving data about the Backdrop
-- -----------------------------------------------------------------------------

-- Returns the Backdrop width.
-- @returns {number} Backdrop width.
function Backdrop:getWidth()
  return self._width
end

-- Returns the Backdrop height.
-- @returns {number} Backdrop height.
function Backdrop:getHeight()
  return self._height
end

-- -----------------------------------------------------------------------------

return Backdrop