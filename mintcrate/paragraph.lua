-- -----------------------------------------------------------------------------
-- MintCrate - Paragraph
-- An entity which is intended for displaying text via bitmap fonts.
-- -----------------------------------------------------------------------------

local Paragraph = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the Paragraph class.
-- @param {table} instances List of all Texts being managed by the engine.
-- @param {string} name Name of the Paragraph, for definition & instantiation.
-- @param {number} x Paragraph's starting X position.
-- @param {number} y Paragraph's starting X position.
-- @param {number} maxCharsPerLine How many characters written before wrapping.
-- @param {number} lineSpacing How much space there is between lines.
-- @param {boolean} wordWrap Whether entire words should wrap or break mid-word.
-- @param {string} alignment How the text should be aligned (left|center|right).
-- @returns {Paragraph} A new instance of the Paragraph class.
function Paragraph:new(instances, name, x, y, maxCharsPerLine, lineSpacing, wordWrap,
  alignment
)
  local o = MintCrate.Entity:new()
  setmetatable(self, {__index = MintCrate.Entity})
  setmetatable(o, self)
  self.__index = self
  
  o._instances = instances
  o._name = name
  o._x = x
  o._y = y
  o._maxCharsPerLine = maxCharsPerLine
  o._lineSpacing = lineSpacing
  o._wordWrap = wordWrap
  o._alignment = alignment
  o._textContent = ""
  o._textLines = {}
  
  return o
end

-- -----------------------------------------------------------------------------

-- Returns the currently-displayed text.
-- @returns {string} Current text.
function Paragraph:getTextContent()
  return self._textContent
end

-- Sets the currently-displayed text.
-- @param {string} textContent The new text to be displayed.
function Paragraph:setTextContent(textContent)
  self._textContent = textContent
  
  textContent = string.gsub(textContent, "\r\n", "\n")
  textContent = string.gsub(textContent, "\n\r", "\n")
  textContent = string.gsub(textContent, "\r", "\n")
  
  local wordWrap = self._wordWrap
  local maxCharsPerLine = self._maxCharsPerLine
  
  -- Split words
  local initialSplit = MintCrate.Util.string.split(textContent, " ")
  -- Split linebreaks into their own "words"
  local words = {}
  for _, fullWord in ipairs(initialSplit) do
    local splitWords = MintCrate.Util.string.split(fullWord, "\n")
    for i, word in ipairs(splitWords) do
      table.insert(words, word)
      if i < #splitWords then table.insert(words, "\n") end
    end
  end
  
  local strLines = {""}
  for i, word in ipairs(words) do
    -- Make a new line if we've hit a line break
    if word == "\n" then
      table.insert(strLines, "")
    -- If we're not going to exceed the max chars allowed, then simply concat the word
    elseif string.len(strLines[#strLines] .. word) <= maxCharsPerLine then
      strLines[#strLines] = strLines[#strLines] .. word
    -- If we are going to exceed, and either the word is too long, or wordwrap is not enabled, then break the word
    elseif string.len(word) > maxCharsPerLine or not wordWrap then
      local spaceAvailable = maxCharsPerLine - string.len(strLines[#strLines])
      local wordLeft = string.sub(word, 1, spaceAvailable)
      local wordRight = string.sub(word, spaceAvailable + 1, #word)
      strLines[#strLines] = strLines[#strLines] .. wordLeft
      table.insert(strLines, wordRight)
    -- Otherwise, move the entire word to the next line
    else
      table.insert(strLines, word)
    end
    
    -- Add space after word that was inserted
    if
      word ~= "\n" and
      words[i+1] and
      string.len(strLines[#strLines] .. words[i+1]) <= maxCharsPerLine and
      words[i+1] ~= "\n"
    then
    strLines[#strLines] = strLines[#strLines] .. " "
    end
    
    -- keep breaking remainder onto new lines
    while string.len(strLines[#strLines]) > maxCharsPerLine do
      local line = strLines[#strLines]
      local lineLeft = string.sub(line, 1, maxCharsPerLine)
      local lineRight = string.sub(line, maxCharsPerLine + 1, #line)
      strLines[#strLines] = lineLeft
      table.insert(strLines, lineRight)
    end
  end
  
  self._textLines = strLines
end

-- Returns the formatted lines to properly write the text with.
-- @returns {table} Formatted lines of the text element.
function Paragraph:_getTextLines()
  return self._textLines
end

-- Returns the maximum number of characters allowed to be printed per line.
-- @returns {number} Max characters per line.
function Paragraph:_getMaxCharsPerLine()
  return self._maxCharsPerLine
end

-- Returns the amount of space between each line.
-- @returns {number} Space between lines, in pixels.
function Paragraph:_getLineSpacing()
  return self._lineSpacing
end

-- Returns whether word wrapping is enabled.
-- @returns {boolean} Word-wrapping mode.
function Paragraph:_getWordWrap()
  return self._wordWrap
end

-- Returns the text's alignment.
-- @returns {text} The text's alignment setting.
function Paragraph:_getAlignment()
  return self._alignment
end

-- -----------------------------------------------------------------------------

return Paragraph