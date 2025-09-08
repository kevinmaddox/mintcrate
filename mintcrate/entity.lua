-- -----------------------------------------------------------------------------
-- MintCrate - Entity
-- A visual game object that can be manipulated in various ways.
-- -----------------------------------------------------------------------------

local Entity = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Set class's type.
Entity.type = "Entity"

-- Creates an instance of the Entity class.
-- @returns {Entity} A new instance of the Entity class.
function Entity:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  -- Initialize properties
  o._wasDestroyed = false
  o._isVisible    = true
  o._opacity      = 1.0
  
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
  local f = 'destroy'
  MintCrate.Assert.self(f, self)
  
  -- Remove entity from MintCrate's instance and draw order tables
  table.remove(self._instances, self:_getInstanceIndex(self._instances))
  table.remove(self._drawOrder, self:_getInstanceIndex(self._drawOrder))
  
  -- Mark that the entity was destroyed
  self._wasDestroyed = true
  
  -- Return nil for convenience (to nil out an instance variable via assignment)
  return nil
end

-- Checks whether the entity has been previously destroyed.
-- @returns {boolean} Whether the entity was previously removed from the engine.
function Entity:exists()
  local f = 'exists'
  MintCrate.Assert.self(f, self)
  
  return (not self._wasDestroyed)
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
  local f = 'getX'
  MintCrate.Assert.self(f, self)
  
  return self._x
end

-- Returns the entity's Y position.
-- @returns {number} Entity's Y position.
function Entity:getY()
  local f = 'getY'
  MintCrate.Assert.self(f, self)
  
  return self._y
end

-- Sets the entity's X position.
-- @param {number} The new X position.
function Entity:setX(x)
  local f = 'setX'
  MintCrate.Assert.self(f, self)
  
  -- Validate: x
  MintCrate.Assert.type(f, 'x', x, 'number')
  
  -- Update x position value
  self._x = x
  
  -- Update collider's x position value
  if (self._collider) then
    self._collider.x = x + self._colliderOffsetX
  end
end

-- Sets the entity's Y position.
-- @param {number} The new Y position.
function Entity:setY(y)
  local f = 'setY'
  MintCrate.Assert.self(f, self)
  
  -- Validate: y
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  -- Update y position value
  self._y = y
  
  -- Update collider's y position value
  if (self._collider) then
    self._collider.y = y + self._colliderOffsetY
  end
end

-- Moves the entity horizontally by a specified number of pixels.
-- @param {number} pixels How many pixels to move the entity along the X axis.
function Entity:moveX(pixels)
  local f = 'moveX'
  MintCrate.Assert.self(f, self)
  
  -- Validate: pixels
  MintCrate.Assert.type(f, 'pixels', pixels, 'number')
  
  -- Update x position
  self:setX(self._x + pixels)
end

-- Moves the entity vertically by a specified number of pixels.
-- @param {number} pixels How many pixels to move the entity along the Y axis.
function Entity:moveY(pixels)
  local f = 'moveY'
  MintCrate.Assert.self(f, self)
  
  -- Validate: pixels
  MintCrate.Assert.type(f, 'pixels', pixels, 'number')
  
  -- Update y position
  self:setY(self._y + pixels)
end

-- -----------------------------------------------------------------------------
-- Methods for managing draw order
-- -----------------------------------------------------------------------------

-- Brings the entity one position up in the draw order.
function Entity:bringForward()
  local f = 'bringForward'
  MintCrate.Assert.self(f, self)
  
  -- Rearrange entity
  MintCrate.Util.table.moveItemUp(
    self._drawOrder,
    self:_getInstanceIndex(self._drawOrder))
end

-- Pushes the entity one position down in the draw order.
function Entity:sendBackward()
  local f = 'sendBackward'
  MintCrate.Assert.self(f, self)
  
  -- Rearrange entity
  MintCrate.Util.table.moveItemDown(
    self._drawOrder,
    self:_getInstanceIndex(self._drawOrder))
end

-- Brings the entity to the top of the draw order.
function Entity:bringToFront()
  local f = 'bringToFront'
  MintCrate.Assert.self(f, self)
  
  -- Rearrange entity
  MintCrate.Util.table.moveItemToEnd(
    self._drawOrder,
    self:_getInstanceIndex(self._drawOrder))
end

-- Pushes the entity to the bottom of the draw order.
function Entity:sendToBack()
  local f = 'sendToBack'
  MintCrate.Assert.self(f, self)
  
  -- Rearrange entity
  MintCrate.Util.table.moveItemToStart(
    self._drawOrder,
    self:_getInstanceIndex(self._drawOrder))
end

-- -----------------------------------------------------------------------------
-- Methods for managing visibility
-- -----------------------------------------------------------------------------

-- Returns whether the entity is visible or not.
-- @returns {boolean} Whether the entity is visible or not.
function Entity:isVisible()
  local f = 'isVisible'
  MintCrate.Assert.self(f, self)
  
  return self._isVisible
end

-- Sets the visibility of the entity.
-- @param {boolean} Whether to show or hide the entity.
function Entity:setVisibility(isVisible)
  local f = 'setVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: isVisible
  MintCrate.Assert.type(f, 'isVisible', isVisible, 'boolean')
  
  -- Set visibility state
  self._isVisible = isVisible
end

-- Returns the entity's current opacity value.
-- @returns {number} Opacity value.
function Entity:getOpacity()
  local f = 'getOpacity'
  MintCrate.Assert.self(f, self)
  
  return self._opacity
end

-- Sets the entity's opacity value.
-- @param {number} opacity The new opacity value (0.0 - 1.0) (1.0 is opaque).
function Entity:setOpacity(opacity)
  local f = 'setOpacity'
  MintCrate.Assert.self(f, self)
  
  -- Validate: opacity
  MintCrate.Assert.type(f, 'opacity', opacity, 'number')
  
  -- Set opacity
  self._opacity = MintCrate.MathX.clamp(opacity, 0, 1)
end

-- Adds/subtracts from the entity's current opacity level.
-- @param {number} opacity The opacity value to adjust by.
function Entity:adjustOpacity(opacity)
  local f = 'setOpacity'
  MintCrate.Assert.self(f, self)
  
  -- Validate opacity
  MintCrate.Assert.type(f, 'opacity', opacity, 'number')
  
  -- Set opacity
  self._opacity = MintCrate.MathX.clamp(self._opacity + opacity, 0, 1)
end

-- -----------------------------------------------------------------------------

return Entity