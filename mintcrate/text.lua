-- -----------------------------------------------------------------------------
-- MintCrate - Text
-- An entity which is intended for displaying text via bitmap fonts.
-- -----------------------------------------------------------------------------

local Text = MintCrate.Entity:new()

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the Text class.
-- @param {table} instances List of all Texts being managed by the engine.
-- @param {string} name Name of the Text, for definition & instantiation.
-- @param {number} x Text object's starting X position.
-- @param {number} y Text object's starting X position.
-- @param {number} maxCharsPerLine How many characters written before wrapping.
-- @param {number} lineSpacing How much space there is between lines.
-- @param {boolean} wordWrap Whether entire words should wrap or break mid-word.
-- @returns {Text} A new instance of the Text class.
function Text:new(instances, name, x, y, maxCharsPerLine, lineSpacing, wordWrap)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  o._instances = instances
  o._name = name
  o._x = x
  o._y = y
  o._maxCharsPerLine = maxCharsPerLine
  o._lineSpacing = lineSpacing
  o._wordWrap = wordWrap
  o._textContent = ""
  
  return o
end

-- -----------------------------------------------------------------------------

-- Returns the currently-displayed text.
-- @returns {string} Current text.
function Text:getTextContent()
  return self._textContent
end

-- Sets the currently-displayed text.
-- @param {string} textContent The new text to be displayed.
function Text:setTextContent(textContent)
  textContent = string.gsub(textContent, "\r\n", "\n")
  textContent = string.gsub(textContent, "\n\r", "\n")
  textContent = string.gsub(textContent, "\r", "\n")
  self._textContent = textContent
end

-- Returns the maximum number of characters allowed to be printed per line.
-- @returns {number} Max characters per line.
function Text:_getMaxCharsPerLine()
  return self._maxCharsPerLine
end

-- Returns the amount of space between each line.
-- @returns {number} Space between lines, in pixels.
function Text:_getLineSpacing()
  return self._lineSpacing
end

-- Returns whether word wrapping is enabled.
-- @returns {boolean} Word-wrapping mode.
function Text:_getWordWrap()
  return self._wordWrap
end

-- -----------------------------------------------------------------------------

return Text