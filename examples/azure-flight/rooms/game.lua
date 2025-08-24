Game = {}

--[[
  Note: The formulas and values in this code can be a bit weird. I cobbled
  them together abck in 2016 for the original version of Azure Flight. I didn't
  totally know what I was doing back then. For the sake of consistency between
  the versions, I'm choosing to keep it the same, albeit adjusted for
  MintCrate's fixed timestep. The original version of Azure Flight had a
  variable timestep, which I now feel is an overhyped paradigm and is neither
  suitable for all types of games nor does it really matter anymore for simple
  2D games with how powerful computers have become.
--]]

function Game:new()
  local o = MintCrate.Room:new("Game", 240, 160)
  setmetatable(self, {__index = MintCrate.Room})
  setmetatable(o, self)
  self.__index = self
  
  self:configureFadeIn(15, 0, {r=0,g=0,b=0})
  self:configureFadeOut(15, 30, {r=0,g=0,b=0})
  
  mint:addBackdrop('mountains')
  
  mint:setMusic('tangent')
  -- mint:playMusic()
  
  o.dangerIconDown = mint:addActive('danger-down', 4, 133)
  o.dangerIconUp = mint:addActive('danger-up', 201, 3)
  o.dangerIconDown:setOpacity(0.6)
  o.dangerIconUp:setOpacity(0.6)
  
  o.ready = mint:addBackdrop('ready', 0, 24)
  o.ready:setX(mint:getScreenWidth() / 2 - o.ready:getWidth() / 2)
  
  o.instructions = mint:addParagraph('ui-main', mint:getScreenWidth() / 2, 0, 'TAP & HOLD\nTO FLY', {alignment='center'})
  o.sineWaveTicks = 0
  
  o.poles = {
    PhysicsObject:new('post-pole', 112, 148, (4.0 / 60)),
    PhysicsObject:new('post-pole', 128, 148, (4.0 / 60)),
    PhysicsObject:new('post-top',  120, 136, (4.0 / 60))
  }
  
  o.splashes = {}
  o.droplets = {}
  
  o.harpy = PhysicsObject:new('harpy', 120, 124, (5.5 / 60))
  o.harpy.lift = o.harpy.gravity
  o.harpy.flapSoundDelay = 0
  o.harpy.treadDelay = 0
  o.harpy.wasHit = false
  
  o.TOTAL_BOULDERS = 5
  o.TOTAL_BOULDER_ROWS = 6
  o.BOULDER_ROWS_STARTING_Y = 4
  o.BOULDER_ROWS_SPACING = 1
  o.BOULDER_MAX_SPEED = (150 / 60)
  o.boulders = {}
  o.boulderSpawnTimer = 0
  o.boulderRowOccupancy = {}
  for i = 1, o.TOTAL_BOULDER_ROWS do
    o.boulderRowOccupancy[i] = false
  end
  
  o.waterLine = mint:addActive('water', 0, 156)
  
  o.state = 'ready'
  
  return o
end

