-- -----------------------------------------------------------------------------
-- MintCrate - Active
-- An animated entity that supports collisions and action points.
-- -----------------------------------------------------------------------------

local Active = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Set class's type.
Active.type = "Active"

-- Creates an instance of the Active class.
-- @param {table} instances List of all Actives being managed by the engine.
-- @param {string} name Name of the Active, for definition & instantiation.
-- @param {number} x Active's starting X position.
-- @param {number} y Active's starting Y position.
-- @param {number} colliderShape Shape of the Active's collision mask.
-- @param {number} colliderOffsetX X offset position of the collision mask.
-- @param {number} colliderOffsetY Y offset position of the collision mask.
-- @param {number} colliderWidth Width of the collision mask (rectangle type).
-- @param {number} colliderHeight Height of the collision mask (rectangle type).
-- @param {number} colliderRadius Radius of the collision mask (circle type).
-- @param {table} animationList List of all of the Active's animations.
-- @param {string} initialAnimationName Active's starting animation name.
-- @param {string} initialAnimation Active's starting animation data.
-- @returns {Active} A new instance of the Active class.
function Active:new(instances, drawOrder, name, x, y, colliderShape,
  colliderOffsetX, colliderOffsetY, colliderWidth, colliderHeight,
  colliderRadius, animationList, initialAnimationName, initialAnimation
)
  local o = MintCrate.Entity:new()
  setmetatable(self, {__index = MintCrate.Entity})
  setmetatable(o, self)
  self.__index = self
  
  o._entityType = 'active'
  
  o._instances = instances
  o._drawOrder = drawOrder
  o._name = name
  o._x = x
  o._y = y
  
  o._angle = 0
  o._rotatedWidth = 0
  o._rotatedHeight = 0
  
  o._scaleX = 1
  o._scaleY = 1
  o._flippedHorizontally = false
  o._flippedVertically = false
  o._collider = {
    s = colliderShape,
    x = x + colliderOffsetX,
    y = y + colliderOffsetY,
    w = colliderWidth,
    h = colliderHeight,
    r = colliderRadius,
    collision = false,
    mouseOver = false
  }
  o._colliderOffsetX = colliderOffsetX
  o._colliderOffsetY = colliderOffsetY
  
  o._animationList = animationList
  o._animationName = initialAnimationName
  o._currentAnimation = initialAnimation
  o._animationFrameNumber = 1
  o._animationFrameTimer = 0
  
  -- The current global position of the current animation frame's action point.
  o._actionPointX = 0
  o._actionPointY = 0
  
  return o
end

-- -----------------------------------------------------------------------------
-- Methods for performing graphical changes
-- -----------------------------------------------------------------------------

-- Returns the current angle, in degrees.
-- @returns {number} The current angle.
function Active:getAngle()
  local f = 'getAngle'
  MintCrate.Assert.self(f, self)
  
  return self._angle
end

-- Sets the active's angle.
-- @param {number} degrees The new angle, in degrees.
function Active:setAngle(degrees)
  local f = 'setAngle'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'degrees', degrees, 'number')
  
  self._angle = degrees
end

-- Rotates the active by a specified number of degrees.
-- @param {number} degrees The number of degrees to rotate by.
function Active:rotate(degrees)
  local f = 'rotate'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'degrees', degrees, 'number')
  
  self._angle = self._angle + degrees
end

-- Makes the active look at a specific point.
-- @param {number} x The X coordinate of the point to look at.
-- @param {number} y The Y coordinate of the point to look at.
function Active:angleLookAtPoint(x, y)
  local f = 'angleLookAtPoint'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'x', x, 'number')
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  local ax = self:getX()
  local ay = self:getY()
  
  local vx = x - ax
  local vy = y - ay
  
  local radians = math.atan2(vy, vx)
  local degrees = radians * (180 / math.pi)
  self:setAngle(degrees)
end

-- Returns the active's horizontal scaling value.
-- @returns {number} Horizontal scaling value.
function Active:getScaleX()
  local f = 'getScaleX'
  MintCrate.Assert.self(f, self)
  
  return self._scaleX
end

-- Returns the active's vertical scaling value.
-- @returns {number} Vertical scaling value.
function Active:getScaleY()
  local f = 'getScaleY'
  MintCrate.Assert.self(f, self)
  
  return self._scaleY
end

-- Sets the active's horizontal scaling value.
-- @param {number} scaleX The new horizontal scaling value (1.0 is normal).
function Active:setScaleX(scaleX)
  local f = 'setScaleX'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'scaleX', scaleX, 'number')
  
  self._scaleX = scaleX
end

-- Sets the active's vertical scaling value.
-- @param {number} scaleX The new vertical scaling value (1.0 is normal).
function Active:setScaleY(scaleY)
  local f = 'setScaleY'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'scaleY', scaleY, 'number')
  
  self._scaleY = scaleY
