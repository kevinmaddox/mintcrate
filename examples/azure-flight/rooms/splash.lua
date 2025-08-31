Splash = {type = MintCrate.Room.type}

function Splash:new()
  local o = MintCrate.Room:new("Splash", 240, 160)
  setmetatable(self, {__index = MintCrate.Room})
  setmetatable(o, self)
  self.__index = self
  
  self:setBackgroundColor(255, 255, 255)
  self:configureFadeIn(15, 15, {r=255,g=255,b=255})
  self:configureFadeOut(15, 30, {r=255,g=255,b=255})
  
  o.harpy = mint:addBackdrop("harpy", 0, 52)
  o.harpy:setX((mint:getScreenWidth()/2) - (o.harpy:getWidth()/2) - 4)
  
  o.copyright = mint:addParagraph("system_dialog", mint:getScreenWidth()/2, o.harpy:getY() + 40, "Studio Densetsu", {alignment="center"})
  
  mint:delayFunction(function()
    mint:changeRoom(Title)
  end, 120)
  
  return o
end

return Splash