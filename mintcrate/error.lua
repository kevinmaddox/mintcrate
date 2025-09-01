-- -----------------------------------------------------------------------------
-- MintCrate - Error
-- An engine utility class for throwing errors.
-- -----------------------------------------------------------------------------

-- Throws an error, pushed up in the stack (convenience function).
-- @param {string} msg The error message.
return function(msg)
  error(msg, 3)
end