Button = {}

function Button:new(x, y, size, text, toggleable, clickedCallback, oneClickOnly,
  keyboardKey, startEnabled
)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o.btn = mint:addActive('button-'..size, x, y)
  
  o.textActive = mint:addText('ui-main', 0, 0, text, {alignment='center'})
  o.textActive:setX(o.btn:getX() + o.btn:getSpriteWidth() / 2)
  o.textActive:setY(
    o.btn:getY()
    + o.btn:getSpriteHeight() / 2
    - o.textActive:getGlyphHeight() / 2
  )
  
  o.isDown = false
  
  o.toggleable = toggleable
  o.enabled = true
  if (startEnabled == false) then o.enabled = false end
  
  o.oneClickOnly = oneClickOnly or false
  o.wasClicked = false
  
  o.clickedCallback = clickedCallback
  
  o.keyboardKey = keyboardKey or nil
  
  return o
end

function Button:update()
  if (self.oneClickOnly and self.wasClicked) then goto UpdateDone end
  
  -- Handle button clicking
  if ((mint:mouseReleased(1) and mint:mouseOverActive(self.btn)) or (self.keyboardKey and mint:keyReleased(self.keyboardKey))) then
    if self.toggleable then self.enabled = not self.enabled end
    mint:playSound('button-up')
    self.clickedCallback(self.enabled)
    if (self.oneClickOnly) then self.wasClicked = true end
  end
  
  -- Handle visuals
  if ((mint:mouseHeld(1) and mint:mouseOverActive(self.btn)) or (self.keyboardKey and mint:keyHeld(self.keyboardKey))) then
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
  
  ::UpdateDone::
end

function Button:setEnabledState(enabled)
  self.enabled = enabled
end

return Button