PhysicsObject = {}

function PhysicsObject:new(activeName, x, y, gravity)
  local o = mint:addActive(activeName, x, y)
  setmetatable(self, {__index = MintCrate.Active})
  setmetatable(o, self)
  self.__index = self
  
  o.xSpeed = 0
  o.ySpeed = 0
  o.gravity = gravity
  
  o.isFalling = false
  
  return o
end

function PhysicsObject:addYSpeed(val)
  self.ySpeed = self.ySpeed + val
end

function PhysicsObject:setYSpeed(val)
  self.ySpeed = val
end

function PhysicsObject:setXSpeed(val)
  self.xSpeed = val
end

function PhysicsObject:getXSpeed()
  return self.xSpeed
end

function PhysicsObject:updatePhysics()
  -- Handle "falling" state
  if self.isFalling then
    self.ySpeed = self.ySpeed - self.gravity
    self:setAngle(self:getAngle() + (self.xSpeed))
  end
  
  -- Update X and Y positions
  self:setX(self:getX() + self.xSpeed)
  self:setY(self:getY() - self.ySpeed)
end

return PhysicsObject