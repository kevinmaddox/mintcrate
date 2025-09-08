-- -----------------------------------------------------------------------------
-- MintCrate - MathX
-- A utility library for assorted mathematical functions.
-- -----------------------------------------------------------------------------

local MathX = {}

-- -----------------------------------------------------------------------------
-- General mathematical methods
-- -----------------------------------------------------------------------------

-- Returns the average value of a series of numbers.
-- @param {number} ... Any number of numeric values to be averaged.
-- @returns {number} Average of all numbers.
function MathX.average(...)
  local f = 'average'
  
  -- Store arguments in table
  local values = {...}
  
  -- Validate: arguments
  MintCrate.Assert.condition(f,
    '...',
    (#values > 0),
    'expects at least one argument')
  
  -- Calculate mean
  local total = 0
  
  for i, value in pairs(values) do
    -- Validate: arguments (individual value)
    MintCrate.Assert.condition(f,
      '...',
      type(value) == 'number',
      'must only be numeric values')
    
    total = total + value
  end
  
  -- Return result
  return total / util.size(values)
end

-- Forces a number to be within a certain range (inclusive).
-- @param {number} value The value to be clamped.
-- @param {number} limitLower The lower value of the clamping range.
-- @param {number} limitUpper The upper value of the clamping range.
-- @returns {number} Clamped value.
function MathX.clamp(value, limitLower, limitUpper)
  local f = 'clamp'
  
  -- Validate: value
  MintCrate.Assert.type(f, 'value', value, 'number')
  
  -- Validate: limitLower
  MintCrate.Assert.type(f, 'limitLower', limitLower, 'number')
  
  -- Validate: limitUpper
  MintCrate.Assert.type(f, 'limitUpper', limitUpper, 'number')
  
  -- Validate: limitLower and limitUpper
  if (limitLower > limitUpper) then
    MintCrate.Error(f,
      'Argument "limitLower" cannot be greater than argument "limitUpper".'
    )
  end
  
  -- Clamp value and return result
  return math.max(limitLower, math.min(limitUpper, value))
end

-- Tests whether a number is an integer.
-- @param {number} value The value to test.
-- @returns {boolean} Whether the value is integral.
function MathX.isIntegral(value)
  local f = 'isIntegral'
  
  -- Vaidate: value
  MintCrate.Assert.type(f, 'value', value, 'number')
  
  -- Test integrality and return result
  return (math.floor(value) == value)
end

-- Returns the midpoint X,Y coordinates for a line (two points in space).
-- @param {number} x1 X coordinate of the first point.
-- @param {number} y1 Y coordinate of the first point.
-- @param {number} x2 X coordinate of the second point.
-- @param {number} y2 Y coordinate of the second point.
-- @returns {number, number} X,Y coordinates of the midpoint.
function MathX.midpoint(x1, y1, x2, y2)
  local f = 'midpoint'
  
  -- Validate: x1
  MintCrate.Assert.type(f, 'x1', x1, 'number')
  
  -- Validate: y1
  MintCrate.Assert.type(f, 'y1', y1, 'number')
  
  -- Validate: x2
  MintCrate.Assert.type(f, 'x2', x2, 'number')
  
  -- Validate: y2
  MintCrate.Assert.type(f, 'y2', y2, 'number')
  
  -- Calculate midpoint and result result
  return ((x1 + x2) / 2), ((y1 + y2) / 2)
end

-- Rounds a decimal value to the nearest whole value (up or down).
-- @param {number} value The value to be rounded.
-- @param {number} numDecimalPlaces The number of decimal places to round to.
-- @returns {number} Rounded value.
function MathX.round(value, numDecimalPlaces)
  local f = 'round'
  
  -- Default params
  if (numDecimalPlaces == nil) then numDecimalPlaces = 0 end
  
  -- Validate: value
  MintCrate.Assert.type(f, 'value', value, 'number')
  
  -- Validate: numDecimalPlaces
  MintCrate.Assert.type(f, 'numDecimalPlaces', numDecimalPlaces, 'number')
  
  MintCrate.Assert.condition(f,
    'numDecimalPlaces',
    (numDecimalPlaces >= 0),
    'cannot be a negative value')
  
  -- Round value and result result
  local mult = 10^(numDecimalPlaces)
  
  return math.floor(value * mult + 0.5) / mult
end

-- Returns 1 if positive, -1 if negative, and 0 if 0.
-- @param {number} n A numeric value.
-- @returns {number} A representation of the state of the number's sign.
function MathX.sign(value)
  local f = 'sign'
  
  -- Validate: value
  MintCrate.Assert.type(f, 'value', value, 'number')
  
  -- Determine sign
  local sign = 0
  
  if (n > 0) then
    sign = 1
  elseif (n < 0) then
    sign = -1
  end
  
  -- Return result
  return sign
end

-- Returns a value only if it's at or above a threshold
-- @param {number} value The numeric value to threshold.
-- @param {number} threshold Numeric threshold which must be met or exceeded.
-- @param {number} default Value returned if the condition is not met.
-- @returns {number} Thresholded-above value.
function MathX.thresholdAbove(value, threshold, default)
  local f = 'thresholdAbove'
  
  -- Validate: value
  MintCrate.Assert.type(f, 'value', value, 'number')
  
  -- Validate: threshold
  MintCrate.Assert.type(f, 'threshold', threshold, 'number')
  
  -- Validate: default
  MintCrate.Assert.type(f, 'default', default, 'number')
  
  -- Threshold value
  local result = default
  if (value >= threshold) then
    result = value
  end
  
  -- Return result
  return result
end

-- Returns a value only if it's at or below a threshold.
-- @param {number} value The numeric value to threshold.
-- @param {number} threshold Numeric threshold which must be met or not exceeded.
-- @param {number} default Value returned if the condition is not met.
-- @returns {number} Thresholded-below value.
function MathX.thresholdBelow(value, threshold, default)
  local f = 'thresholdBelow'
  
  -- Validate: value
  MintCrate.Assert.type(f, 'value', value, 'number')
  
  -- Validate: threshold
  MintCrate.Assert.type(f, 'threshold', threshold, 'number')
  
  -- Validate: default
  MintCrate.Assert.type(f, 'default', default, 'number')
  
  -- Threshold value
  local result = default
  if (value <= threshold) then
    result = value
  end
  
  -- Return result
  return result
end

-- -----------------------------------------------------------------------------

return MathX