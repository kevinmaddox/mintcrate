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
  local values = {...}
  local total = 0
  
  for i, value in pairs(values) do
    total = total + value
  end
  
  return total / util.size(values)
end

-- Forces a number to be within a certain range (inclusive).
-- @param {number} value The value to be clamped.
-- @param {number} limitLower The lower value of the clamping range.
-- @param {number} limitUpper The upper value of the clamping range.
-- @returns {number} Clamped value.
function MathX.clamp(value, limitLower, limitUpper)
  -- Allow checking regardless of range order
  if limitLower > limitUpper then
    limitLower, limitUpper = limitUpper, limitLower
  end
  
  return math.max(limitLower, math.min(limitUpper, value))
end

-- Returns the midpoint X,Y coordinates for a line (two points in space).
-- @param {number} x1 X coordinate of the first point.
-- @param {number} y1 Y coordinate of the first point.
-- @param {number} x2 X coordinate of the second point.
-- @param {number} y2 Y coordinate of the second point.
-- @returns {number, number} X,Y coordinates of the midpoint.
function MathX.midpoint(x1, y1, x2, y2)
  return ((x1 + x2) / 2), ((y1 + y2) / 2)
end

-- Rounds a decimal value to the nearest whole value (up or down).
-- @param {number} value The value to be rounded.
-- @param {number} numDecimalPlaces The number of decimal places to round to.
-- @returns {number} Rounded value.
function MathX.round(value, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(value * mult + 0.5) / mult
end

-- Returns the positive (1) or negative (-1) sign of a value (returns 0 if 0).
-- @param {number} value The value to get the sign of.
-- @returns {number} Sign of value.
function MathX.sign(value)
  if value == 0 then
    return 0
  elseif value > 0 then
    return 1
  else
    return -1
  end
end

-- Returns a value only if it's at or above a threshold
-- @param {number} value The numeric value to threshold.
-- @param {number} threshold Numeric threshold which must be met or exceeded.
-- @param {number} default Value returned if the condition is not met.
-- @returns {number} Thresholded-above value.
function MathX.thresholdAbove(value, threshold, default)
  local result = default
  if value >= threshold then result = value end
  return result
end

-- Returns a value only if it's at or below a threshold.
-- @param {number} value The numeric value to threshold.
-- @param {number} threshold Numeric threshold which must be met or not exceeded.
-- @param {number} default Value returned if the condition is not met.
-- @returns {number} Thresholded-below value.
function MathX.thresholdBelow(value, threshold, default)
  local result = default
  if value <= threshold then result = value end
  return result
end

-- -----------------------------------------------------------------------------

return MathX