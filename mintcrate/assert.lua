-- -----------------------------------------------------------------------------
-- MintCrate - Assert
-- An engine utility class for performing function argument validation.
-- -----------------------------------------------------------------------------

local Assert = {}

-- Asserts that a function parameter is defined and is of a specified type.
-- @param {string} funcName The name of the housing function.
-- @param {string} argName The name of the argument to check.
-- @param {*} val The value of the argument to check.
-- @param {string} expectedType The expected variable type.
function Assert.type(funcName, argName, val, expectedType)
  -- Get argument type, including pseudo-types from classes.
  local argType = type(val)
  if (argType == 'table' and val.type) then argType = val.type end
  
  -- Check for errors.
  local faultCode = 0
  
  -- Check that an argument was supplied.
  if (argType == 'nil') then faultCode = 1
  -- Check type.
  elseif (argType ~= expectedType) then faultCode = 2 end
  
  -- Throw error based on fault code.
  if     (faultCode == 1) then
    error('Missing mandatory argument "' .. argName .. 
      '" in function "' .. funcName .. '".', 3)
  elseif (faultCode == 2) then
    error('Argument "' .. argName .. '" in function "' .. funcName .. 
      '" must be of type "' .. expectedType .. '".', 3)
  end
end

-- Asserts that a function had "self" passed into it.
-- @param {string} funcName The name of the housing function.
-- @param {*} selfInstance The instance of "self".
function Assert.self(funcName, selfInstance)
  if (type(selfInstance) == 'nil') then
    error('Missing reference to "self" in function "' .. funcName .. 
      '". Most likely, you called this function via a dot ' ..
      'instead of a colon.', 3)
  end
end

-- -----------------------------------------------------------------------------

return Assert