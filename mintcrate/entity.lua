-- -----------------------------------------------------------------------------
-- MintCrate - Entity
-- A visual game object that can be manipulated in various ways.
-- -----------------------------------------------------------------------------

local Entity = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the Entity class.
-- @returns {Entity} A new instance of the Entity class.
function Entity:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for management
-- -----------------------------------------------------------------------------

-- Returns the entity's position in the list of all current instances.
-- @returns {number} Entity's instance index.
function Entity:_getInstanceIndex()
  local idx
  for i, item in ipairs(self._instances) do
    if (self == item) then
      idx = i
    end
  end
  return idx or -1
end

-- Removes the entity from the room and informs the engine to stop managing it.
function Entity:destroy()
  table.remove(self._instances, self:_getInstanceIndex())
end

-- Returns the entity's name.
-- @returns {string} Entity's name.
function Entity:_getName()
  return self._name
end

-- -----------------------------------------------------------------------------
-- Methods for managing positions
-- -----------------------------------------------------------------------------

-- Returns the entity's X position.
-- @returns {number} Entity's X posiiton.
function Entity:getX()
  return self._x
end

-- Returns the entity's Y position.
-- @returns {number} Entity's Y position.
function Entity:getY()
  return self._y
end

-- Sets the entity's X position.
-- @param {number} The new X position.
function Entity:setX(x)
  self._x = x
  if (self._collider) then
    self._collider.x = x + self._colliderOffsetX
  end
end

-- Sets the entity's Y position.
-- @param {number} The new Y position.
function Entity:setY(y)
  self._y = y
  if (self._collider) then
    self._collider.y = y + self._colliderOffsetY
  end
end

-- -----------------------------------------------------------------------------
-- Methods for managing draw order
-- -----------------------------------------------------------------------------

-- Brings the entity one position up in the draw order.
function Entity:bringForward()
  MintCrate.Util.table.moveItemUp(
    self._instances, self:_getInstanceIndex())
end

-- Pushes the entity one position down in the draw order.
function Entity:sendBackward()
  MintCrate.Util.table.moveItemDown(
    self._instances, self:_getInstanceIndex())
end

-- Brings the entity to the top of the draw order.
function Entity:bringToFront()
  MintCrate.Util.table.moveItemToEnd(
    self._instances, self:_getInstanceIndex())
end

-- Pushes the entity to the bottom of the draw order.
function Entity:sendToBack()
  MintCrate.Util.table.moveItemToStart(
    self._instances, self:_getInstanceIndex())
end

-- -----------------------------------------------------------------------------

return Entity