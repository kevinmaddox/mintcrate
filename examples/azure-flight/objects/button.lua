Button = {}

function Button:new(x, y, size, text)
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
  
  return o
end

return Button