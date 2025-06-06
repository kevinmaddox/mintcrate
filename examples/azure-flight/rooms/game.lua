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
  
  o.poles = {
    PhysicsObject:new('post-pole', 109, 140, (4.0 / 60)),
    PhysicsObject:new('post-pole', 125, 140, (4.0 / 60)),
    PhysicsObject:new('post-top',  106,   132, (4.0 / 60))
  }
  
  o.harpy = PhysicsObject:new('harpy', 110, 116, (5.5 / 60))
  o.harpy.lift = o.harpy.gravity
  o.harpy.flapSoundDelay = 0
  
  o.state = 'ready'
  
  return o
end

function Game:update()
  -- local val = 0
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
      
      for _, pole in ipairs(self.poles) do
        pole.isFalling = true
        local dir = love.math.random(0, 1)
        if dir == 0 then dir = -1 end
        pole:setXSpeed((0.67 + (love.math.random(0, 20) * 0.01)) * dir)
      end
    end
  elseif self.state == 'playing' then
    -- Player movement (harpy flight)
    -- Note: The code below is a bit weird. I cobbled together the formulas back
    -- in 2016 for the original version of Azure Flight. For the sake of
    -- consistency between the ports, I'm choosing to keep it the same, albeit
    -- adjusted for MintCrate's fixed timestep.
    if mint:mouseHeld(1) and self.harpy.ySpeed < 0 then
      self.harpy:addYSpeed(self.harpy.lift * 2)
    elseif mint:mouseHeld(1) then
      self.harpy:addYSpeed((1.5-self.harpy.ySpeed/(233/60)) * self.harpy.lift)
    else
      self.harpy:addYSpeed(-self.harpy.gravity)
    end
    
    -- Update player position.
    self.harpy:updatePhysics()
    
    -- Handle harpy animations.
    if mint:mouseHeld(1) then
      self.harpy:getActive():playAnimation('flap')
    else
      self.harpy:getActive():playAnimation('fall')
    end
    
    -- Play flapping sound.
    if mint:mouseHeld(1) and self.harpy.flapSoundDelay <= 0 then
      mint:playSound('flap', {pitch = 0.875 + (math.random() / 4)})
      self.harpy.flapSoundDelay = 15
    elseif not mint:mouseHeld(1) then
      self.harpy.flapSoundDelay = 0
    end
    self.harpy.flapSoundDelay = self.harpy.flapSoundDelay - 1
    
    -- Handle starting platforms poles/logs.
    for _, pole in ipairs(self.poles) do
      pole:updatePhysics()
    end
    
  elseif self.state == 'gameover' then
    
  end
end

return Game