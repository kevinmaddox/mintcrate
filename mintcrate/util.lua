-- -----------------------------------------------------------------------------
-- MintCrate - Util
-- A utility library for assorted helper functions.
-- -----------------------------------------------------------------------------

local Util = {}

-- -----------------------------------------------------------------------------
-- Boolean methods
-- -----------------------------------------------------------------------------

Util.boolean = {}

-- Returns a numeric value based on a boolean value (true = 1, false = 0).
-- @param {boolean} b A boolean value.
-- @returns {number} Numeric representation of a boolean value.
function Util.boolean.toNumber(b)
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
  return n > 0 and true or false
end

-- Returns 1 if positive, -1 if negative, and 0 if 0.
-- @param {number} n A numeric value.
-- @returns {number} A representation of the state of the number's sign.
function Util.number.sign(n)
  local sign = 0
  if (n > 0) then sign = 1 elseif (n < 0) then sign = -1 end
  return sign
end

-- -----------------------------------------------------------------------------
-- Table-related methods
-- -----------------------------------------------------------------------------

Util.table = {}

-- Formats a table as a newline-delimited string, useful for debugging.
-- @param {table} o The table to be formatted.
-- @param {number} indent How much to indent each nested item.
-- @returns {string} A formatted string representing a table.
function Util.table.toString(o, indent)
  local indent = indent or 1

  if type(o) == "table" then
    local s = "{"
      for k, v in pairs(o) do
        if type(k) ~= "number" then k = "\""..k.."\"" end
        s = s .. "\n" .. string.rep("  ", indent) .. "["..k.."] = " ..
          Util.table.toString(v, indent + 1) .. ","
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

-- Prints a table.
-- @param {table} tbl The table to be printed.
-- @param {boolean} numericallyIndexed Whether keys are numeric & sequential.
function Util.table.print(tbl, numericallyIndexed)
  if (numericallyIndexed) then
    for i,v in ipairs(tbl) do print(i,v) end
  else
    for k,v in pairs(tbl) do print(k,v) end
  end
end

-- Moves an item backward in a table (decrements its index).
-- @param {table} tbl The table to be rearranged.
-- @param {number} index The index of the item to be moved.
function Util.table.moveItemDown(tbl, index)
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
  if index >= 1 and index < #tbl then
    local val = tbl[index]
    table.remove(tbl, index)
    table.insert(tbl, #tbl+1, val)
  end
end

-- Reverses the order of a table (for numerically-indexed tables).
-- @param {table} tbl The table to be reversed.
function Util.table.reverse(tbl)
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
  local c = 0
  for k,v in pairs(tbl) do c = c + 1 end
  return c
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
  delimiter = delimiter or ''
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
  local bool = false
  if str == 'true' then bool = true end
  return bool
end

-- Trims leading and trailing whitespace from a string, including returns.
-- @param {string} str The string to be trimmed.
-- @returns {string} A string with its leading/trailing whitespace removed.
function Util.string.trim(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

-- Repeats a string.
-- @param {string} str The string to be repeated.
-- @param {number} numRepeat The number of times to repeat the string.
-- @returns {string} A repeated string.
function Util.string.reiterate(str, numRepeat)
  local repStr = ""
  for i = 1, numRepeat do
    repStr = repStr .. str
  end
  return repStr
end

-- Pads the left side of a string with characters to a specified length.
-- @param {string} str The string to be padded (numbers work too).
-- @param {number} length The length to pad the string to.
-- @param {string} padChar The character to pad the string with.
-- @returns {string} A left-padded string.
function Util.string.padLeft(str, length, padChar)
  str = str or ""
  str = tostring(str)
  while string.len(str) < length do str = padChar .. str end
  return str
end

-- Pads the right side of a string with characters to a specified length.
-- @param {string} str The string to be padded (numbers work too).
-- @param {number} length The length to pad the string to.
-- @param {string} padChar The character to pad the string with.
-- @returns {string} A right-padded string.
function Util.string.padRight(str, length, padChar)
  str = str or ""
  str = tostring(str)
  while string.len(str) < length do str = str .. padChar end
  return str
end

-- -----------------------------------------------------------------------------

return Util