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
    mint:addActive('post-pole', 125, 140),
    mint:addActive('post-top', 0, 132)
  }
  o.platformPoles[3]:setX(mint:getScreenWidth() / 2 - o.platformPoles[3]:getImageWidth() / 2)
  
  o.harpy = PhysicsObject:new('harpy', 110, 116, 5.5)
  o.harpy.flapSoundDelay = 0
  o.harpy.lift = 5.5
  
  o.playerData = {
    speedCoefficient = 1.5,
    maxYSpeed = 233
  }
  
  o.harpyX = PhysicsObject:new('harpy', 124, 116, 0.0917)
  o.harpyX.lift = 0.1834
  
  local startpos = 140
  o.harpy:getActive():setY(startpos)
  o.harpyX:getActive():setY(startpos)
  
  o.state = 'ready'
  
  return o
end

function Game:update()
  if self.state == 'ready' then
    -- Floating effect for instructions text
    self.sineWaveTicks = self.sineWaveTicks + 0.1
    self.instructions:setY(3 * math.sin(self.sineWaveTicks) + 68)
    
    -- Start actually playing the game when the user clicks
    if mint:mousePressed(1) or mint:mousePressed(2) then
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
    -- if mint:mouseHeld(1) then
    if mint:mouseHeld(1) and self.harpy.ySpeed < 0 then
      self.harpy:addYSpeed(self.harpy.lift * 2)
    elseif mint:mouseHeld(1) then
      local val = (self.playerData.speedCoefficient -
        self.harpy.ySpeed / self.playerData.maxYSpeed) * self.harpy.lift
      self.harpy:addYSpeed(val)
      -- print(self.harpy.ySpeed / self.playerData.maxYSpeed, val)
    else
      self.harpy:addYSpeed(-self.harpy.gravity)
    end
    
    -- Update player position.
    -- self.harpy:updatePhysics()
    self.harpy:getActive():setY(self.harpy:getActive():getY() - self.harpy.ySpeed * (1/60))
    
    
    
    -- TODO: This is the only value not correct
    local val = (7 - self.harpyX.ySpeed) * 0.0184
    print(self.harpyX:getActive():getY())
    -- print(val, self.harpyX.ySpeed)
    -- if mint:mouseHeld(1) then
    if mint:mouseHeld(1) and self.harpy.ySpeed < 0 then
      self.harpyX:addYSpeed(self.harpyX.lift)
    elseif mint:mouseHeld(1) then
      self.harpyX:addYSpeed(val)
    else
      self.harpyX:addYSpeed(-self.harpyX.gravity)
    end
    
    self.harpyX:getActive():setY(self.harpyX:getActive():getY() - self.harpyX.ySpeed)
    
    
    
    
    -- Handle harpy animations.
    if mint:mouseHeld(1) then
      -- self.harpy:getActive():playAnimation('flap')
    else
      -- self.harpy:getActive():playAnimation('fall')
    end
    
    -- Play flapping sound
    if mint:mouseHeld(1) and self.harpy.flapSoundDelay <= 0 then
      mint:playSound('flap', {pitch = 0.875 + (math.random() / 4)})
      self.harpy.flapSoundDelay = 15
    elseif not mint:mouseHeld(1) then
      self.harpy.flapSoundDelay = 0
    end
    self.harpy.flapSoundDelay = self.harpy.flapSoundDelay - 1
  elseif self.state == 'gameover' then
    
  end
end

return Game