-- -----------------------------------------------------------------------------
-- MintCrate - Assert
-- An engine utility for performing function argument validation.
-- -----------------------------------------------------------------------------

return function(expectedType, funcName, argName, val, options)
  local options = options or {}
  local optional = false
  if (type(options.optional) ~= 'nil') then optional = options.optional end
  local condition = true
  if (type(options.condition) ~= 'nil') then condition = options.condition end
  
  local faultCode = 0
  
  -- Get argument type, including pseudo types from classes.
  local argType = type(val)
  if (argType == 'table' and val.type) then argType = val.type end
  -- print(val.type)
  
  -- Skip all checking if argument is optional and no value was supplied.
  if (optional and argType == 'nil') then goto done end
  
  -- Check that an argument was supplied.
  if (argType == nil) then faultCode = 1
  -- Check type.
  elseif (argType ~= expectedType) then faultCode = 2
  -- Check conditional.
  elseif (not condition) then faultCode = 3 end
  
  ::done::
  
  if (faultCode ~= 0) then
    if     (faultCode == 1) then
      error('Missing mandatory argument "'..argName..'" in function "'..funcName..'".')
    elseif (faultCode == 2) then
      error('Argument "'..argName..'" in function "'..funcName..'" must be of type "'..expectedType..'".')
    elseif (faultCode == 3) then
      error('Argument "'..argName..'" in function "'..funcName..'" failed to meet required condition(s).')
    end
  end
end