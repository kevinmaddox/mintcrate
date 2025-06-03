Game = {}

function Game:new()
  local o = MintCrate.Room:new("Game", 240, 160)
  setmetatable(self, {__index = MintCrate.Room})
  setmetatable(o, self)
  self.__index = self
  
  self:configureFadeIn(15, 0, {r=0,g=0,b=0})
  self:configureFadeOut(15, 30, {r=0,g=0,b=0})
  
  mint:addBackdrop('mountains')
  
  mint:setMusic('tangent')
  mint:playMusic()
  
  o.dangerIconDown = mint:addActive('danger-down', 4, 133)
  o.dangerIconUp = mint:addActive('danger-up', 201, 3)
  o.dangerIconDown:setOpacity(0.6)
  o.dangerIconUp:setOpacity(0.6)
  
  o.ready = mint:addBackdrop('ready', 0, 24)
  o.ready:setX(mint:getScreenWidth() / 2 - o.ready:getWidth() / 2)
  
  o.instructions = mint:addParagraph('ui-main', mint:getScreenWidth() / 2, 0, 'TAP & HOLD\nTO FLY', {alignment='center'})
  o.sineWaveTicks = 0
  
  o.platformPoles = {
    mint:addActive('post-pole', 109, 140),
    mint:addActive('post-pole', 125, 140)
  }
  o.platformTop = mint:addActive('post-top', 0, 132)
  o.platformTop:setX(mint:getScreenWidth() / 2 - o.platformTop:getImageWidth() / 2)
  
  o.harpy = mint:addActive('harpy', 0, 116)
  o.harpy:setX(mint:getScreenWidth() / 2 - o.harpy:getImageWidth() / 2)
  
  o.playerData = {
    ySpeed = 0,
    thrust = 5.5,
    yAcceleration = 0,
    speedCoefficient = 1.5,
    maxYSpeed = 350,
    maxYSpeedActual = 350 / 1.5,
    gravity = 5.5
  }
  
  o.state = 'ready'
  
  return o
end

function Game:update()
  if self.state == 'ready' then
    -- Floating effect for instructions text
    self.sineWaveTicks = self.sineWaveTicks + 0.1
    self.instructions:setY(3 * math.sin(self.sineWaveTicks) + 68)
    
    -- Start actually playing the game when the user clicks
    if mint:mousePressed(1) then
      self.state = 'playing'
      self.ready = self.ready:destroy()
      self.instructions = self.instructions:destroy()
      self.dangerIconDown = self.dangerIconDown:destroy()
      self.dangerIconUp = self.dangerIconUp:destroy()
    end
  elseif self.state == 'playing' then
    -- Player movement (harpy flight)
    -- Note: The code below is a bit weird. I wrote the formulas back in 2016
    -- for the original version of Azure Flight. For the sake of consistency
    -- between the ports, I'm choosing to keep it the same.
    if mint:mouseHeld(1) and self.playerData.ySpeed < 0 then
      self.playerData.yAcceleration = self.playerData.thrust * 2
    elseif mint:mouseHeld(1) then
      self.playerData.yAcceleration = (self.playerData.speedCoefficient -
        self.playerData.ySpeed / (self.playerData.maxYSpeedActual)) *
        self.playerData.thrust
    end
    
    -- Cap vertical speed.
    if self.playerData.ySpeed > self.playerData.maxYSpeed then
      self.playerData.ySpeed = self.playerData.maxYSpeed
    end
    
    -- Update player position.
    self.playerData.ySpeed = self.playerData.ySpeed + self.playerData.yAcceleration
    self.harpy:setY(self.harpy:getY() - self.playerData.ySpeed * (1/60))
    
    -- Apply gravity.
    self.playerData.yAcceleration = -self.playerData.gravity
    
    -- Handle harpy animations.
    if mint:mouseHeld(1) then
      self.harpy:playAnimation('flap')
    else
      self.harpy:playAnimation('fall')
    end
  elseif self.state == 'gameover' then
    
  end
end

return Game