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
  
  o._wasDestroyed = false
  o._isVisible = true
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for management
-- -----------------------------------------------------------------------------

-- Returns the entity's position in the list of all current instances.
-- @returns {number} Entity's instance index.
function Entity:_getInstanceIndex(entityTable)
  local idx
  for i, item in ipairs(entityTable) do
    if (self == item) then
      idx = i
    end
  end
  return idx or -1
end

-- Removes the entity from the room and informs the engine to stop managing it.
-- @returns {nil} This can be used to dereference the instance via assignment.
function Entity:destroy()
  table.remove(self._instances, self:_getInstanceIndex(self._instances))
  table.remove(self._drawOrder, self:_getInstanceIndex(self._drawOrder))
  self._wasDestroyed = true
  return nil
end

-- Checks whether the entity has been previously destroyed.
-- @returns {boolean} Whether the entity was previously removed from the engine.
function Entity:exists()
  return not self._wasDestroyed
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
    self._drawOrder, self:_getInstanceIndex(self._drawOrder))
end

-- Pushes the entity one position down in the draw order.
function Entity:sendBackward()
  MintCrate.Util.table.moveItemDown(
    self._drawOrder, self:_getInstanceIndex(self._drawOrder))
end

-- Brings the entity to the top of the draw order.
function Entity:bringToFront()
  MintCrate.Util.table.moveItemToEnd(
    self._drawOrder, self:_getInstanceIndex(self._drawOrder))
end

-- Pushes the entity to the bottom of the draw order.
function Entity:sendToBack()
  MintCrate.Util.table.moveItemToStart(
    self._drawOrder, self:_getInstanceIndex(self._drawOrder))
end

-- -----------------------------------------------------------------------------
-- Methods for managing visibility
-- -----------------------------------------------------------------------------

-- Shows the entity if hidden.
function Entity:show()
  self._isVisible = true
end

-- Hides the entity if visible.
function Entity:hide()
  self._isVisible = false
end

-- Sets the visibility of the entity.
-- @param {boolean} Whether to show or hide the entity.
function Entity:setVisibility(isVisible)
  self._isVisible = isVisible
end

-- Returns whether the entity is visible or not.
-- @returns {boolean} Whether the entity is visible or not.
function Entity:isVisible()
  return self._isVisible
end

-- -----------------------------------------------------------------------------

return Entity