function Game:update()
  local inputReceived =
    (mint:mouseHeld(1) or mint:mouseHeld(2) or mint:keyHeld('x'))
  
  -- State: Ready to play ------------------------------------------------------
  
  if self.state == 'ready' then
    -- Floating effect for instructions text
    self.sineWaveTicks = self.sineWaveTicks + 0.1
    self.instructions:setY(3 * math.sin(self.sineWaveTicks) + 68)
    
    -- Start actually playing the game when the user clicks
    if inputReceived then
      self.state = 'playing'
      self.ready = self.ready:destroy()
      self.instructions = self.instructions:destroy()
      self.dangerIconDown = self.dangerIconDown:destroy()
      self.dangerIconUp = self.dangerIconUp:destroy()
      
      -- Drop starting platform into river
      for _, pole in ipairs(self.poles) do
        pole.isFalling = true
        local dir = love.math.random(0, 1)
        if dir == 0 then dir = -1 end
        pole:setXSpeed((0.67 + (love.math.random(0, 20) * 0.01)) * dir)
      end
    end
  
  -- State: Playing the game ---------------------------------------------------
  
  elseif self.state == 'playing' then
    if (self.harpy.wasHit) then inputReceived = false end
    
    -- Spawn boulders
    if (
      #self.boulders < self.TOTAL_BOULDERS and
      self.boulderSpawnTimer <= 0
    ) then
      self.boulderSpawnTimer = 240
      local boulder = PhysicsObject:new('boulder', -64, -64, (5.5 / 60))
      boulder.currentSpeed = (80 / 60)
      boulder.currentRow = 1
      table.insert(self.boulders, boulder)
      self:repositionBoulder(boulder)
    end
    self.boulderSpawnTimer = self.boulderSpawnTimer - 1
    
    -- Player movement (harpy flight)
    if inputReceived and self.harpy.ySpeed < 0 then
      self.harpy:addYSpeed(self.harpy.lift * 2)
    elseif inputReceived then
      self.harpy:addYSpeed((1.5-self.harpy.ySpeed/(233/60)) * self.harpy.lift)
    else
      self.harpy:addYSpeed(-self.harpy.gravity)
    end
    
    -- Update player position.
    self.harpy:updatePhysics()
    
    -- Handle harpy animations.
    if inputReceived then
      self.harpy:playAnimation('flap')
    else
      self.harpy:playAnimation('fall')
    end
    
    -- Play flapping sound.
    if inputReceived and self.harpy.flapSoundDelay <= 0 then
      mint:playSound('flap', {pitch = 0.875 + (math.random() / 4)})
      self.harpy.flapSoundDelay = 15
    elseif not inputReceived then
      self.harpy.flapSoundDelay = 0
    end
    self.harpy.flapSoundDelay = self.harpy.flapSoundDelay - 1
    
    -- Process player-boulder collision
    for _, boulder in ipairs(self.boulders) do
      if (mint:testCollision(self.harpy, boulder)) then
        boulder.isFalling = true
        self.harpy.wasHit = true
        
      end
    end
    
    -- Kill player if they go too high
    if (self.harpy:getY() < 0) then
      self.harpy.wasHit = true
      self.harpy:setY(0)
      self.harpy:setYSpeed(0)
    end
    
  -- Reposition boulders if they've left the screen
  for i, boulder in ipairs(self.boulders) do
    if (
      (
        boulder:getXSpeed() > 0 and
        boulder:getX() > (mint:getScreenWidth() + boulder:getRadius())
      ) or
      (
        boulder:getXSpeed() < 0 and
        boulder:getX() < (0 - boulder:getRadius())
      )
    ) then
      self:repositionBoulder(boulder)
    end
  end
    
    -- Create water splashes when player treads into it
    if (self.harpy:getY() >= 154 and self.harpy.treadDelay <= 0) then
      self.harpy.treadDelay = 0.2
      local splash = WaterSplash:new(self.harpy:getX(), 157, 0.05, 0.25)
      table.insert(self.splashes, splash)
      self:createDroplets(self.harpy:getX(), 157, 2, true)
    end
    
    self.harpy.treadDelay = self.harpy.treadDelay - (1/60)
    
    -- Bring water line to the front of the view
    self.waterLine:bringToFront()
    
    -- Show Game Over screen if the player goes too low
    if (self.harpy:getY() > mint:getScreenHeight()) then
      self.state = 'gameover'
    end
    
  -- State: Game over screen ---------------------------------------------------
  
  elseif self.state == 'gameover' then
    if (self.harpy) then
      self.harpy = self.harpy:destroy()
      
      mint:addParagraph('ui-main', mint:getScreenWidth() / 2, 35,
        'SCORE 0', {alignment='center'})
      mint:addParagraph('ui-main', mint:getScreenWidth() / 2, 53,
        'BEST 19', {alignment='center'})
      
      self.btnRetry = Button:new(56, 72, 128, 'RETRY', false, function()
        mint:changeRoom(Game)
      end)
      
      self.btnMenu = Button:new(56, 96, 128, 'MENU', false, function()
        mint:changeRoom(Title)
      end)
    end
    
    self.btnRetry:update()
    self.btnMenu:update()
  end
  
  -- Process for all states ----------------------------------------------------
  
  -- Handle boulders.
  for i = #self.boulders, 1, -1 do
    local boulder = self.boulders[i]
    
    -- Update boulder's physics simulation
    boulder:updatePhysics()
    
    -- Rotate boulder
    boulder:rotate(boulder:getXSpeed() / (30 / 60))
    
    -- Remove boulder if it falls into the water
    if boulder:getY() > mint:getScreenHeight() + boulder:getRadius() then
      local splash = WaterSplash:new(boulder:getX(), 157)
      table.insert(self.splashes, splash)
      self:createDroplets(boulder:getX(), 157)
      boulder:destroy()
      table.remove(self.boulders, i)
    end
  end
  
  -- Handle starting platforms poles/logs.
  for i = #self.poles, 1, -1 do
    local pole = self.poles[i]
    pole:updatePhysics()
    -- Remove pole if it falls into the water.
    if pole:getY() > 156 then
      local splash = WaterSplash:new(pole:getX(), 157)
      table.insert(self.splashes, splash)
      self:createDroplets(pole:getX(), 157)
      pole:destroy()
      table.remove(self.poles, i)
    end
  end
  
  -- Handle water splashes
  for i = #self.splashes, 1, -1 do
    local splash = self.splashes[i]
    splash:update()
    -- Remove splash if it's no longer visible.
    if (splash:getScaleY() <= 0 or splash:getOpacity() <= 0) then
      splash:destroy()
      table.remove(self.splashes, i)
    end
  end
  
  -- Handle water droplets
  for i = #self.droplets, 1, -1 do
    local droplet = self.droplets[i]
    droplet:updatePhysics()
    -- Remove droplet if it's no longer visible.
    if (droplet:getY() > 160) then
      droplet:destroy()
      table.remove(self.droplets, i)
    end
  end
