WaterSplash = {}

function WaterSplash:new(x, y, scaleSpeed, scaleX)
  local o = mint:addActive('splash', x, y)
  setmetatable(self, {__index = MintCrate.Active})
  setmetatable(o, self)
  self.__index = self
  
  o.scaleSpeed = scaleSpeed or 0.0667
  o:setScaleX(scaleX or 0.85)
  o:setScaleY(0)
  
  return o
end

function WaterSplash:update()
  self.scaleSpeed = self.scaleSpeed - 0.002917
  
  self:setScaleX(self:getScaleX() + 0.0375)
  self:setScaleY(self:getScaleY() + self.scaleSpeed)
  
  self:setOpacity(self:getOpacity() - 0.01667)
end

return WaterSplash