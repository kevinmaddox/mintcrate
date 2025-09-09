-- -----------------------------------------------------------------------------
-- MintCrate - Loader
-- A script for loading the entire MintCrate framework.
-- -----------------------------------------------------------------------------

local pkg = (...):match("(.-)[^%.]+$")

MintCrate = {}
MintCrate.Core         = require(pkg .. "core")
MintCrate.Error        = require(pkg .. "error")
MintCrate.Assert       = require(pkg .. "assert")
MintCrate.Entity       = require(pkg .. "entity")
MintCrate.Active       = require(pkg .. "active")
MintCrate.Backdrop     = require(pkg .. "backdrop")
MintCrate.Text         = require(pkg .. "text")
MintCrate.Room         = require(pkg .. "room")
MintCrate.InputHandler = require(pkg .. "inputhandler")
MintCrate.Util         = require(pkg .. "util")
MintCrate.MathX        = require(pkg .. "mathx")

-- Creates and returns an instance of the MintCrate framework (see class Core).
-- @param baseWidth The game's unscaled, base width resolution, in pixels.
-- @param baseHeight The game's unscaled, base height resolution, in pixels.
-- @param startingRoom The room to initially load into.
-- @param {table} options Additional/optional parameters for configuration.
-- @returns A new instance of the Engine class.
function MintCrate:new(
  baseWidth,
  baseHeight,
  startingRoom,
  options
)
  -- Create MintCrate instance
  local mc = MintCrate.Core:new(
    baseWidth,
    baseHeight,
    startingRoom,
    options
  )
  
  -- Store module path for loading system image resources
  mc._sysImgPath = pkg.."img.encoded."
  
  -- Store libs into instance so that user can access them easily
  mc.util   = MintCrate.Util
  mc.math   = MintCrate.MathX

  -- Return MintCrate instance
  return mc
end