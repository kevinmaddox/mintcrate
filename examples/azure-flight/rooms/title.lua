Title = {}

function Title:new()
  local o = MintCrate.Room:new("Title", 240, 160)
  setmetatable(self, {__index = MintCrate.Room})
  setmetatable(o, self)
  self.__index = self
  
  self:setBackgroundColor(255, 255, 255)
  if globals.enteringFromSplashScreen then
    self:configureFadeIn(15, 0, {r=255,g=255,b=255})
  else
    self:configureFadeIn(15, 0, {r=0,g=0,b=0})
  end
  self:configureFadeOut(15, 30, {r=0,g=0,b=0})
  
  o.bg = mint:addBackdrop('menu-bg', 0, 0, {width=272, height=192})
  o.bg:setX(-o.bg:getTextureWidth())
  o.bg:setY(-o.bg:getTextureHeight())
  
  o.logoShadow = mint:addBackdrop('logo-shadow', 0, 10)
  o.logoShadow:setX(mint:getScreenWidth() / 2 - o.logoShadow:getWidth() / 2)
  
  o.logo = mint:addBackdrop('logo', 0, 0)
  o.logo:setX(o.logoShadow:getX())
  
  o.logoFloatTicks = 0.2
  
  o.btnStart = Button:new(56, 72, 128, 'PLAY', false, function()
    globals.enteringFromSplashScreen = false
    mint:changeRoom(Title)
  end)
  o.btnBgm = Button:new(56, 96, 64, 'BGM', true, function(enabled)
    -- TODO
  end)
  o.btnSfx = Button:new(120, 96, 64, 'SFX', true, function(enabled)
    -- TODO
  end)
  o.btnQuit = Button:new(56, 120, 128, 'QUIT', false, function()
    mint:quit(true)
  end)
  
  return o
end

function Title:update()
  -- Scroll background
  self.bg:setX(self.bg:getX() + 0.75)
  self.bg:setY(self.bg:getY() + 0.75)
  if self.bg:getX() >= 0 then self.bg:setX(-self.bg:getTextureWidth()) end
  if self.bg:getY() >= 0 then self.bg:setY(-self.bg:getTextureHeight()) end
  
  -- Float logo text
  -- I wrote this math a long time ago and barely remember why it is the way
  -- it is, lol. However, it works.
  self.logoFloatTicks = self.logoFloatTicks + 0.01
  local logoPosition =
    math.floor((2.5 * math.sin(self.logoFloatTicks * 0.9 * math.pi / 0.5)) + 8)
  self.logo:setY(logoPosition)
  
  -- Update buttons
  self.btnStart:update()
  self.btnBgm:update()
  self.btnSfx:update()
  self.btnQuit:update()
end

return Title