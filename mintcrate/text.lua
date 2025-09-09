-- -----------------------------------------------------------------------------
-- MintCrate - Text
-- An entity which is intended for displaying text via bitmap fonts.
-- -----------------------------------------------------------------------------

local Text = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Set class's type.
Text.type = "Text"

-- Creates an instance of the Text class.
-- @param {table} instances List of all Texts being managed by the engine.
-- @param {string} name Name of the Text, for definition & instantiation.
-- @param {number} x Text's starting X position.
-- @param {number} y Text's starting X position.
-- @param {number} maxCharsPerLine How many characters written before wrapping.
-- @param {number} lineSpacing How much space there is between lines.
-- @param {boolean} wordWrap Whether entire words should wrap or break mid-word.
-- @param {string} alignment How the text should be aligned (left|center|right).
-- @returns {Text} A new instance of the Text class.
function Text:new(instances, drawOrder, name, x, y,
  glyphWidth, glyphHeight, maxCharsPerLine, lineSpacing, wordWrap, alignment
)
  local o = MintCrate.Entity:new()
  setmetatable(self, {__index = MintCrate.Entity})
  setmetatable(o, self)
  self.__index = self
  
  -- Initialize properties
  o._entityType      = 'text'
  o._instances       = instances
  o._drawOrder       = drawOrder
  o._name            = name
  o._x               = x
  o._y               = y
  o._glyphWidth      = glyphWidth
  o._glyphHeight     = glyphHeight
  o._maxCharsPerLine = maxCharsPerLine
  o._lineSpacing     = lineSpacing
  o._wordWrap        = wordWrap
  o._alignment       = alignment
  o._textContent     = ""
  o._textLines       = {}
  
  return o
end

-- -----------------------------------------------------------------------------

-- Returns the currently-displayed text.
-- @returns {string} Current text.
function Text:getTextContent()
  local f = 'getTextContent'
  MintCrate.Assert.self(f, self)
  
  return self._textContent
end

-- Sets the currently-displayed text.
-- @param {string} textContent The new text to be displayed.
function Text:setTextContent(textContent)
  local f = 'setTextContent'
  MintCrate.Assert.self(f, self)
  
  -- Convert any input to a string
  textContent = tostring(textContent)
  
  -- Store unformatted text content
  self._textContent = textContent
  
  -- Normalize line breaks
  textContent = string.gsub(textContent, "\r\n", "\n")
  textContent = string.gsub(textContent, "\n\r", "\n")
  textContent = string.gsub(textContent, "\r", "\n")
  
  -- Prepare to parse text into lines
  local wordWrap        = self._wordWrap
  local maxCharsPerLine = self._maxCharsPerLine
  
  -- Split words into table
  local initialSplit = MintCrate.Util.string.split(textContent, " ")
  
  -- Split linebreaks into their own "words" so they'll be parsed too
  -- i.e. "Apple\nBanana Carrot" -> {"Apple", "\n", "Banana", "Carrot"}
  local words = {}
  for _, fullWord in ipairs(initialSplit) do
    local splitWords = MintCrate.Util.string.split(fullWord, "\n")
    for i, word in ipairs(splitWords) do
      table.insert(words, word)
      if i < #splitWords then table.insert(words, "\n") end
    end
  end
  
  -- Construct formatted lines
  -- Text in Text objects is stored as pre-formatted lines
  -- Basically, we're trying to fit as many words as possible into each line
  local strLines = {""}
  
  for i, word in ipairs(words) do
    -- Force a new line if we've hit a line break
    if (word == "\n") then
      table.insert(strLines, "")
    
    -- If we're not going to exceed the max chars allowed, then concat the word
    elseif (string.len(strLines[#strLines] .. word) <= maxCharsPerLine) then
      strLines[#strLines] = strLines[#strLines] .. word
    
    -- If we are going to exceed, and either the word is too long
    -- or wordwrap is not enabled, then break the word
    elseif (string.len(word) > maxCharsPerLine or not wordWrap) then
      local spaceAvailable = maxCharsPerLine - string.len(strLines[#strLines])
      local wordLeft       = string.sub(word, 1, spaceAvailable)
      local wordRight      = string.sub(word, spaceAvailable + 1, #word)
      
      strLines[#strLines] = strLines[#strLines] .. wordLeft
      
      table.insert(strLines, wordRight)
    
    -- Otherwise, move the entire word to the next line
    else
      table.insert(strLines, word)
    end
    
    -- Add space after word that was inserted
    if (
          word ~= "\n"
      and words[i+1]
      and string.len(strLines[#strLines] .. words[i+1]) <= maxCharsPerLine
      and words[i+1] ~= "\n"
    ) then
      strLines[#strLines] = strLines[#strLines] .. " "
    end
    
    -- keep breaking remainder onto new lines
    while (string.len(strLines[#strLines]) > maxCharsPerLine) do
      local line      = strLines[#strLines]
      local lineLeft  = string.sub(line, 1, maxCharsPerLine)
      local lineRight = string.sub(line, maxCharsPerLine + 1, #line)
      
      strLines[#strLines] = lineLeft
      
      table.insert(strLines, lineRight)
    end
  end
  
  -- Store formatted lines
  self._textLines = strLines
end

-- Returns the width of a single glyph (character).
-- @returns {number} The width of a glyph/character.
function Text:getGlyphWidth()
  local f = 'getGlyphWidth'
  MintCrate.Assert.self(f, self)
  
  return self._glyphWidth
end

-- Returns the height of a single glyph (character).
-- @returns {number} The height of a glyph/character.
function Text:getGlyphHeight()
  local f = 'getGlyphHeight'
  MintCrate.Assert.self(f, self)
  
  return self._glyphHeight
end

-- Returns the formatted lines to properly write the text with.
-- @returns {table} Formatted lines of the text element.
function Text:_getTextLines()
  return self._textLines
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

-- Returns the text's alignment.
-- @returns {text} The text's alignment setting.
function Text:_getAlignment()
  return self._alignment
end

-- -----------------------------------------------------------------------------

return Text