end

-- Scales the active horizontally by a specified amount.
-- @param {number} scaleX The amount to scale horizontally by.
function Active:scaleX(scaleX)
  local f = 'scaleX'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'scaleX', scaleX, 'number')
  
  self._scaleX = self._scaleX + scaleX
end

-- Scales the active vertically by a specified amount.
-- @param {number} scaleY The amount to scale vertically by.
function Active:scaleY(scaleY)
  local f = 'scaleY'
  MintCrate.Assert.self(f, self)
  MintCrate.Assert.type(f, 'scaleY', scaleY, 'number')
  
  self._scaleY = self._scaleY + scaleY
end

-- Returns whether the active is flipped horizontally.
-- @returns {boolean} Horizontal-flip state.
function Active:isFlippedHorizontally()
  local f = 'isFlippedHorizontally'
  MintCrate.Assert.self(f, self)
  
  return self._flippedHorizontally
end

-- Returns whether the active is flipped vertically.
-- @returns {boolean} Vertical-flip state.
function Active:isFlippedVertically()
  local f = 'isFlippedVertically'
  MintCrate.Assert.self(f, self)
  
  return self._flippedVertically
end

-- Flips the active horizontally.
-- @param {boolean} isFlipped Forces whether the active is flipped or not.
function Active:flipHorizontally(isFlipped)
  local f = 'flipHorizontally'
  MintCrate.Assert.self(f, self)
  
  if (isFlipped == nil) then isFlipped = (not self._flippedHorizontally) end
  MintCrate.Assert.type(f, 'isFlipped', isFlipped, 'boolean')
  
  self._flippedHorizontally = isFlipped
end

-- Flips the active vertically.
-- @param {boolean} isFlipped Forces whether the active is flipped or not.
function Active:flipVertically(isFlipped)
  local f = 'flipVertically'
  MintCrate.Assert.self(f, self)
  
  if (isFlipped == nil) then isFlipped = (not self._flippedVertically) end
  MintCrate.Assert.type(f, 'isFlipped', isFlipped, 'boolean')
  
  self._flippedVertically = isFlipped
end

-- -----------------------------------------------------------------------------
-- Methods for handling animation
-- -----------------------------------------------------------------------------

-- Returns the currently-playing animation's name.
-- @returns {string} Current animation name.
function Active:getAnimationName()
  local f = 'getAnimationName'
  MintCrate.Assert.self(f, self)
  
  return self._animationName or ""
end

-- Returns the currently-playing animation's frame number.
-- @returns {number} Current animation frame.
function Active:getAnimationFrameNumber()
  local f = 'getAnimationFrameNumber'
  MintCrate.Assert.self(f, self)
  
  return self._animationFrameNumber
end

-- Changes the active's current animation.
-- @param {string} animationName The animation to play.
-- @param {boolean} forceRestart Forces the animation to always start over.
function Active:playAnimation(animationName, forceRestart)
  local f = 'playAnimation'
  MintCrate.Assert.self(f, self)
  
  MintCrate.Assert.type(f, 'animationName', animationName, 'string')
  
  MintCrate.Assert.condition(f,
    'animationName',
    (MintCrate.Util.table.contains(self._animationList, animationName)),
    'does not refer to a valid animation'
  )
  
  if (forceRestart == nil) then forceRestart = false end
  
  MintCrate.Assert.type(f, 'forceRestart', forceRestart, 'boolean')
  
  self._animationName = animationName
  if forceRestart then
    self._animationFrameNumber = 1
    self._animationFrameTimer = 0
  end
end

-- Updates the animation.
function Active:_animate(animation)
  if self._animationName then
    self._animationFrameTimer = self._animationFrameTimer + 1
    
    if self._animationFrameTimer > animation.frameDuration then
      self._animationFrameNumber = self._animationFrameNumber + 1
      self._animationFrameTimer = 0
    end
    
    if self._animationFrameNumber > animation.frameCount then
      self._animationFrameNumber = 1
    end
    
    self._currentAnimation = animation
  end
end

-- Returns the width of the current animation frame.
-- @returns {number} Current frame width.
function Active:getImageWidth()
  local f = 'getImageWidth'
  MintCrate.Assert.self(f, self)
  
  local val = 0
  if self._currentAnimation then val = self._currentAnimation.frameWidth end
  return val
end

-- Returns the height of the current animation frame.
-- @returns {number} Current frame height.
function Active:getImageHeight()
  local f = 'getImageHeight'
  MintCrate.Assert.self(f, self)
  
  local val = 0
  if self._currentAnimation then val = self._currentAnimation.frameHeight end
  return val
end

