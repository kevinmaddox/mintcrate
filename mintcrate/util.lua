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
  local f = 'randomChoice'
  
  -- Store arguments in table
  local values = {...}
  
  -- Validate: arguments
  MintCrate.Assert.condition(f,
    '...',
    (#values > 0),
    'expects at least one argument')
  
  -- Return random item
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
  
  -- Validate: b
  MintCrate.Assert.type(f, 'b', b, 'boolean')
  
  -- Return result
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
  
  -- Validate: n
  MintCrate.Assert.type(f, 'n', n, 'number')
  
  -- Return result
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
  
  -- Default params
  if (indent == nil) then indent = 1 end
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  -- Validate: indent
  MintCrate.Assert.type(f, 'indent', indent, 'number')
  
  -- Recursive function for building the table string
  function printTbl(o, indent)
    if (type(o) == "table") then
      local s = "{"
        for k, v in pairs(o) do
          if (type(k) ~= "number") then k = "\""..k.."\"" end
          s = s .. "\n" .. string.rep("  ", indent) .. "["..k.."] = " ..
            printTbl(v, indent + 1) .. ","
        end
      if (s:sub(-1) == ",") then s = s:sub(1, -2) end
      return s .. "\n" .. string.rep("  ", indent - 1) .. "}"
    else
      if (type(o) == "string") then
        return "\""..o.."\""
      else
        return tostring(o)
      end
    end
  end
  
  -- Return result
  return printTbl(tbl, indent)
end

-- Prints a table.
-- @param {table} tbl The table to be printed.
function Util.table.print(tbl)
  local f = 'table.print'
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  -- Print table
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
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  MintCrate.Assert.condition(f,
    'tbl',
    Util.table.matchesArrayPattern(tbl),
    'must have numerically-indexed, sequential keys')
  
  -- Validate: index
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  MintCrate.Assert.condition(f,
    'index',
    (index > 0),
    'must be a value greater than zero')
  
  -- Rearrange item
  if (index > 1 and index <= #tbl) then
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
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  MintCrate.Assert.condition(f,
    'tbl',
    Util.table.matchesArrayPattern(tbl),
    'must have numerically-indexed, sequential keys')
  
  -- Validate: index
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  MintCrate.Assert.condition(f,
    'index',
    (index > 0),
    'must be a value greater than zero')
  
  -- Rearrange item
  if (index >= 1 and index < #tbl) then
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
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  MintCrate.Assert.condition(f,
    'tbl',
    Util.table.matchesArrayPattern(tbl),
    'must have numerically-indexed, sequential keys')
  
  -- Validate: index
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  MintCrate.Assert.condition(f,
    'index',
    (index > 0),
    'must be a value greater than zero')
  
  -- Rearrange item
  if (index > 1 and index <= #tbl) then
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
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  MintCrate.Assert.condition(f,
    'tbl',
    Util.table.matchesArrayPattern(tbl),
    'must have numerically-indexed, sequential keys')
  
  -- Validate: index
  MintCrate.Assert.type(f, 'index', index, 'number')
  
  MintCrate.Assert.condition(f,
    'index',
    (index > 0),
    'must be a value greater than zero')
  
  -- Rearrange item
  if (index >= 1 and index < #tbl) then
    local val = tbl[index]
    table.remove(tbl, index)
    table.insert(tbl, #tbl+1, val)
  end
end

-- Reverses the order of a table (for numerically-indexed tables).
-- @param {table} tbl The table to be reversed.
function Util.table.reverse(tbl)
  local f = 'table.reverse'
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  MintCrate.Assert.condition(f,
    'tbl',
    Util.table.matchesArrayPattern(tbl),
    'must have numerically-indexed, sequential keys')
  
  -- Reverse table
  local i, j = 1, #tbl
  
  while (i < j) do
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
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  -- Tally table
  local c = 0
  for k,v in pairs(tbl) do
    c = c + 1
  end
  
  -- Return result
  return c
end

-- Checks if a table contains a specified item.
-- @param {table} tbl The table to search in.
-- @param {*} item The item to search for.
-- @returns {boolean} Whether the item was found in the table.
function Util.table.contains(tbl, item)
  local f = 'table.contains'
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  -- Search for item in table
  local found = false
  
  for _,v in pairs(tbl) do
    if (v == item) then
      found = true
    end
  end
  
  -- Return result
  return found
end

-- Checks whether a table resembles an array (numeric+sequential keys).
-- @param {table} tbl The table to check.
function Util.table.matchesArrayPattern(tbl)
  local f = 'table.matchesArrayPattern'
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  -- Determine if table matches array pattern
  local isArray = true
  local i       = 0
  
  for _, __ in pairs(tbl) do
    i = i + 1
    if (tbl[i] == nil) then
      isArray = false
      break
    end
  end
  
  -- Return result
  return isArray
end

-- -----------------------------------------------------------------------------
-- String-related methods
-- -----------------------------------------------------------------------------

Util.string = {}

-- Splits a string into a table (only works with a single-character delimiter).
-- @param {string} str The string to be split.
-- @param {string} delimiter The character to split on (omit to split all).
-- @returns {table} The split-up parts of a string.
function Util.string.split(str, delimiter)
  local f = 'string.split'
  
  -- Default params
  if (delimiter == nil) then delimiter = '' end
  
  -- Validate: str
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  -- Validate: delimiter
  MintCrate.Assert.type(f, 'delimiter', delimiter, 'string')
  
  -- Split string into table
  str       = tostring(str)
  delimiter = tostring(delimiter)
  
  local split = {}
  local start = 1
  local i     = 1
  
  for chr in string.gmatch(str, ".") do
    if (delimiter == '') then
      table.insert(split, chr)
    elseif (chr == delimiter) then
      table.insert(split, str:sub(start, i - 1))
      start = i + 1
    end
    
    i = i + 1
  end
  
  if (delimiter ~= '') then
    table.insert(split, str:sub(start, i))
  end
  
  -- Return result
  return split
end

-- Converts a string, either "true" or "false", to the boolean-type equivalent.
-- @param {string} str The string to be converted.
-- @returns {boolean} A boolean representation of a string.
function Util.string.toBoolean(str)
  local f = 'string.toBoolean'
  
  -- Validate: str
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  MintCrate.Assert.condition(f,
    'str',
    (str == 'true' or str == 'false'),
    'must be a string that\'s either "true" or "false"')
  
  -- Convert string to boolean
  local bool = false
  
  if (str == 'true') then
    bool = true
  end
  
  -- Return result
  return bool
end

-- Trims leading and trailing whitespace from a string, including returns.
-- @param {string} str The string to be trimmed.
-- @returns {string} A string with its leading/trailing whitespace removed.
function Util.string.trim(str)
  local f = 'string.trim'
  
  -- Validate: str
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  -- Return result
  return str:gsub("^%s*(.-)%s*$", "%1")
end

-- Pads the left side of a string with characters to a specified length.
-- @param {string} str The string to be padded.
-- @param {number} length The length to pad the string to.
-- @param {string} padChar The character to pad the string with.
-- @returns {string} A left-padded string.
function Util.string.padLeft(str, length, padChar)
  local f = 'string.padLeft'
  
  -- Validate: str
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  -- Validate: length
  MintCrate.Assert.type(f, 'length', length, 'number')
  
  MintCrate.Assert.condition(f,
    'length',
    (length >= 0),
    'cannot be a negative value')
  
  -- Validate: padChar
  MintCrate.Assert.type(f, 'padChar', padChar, 'string')
  
  -- Pad string
  while (string.len(str) < length) do
    str = padChar .. str
  end
  
  -- Return result
  return str
end

-- Pads the right side of a string with characters to a specified length.
-- @param {string} str The string to be padded.
-- @param {number} length The length to pad the string to.
-- @param {string} padChar The character to pad the string with.
-- @returns {string} A right-padded string.
function Util.string.padRight(str, length, padChar)
  local f = 'string.padRight'
  
  -- Validate: str
  MintCrate.Assert.type(f, 'str', str, 'string')
  
  -- Validate: length
  MintCrate.Assert.type(f, 'length', length, 'number')
  
  MintCrate.Assert.condition(f,
    'length',
    (length >= 0),
    'cannot be a negative value')
  
  -- Validate: padChar
  MintCrate.Assert.type(f, 'padChar', padChar, 'string')
  
  -- Pad string
  while (string.len(str) < length) do
    str = str .. padChar
  end
  
  -- Return result
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
  
  -- Default params
  if (prettyPrint == nil) then prettyPrint = false end
  if (numSpaces == nil) then numSpaces = 2 end
  
  -- Validate: tbl
  MintCrate.Assert.type(f, 'tbl', tbl, 'table')
  
  -- Validate: prettyPrint
  MintCrate.Assert.type(f, 'prettyPrint', prettyPrint, 'boolean')
  
  -- Validate: numSpaces
  MintCrate.Assert.type(f, 'numSpaces', numSpaces, 'number')
  
  MintCrate.Assert.condition(f,
    'numSpaces',
    (numSpaces >= 0),
    'cannot be a negative value')
  
  -- This sub-function attempts to serialize a value
  function serializeValue(val, key, indent, tab, newline)
    local str      = ''
    local errorMsg = ''
    
    -- Add formatting
    str = str .. newline .. str.rep(tab, indent)
    
    -- Add key if table has named keys
    if (key) then str = str .. '"'..key..'":' end
    
    -- Serialize value
    if (type(val) == 'boolean') then
      str = str .. tostring(val) .. ','
    elseif (type(val) == 'number') then
      str = str .. val .. ','
    elseif (type(val) == 'string') then
      -- Handle characters which need to be escaped
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
      -- Recursively serialize sub-table
      local result
      result, errorMsg = serializeTable(val, indent, tab, newline)
      if (result ~= nil) then
        str = str .. result .. ','
      else
        return nil, errorMsg
      end
    else
      -- Return error if type was not serializable
      return
        nil,
        'Attempted to serialize data of invalid type "' .. type(val) .. '".'
    end
    
    return str, errorMsg
  end
  
  -- This sub-function attempts to serialize a table
  function serializeTable(tbl, indent, tab, newline)
    -- Prepare for serialization
    local str      = ''
    local errorMsg = ''
    
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
    if (isArray) then
      for _, val in ipairs(tbl) do
        local result
        result, errorMsg = serializeValue(val, nil, indent, tab, newline)
        if (result ~= nil) then
          str = str .. result
        else
          return nil, errorMsg
        end
      end
    else
      for key, val in pairs(tbl) do
        local result
        result, errorMsg = serializeValue(val, key, indent, tab, newline)
        if (result ~= nil) then
          str = str .. result
        else
          return nil, errorMsg
        end
      end
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
    
    return str, errorMsg
  end
  
  local indent  = 0
  local tab     = ''
  local newline = ''
  if (prettyPrint) then
    tab = string.rep(' ', numSpaces)
    -- tab = '\t' -- TODO: Remove me?
    newline = '\n'
  end
  
  -- Convert table to JSON string
  local result, errorMsg = serializeTable(tbl, indent, tab, newline)
  
  -- Return result
  return result, errorMsg
end

-- Deserializes a standard JSON string into a table.
-- @param {string} json The JSON string to deserialize.
-- @returns {string} A table parsed from the JSON string.
function Util.json.decode(json)
  local f = 'json.decode'
  
  -- Validate: json
  MintCrate.Assert.type(f, 'json', json, 'string')
  
  -- This sub-function attempts to un-escape an escaped character
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
  
  -- This sub-function attempts to parse a JSON-encoded value
  function parseValue(json, index)
    local val        = ''
    local ignoreChar = false -- Used to ignore second part of escape chars
    local isString   = false -- Used to handle quoted strings
    
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
      elseif (
        not isString
        and (c == ']' or c == '}')
      ) then
        index = index - 1
        break
      -- Parse next 2 characters if an escape character was found
      elseif (c == '\\') then
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
  
  -- This sub-function attempts to parse a JSON array/object
  function deserializeJson(json, index)
    local state     = ''         -- Used to branch parsing of keys vs values
    local tableType = ''         -- Used to handle parsing objects vs arrays
    local index     = index or 1 -- The current parsing position of the string
    local data      = {}         -- Stores the parsed data
    local errorMsg  = ''
    
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
      return nil, nil, 'Could not find opening bracket or brace.'
    end
    
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
        -- Exit out of current array/object
        index = i + 1
        break
      end
      
      -- We're searching for a key...
      if (state == 'findKey') then
        if (c == '"') then
          -- Parse key
          currentKey, index = parseValue(json, i)
          
          -- Indicate we'll look for a value next time
          state = 'findValue'
        end
      -- We're searching for a value...
      elseif (state == 'findValue') then
        -- Parse value
        if (c == '{' or c == '[') then
          -- Recurse if we've found an array/object
          currentValue, index, errorMsg = deserializeJson(json, i)
          if (currentValue == nil) then
            return nil, nil, errorMsg
          end
        else
          -- Parse value normally
          currentValue, index = parseValue(json, i)
        end
        
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
    
    return data, index, errorMsg
  end
  
  -- Convert JSON string to table
  local result, index, errorMsg = deserializeJson(json)
  
  if (errorMsg ~= '') then
    errorMsg = 'JSON parsing error: ' .. errorMsg
  end
  
  -- Return result
  return result, errorMsg
end

-- -----------------------------------------------------------------------------

return Util