end

function Game:createDroplets(x, y, numDrops, weak)
  local numDrops = numDrops or 4
  local weak = weak or false
  
  for i = 1, numDrops do
    local xSpeed = love.math.random(0, 100) * 0.01
    local ySpeed = 1.5 + (love.math.random(75) * 0.01)
    
    if (weak) then
      xSpeed = xSpeed * 0.75
      ySpeed = ySpeed * 0.75
    end
    
    local droplet = PhysicsObject:new('droplet', x, y, (4.5 / 60))
    droplet.isFalling = true
    droplet:setOpacity(0.75)
    droplet:playAnimation('0'..love.math.random(1, 3))
    
    local dir = love.math.random(0, 1)
    if dir == 0 then dir = -1 end
    droplet:setXSpeed(xSpeed * dir)
    droplet:setYSpeed(ySpeed)
    
    table.insert(self.droplets, droplet)
  end
end

function Game:repositionBoulder(boulder)
  if boulder.isFalling then goto end_repositionBoulder end
  
  -- Determine which rows are not occupied by a boulder
  local availableRows = {}
  for i, isOccupied in ipairs(self.boulderRowOccupancy) do
    if (not isOccupied) then
      table.insert(availableRows, i)
    end
  end
  
  -- Pick a random row
  local targetRow = availableRows[love.math.random(1, #availableRows)]
  boulder.currentRow = targetRow
  targetRow = targetRow - 1
  
  -- Pick a random side
  local dir = love.math.random(0, 1)
  if (dir == 0) then dir = -1 end
  
  -- Warp boulder
  if (dir == 1) then
    boulder:setX(0 - boulder:getRadius())
  else
    boulder:setX(mint:getScreenWidth() + boulder:getRadius())
  end
  
  boulder:setY(
    (self.BOULDER_ROWS_STARTING_Y + boulder:getRadius()) +
    (boulder:getRadius() * 2 * targetRow) +
    (self.BOULDER_ROWS_SPACING * targetRow)
  )
  
  -- Set boulder's speed/direction
  boulder:setXSpeed(
    (boulder.currentSpeed + (love.math.random(1, 30) / 60)) * dir
  )
  
  if (boulder.currentSpeed < self.BOULDER_MAX_SPEED) then
    boulder.currentSpeed = boulder.currentSpeed + (1 / 60)
  end
  
  -- Update row-occupancy states
  for i = 1, #self.boulderRowOccupancy do
    self.boulderRowOccupancy[i] = false
  end
  
  for _, boulder in ipairs(self.boulders) do
    self.boulderRowOccupancy[boulder.currentRow] = true
  end
  
  ::end_repositionBoulder::
end

return Game