function Active:getTransformedImageWidth()
  local f = 'getTransformedImageWidth'
  MintCrate.Assert.self(f, self)
  
  local width  = self:getImageWidth()  * self._scaleX
  local height = self:getImageHeight() * self._scaleY
  local rotation = math.rad(math.abs(self._angle))
  
  local tWidth = (width  * math.cos(rotation)) + (height * math.sin(rotation))
  
  return MintCrate.MathX.round(tWidth)
end

function Active:getTransformedImageHeight()
  local f = 'getTransformedImageHeight'
  MintCrate.Assert.self(f, self)
  
  local width  = self:getImageWidth()  * self._scaleX
  local height = self:getImageHeight() * self._scaleY
  local rotation = math.rad(math.abs(self._angle))
  
  local tHeight = (width  * math.cos(rotation)) + (height * math.sin(rotation))
  
  return MintCrate.MathX.round(tHeight)
end

-- -----------------------------------------------------------------------------
-- Methods for retrieving data about the collision mask
-- -----------------------------------------------------------------------------

-- Returns the active's collision mask.
-- @returns {table} Collider.
function Active:_getCollider()
  return self._collider
end

-- Returns the collision mask's width (for rectangular masks).
-- @returns {number} Collider width.
function Active:getWidth()
  local f = 'getWidth'
  MintCrate.Assert.self(f, self)
  
  return self._collider.w
end

-- Returns the collision mask's height (for rectangular masks).
-- @returns {number} Collider height.
function Active:getHeight()
  local f = 'getHeight'
  MintCrate.Assert.self(f, self)
  
  return self._collider.h
end

-- Returns the X position of the collider's left edge (for rectangular masks).
-- @returns {number} Collider left edge.
function Active:getLeftEdgeX()
  local f = 'getLeftEdgeX'
  MintCrate.Assert.self(f, self)
  
  return self._collider.x
end

-- Returns the X position of the collider's right edge (for rectangular masks).
-- @returns {number} Collider right edge.
function Active:getRightEdgeX()
  local f = 'getRightEdgeX'
  MintCrate.Assert.self(f, self)
  
  return self._collider.x + self._collider.w
end

-- Returns the Y position of the collider's top edge (for rectangular masks).
-- @returns {number} Collider top edge.
function Active:getTopEdgeY()
  local f = 'getTopEdgeY'
  MintCrate.Assert.self(f, self)
  
  return self._collider.y
end

-- Returns the Y position of the collider's bottom edge (for rectangular masks).
-- @returns {number} Collider bottom edge.
function Active:getBottomEdgeY()
  local f = 'getBottomEdgeY'
  MintCrate.Assert.self(f, self)
  
  return self._collider.y + self._collider.h
end

-- Returns the collision mask's radius (for circular masks).
-- @returns {number} Collider radius.
function Active:getRadius()
  local f = 'getRadius'
  MintCrate.Assert.self(f, self)
  
  return self._collider.r
end

-- -----------------------------------------------------------------------------
-- Methods for retrieving data for transformation and action points
-- -----------------------------------------------------------------------------

-- Returns the current X coordinate of the active's action point.
-- @returns {number} Action point X.
function Active:getActionPointX()
  local f = 'getActionPointX'
  MintCrate.Assert.self(f, self)
  
  self:_updateActionPoints()
  return self._actionPointX
end

-- Returns the current Y coordinate of the active's action point.
-- @returns {number} Action point Y.
function Active:getActionPointY()
  local f = 'getActionPointY'
  MintCrate.Assert.self(f, self)
  
  self:_updateActionPoints()
  return self._actionPointY
end

-- Updates the action point's position.
function Active:_updateActionPoints()
  -- Get un-transformed action points for current animation frame
  local ax = 0
  local ay = 0
  if self._currentAnimation then
    -- ax = self._currentAnimation.actionX + self._currentAnimation.offsetX
    -- ay = self._currentAnimation.actionY + self._currentAnimation.offsetY
    
    ax = self._currentAnimation.actionPoints[self._animationFrameNumber][1]
    ay = self._currentAnimation.actionPoints[self._animationFrameNumber][2]
    
    ax = ax + self._currentAnimation.offsetX
    ay = ay + self._currentAnimation.offsetY
  end
  
  -- Get flipped states
  local flippedX = 1
  if self._flippedHorizontally then flippedX = -1 end
  local flippedY = 1
  if self._flippedVertically then flippedY = -1 end
  
  -- Scale
  ax = ax * self._scaleX * flippedX
  ay = ay * self._scaleY * flippedY
  
  -- Rotate
  local r = self._angle * math.pi / 180
  local rx = ax * math.cos(r) - ay * math.sin(r)
  local ry = ax * math.sin(r) + ay * math.cos(r)
  ax = rx
  ay = ry
  
  -- Update action points
  self._actionPointX = self:getX() + ax
  self._actionPointY = self:getY() + ay
end

-- -----------------------------------------------------------------------------

return Active