Button = {}

function Button:new(x, y, size, text, toggleable, clickedCallback)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.btn = mint:addActive('button-'..size, x, y)
  
  o.textActive = mint:addParagraph('ui-main', 0, 0, text, {alignment='center'})
  o.textActive:setX(o.btn:getX() + o.btn:getImageWidth() / 2)
  o.textActive:setY(
    o.btn:getY()
    + o.btn:getImageHeight() / 2
    - o.textActive:getGlyphHeight() / 2
  )
  
  o.isDown = false
  
  o.toggleable = toggleable
  o.enabled = true
  
  o.clickedCallback = clickedCallback
  
  return o
end

function Button:update()
  -- Handle button clicking
  if mint:mouseReleased(1) and mint:mouseOverActive(self.btn) then
    if self.toggleable then self.enabled = not self.enabled end
    mint:playSound('button-up')
    self.clickedCallback(self.enabled)
  end
  
  -- Handle visuals
  if mint:mouseHeld(1) and mint:mouseOverActive(self.btn) then
    if not self.isDown then
      mint:playSound('button-down')
      self.isDown = true
    end
    
    if self.enabled then
      self.btn:playAnimation('active-down')
    else
      self.btn:playAnimation('inactive-down')
    end
  else
    self.isDown = false
    if self.enabled then
      self.btn:playAnimation('active-up')
    else
      self.btn:playAnimation('inactive-up')
    end
  end
end

function Button:setEnabledState(enabled)
  self.enabled = enabled
end

return Button