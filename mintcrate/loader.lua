-- -----------------------------------------------------------------------------
-- MintCrate - Loader
-- A script for loading the entire MintCrate framework.
-- -----------------------------------------------------------------------------

local pkg = (...):match("(.-)[^%.]+$")

MintCrate = {}
MintCrate.Engine       = require(pkg .. "engine")
MintCrate.Error        = require(pkg .. "error")
MintCrate.Assert       = require(pkg .. "assert")
MintCrate.Entity       = require(pkg .. "entity")
MintCrate.Active       = require(pkg .. "active")
MintCrate.Backdrop     = require(pkg .. "backdrop")
MintCrate.Paragraph    = require(pkg .. "paragraph")
MintCrate.Room         = require(pkg .. "room")
MintCrate.InputHandler = require(pkg .. "inputhandler")
MintCrate.Util         = require(pkg .. "util")
MintCrate.MathX        = require(pkg .. "mathx")

-- Creates and returns an instance of the MintCrate engine (see class Engine).
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
  local engine = MintCrate.Engine:new(
    baseWidth,
    baseHeight,
    startingRoom,
    options
  )
  
  -- Store module path for loading system image resources
  engine._sysImgPath = pkg.."img.encoded."
  
  -- Store libs into engine instance so that user can access them easily.
  engine.util   = MintCrate.Util
  engine.math   = MintCrate.MathX
  
  return engine
end