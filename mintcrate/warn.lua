-- -----------------------------------------------------------------------------
-- MintCrate - Warn
-- An engine utility class for printing warnings.
-- -----------------------------------------------------------------------------

-- Print a warning message.
-- @param {string|nil} funcName The name of the housing function.
-- @param {string} msg The warning message.
return function(funcName, msg)
  if (funcName ~= nil) then
    print('Warning in function "' .. funcName .. '". ' .. msg)
  else
    print(msg)
  end
end