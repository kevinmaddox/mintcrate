Level = MintCrate.Room:new("Level", 640, 240)

function Level:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o:setTilemap('level_snow-forest')
  o:setBackgroundColor(184, 184, 248)
  
  o.player = mint:addActive('miamori', 64, 128)
  o.player.xSpeed = 0
  o.player.ySpeed = 0
  o.player.isGrounded = false
  o.player.slideTimer = 0
  o.player.direction = 1
  o.player.slideDirection = 1
  o.player.spring = false
  
  o.bg = mint:addBackdrop('bg', 0, 64, {width = 800, height = 224})
  
  mint:setMusic('snow-forest')
  -- mint:playMusic()
  
  return o
end

function Level:update()
  
  local collisions
  local previousY
  
  -- Player movement -----------------------------------------------------------
  
  -- Walking
  if input:held("right") then
    self.player.xSpeed = 1
    self.player.direction = 1
  elseif input:held("left") then
    self.player.xSpeed = -1
    self.player.direction = -1
  else
    self.player.xSpeed = 0
  end
  
  if mint:keyHeld("s") then self.player.xSpeed = 5 end
  
  -- Sliding
  if
    self.player.isGrounded and
    self.player.slideTimer == 0 and
    input:pressed("fire1") and
    input:held("down")
  then
    self.player.slideTimer = 30
    self.player.slideDirection = self.player.direction
  end
  
  if self.player.slideTimer > 0 then
    self.player.slideTimer = self.player.slideTimer - 1
    self.player.xSpeed = self.player.slideDirection * 2
  end
  
  if
    (self.player.slideDirection == 1 and input:pressed("left")) or
    (self.player.slideDirection == -1 and input:pressed("right")) or
    (not self.player.isGrounded)
  then
    self.player.slideTimer = 0
  end
  
  -- Jumping
  if
    self.player.isGrounded and
    input:pressed("fire1") and
    not input:held("down")
  then
    self.player.ySpeed = -2.75
    self.player.slideTimer = 0
  end
  
  -- Jump canceling
  if
    self.player.ySpeed < -1 and
    input:released("fire1") and
    not self.player.sprung
  then
    self.player.ySpeed = -1
  end
  
  self.player.ySpeed = self.player.ySpeed + 0.1
  
  -- Turn sprung state off only if player is falling (so they can't cancel it)
  if self.player.ySpeed >= 0 then
    self.player.sprung = false
  end
  
  -- Turn grounded state off as we're done processing movement
  self.player.isGrounded = false
  
  -- Update positions and handle collisions ------------------------------------
  
  collisions = false
  
  -- Update player's X position
  self.player:setX(self.player:getX() + self.player.xSpeed)
  
  -- Walls
  collisions = mint:testMapCollision(self.player, 1)
  if collisions then
    if self.player.xSpeed > 0 then
      self.player:setX(collisions[1].leftEdgeX -
        math.floor(self.player:getWidth()/2))
    else
      self.player:setX(collisions[1].rightEdgeX +
        math.floor(self.player:getWidth()/2)+1)
    end
    self.player.xSpeed = 0
    self.player.slideTimer = 0
  end
  
  -- Update player's Y position
  previousY = self.player:getY()
  self.player:setY(self.player:getY() + self.player.ySpeed)
  
  -- Floors/ceilings (obstacles)
  collisions = mint:testMapCollision(self.player, 1)
  if collisions then
    if self.player.ySpeed > 0 then
      self.player:setY(collisions[1].topEdgeY)
      self.player.isGrounded = true
    else
      self.player:setY(collisions[1].bottomEdgeY + self.player:getHeight())
    end
    self.player.ySpeed = 0
  end
  
  -- Floors (pass-through platforms)
  collisions = mint:testMapCollision(self.player, 2) or {}
  for _, collision in ipairs(collisions) do
    if
      self.player.ySpeed > 0 and
      previousY <= collision.topEdgeY
    then
      self.player:setY(collision.topEdgeY)
      self.player.isGrounded = true
      self.player.ySpeed = 0
    end
  end
  
  -- FLoors (springs)
  collisions = mint:testMapCollision(self.player, 3) or {}
  for _, collision in ipairs(collisions) do
    if
      self.player.ySpeed > 0 and
      previousY <= collision.topEdgeY
    then
      self.player:setY(collision.topEdgeY)
      self.player.ySpeed = -6
      self.player.sprung = true
    end
  end
  
  -- Invisible barriers
  if self.player:getLeftEdgeX() < 0 then
    self.player:setX(self.player:getWidth()/2)
    self.player.xSpeed = 0
  elseif self.player:getRightEdgeX() > self:getRoomWidth() then
    self.player:setX(self:getRoomWidth() - self.player:getWidth()/2)
    self.player.xSpeed = 0
  end
  
  -- Player graphic ------------------------------------------------------------
  
  -- Animations
  if self.player.slideTimer > 0 then
    self.player:playAnimation('slide')
  elseif self.player.xSpeed == 0 and self.player.isGrounded then
    self.player:playAnimation('idle')
  elseif self.player.xSpeed ~= 0 and self.player.isGrounded then
    self.player:playAnimation('walk')
  elseif not self.player.isGrounded then
    self.player:playAnimation('jump')
  end
  
  -- Set sprite direction
  if self.player.xSpeed ~= 0 then
    self.player:flipHorizontally((self.player.direction == -1))
  end
  
  -- Other room stuff ----------------------------------------------------------
  
  -- Center camera on player
  mint:centerCamera(self.player:getX(), self.player:getY())
  
  -- Update background trees position
  self.bg:setX(mint:getCameraX() / 2)
end

return Level