PhysicsObject = {}

function PhysicsObject:new(activeName, x, y, gravity)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.active = mint:addActive(activeName, x, y)
  
  o.xSpeed = 0
  o.ySpeed = 0
  o.gravity = gravity
  
  return o
end

function PhysicsObject:addYSpeed(val)
  self.ySpeed = self.ySpeed + val
end

function PhysicsObject:updatePhysics()
  self.active:setY(self.active:getY() - self.ySpeed * (1/60))
end

function PhysicsObject:getActive()
  return self.active
end

return PhysicsObject