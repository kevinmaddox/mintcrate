-- -----------------------------------------------------------------------------
-- MintCrate - Util
-- A utility library for assorted helper functions.
-- -----------------------------------------------------------------------------

local Util = {}

-- -----------------------------------------------------------------------------
-- General methods
-- -----------------------------------------------------------------------------

-- Picks a random entry from a set of items.
-- @param {*} ... Any number of items to pick a random entry from.
-- @returns {*} A randomly-selected entry from the provided list of items.
function Util.randomChoice(...)
  local values = {...}
  local f = 'randomChoice'
  MintCrate.Assert.cond(f, '...', (#values > 0),
    'expects at least one argument')
  return values[love.math.random(1, #values)]
end

-- -----------------------------------------------------------------------------
-- Boolean methods
-- -----------------------------------------------------------------------------

Util.boolean = {}

-- Returns a numeric value based on a boolean value (true = 1, false = 0).
-- @param {boolean} b A boolean value.
-- @returns {number} Numeric representation of a boolean value.
function Util.boolean.toNumber(b)
  local f = 'boolean.toNumber'
  MintCrate.Assert.type(f, 'b', b, 'boolean')
  
  return b and 1 or 0
end

-- -----------------------------------------------------------------------------
-- Number methods
-- -----------------------------------------------------------------------------

Util.number = {}

-- Returns a boolean value based on a numeric value (1 = true, 0 = false).
-- @param {number} n A numeric value (1 or 0).
-- @returns {boolean} Boolean representation of a numeric value.
function Util.number.toBoolean(n)
  local f = 'number.toBoolean'
  MintCrate.Assert.type(f, 'n', n, 'number')
  
  return n > 0 and true or false
end

-- -----------------------------------------------------------------------------
-- Table-related methods
-- -----------------------------------------------------------------------------

Util.table = {}

-- Formats a table as a newline-delimited string, useful for debugging.
-- @param {table} tbl The table to be formatted.
-- @param {number} indent How much to indent each nested item.
-- @returns {string} A formatted string representing a table.
function Util.table.toString(tbl, indent)
  local f = 'table.toString'
  
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  if (indent == nil) then indent = 1 end
  MintCrate.Assert.type(f, 'indent', indent, 'number')
  
  function printTbl(o, indent)
    if type(o) == "table" then
      local s = "{"
        for k, v in pairs(o) do
          if type(k) ~= "number" then k = "\""..k.."\"" end
          s = s .. "\n" .. string.rep("  ", indent) .. "["..k.."] = " ..
            printTbl(v, indent + 1) .. ","
        end
      if s:sub(-1) == "," then s = s:sub(1, -2) end
      return s .. "\n" .. string.rep("  ", indent - 1) .. "}"
    else
      if type(o) == "string" then
        return "\""..o.."\""
      else
        return tostring(o)
      end
    end
  end
  
  return printTbl(tbl, indent)
end

-- Prints a table.
-- @param {table} tbl The table to be printed.
function Util.table.print(tbl)
  local f = 'table.print'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  if (Util.table.matchesArrayPattern(tbl)) then
    for i,v in ipairs(tbl) do print(i,v) end
  else
    for k,v in pairs(tbl) do print(k,v) end
  end
end

-- Moves an item backward in a table (decrements its index).
-- @param {table} tbl The table to be rearranged.
-- @param {number} index The index of the item to be moved.
function Util.table.moveItemDown(tbl, index)
  local f = 'table.moveItemDown'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  if index > 1 and index <= #tbl then
    local val = tbl[index]
    table.remove(tbl, index)
    table.insert(tbl, index-1, val)
  end
end

-- Moves an item forward in a table (increments its index).
-- @param {table} tbl The table to be rearranged.
-- @param {number} index The index of the item to be moved.
function Util.table.moveItemUp(tbl, index)
  local f = 'table.moveItemUp'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  if index >= 1 and index < #tbl then
    local val = tbl[index]
    table.remove(tbl, index)
    table.insert(tbl, index+1, val)
  end
end

-- Moves an item to the beginning of a table (index becomes 1).
-- @param {table} tbl The table to be rearranged.
-- @param {number} index The index of the item to be moved.
function Util.table.moveItemToStart(tbl, index)
  local f = 'table.moveItemToStart'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  if index > 1 and index <= #tbl then
    local val = tbl[index]
    table.remove(tbl, index)
    table.insert(tbl, 1, val)
  end
end

-- Moves an item to the end of a table (index becomes length of table).
-- @param {table} tbl The table to be rearranged.
-- @param {number} index The index of the item to be moved.
function Util.table.moveItemToEnd(tbl, index)
  local f = 'table.moveItemToEnd'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  if index >= 1 and index < #tbl then
    local val = tbl[index]
    table.remove(tbl, index)
    table.insert(tbl, #tbl+1, val)
  end
end

-- Reverses the order of a table (for numerically-indexed tables).
-- @param {table} tbl The table to be reversed.
function Util.table.reverse(tbl)
  local f = 'table.reverse'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  local i, j = 1, #tbl
  
  while i < j do
    tbl[i], tbl[j] = tbl[j], tbl[i]
    i = i + 1
    j = j - 1
  end
end

-- Returns the number of elements in a table, including those with keys.
-- @param {table} tbl The table to be tallied.
-- @returns {number} The total number of table elements.
function Util.table.count(tbl)
  local f = 'table.count'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  local c = 0
  for k,v in pairs(tbl) do c = c + 1 end
  return c
end

-- Checks whether a table resembles an array (numeric+sequential keys).
-- @param {table} tbl The table to check.
function Util.table.matchesArrayPattern(tbl)
  local f = 'table.matchesArrayPattern'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  local i = 0
  local isArray = true
  for _,__ in pairs(tbl) do
    i = i + 1
    if tbl[i] == nil then
      isArray = false
      break
    end
  end
  return isArray
end

-- -----------------------------------------------------------------------------
-- String-related methods
-- -----------------------------------------------------------------------------

Util.string = {}

-- Splits a string into an array (only works with a single-character delimiter).
-- @param {string} str The string to be split.
-- @param {string} delimiter The character to split on (omit to split all).
-- @returns {table} The split-up parts of a string.
function Util.string.split(str, delimiter)
  local f = 'string.split'
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  if (delimiter == nil) then delimiter = '' end
  MintCrate.Assert.type(f, 'delimiter', delimiter, 'string')
  
  str = tostring(str)
  delimiter = tostring(delimiter)
  local split = {}
  local start = 1
  local i = 1
  for chr in string.gmatch(str, ".") do
    if delimiter == '' then
      table.insert(split, chr)
    elseif chr == delimiter then
      table.insert(split, str:sub(start, i - 1))
      start = i + 1
    end
    i = i + 1
  end
  
  if delimiter ~= '' then
    table.insert(split, str:sub(start, i))
  end
  
  return split
end

-- Converts a string, either "true" or "false", to the boolean-type equivalent.
-- @param {string} str The string to be converted.
-- @returns {boolean} A boolean representation of a string.
function Util.string.toBoolean(str)
  local f = 'string.toBoolean'
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  local bool = false
  if str == 'true' then bool = true end
  return bool
end

-- Trims leading and trailing whitespace from a string, including returns.
-- @param {string} str The string to be trimmed.
-- @returns {string} A string with its leading/trailing whitespace removed.
function Util.string.trim(str)
  local f = 'string.trim'
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  return str:gsub("^%s*(.-)%s*$", "%1")
end

-- Pads the left side of a string with characters to a specified length.
-- @param {string} str The string to be padded.
-- @param {number} length The length to pad the string to.
-- @param {string} padChar The character to pad the string with.
-- @returns {string} A left-padded string.
function Util.string.padLeft(str, length, padChar)
  local f = 'string.padLeft'
  MintCrate.Assert.type(f, 'str', str, 'string')
  MintCrate.Assert.type(f, 'length', length, 'number')
  MintCrate.Assert.type(f, 'padChar', padChar, 'string')
  
  while string.len(str) < length do str = padChar .. str end
  return str
end

-- Pads the right side of a string with characters to a specified length.
-- @param {string} str The string to be padded.
-- @param {number} length The length to pad the string to.
-- @param {string} padChar The character to pad the string with.
-- @returns {string} A right-padded string.
function Util.string.padRight(str, length, padChar)
  local f = 'string.padRight'
  MintCrate.Assert.type(f, 'str', str, 'string')
  MintCrate.Assert.type(f, 'length', length, 'number')
  MintCrate.Assert.type(f, 'padChar', padChar, 'string')
  
  while string.len(str) < length do str = str .. padChar end
  return str
end

-- -----------------------------------------------------------------------------
-- JSON-related methods
-- -----------------------------------------------------------------------------

Util.json = {}

-- Serializes a table into a standard JSON string.
-- @param {table} tbl The table to serialize.
-- @param {boolean} prettyPrint Formats the output nicely with tabs and lines.
-- @param {number} numSpaces How many spaces should be used for a tab.
-- @returns {string} A JSON string representing the table.
function Util.json.encode(tbl, prettyPrint, numSpaces)
  local f = 'json.encode'
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  if (prettyPrint == nil) then prettyPrint = false end
  MintCrate.Assert.type(f, 'prettyPrint', prettyPrint, 'boolean')
  
  if (numSpaces == nil) then numSpaces = 2 end
  MintCrate.Assert.type(f, 'numSpaces', numSpaces, 'number')
  
  function serializeValue(val, key, indent, tab, newline)
    local str = ''
    
    str = str .. newline .. str.rep(tab, indent)
    
    if (key) then str = str .. '"'..key..'":' end
    
    if (type(val) == 'boolean') then
      str = str .. tostring(val) .. ','
    elseif (type(val) == 'number') then
      str = str .. val .. ','
    elseif (type(val) == 'string') then
      -- Escape characters
      val = val:gsub('\\', '\\\\') -- Backslash
      val = val:gsub('/', '\\/')    -- Forward slash
      val = val:gsub('"', '\\"')    -- Double quote
      val = val:gsub('\b', '\\b')  -- Backspace
      val = val:gsub('\f', '\\f')  -- Form feed
      val = val:gsub('\n', '\\n')  -- Newline
      val = val:gsub('\r', '\\r')  -- Carriage return
      val = val:gsub('\t', '\\t')  -- Tab
      
      str = str .. '"'..val..'"' .. ','
    elseif (type(val) == 'table') then
      str = str .. serializeTable(val, indent, tab, newline) .. ','
    else
      -- TODO: Throw error
    end
    
    return str
  end
  
  function serializeTable(tbl, indent, tab, newline)
    -- Prepare for serialization
    local str = ''
    
    -- Determine whether table matches the pattern of a JS array or object
    local isArray = Util.table.matchesArrayPattern(tbl)
    
    -- Begin array/object
    if (isArray) then
      str = str .. "["
    else
      str = str .. "{"
    end
    
    indent = indent + 1
    
    -- Serialize value
    if (Util.table.matchesArrayPattern(tbl)) then
      for _, val in ipairs(tbl) do str = str .. serializeValue(val, nil, indent, tab, newline) end
    else
      for key, val in pairs(tbl) do str = str .. serializeValue(val, key, indent, tab, newline) end
    end
    
    -- Remove last comma
    str = str:sub(1, -2)
    
    indent = indent - 1
    
    -- End array/object
    if (isArray) then
      str = str .. newline .. str.rep(tab, indent) .. "]"
    else
      str = str .. newline .. str.rep(tab, indent) .. "}"
    end
    
    return str
  end
  
  local indent = 0
  local tab = ''
  local newline = ''
  if (prettyPrint) then
    tab = string.rep(' ', numSpaces)
    -- tab = '\t'
    newline = '\n'
  end
  
  return serializeTable(tbl, indent, tab, newline)
end

-- Deserializes a standard JSON string into a table.
-- @param {string} json The JSON string to deserialize.
-- @returns {string} A table parsed from the JSON string.
function Util.json.decode(json)
  local f = 'json.encode'
  MintCrate.Assert.type(f, 'json', json, 'string')
  
  function unescapeChar(str)
    if     (str == '\\"')  then str = '"'       -- Double quote
    elseif (str == '\\b')  then str = '\b'      -- Backspace
    elseif (str == '\\f')  then str = '\f'      -- Form feed
    elseif (str == '\\n')  then str = '\n'      -- Newline
    elseif (str == '\\r')  then str = '\r'      -- Carriage return
    elseif (str == '\\t')  then str = '\t'      -- Tab
    elseif (str == '\\/')  then str = '/'       -- Forward slash
    elseif (str == '\\\\') then str = '\\' end  -- Backslash
    return str
  end
  
  function parseValue(json, index)
    local val = ''
    local ignoreChar = false -- Used to ignore second part of escape chars
    local isString = false   -- Used to handle quoted strings
    
    -- Check if value-to-be-parsed is a string (quotes must be accounted for)
    if (json:sub(index, index) == '"') then
      isString = true
      index = index + 1
    end
    
    -- Iterate until we parse the entire value
    for i = index, #json do
      local c = json:sub(i, i)
      index = index + 1
      
      -- Current char is part of an escape character and was previously handled
      if (ignoreChar) then
        ignoreChar = false
        goto continue
      end
      
      -- Terminate parsing if we've hit a JSON-structure character
      if (
        (isString and c == '"')
        or (not isString and (c == ' ' or c == ','))
      ) then
        break
      -- Terminate parsing if we've hit the end of an array or object
      elseif (not isString and (c == ']' or c == '}')) then
        index = index - 1
        break
      -- Parse next 2 characters if an escape character was found
      elseif (c == '\\') then
        -- print('ESCAPE!', json:sub(i, i+4))
        val = val .. unescapeChar(c..json:sub(i+1, i+1))
        ignoreChar = true
      -- Parse normal character
      else
        val = val .. c
      end
      
      ::continue::
    end
    
    -- If value is not a string, then convert it to the correct type
    if (not isString) then
      if     (val == 'true')  then val = true
      elseif (val == 'false') then val = false
      else                         val = tonumber(val) end
    end
    
    return val, index
  end
  
  function deserializeJson(json, index)
    local state = ''         -- Used to branch parsing of keys vs values
    local tableType = ''     -- Used to handle parsing objects (keyed) vs arrays
    local index = index or 1 -- The current parsing position of the JSON string
    local data = {}          -- Stores the parsed data
    
    -- Get rid of formatting-related line breaks and tabs
    json = json:gsub('\n', '')
    json = json:gsub('\t', '')
    
    -- Determine whether we're parsing an object or an array
    local firstChar = json:sub(index, index)
    if (firstChar == '{') then
      tableType = 'object'
      state = 'findKey'
    elseif (firstChar == '[') then
      tableType = 'array'
      state = 'findValue'
    else
      -- TODO: Throw error
    end
    
    
    -- print('first:', firstChar)
    
    index = index + 1
    
    local currentKey = ''   -- Stores a parsed key (if collection is an object)
    local currentValue = '' -- Stores a parsed value
    
    -- Iterate until we're done parsing current array/object
    for i = index, #json do
      -- Get character at this index
      local c = json:sub(i, i)
      
      -- Ignore irrelevant characters
      if (c == ' ' or c == ':' or c == ',' or i < index) then goto continue end

      if (c == '}' or c == ']') then
        -- print('exiting...')
        -- print('char', c)
        -- print('loopidx', i)
        -- print('ouridx', index)
        -- print(json:sub(i))
        -- Exit out of current array/object
        index = i + 1
        break
      end
      
      -- We're searching for a key...
      if (state == 'findKey') then
        if (c == '"') then
          -- Parse key
          currentKey, index = parseValue(json, i)
          -- print('key:', currentKey)
          
          -- Indicate we'll look for a value next time
          state = 'findValue'
        end
      -- We're searching for a value...
      elseif (state == 'findValue') then
        -- Parse value
        if (c == '{' or c == '[') then
          -- Recurse if we've found an array/object
          currentValue, index = deserializeJson(json, i)
        else
          -- Parse value normally
          currentValue, index = parseValue(json, i)
        end
        -- print('val:', currentValue)
        
        -- Store into data
        if (tableType == 'object') then
          data[currentKey] = currentValue
          state = 'findKey'
        elseif (tableType == 'array') then
          table.insert(data, currentValue)
        end
        
        -- Reset current key/value
        currentKey = ''
        currentValue = ''
      end
      
      ::continue::
    end
    
    return data, index
  end
  
  return deserializeJson(json)
end

-- -----------------------------------------------------------------------------

return Util