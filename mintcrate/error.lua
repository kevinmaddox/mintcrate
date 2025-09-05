-- -----------------------------------------------------------------------------
-- MintCrate - Error
-- An engine utility class for throwing errors.
-- -----------------------------------------------------------------------------

-- Throws an error, pushed up in the stack (convenience function).
-- @param {string} msg The error message.
return function(funcName, msg)
  if (funcName ~= nil) then
    error('Error in function "' .. funcName .. '". ' .. msg, 3)
  else
    error(msg, 3)
  end
end