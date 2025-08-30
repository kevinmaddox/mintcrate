-- -----------------------------------------------------------------------------
-- MintCrate - Assert
-- An engine utility class for performing function argument validation.
-- -----------------------------------------------------------------------------

local Assert = {}

function Assert.type(funcName, argName, val, expectedType, isOptional)
  if (not isOptional) then isOptional = false end
  
  -- Get argument type, including pseudo-types from classes.
  local argType = type(val)
  if (argType == 'table' and val.type) then argType = val.type end
  
  -- Check for errors.
  local faultCode = 0
  
  if (not isOptional or argType ~= 'nil') then
    -- Check that an argument was supplied.
    if (argType == 'nil') then faultCode = 1
    -- Check type.
    elseif (argType ~= expectedType) then faultCode = 2 end
  end
  
  if     (faultCode == 1) then
    error('Missing mandatory argument "'..argName..'" in function "'..funcName..'".', 3)
  elseif (faultCode == 2) then
    error('Argument "'..argName..'" in function "'..funcName..'" must be of type "'..expectedType..'".', 3)
  end
end

function Assert.self(funcName, val)
  if (type(val) == 'nil') then
    error('Missing reference to "self" in function "'..funcName..'". Most likely, you called this function via a dot instead of a colon.', 3)
  end
end

-- -----------------------------------------------------------------------------

return Assert