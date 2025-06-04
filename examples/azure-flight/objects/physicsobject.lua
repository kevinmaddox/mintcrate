PhysicsObject = {}

function PhysicsObject:new(activeName, x, y, gravity)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.active = mint:addActive(activeName, x, y)
  
  o.xSpeed = 0
  o.ySpeed = 0
  o.gravity = gravity
  
  o.isFalling = false
  
  return o
end

function PhysicsObject:addYSpeed(val)
  self.ySpeed = self.ySpeed + val
end

function PhysicsObject:setXSpeed(val)
  self.xSpeed = val
end

function PhysicsObject:updatePhysics()
  -- Handle "falling" state
  if self.isFalling then
    self.ySpeed = self.ySpeed - self.gravity
    self.active:setAngle(self.active:getAngle() + (self.xSpeed))
  end
  
  -- Update X and Y positions
  self.active:setX(self.active:getX() - self.xSpeed)
  self.active:setY(self.active:getY() - self.ySpeed)
end

function PhysicsObject:getActive()
  return self.active
end

return PhysicsObject