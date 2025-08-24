-- -----------------------------------------------------------------------------
-- MintCrate - Active
-- An animated entity that supports collisions and action points.
-- -----------------------------------------------------------------------------

local Active = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

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
-- @param {string} initialAnimationName Active's starting animation.
-- @returns {Active} A new instance of the Active class.
function Active:new(instances, name, x, y, colliderShape,
  colliderOffsetX, colliderOffsetY, colliderWidth, colliderHeight,
  colliderRadius, initialAnimationName, initialAnimation
)
  local o = MintCrate.Entity:new()
  setmetatable(self, {__index = MintCrate.Entity})
  setmetatable(o, self)
  self.__index = self
  
  o._instances = instances
  o._name = name
  o._x = x
  o._y = y
  
  o._angle = 0
  o._scaleX = 1
  o._scaleY = 1
  o._flippedHorizontally = false
  o._flippedVertically = false
  o._opacity = 1.0
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
  return self._angle
end

-- Sets the active's angle.
-- @param {number} degrees The new angle, in degrees.
function Active:setAngle(degrees)
  self._angle = degrees
end

-- Rotates the active by a specified number of degrees.
-- @param {number} degrees The number of degrees to rotate by.
function Active:rotate(degrees)
  self._angle = self._angle + degrees
end

-- Makes the active look at a specific point.
-- @param {number} x The X coordinate of the point to look at.
-- @param {number} y The Y coordinate of the point to look at.
function Active:angleLookAtPoint(x, y)
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
  return self._scaleX
end

-- Returns the active's vertical scaling value.
-- @returns {number} Vertical scaling value.
function Active:getScaleY()
  return self._scaleY
end

-- Sets the active's horizontal scaling value.
-- @param {number} scaleX The new horizontal scaling value (1.0 is normal).
function Active:setScaleX(scaleX)
  self._scaleX = scaleX
end

-- Sets the active's vertical scaling value.
-- @param {number} scaleX The new vertical scaling value (1.0 is normal).
function Active:setScaleY(scaleY)
  self._scaleY = scaleY
end

-- Returns whether the active is flipped horizontally.
-- @returns {boolean} Horizontal-flip state.
function Active:isFlippedHorizontally()
  return self._flippedHorizontally
end

-- Returns whether the active is flipped vertically.
-- @returns {boolean} Vertical-flip state.
function Active:isFlippedVertically()
  return self._flippedVertically
end

-- Flips the active horizontally.
-- @param {boolean} isFlipped Forces whether the active is flipped or not.
function Active:flipHorizontally(isFlipped)
  if type(isFlipped) == "nil" then
    self._flippedHorizontally = not self._flippedHorizontally
  else
    self._flippedHorizontally = isFlipped
  end
end

-- Flips the active vertically.
-- @param {boolean} isFlipped Forces whether the active is flipped or not.
function Active:flipVertically(isFlipped)
  if type(isFlipped) == "nil" then
    self._flippedVertically = not self._flippedVertically
  else
    self._flippedVertically = isFlipped
  end
end

-- Returns the active's current opacity value.
-- @returns {number} Opacity value.
function Active:getOpacity()
  return self._opacity
end

-- Sets the active's opacity value.
-- @param {number} opacity The new opacity value (0.0 - 1.0) (1.0 is opaque).
function Active:setOpacity(opacity)
  self._opacity = opacity
end

-- -----------------------------------------------------------------------------
-- Methods for handling animation
-- -----------------------------------------------------------------------------

-- Returns the currently-playing animation's name.
-- @returns {string} Current animation name.
function Active:getAnimationName()
  return self._animationName or ""
end

-- Returns the currently-playing animation's frame number.
-- @returns {number} Current animation frame.
function Active:getAnimationFrameNumber()
  return self._animationFrameNumber
end

-- Changes the active's current animation.
-- @param {string} animationName The animation to play.
-- @param {boolean} forceRestart Forces the animation to always start over.
function Active:playAnimation(animationName, forceRestart)
  forceRestart = forceRestart or false
  
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
  local val = 0
  if self._currentAnimation then val = self._currentAnimation.frameWidth end
  return val
end

-- Returns the height of the current animation frame.
-- @returns {number} Current frame height.
function Active:getImageHeight()
  local val = 0
  if self._currentAnimation then val = self._currentAnimation.frameHeight end
  return val
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
  return self._collider.w
end

-- Returns the collision mask's height (for rectangular masks).
-- @returns {number} Collider height.
function Active:getHeight()
  return self._collider.h
end

-- Returns the X position of the collider's left edge (for rectangular masks).
-- @returns {number} Collider left edge.
function Active:getLeftEdgeX()
  return self._collider.x
end

-- Returns the X position of the collider's right edge (for rectangular masks).
-- @returns {number} Collider right edge.
function Active:getRightEdgeX()
  return self._collider.x + self._collider.w
end

-- Returns the Y position of the collider's top edge (for rectangular masks).
-- @returns {number} Collider top edge.
function Active:getTopEdgeY()
  return self._collider.y
end

-- Returns the Y position of the collider's bottom edge (for rectangular masks).
-- @returns {number} Collider bottom edge.
function Active:getBottomEdgeY()
  return self._collider.y + self._collider.h
end

-- Returns the collision mask's radius (for circular masks).
-- @returns {number} Collider radius.
function Active:getRadius()
  return self._collider.r
end

-- -----------------------------------------------------------------------------
-- Methods for retrieving data for transformation and action points
-- -----------------------------------------------------------------------------

-- Returns the current X coordinate of the active's action point.
-- @returns {number} Action point X.
function Active:getActionPointX()
  self:_updateActionPoints()
  return self._actionPointX
end

-- Returns the current Y coordinate of the active's action point.
-- @returns {number} Action point Y.
function Active:getActionPointY()
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