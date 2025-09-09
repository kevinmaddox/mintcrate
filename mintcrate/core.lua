-- -----------------------------------------------------------------------------
-- MintCrate - Core
-- Framework core.
-- -----------------------------------------------------------------------------

local Core = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the framework core class.
-- @param {number} baseWidth The game's unscaled, base width resolution.
-- @param {number} baseHeight The game's unscaled, base height resolution.
-- @param {Room} startingRoom The room to initially load into.
-- @param {table} options Additional/optional parameters for configuration.
-- @param {number} options.windowScale Starting graphical scale of the window.
-- @param {string} options.windowTitle Title shown on the window title bar.
-- @param {string} options.windowIconPath Icon shown on the window title bar.
-- @returns {Core} A new instance of the Core class.
function Core:new(
  baseWidth,
  baseHeight,
  startingRoom,
  options
)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  local f = 'new'
  
  -- Default params
  if (options == nil) then
    options = {}
  end
  
  if (options.windowScale == nil) then
    options.windowScale = 1
  end
  
  if (options.windowTitle == nil) then
    options.windowTitle = "MintCrate Project"
  end
  
  if (options.windowIconPath == nil) then
    options.windowIconPath = ""
  end
  
  -- Validate: baseWidth
  MintCrate.Assert.type(f,
    'baseWidth',
    baseWidth,
    'number')
  
  MintCrate.Assert.condition(f,
    'baseWidth',
    (baseWidth > 0),
    'must be a value greater than 0')
  
  -- Validate: baseHeight
  MintCrate.Assert.type(f,
    'baseHeight',
    baseHeight,
    'number')
  
  MintCrate.Assert.condition(f,
    'baseHeight',
    (baseHeight > 0),
    'must be a value greater than 0')
  
  -- Validate: startingRoom
  MintCrate.Assert.type(f,
    'startingRoom',
    startingRoom,
    'Room')
  
  -- Validate: options
  MintCrate.Assert.type(f,
    'options',
    options,
    'table')
  
  -- Validate: options.windowScale
  MintCrate.Assert.type(f,
    'options.windowScale',
    options.windowScale,
    'number')
  
  MintCrate.Assert.condition(f,
    'options.windowScale',
    (options.windowScale > 0),
    'must be a value greater than 0')
  
  MintCrate.Assert.condition(f,
    'options.windowScale',
    (MintCrate.MathX.isIntegral(options.windowScale)),
    'must be an integer')
  
  -- Validate: windowTitle
  MintCrate.Assert.type(f,
    'options.windowTitle',
    options.windowTitle,
    'string')
  
  -- Validate: options.windowIconPath
  MintCrate.Assert.type(f,
    'options.windowIconPath',
    options.windowIconPath,
    'string')
  
  -- Initialize Love
  love.graphics.setLineStyle("rough")
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Constants
  o._COLLIDER_SHAPES = {NONE = 0, RECTANGLE = 1, CIRCLE = 2}
  
  -- Resource directory paths
  o._resPaths = {
    actives   = "res/actives/",
    backdrops = "res/backdrops/",
    fonts     = "res/fonts/",
    music     = "res/music/",
    sounds    = "res/sounds/",
    tilemaps  = "res/tilemaps/"
  }
  
  -- Base game width/height
  o._baseWidth  = baseWidth
  o._baseHeight = baseHeight
  
  -- Window values
  self._windowTitle    = options.windowTitle
  self._windowIconPath = options.windowIconPath
  
  -- Graphics scaling values
  o._windowScale     = options.windowScale -- Unaffected by fullscreen
  o._gfxScale        = o._windowScale -- The actual graphics scaling value
  o._fullscreen      = false
  o._fullscreenDirty = false -- Indicates scale was changed in fullscreen mode
  
  -- Graphics offset values (important for graphics scaling)
  o._gfxOffsetX = 0
  o._gfxOffsetY = 0
  
  -- Holds RGB value sets for color keying
  o._colorKeyColors = {}
  
  -- System graphics for debugging purposes
  o._systemImages = {}
  o._systemFonts  = {}
  
  -- Functions that get called after a delay
  self._queuedFunctions = {}
  
  -- Stores input handlers for managing player input
  o._inputHandlers = {}
  o._keystates     = {}
  o._joystates     = {}
  o._keyboard      = {}
  
  -- Store handlers for managing mouse events
  self._mouseStates = {}
  self._mousePositions = {
    localX  = 0, localY  = 0,
    globalX = 0, globalY = 0
  }
  self._mouseButtons = {
    [1] = {pressed = false, held = false, released = false},
    [2] = {pressed = false, held = false, released = false},
    [3] = {pressed = false, held = false, released = false}
  }
  
  -- Camera
  self._camera        = {x = 0, y = 0}
  self._cameraBounds  = {x1 = 0, x2 = 0, y1 = 0, y2 = 0}
  self._cameraIsBound = false

  -- Debug functionality
  o._showFps      = false
  o._showRoomInfo = false
  
  o._showActiveCollisionMasks = false
  o._showActiveInfo           = false
  o._showActiveOriginPoints   = false
  o._showActiveActionPoints   = false

  -- FPS limiter
  o._fpsMinDt       = 1 / 60
  o._fpsNextTime    = love.timer.getTime()
  o._fpsCurrentTime = o._fpsNextTime

  -- Room/gamestate management
  o._startingRoom    = startingRoom
  o._isChangingRooms = false
  
  -- Music/SFX global volume levels
  o.masterBgmVolume = 1
  o.masterSfxVolume = 1
  o.masterBgmPitch  = 1
  
  -- Game data
  o._data = {
    actives   = {},
    backdrops = {},
    fonts     = {},
    tilemaps  = {},
    sounds    = {},
    music     = {}
  }
  
  o._instances = {
    actives    = {},
    backdrops  = {},
    text       = {},
    tiles      = {}
  }
  
  o._drawOrders = {
    backdrops = {},
    main      = {}
  }
  
  -- TODO: Implement <close> var to autorun init() when Love 12 comes out
  
  return o
end

-- -----------------------------------------------------------------------------
-- General system methods
-- -----------------------------------------------------------------------------

-- Prepares the framework for use after instantiation.
function Core:init()
  local f = 'init'
  MintCrate.Assert.self(f, self)
  
  -- Set window title.
  love.window.setTitle(self._windowTitle)
  
  -- Set window icon path.
  if (self._windowIconPath ~= "") then
    local icon = love.image.newImageData(self._windowIconPath)
    love.window.setIcon(icon)
  end
  
  -- Scale window.
  self:setWindowScale(self._windowScale, true)
end

-- Signifies that all loading has been completed and the game should run.
function Core:ready()
  local f = 'ready'
  MintCrate.Assert.self(f, self)
  
  -- Load system images (these are not Actives, just raw images)
  self._systemImages = {
    point_origin = self:_loadImage(self._sysImgPath.."point_origin", true),
    point_action = self:_loadImage(self._sysImgPath.."point_action", true)
  }
  
  -- Load system fonts (done here in case defineFonts is not called)
  self._data.fonts["system_boot"]    = self:_loadFont("system_boot")
  self._data.fonts["system_dialog"]  = self:_loadFont("system_dialog")
  self._data.fonts["system_counter"] = self:_loadFont("system_counter")
  
  -- Change to starting room
  self:changeRoom(self._startingRoom)
end

-- Terminates the application.
-- @param {boolean} fadeBeforeQuitting Trigger's the Room's fadeout first.
-- @param {boolean} fadeMusic Fades the music with the visual fade-out.
function Core:quit(fadeBeforeQuitting, fadeMusic)
  local f = 'quit'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (fadeBeforeQuitting == nil) then fadeBeforeQuitting = false end
  if (fadeMusic          == nil) then fadeMusic = false          end
  
  -- Validate: fadeBeforeQuitting
  MintCrate.Assert.type(f, 'fadeBeforeQuitting', fadeBeforeQuitting, 'boolean')
  
  -- Validate: fadeMusic
  MintCrate.Assert.type(f, 'fadeMusic', fadeMusic, 'boolean')
  
  -- Trigger the fade-out effect, then change room when it's done.
  if (fadeBeforeQuitting) then
    self:_triggerRoomFade('fadeOut', love.event.quit, fadeMusic)
  else
    love.event.quit()
  end
end

-- -----------------------------------------------------------------------------
-- Methods for loading game resources
-- -----------------------------------------------------------------------------

-- Specifies paths for loading resource files (all paths must end with a slash).
-- @param {table} resourcePaths Paths for where to find resource files.
-- @param {string} resourcePaths.actives Path for Actives.
-- @param {string} resourcePaths.backdrops Path for Backdrops.
-- @param {string} resourcePaths.fonts Path for Fonts.
-- @param {string} resourcePaths.music Path for Music.
-- @param {string} resourcePaths.sounds Path for Sounds.
-- @param {string} resourcePaths.tilemaps Path for Tilemaps.
function Core:setResourcePaths(resourcePaths)
  local f = 'setResourcePaths'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (resourcePaths == nil) then
    resourcePaths = {}
  end
  
  if (resourcePaths.actives == nil) then
    resourcePaths.actives = self._resPaths.actives
  end
  
  if (resourcePaths.backdrops == nil) then
    resourcePaths.backdrops = self._resPaths.backdrops
  end
  
  if (resourcePaths.fonts == nil) then
    resourcePaths.fonts = self._resPaths.fonts
  end
  
  if (resourcePaths.music == nil) then
    resourcePaths.music = self._resPaths.music
  end
  
  if (resourcePaths.sounds == nil) then
    resourcePaths.sounds = self._resPaths.sounds
  end
  
  if (resourcePaths.tilemaps == nil) then
    resourcePaths.tilemaps = self._resPaths.tilemaps
  end
    
  -- Validate: resourcePaths
  MintCrate.Assert.type(f, 
    'resourcePaths', resourcePaths, 'table')
  
  -- Validate: resourcePaths.actives
  MintCrate.Assert.type(f,
    'resourcePaths.actives', resourcePaths.actives, 'string')
  
  -- Validate: resourcePaths.backdrops
  MintCrate.Assert.type(f,
    'resourcePaths.backdrops', resourcePaths.backdrops, 'string')
  
  -- Validate: resourcePaths.fonts
  MintCrate.Assert.type(f,
    'resourcePaths.fonts', resourcePaths.fonts, 'string')
  
  -- Validate: resourcePaths.music
  MintCrate.Assert.type(f,
    'resourcePaths.music', resourcePaths.music, 'string')
  
  -- Validate: resourcePaths.sounds
  MintCrate.Assert.type(f,
    'resourcePaths.sounds', resourcePaths.sounds, 'string')
  
  -- Validate: resourcePaths.tilemaps
  MintCrate.Assert.type(f,
    'resourcePaths.tilemaps', resourcePaths.tilemaps, 'string')
  
  -- Store resource paths.
  for resType, path in pairs(resourcePaths) do
    self._resPaths[resType] = path
  end
end

-- Specifies which color(s) should become transparent when loading images.
-- @param {table} rgbSets Table of {r,g,b} tables, indicating the color keys.
function Core:defineColorKeys(rgbSets)
  local f = 'defineColorKeys'
  MintCrate.Assert.self(f, self)
  
  -- Validate: rgbSets
  MintCrate.Assert.type(f, 'rgbSets', rgbSets, 'table')
  
  for _, rgb in pairs(rgbSets) do
    MintCrate.Assert.type(f, 'rgbSets.table.r', rgb.r, 'number')
    MintCrate.Assert.type(f, 'rgbSets.table.g', rgb.g, 'number')
    MintCrate.Assert.type(f, 'rgbSets.table.b', rgb.b, 'number')
  end
  
  -- Store color key sets
  self._colorKeyColors = rgbSets
end

-- Loads an image resource from a file with color-keying support.
-- @param {string} imagePath Relative path of the image file.
-- @param {boolean} isSystemResource Whether the file is a MintCrate resource.
-- @returns {Source} Chroma-keyed image resource.
function Core:_loadImage(imagePath, isSystemResource)
  -- Default params
  if (isSystemResource == nil) then isSystemResource = false end
  
  -- Get ready to load image data
  local imageData
  
  -- Load Base64 image if it's an MintCrate system resource
  if (isSystemResource) then
    local imageB64     = require(imagePath)
    local imageDecoded = love.data.decode("data", "base64", imageB64)
    local imageFile    = love.filesystem.newFileData(imageDecoded, 'img.png')
    imageData          = love.image.newImageData(imageFile)
  -- Otherwise, load image from file
  else
    -- Figure out file extension
    local fileFound = false
    for _, ext in ipairs({'png', 'jpg'}) do
      if (love.filesystem.getInfo(imagePath..'.'..ext)) then
        imagePath = imagePath..'.'..ext
        fileFound = true
        break
      end
    end
    
    -- Validate: file presence
    if (not fileFound) then
      MintCrate.Error(nil,
        'Could not locate entity image "' .. imagePath .. '". ' ..
        'There does not appear to be a valid PNG or JPG file at this path.')
    end
    
    -- Load image data from file
    imageData = love.image.newImageData(imagePath)
  end
  
  
  -- Store color keys
  local colorKeyColors = self._colorKeyColors
  
  if (isSystemResource) then
    colorKeyColors = {
      {r =  82, g = 173, b = 154},
      {r = 140, g = 222, b = 205}
    }
  end
  
  -- Color key image
  for _, ckc in ipairs(colorKeyColors) do
    imageData:mapPixel(function(x, y, r, g, b, a)
      local rb, gb, bb = love.math.colorToBytes(r, g, b)
      if (rb == ckc.r and gb == ckc.g and bb == ckc.b) then a = 0 end
      return r, g, b, a
    end)
  end
  
  -- Return image
  return love.graphics.newImage(imageData)
end

-- Defines the active object entities that can be created during gameplay.
-- @param {table} data A table of active object definitions (see docs).
function Core:defineActives(data)
  local f = 'defineActives'
  MintCrate.Assert.self(f, self)
  
  -- Validate: data
  MintCrate.Assert.type(f, 'data', data, 'table')
  
  for _, item in ipairs(data) do
    -- Validate: item
    MintCrate.Assert.type(f, 'data.table', item, 'table')
    
    -- Validate: item.name
    MintCrate.Assert.type(f, 'data.table.name', item.name, 'string')
    
    -- Active's base name
    if (not string.find(item.name, '_')) then
      -- Validate: item.name (for base name)
      MintCrate.Assert.condition(f,
        'data.table.name',
        (item.name ~= ""),
        'cannot be blank')
      
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (self._data.actives[item.name] == nil),
        'was already specified')
      
      -- Store new entry for Active
      self._data.actives[item.name] = { animations = {} }
    
    -- Active's collider data
    elseif (string.find(item.name, 'collider')) then
      -- Default params
      if (item.offset == nil) then item.offset = {0, 0} end
      if (item.width  == nil) then item.width = 0       end
      if (item.height == nil) then item.height = 0      end
      if (item.radius == nil) then item.radius = 0      end
      
      -- Split name to get Active's name
      local nameParts = self.util.string.split(item.name, '_')
      
      -- Validate: item.name (for collider)
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (#nameParts == 2),
        'must be formatted as "active_collider"')
      
      -- Store active's name
      local activeName = nameParts[1]
      
      MintCrate.Assert.condition(f,
        'data.table.name',
        (activeName ~= ""),
        'cannot be blank, expected format is "active_collider"')
      
      -- Validate: item.name (for collider)
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (self._data.actives[activeName].collider == nil),
        'was already specified')
      
      -- Validate: item.offset
      MintCrate.Assert.type(f,
        "data.table.offset (entry: '"..item.name.."')",
        item.offset,
        'table')
      
      MintCrate.Assert.condition(f,
        "data.table.offset (entry: '"..item.name.."')",
        (#item.offset == 2),
        'expects two numbers, representing the X and Y offsets of the collider')
      
      -- Validate: item.width
      MintCrate.Assert.type(f,
        "data.table.width (entry: '"..item.name.."')",
        item.width,
        'number')
      
      -- Validate: item.height
      MintCrate.Assert.type(f,
        "data.table.height (entry: '"..item.name.."')",
        item.height,
        'number')
      
      -- Validate: item.radius
      MintCrate.Assert.type(f,
        "data.table.radius (entry: '"..item.name.."')",
        item.radius,
        'number')
      
      -- Validate: collider dimensions
      if (
        item.width  == 0 and
        item.height == 0 and
        item.radius == 0
      ) then
        MintCrate.Error(f,
          'Non-zero dimensions must be provided for this collider ' ..
          "(entry: '"..item.name.."').")
      elseif (
        (item.width  ~= 0 and item.radius ~= 0) or
        (item.height ~= 0 and item.radius ~= 0)
      ) then
        MintCrate.Error(f,
          'Width/height cannot be specified along with radius. ' ..
          "They are mutually exclusive (entry: '"..item.name.."').")
      elseif (
        item.width  ~= 0 and
        item.height == 0
      ) then
        MintCrate.Error(f,
          "Width was non-zero, but height was not " ..
          "(entry: '"..item.name.."').")
      elseif (
        item.width  == 0 and
        item.height ~= 0
      ) then
        MintCrate.Error(f,
          "Height was non-zero, but width was not " ..
          "(entry: '"..item.name.."').")
      end
      
      -- Figure out collider's shape
      local shape = self._COLLIDER_SHAPES.RECTANGLE
      if (item.radius ~= 0) then
        shape = self._COLLIDER_SHAPES.CIRCLE
      end
      
      -- Create and store collider data structure
      self._data.actives[activeName].collider = {
        width   = item.width,
        height  = item.height,
        radius  = item.radius,
        offsetX = item.offset[1],
        offsetY = item.offset[2],
        shape   = shape
      }
      
    -- Active's sprites/animations
    else
      -- Default params
      if (item.offset        == nil) then item.offset = {0, 0}         end
      if (item.actionPoints  == nil) then item.actionPoints = {{0, 0}} end
      if (item.frameCount    == nil) then item.frameCount = 1          end
      if (item.frameDuration == nil) then item.frameDuration = 20      end
      
      -- Split name to get Active's name and animation
      local nameParts = self.util.string.split(item.name, '_')
      
      -- Validate: item.name (for animation)
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (#nameParts == 2),
        'must be formatted as "active_animation"')
      
      -- Store active and animation names
      local activeName    = nameParts[1]
      local animationName = nameParts[2]
      
      -- Validate: item.name (for animation)
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (self._data.actives[activeName].animations[animationName] == nil),
        'was already specified')
      
      MintCrate.Assert.condition(f,
        'data.table.name',
        (activeName ~= ""),
        'cannot be blank on either side, expected format is "active_animation"')
      
      MintCrate.Assert.condition(f,
        'data.table.name',
        (animationName ~= ""),
        'cannot be blank on either side, expected format is "active_animation"')
      
      -- Validate: item.offset
      MintCrate.Assert.type(f,
        "data.table.offset (entry: '"..item.name.."')",
        item.offset,
        'table')
      
      MintCrate.Assert.condition(f,
        "data.table.offset (entry: '"..item.name.."')",
        (#item.offset == 2),
        'expects two numbers, representing the X and Y offsets of the sprite')
      
      -- Validate: item.actionPoints
      MintCrate.Assert.type(f,
        "data.table.actionPoints (entry: '"..item.name.."')",
        item.actionPoints,
        'table')
      
      for i = 1, #item.actionPoints do
        MintCrate.Assert.type(f,
          "data.table.actionPoints["..i.."] (entry: '"..item.name.."')",
          item.actionPoints[i],
          'table')
        
        MintCrate.Assert.condition(f,
          "data.table.actionPoints["..i.."] (entry: '"..item.name.."')",
          #item.actionPoints[i] == 2,
          'expects two numbers, representing ' ..
          'the X and Y offsets of the action point')
        
        MintCrate.Assert.type(f,
          "data.table.actionPoints["..i.."][1] (entry: '"..item.name.."')",
          item.actionPoints[i][1],
          'number')
        
        MintCrate.Assert.type(f,
          "data.table.actionPoints["..i.."][2] (entry: '"..item.name.."')",
          item.actionPoints[i][2],
          'number')
      end
      
      -- Validate: item.frameCount
      MintCrate.Assert.type(f,
        "data.table.frameCount (entry: '"..item.name.."')",
        item.frameCount,
        'number')
      
      MintCrate.Assert.condition(f,
        "data.table.frameCount (entry:'"..item.name.."')",
        (item.frameCount > 0),
        'must be a value greater than 0')
      
      MintCrate.Assert.condition(f,
        "data.table.frameCount (entry:'"..item.name.."')",
        (self.math.isIntegral(item.frameCount)),
        'must be an integer')
      
      -- Validate: item.frameDuration
      MintCrate.Assert.type(f,
        "data.table.frameDuration (entry: '"..item.name.."')",
        item.frameDuration,
        'number')
      
      MintCrate.Assert.condition(f,
        "data.table.frameDuration (entry:'"..item.name.."')",
        (item.frameDuration >= 0),
        'cannot be a negative value')
      
      MintCrate.Assert.condition(f,
        "data.table.frameDuration (entry:'"..item.name.."')",
        (self.math.isIntegral(item.frameDuration)),
        'must be an integer')
      
      -- Specify default animation (the first one the user defines)
      if (not self._data.actives[activeName].initialAnimationName) then
        self._data.actives[activeName].initialAnimationName = animationName
      end
      
      -- Store action points, filling with available action points...
      local actionPoints = {}
      for i = 1, #item.actionPoints do
        table.insert(actionPoints, item.actionPoints[i])
      end
      
      -- ... then propagating remaining slots with the last-provided set
      for i = #actionPoints + 1, item.frameCount do
        table.insert(actionPoints, item.actionPoints[#item.actionPoints])
      end
      
      -- Store animation data
      local image = self:_loadImage(self._resPaths.actives .. item.name)
      local animation = {
        image         = image,
        quads         = {},
        offsetX       = item.offset[1],
        offsetY       = item.offset[2],
        actionPoints  = actionPoints,
        frameCount    = item.frameCount,
        frameDuration = item.frameDuration,
        frameWidth    = image:getWidth() / item.frameCount,
        frameHeight   = image:getHeight()
      }
      
      
      -- Validate: animation.frameWidth
      if (not self.math.isIntegral(animation.frameWidth)) then
        MintCrate.Error(f,
          'Calculated frame width for animation "' .. item.name .. '" ' ..
          'was non-integral. Are all your frames the same width? ' ..
          'And, did you provide the correct number of frames?')
      end
      
      -- Generate quads
      for
        x = 0,
        animation.image:getWidth() - animation.frameWidth,
        animation.frameWidth
      do
        table.insert(animation.quads, love.graphics.newQuad(
          x, 0,
          animation.frameWidth, animation.frameHeight,
          animation.image:getDimensions()))
      end
      
      -- Store animation
      self._data.actives[activeName].animations[animationName] = animation
    end
  end
end

-- Defines the backdrop object entities that can be created during gameplay.
-- @param {table} data A table of backdrop object definitions (see docs).
function Core:defineBackdrops(data)
  local f = 'defineBackdrops'
  MintCrate.Assert.self(f, self)
  
  -- Validate: data
  MintCrate.Assert.type(f, 'data', data, 'table' )
  
  for _, item in ipairs(data) do
    -- Validate: item
    MintCrate.Assert.type(f, 'data.table', item, 'table')
    
    -- Default params
    if (item.mosaic == nil) then item.mosaic = false end
    
    -- Validate: item.name
    MintCrate.Assert.type(f,
      'data.table.name',
      item.name,
      'string')
      
    MintCrate.Assert.condition(f,
      'data.table.name',
      (item.name ~= ""),
      'cannot be blank')
    
    MintCrate.Assert.condition(f,
      "data.table.name (entry: '"..item.name.."')",
      (self._data.backdrops[item.name] == nil),
      'was already specified')
    
    -- Validate: item.mosaic
    MintCrate.Assert.type(f,
      "data.table.mosaic (entry: '"..item.name.."')",
      item.mosaic,
      'boolean')
    
    -- Create image
    local image = self:_loadImage(self._resPaths.backdrops .. item.name)
    
    -- Enable image wrapping if mosaic is enabled
    if (item.mosaic) then
      image:setWrap("repeat", "repeat")
    end
    
    -- Store backdrop data
    self._data.backdrops[item.name] = {
      image  = image,
      mosaic = item.mosaic
    }
  end
end

-- Defines the fonts that can be used to create Text objects.
-- @param {table} data A table of bitmap font definitions (see docs).
function Core:defineFonts(data)
  local f = 'defineFonts'
  MintCrate.Assert.self(f, self)
  
  -- Validate: data
  MintCrate.Assert.type(f, 'data', data, 'table')
  
  for _, item in ipairs(data) do
    -- Validate: item
    MintCrate.Assert.type(f, 'data.table', item, 'table')
    
    -- Validate: item.name
    MintCrate.Assert.type(f,
      'data.table.name',
      item.name,
      'string')
    
    MintCrate.Assert.condition(f,
      'data.table.name',
      (item.name ~= ""),
      'cannot be blank')
    
    MintCrate.Assert.condition(f,
      "data.table.name (entry: '"..item.name.."')",
      (self._data.fonts[item.name] == nil),
      'was already specified')
    
    -- Store font
    self._data.fonts[item.name] = self:_loadFont(item.name)
  end
end

-- Loads an bitmap font image into a font data structure.
-- @param {string} fontName The name of the font image (without extension).
function Core:_loadFont(fontName)
  -- Construct path to font
  local path = self._resPaths.fonts
  
  -- Figure out if font is a MintCrate system font
  local isSystemResource = false
  if (string.find(fontName, "system_")) then
    path = self._sysImgPath
    isSystemResource = true
  end
  
  -- Construct font data structure
  local font = {
    image = self:_loadImage(path..fontName, isSystemResource),
    quads = {}
  }
  
  -- Calculate font's individual character width and height
  font.charWidth = font.image:getWidth() / 32
  font.charHeight = font.image:getHeight() / 3
  
  -- Validate: font character width
  if (not self.math.isIntegral(font.charWidth)) then
    MintCrate.Error(f, 'Calculated character width for font "' .. fontName ..
      '" was non-integral. Are all your characters the same width? ' ..
      'And, does it have the correct number of columns (32)?')
  end
  
  -- Validate: font character height
  if (not self.math.isIntegral(font.charHeight)) then
    MintCrate.Error(f, 'Calculated character height for font "' .. fontName ..
      '" was non-integral. Are all your characters the same height? ' ..
      'And, does it have the correct number of rows (3)?')
  end
  
  -- Generate quads based on standard ASCII mapping
  local asciiMap = {
    {
      ' ', '!', '"', '#', '$', '%', '&', "'", '(', ')', '*',
      '+', ',', '-', '.', '/', '0', '1', '2', '3', '4', '5',
      '6', '7', '8', '9', ':', ';', '<', '=', '>', '?'
    }, {
      '@', 'A', 'B', 'C', 'D', 'E', 'F',  'G', 'H', 'I', 'J',
      'K', 'L', 'M', 'N', 'O', 'P', 'Q',  'R', 'S', 'T', 'U',
      'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^', '_'
    }, {
      '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
      'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
      'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~', 'NOOP'
    }
  }
  
  for row = 1, #asciiMap do
    for col = 1, #asciiMap[row] do
      local character = asciiMap[row][col]
      font.quads[character] = love.graphics.newQuad(
        (col - 1) * font.charWidth, (row - 1) * font.charHeight,
        font.charWidth, font.charHeight,
        font.image:getDimensions())
    end
  end
  
  -- Return font
  return font
end

-- Defines the sounds that can be played during gameplay.
-- @param {table} data A table of sound resource definitions (see docs).
function Core:defineSounds(data)
  local f = 'defineSounds'
  MintCrate.Assert.self(f, self)
  
  -- Validate: data
  MintCrate.Assert.type(f, 'data', data, 'table')
  
  for _, item in ipairs(data) do
    -- Validate: item
    MintCrate.Assert.type(f, 'data.table', item, 'table')
    
    -- Validate: item.name
    MintCrate.Assert.type(f,
      'data.table.name',
      item.name,
      'string')
    
    MintCrate.Assert.condition(f,
      'data.table.name',
      (item.name ~= ""),
      'cannot be blank')
    
    MintCrate.Assert.condition(f,
      "data.table.name (entry: '"..item.name.."')",
      (self._data.sounds[item.name] == nil),
      'was already specified')
    
    -- Construct path to file
    local path = self._resPaths.sounds .. item.name
    
    -- Figure out file extension
    local fileFound = false
    for _, ext in ipairs({'wav', 'ogg'}) do
      if (love.filesystem.getInfo(path..'.'..ext)) then
        path = path..'.'..ext
        fileFound = true
        break
      end
    end
    
    -- Validate: file presence
    if (not fileFound) then
      MintCrate.Error(nil,
        'Could not locate audio file "' .. path .. '". ' ..
        'There does not appear to be a valid WAV or OGG file at this path.')
    end
    
    -- Store sound
    self._data.sounds[item.name] = {
      source = love.audio.newSource(path, "static"),
      volume = 1
    }
  end
end

-- Defines the music that can be played during gameplay.
-- @param {table} data A table of music resource definitions (see docs).
function Core:defineMusic(data)
  local f = 'defineMusic'
  MintCrate.Assert.self(f, self)
  
  -- Validate: data
  MintCrate.Assert.type(f, 'data', data, 'table')
  
  for _, item in ipairs(data) do
    -- Validate: item
    MintCrate.Assert.type(f, 'data.table', item, 'table')
    
    -- Validate: item.name
    MintCrate.Assert.type(f,
      'data.table.name',
      item.name,
      'string')
    
    MintCrate.Assert.condition(f,
      'data.table.name',
      (item.name ~= ""),
      'cannot be blank')
    
    MintCrate.Assert.condition(f,
      "data.table.name (entry: '"..item.name.."')",
      (self._data.music[item.name] == nil),
      'was already specified')
    
    -- Construct path to file
    local path = self._resPaths.music .. item.name
    
    -- Figure out file extension
    local fileFound = false
    for _, ext in ipairs({'ogg', 'it', 'xm', 'mod', 's3m'}) do
      if (love.filesystem.getInfo(path..'.'..ext)) then
        path = path..'.'..ext
        fileFound = true
        break
      end
    end
    
    -- Validate: file presence
    if (not fileFound) then
      MintCrate.Error(nil,
        'Could not locate audio file "' .. path .. '". ' ..
        'There does not appear to be a valid OGG, IT, XM, MOD, or S3M ' ..
        'file at this path.')
    end
    
    -- Create audio source
    local source = love.audio.newSource(path, "stream")
    
    -- Default params
    if (item.loop == nil) then
      item.loop = false
    end
    
    if (item.loopStart == nil) then
      item.loopStart = 0
    end
    
    if (item.loopEnd == nil) then
      item.loopEnd = source:getDuration('seconds')
    end
    
    -- Set looping property of audio source
    source:setLooping(item.loop)
    
    -- Default the "currently-playing" track to the first track loaded
    if (self._currentMusic == nil) then
      self._currentMusic = item.name
    end
    
    -- Store music
    self._data.music[item.name] = {
      source    = source,
      loop      = item.loop,
      loopStart = item.loopStart,
      loopEnd   = item.loopEnd,
      volume    = 1
    }
  end
end

-- Defines the tilemaps that can be set during gameplay.
-- @param {table} data A table of tilemap definitions (see docs).
function Core:defineTilemaps(data)
  local f = 'defineTilemaps'
  MintCrate.Assert.self(f, self)
  
  -- Validate: data
  MintCrate.Assert.type(f, 'data', data, 'table')
  
  for _, item in ipairs(data) do
    -- Validate: item
    MintCrate.Assert.type(f, 'data.table', item, 'table')
    
    -- Validate: item.name
    MintCrate.Assert.type(f,
      'data.table.name',
      item.name,
      'string')
    
    -- Tilemap's base name (refers to the image file)
    if (not string.find(item.name, '_')) then
      -- Validate: item.name (for base name)
      MintCrate.Assert.condition(f,
        'data.table.name',
        (item.name ~= ""),
        'cannot be blank')
      
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (self._data.tilemaps[item.name] == nil),
        'was already specified')
      
      -- Validate: item.tileWidth
      MintCrate.Assert.type(f,
        "data.table.tileWidth (entry: '"..item.name.."')",
        item.tileWidth,
        'number')
      
      -- Validate: item.tileHeight
      MintCrate.Assert.type(f,
        "data.table.tileHeight (entry: '"..item.name.."')",
        item.tileHeight,
        'number')
      
      -- Create image
      local image = self:_loadImage(self._resPaths.tilemaps .. item.name)
      
      -- Create clipping rects (quads) for drawing tiles
      local quads = {}
      
      for y = 0, image:getHeight(), item.tileHeight do
        for x = 0, image:getWidth(), item.tileWidth do
          if (x < image:getWidth() and y < image:getHeight()) then
            table.insert(quads, love.graphics.newQuad(
              x, y,
              item.tileWidth, item.tileHeight,
              image:getDimensions()))
          end
        end
      end
      
      -- Store tilemap
      self._data.tilemaps[item.name] = {
        image      = image,
        quads      = quads,
        tileWidth  = item.tileWidth,
        tileHeight = item.tileHeight,
        layouts    = {}
      }
    
    -- Tilemap's actual map data files
    else
      -- Split name to get Tilemap's name and layout
      local nameParts = self.util.string.split(item.name, '_')
      
      -- Validate: item.name (for map layout data)
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (#nameParts == 2),
        'must be formatted as "tilemap_layout"')
      
      -- Store tilemap and tilemap layout names
      local tilemapName = nameParts[1]
      local layoutName  = nameParts[2]
      
      MintCrate.Assert.condition(f,
        'data.table.name',
        (tilemapName ~= ""),
        'cannot be blank on either side, expected format is "tilemap_layout"')
      
      MintCrate.Assert.condition(f,
        'data.table.name',
        (layoutName ~= ""),
        'cannot be blank on either side, expected format is "tilemap_layout"')
      
      MintCrate.Assert.condition(f,
        "data.table.name (entry: '"..item.name.."')",
        (self._data.tilemaps[tilemapName].layouts[layoutName] == nil),
        'was already specified')
      
      -- Construct path to file
      local path = self._resPaths.tilemaps .. item.name .. '.lua'
      
      -- Validate: file presence
      if (not love.filesystem.getInfo(path)) then
        MintCrate.Error(nil,
          'Could not locate tilemap layout file "' .. path .. '". ' ..
          'There does not appear to be a valid LUA file at this path.')
      end
      
      -- Load tilemap layout data
      path = string.gsub(self._resPaths.tilemaps, "/", ".") .. item.name
      local tilemapData = require(path)
      
      -- Store tilemap layout
      self._data.tilemaps[tilemapName].layouts[layoutName] = {
        tiles = tilemapData.tiles
      }
      
      -- Generate and store collision map for tilemap
      self:_generateCollisionMap(tilemapName, layoutName, tilemapData.behaviors)
    end
  end
end

-- Algorithmically generates a relatively-efficient collision map for a tilemap.
-- @param {string} tilemapName The tilemap graphic name.
-- @param {string} layoutName The tilemap layout name.
-- @param {table} behaviorMap The associated behavior map for the tilemap.
function Core:_generateCollisionMap(tilemapName, layoutName, behaviorMap)
  --[[
   * Generate collision mask map (red paint)
   * Search through collision data, looking for find non-blank tiles.
   * Basically, we iterate through every tile in the collision map.
   * When we find a non-zero tile, we define a quad by:
   * - Scanning right to find the ending column
   * - Scanning down to find the ending row
   * When we have our quad, we zero it out of the collision map so that
   * overlapping colliders in the subsequent scanning operation won't be
   * created. We then create a collision mask out of it.
  --]]
  
  -- Get layout data
  local layout = self._data.tilemaps[tilemapName].layouts[layoutName]
  
  -- Generate simple on/off behavior map if none was provided
  local bMap = behaviorMap
  
  if (not bMap) then
    bMap = {}
    for row = 1, #layout.tiles do
      bMap[row] = {}
      for col = 1, #layout.tiles[row] do
        local tileNumber = layout.tiles[row][col]
        if (tileNumber == 0) then
          bMap[row][col] = 0
        else
          bMap[row][col] = 1
        end
      end
    end
  end
  
  -- Generate collision map
  layout.collisionMasks = {}
  
  for row = 1, #bMap do
    for col = 1, #bMap[row] do
      local tileType = bMap[row][col]
      
      -- Skip if empty tile
      if (tileType == 0) then
        goto ColumnComplete
      end
      
      -- If tile found, perform a two-step scan for a full quad
      local start = {row = row, col = col}
      local stop  = {row = row, col = col}
      
      -- Find ending column
      for scanCol = start.col+1, #bMap[row] do
        local scanTileType = bMap[row][scanCol]
        if (scanTileType == 0 or scanTileType ~= tileType) then
          break
        else
          stop.col = scanCol
        end
      end
      
      -- Find ending row
      local done = false
      for scanRow = start.row+1, #bMap do
        for scanCol = start.col, stop.col do
          local scanTileType = bMap[scanRow][scanCol]
          done = (scanTileType == 0 or scanTileType ~= tileType)
          if (done) then break end
        end
        
        if (done) then break end
        
        stop.row = scanRow
      end
      
      -- Remove from collision data map
      for remRow = start.row, stop.row do
        for remCol = start.col, stop.col do
          bMap[remRow][remCol] = 0
        end
      end
      
      -- Store as collision mask
      if (not layout.collisionMasks[tileType]) then
        layout.collisionMasks[tileType] = {}
      end
      
      table.insert(layout.collisionMasks[tileType], {
        s = self._COLLIDER_SHAPES.RECTANGLE,
        x = start.col - 1,
        y = start.row - 1,
        w = stop.col - start.col + 1,
        h = stop.row - start.row + 1,
        -- behavior = tileType, -- TODO: Remove me?
        collision = false
      })
      
      ::ColumnComplete::
    end
  end
  
  -- Convert collision map indices to proper coordinates/dimensions
  for _, maskCollection in pairs(layout.collisionMasks) do
    for __, mask in ipairs(maskCollection) do
      mask.x = mask.x * self._data.tilemaps[tilemapName].tileWidth
      mask.y = mask.y * self._data.tilemaps[tilemapName].tileHeight
      mask.w = mask.w * self._data.tilemaps[tilemapName].tileWidth
      mask.h = mask.h * self._data.tilemaps[tilemapName].tileHeight
    end
  end
end

-- Retrieves the collision masks for the currently-loaded tilemap.
-- @returns {table} Tilemap collision masks.
function Core:_getTilemapCollisionMasks()
  return self._data.tilemaps[self._tilemapName]
    .layouts[self._layoutName].collisionMasks
end

-- -----------------------------------------------------------------------------
-- Methods for room management
-- -----------------------------------------------------------------------------

-- Changes the currently-active scene/level of the game (game state).
-- @param {Room} room The room to load.
-- @param {table} options Optional room-changing properties
-- @param {boolean} options.fadeMusic Fades the music with the visual fade-out.
-- @param {boolean} options.persistAudio Prevents the audio from stopping.
function Core:changeRoom(room, options)
  local f = 'changeRoom'
  MintCrate.Assert.self(f, self)
  
  -- Validate: room
  MintCrate.Assert.type(f, 'room', room, 'Room')
  
  -- Default params
  if (options              == nil) then options = {}                 end
  if (options.fadeMusic    == nil) then options.fadeMusic = false    end
  if (options.persistAudio == nil) then options.persistAudio = false end
  
  -- Validate: options
  MintCrate.Assert.type(f,
    'options',
    options,
    'table')
  
  -- Validate: options.fadeMusic
  MintCrate.Assert.type(f,
    'options.fadeMusic',
    options.fadeMusic,
    'boolean')
  
  -- Validate: options.persistAudio
  MintCrate.Assert.type(f,
    'options.persistAudio',
    options.persistAudio,
    'boolean')
  
  if (options.fadeMusic and options.persistAudio) then
    MintCrate.Error(f,
      'Arguments "option.fadeMusic" and "options.persistAudio" cannot be ' ..
      'enabled simultaneously.')
  end
  
  -- Only change room if we're not currently transitioning to another one.
  if (not self._isChangingRooms) then
    -- Indicate we're now changing rooms.
    self._isChangingRooms = true
    
    -- Handle fade-out before changing room (if configured).
    if (self._currentRoom and self._currentRoom._fadeConf.fadeOut.enabled) then
      -- Trigger the fade-out effect, then change room when it's done.
      self:_triggerRoomFade('fadeOut', function()
          self:_changeRoom(room, options.persistAudio)
        end, options.fadeMusic)
    -- Otherwise, simply change room.
    else
      self:_changeRoom(room, options.persistAudio)
    end
  end
end

-- Triggers a fade-in/out effect for the Room, then fires a specified function.
-- @param {string} fadeType The type of fade ("fadeIn", "fadeOut").
-- @param {function} finishedCallback The function to fire after fading is done.
-- @param {boolean} fadeMusic Fades the music with the visual fade-out.
function Core:_triggerRoomFade(fadeType, finishedCallback, fadeMusic)
  -- Cancel any current fades
  if (self._currentRoom._fadeEffectFunc) then
    self:clearFunction(self._currentRoom._fadeEffectFunc)
  end
  if (self._currentRoom._fadeDoneFunc) then
    self:clearFunction(self._currentRoom._fadeDoneFunc)
  end
  
  -- Set the room's current fade type (used for rendering the fade overlay)
  self._currentRoom._currentFade = fadeType
  
  -- Get the configuration for this fade
  local fadeConf = self._currentRoom._fadeConf[fadeType]
  
  -- Set up function to handle fade-in/out
  local fadeEffectFunc = function()
    self._currentRoom._fadeLevel =
      self._currentRoom._fadeLevel + fadeConf.fadeValue
  end
  
  -- Run it every frame, and store it in case we need to cancel it early
  self:repeatFunction(fadeEffectFunc, 1)
  self._currentRoom._fadeEffectFunc = fadeEffectFunc
  
  -- Set up delayed function to clear fade-effect function when fade is done
  local fadeDoneFunc = function()
    -- Clear fade-effect function
    self:clearFunction(fadeEffectFunc)
    
    -- Ensure fade overlay is either completely hidden or completely shown
    if (fadeType == "fadeIn") then
      self._currentRoom._fadeLevel = 100
    else
      self._currentRoom._fadeLevel = 0
    end
  end
  
  -- Run it when fade's done, and store it in case we need to cancel it early
  self:delayFunction(fadeDoneFunc, fadeConf.fadeFrames + fadeConf.pauseFrames)
  self._currentRoom._fadeDoneFunc = fadeDoneFunc
  
  -- Calculate how long until we need to wait until we execute the callback
  -- This value changes if we're in the midst of a fade-in
  local totalDuration = fadeConf.fadeFrames
  totalDuration       = totalDuration * (self._currentRoom._fadeLevel / 100)
  totalDuration       = math.max(totalDuration, 0)
  
  -- Fade music (if specified)
  if (fadeMusic) then
    self:stopMusic(totalDuration)
  end
  
  -- Set delayed function to execute when fade is finished
  -- This is currently only for fade-outs: leaving the room or quitting the game
  if (finishedCallback) then
    -- Include the pause frames so we don't run the function early
    totalDuration = totalDuration + fadeConf.pauseFrames
    
    -- Execute callback
    self:delayFunction(finishedCallback, totalDuration)
  end
end

-- Internal function which actually performs the room change.
-- @param {Room} room The room to load.
-- @param {boolean} persistAudio Prevents the audio from stopping.
function Core:_changeRoom(room, persistAudio)
  -- Wipe current entity instances
  for key, _ in pairs(self._instances) do
    self._instances[key] = {}
  end
  
  -- Wipe draw-order tables
  for key, _ in pairs(self._drawOrders) do
    self._drawOrders[key] = {}
  end
  
  -- Stop all audio
  if (not persistAudio) then
    self:stopAllSounds()
    self:stopMusic()
  end
  
  -- Reset camera
  self._camera        = {x = 0, y = 0}
  self._cameraBounds  = {x1 = 0, x2 = 0, y1 = 0, y2 = 0}
  self._cameraIsBound = false
  
  -- Remove tilemap from scene
  self._tilemapFullName = nil
  self._tilemapName     = nil
  self._layoutName      = nil
  
  -- Mark delayed/repeated functions to be cleared out
  for _, item in ipairs(self._queuedFunctions) do
    item.cancelled = true
  end
  
  -- Create new room
  self._currentRoom = room:new()
  
  -- Trigger fade in for fresh room (if configured)
  if (self._currentRoom._fadeConf.fadeIn.enabled) then
    self:_triggerRoomFade('fadeIn')
  end
  
  -- Validation: room width
  if (self._currentRoom._roomWidth < self._baseWidth) then
    MintCrate.Error(nil,
      "Width of room '" .. self._currentRoom:getRoomName() .. " " ..
      "is smaller than the game's base width resolution. This is not allowed.")
  end
  
  -- Validation: room height
  if (self._currentRoom._roomHeight < self._baseHeight) then
    MintCrate.Error(nil,
      "Height of room '" .. self._currentRoom:getRoomName() .. " " ..
      "is smaller than the game's base height resolution. This is not allowed.")
  end
  
  -- Indicate we're done changing rooms
  self._isChangingRooms = false
end

-- -----------------------------------------------------------------------------
-- Methods for queued functions
-- -----------------------------------------------------------------------------

-- Fires off a function after n frames.
-- @param {function} callback The function to queue.
-- @param {number} numFrames How many frames should pass before firing.
function Core:delayFunction(callback, numFrames)
  local f = 'delayFunction'
  MintCrate.Assert.self(f, self)
  
  -- Validate: callback
  MintCrate.Assert.type(f, 'callback', callback, 'function')
  
  -- Validate: numFrames
  MintCrate.Assert.type(f, 'numFrames', numFrames, 'number')
  
  MintCrate.Assert.condition(f,
    'numFrames',
    (numFrames >= 0),
    'cannot be a negative value')
  
  -- Store function to be delay-fired by framework
  table.insert(self._queuedFunctions, {
    callback        = callback,
    remainingFrames = numFrames
  })
end

-- Repeats a function every n frames.
-- @param {function} callback The function to queue.
-- @param {number} numFrames How many frames should pass before firing.
-- @param {boolean} fireImmediately Whether the function should initially fire.
function Core:repeatFunction(callback, numFrames, fireImmediately)
  local f = 'repeatFunction'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (fireImmediately == nil) then fireImmediately = false end
  
  -- Validate: callback
  MintCrate.Assert.type(f, 'callback', callback, 'function')
  
  -- Validate: numFrames
  MintCrate.Assert.type(f, 'numFrames', numFrames, 'number')
  
  MintCrate.Assert.condition(f,
    'numFrames',
    (numFrames >= 0),
    'cannot be a negative value')
  
  -- Validate: fireImmediately
  MintCrate.Assert.type(f, 'fireImmediately', fireImmediately, 'boolean')
  
  -- Do an initial run of the function if specified
  if (fireImmediately) then
    callback()
  end
  
  -- Store function to be repeat-fired by framework
  table.insert(self._queuedFunctions, {
    callback        = callback,
    remainingFrames = numFrames,
    repeatValue     = numFrames
  })
end

-- Clears a queued function.
-- @param {function} callback The queued function to cancel/clear.
function Core:clearFunction(callback)
  local f = 'clearFunction'
  MintCrate.Assert.self(f, self)
  
  -- Validate: callback
  MintCrate.Assert.type(f, 'callback', callback, 'function')
  
  -- Find function and mark it to be cleared out
  for _, item in ipairs(self._queuedFunctions) do
    if (item.callback == callback) then
      item.cancelled = true
    end
  end
end

-- -----------------------------------------------------------------------------
-- Methods for creating game objects
-- -----------------------------------------------------------------------------

-- Creates an Active object to be manipulated by the currently-active room.
-- @param {string} name The name of the Active (from defineActives()).
-- @param {number} x The starting X position of the Active.
-- @param {number} y The ending X position of the Active.
-- @returns {Active} A new instance of the Active class.
function Core:addActive(name, x, y)
  local f = 'addActive'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (x == nil) then x = 0 end
  if (y == nil) then y = 0 end
  
  -- Validate: name
  MintCrate.Assert.type(f, 'name', name, 'string')
  MintCrate.Assert.condition(f,
    'name',
    (self._data.actives[name] ~= nil),
    'does not refer to a valid Active object')
  
  -- Validate: x
  MintCrate.Assert.type(f, 'x', x, 'number')
  
  -- Validate: y
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  -- Retrieve active's collider data (if available)
  local collider = self._data.actives[name].collider or {}
  
  -- Retrieve list of animations for the active (if available)
  local animationList = {}
  for animName, _ in pairs(self._data.actives[name].animations) do
    table.insert(animationList, animName)
  end
  
  -- Retrieve initial animation to play upon creation (if available)
  local initialAnimationName = self._data.actives[name].initialAnimationName
  local animation
  if (initialAnimationName) then
    animation = self._data.actives[name].animations[initialAnimationName]
  end
  
  -- Create new active
  local active = MintCrate.Active:new(
    self._instances.actives,
    self._drawOrders.main,
    name,
    x, y,
    collider.shape or self._COLLIDER_SHAPES.NONE,
    collider.offsetX or 0, collider.offsetY or 0,
    collider.width or 0, collider.height or 0,
    collider.radius or 0,
    animationList,
    initialAnimationName,
    animation
  )
  
  -- Store entry for active in instance and draw-order lists
  table.insert(self._instances.actives, active)
  table.insert(self._drawOrders.main, active)
  
  -- Return active
  return active
end

-- Creates a Backdrop object to be manipulated by the currently-active room.
-- @param {string} name The name of the Backdrop (from defineBackdrops).
-- @param {number} x The starting X position of the backdrop.
-- @param {number} y The ending X position of the backdrop.
-- @param {table} options Optional Backdrop properties.
-- @param {number} options.width The width of the backdrop.
-- @param {number} options.height The height of the backdrop.
-- @returns {Backdrop} A new instance of the Backdrop class.
function Core:addBackdrop(name, x, y, options)
  local f = 'addBackdrop'
  MintCrate.Assert.self(f, self)
  
  -- Validate: name
  MintCrate.Assert.type(f, 'name', name, 'string')
  MintCrate.Assert.condition(f,
    'name',
    (self._data.backdrops[name] ~= nil),
    'does not refer to a valid Backdrop object')
  
  -- Load background image
  local image = self._data.backdrops[name].image
  
  -- Default params
  if (x              == nil) then x = 0                              end
  if (y              == nil) then y = 0                              end
  if (options        == nil) then options = {}                       end
  if (options.width  == nil) then options.width = image:getWidth()   end
  if (options.height == nil) then options.height = image:getHeight() end
  
  -- Validate: x
  MintCrate.Assert.type(f, 'x', x, 'number')
  
  -- Validate: y
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  -- Validate: options
  MintCrate.Assert.type(f, 'options', options, 'table')
  
  -- Validate: options.width
  MintCrate.Assert.type(f, 'options.width', options.width, 'number')
  
  MintCrate.Assert.condition(f,
    'options.width',
    (options.width > 0),
    'must be a value greater than 0')
  
  -- Validate: options.height
  MintCrate.Assert.type(f, 'options.height', options.height, 'number')
  
  MintCrate.Assert.condition(f,
    'options.height',
    (options.height > 0),
    'must be a value greater than 0')
  
  -- Prepare some data for tiling/scaling processing
  local textureWidth, textureHeight = image:getDimensions()
  local width                       = options.width
  local height                      = options.height
  local scaleX                      = 1
  local scaleY                      = 1
  local quad
  
  -- If image is set to tile, then create quad to handle tiling
  if (self._data.backdrops[name].mosaic) then
    quad = love.graphics.newQuad(0, 0, width, height, image:getDimensions())
  -- Otherwise, calculate scaling values for stretching the image
  else
    scaleX = width / textureWidth
    scaleY = height / textureHeight
  end
  
  -- Create new backdrop
  local backdrop = MintCrate.Backdrop:new(
    self._instances.backdrops,
    self._drawOrders.backdrops,
    name,
    x, y,
    width, height,
    quad,
    scaleX, scaleY,
    textureWidth, textureHeight
  )
  
  -- Store entry for backdrop in instance and draw-order lists
  table.insert(self._instances.backdrops, backdrop)
  table.insert(self._drawOrders.backdrops, backdrop)
  
  -- Return backdrop
  return backdrop
end

-- Creates a Text to be manipulated by the currently-active room.
-- @param {string} name The name of the Font (from defineFonts()).
-- @param {number} x The starting X position of the Text.
-- @param {number} y The starting Y position of the Text.
-- @param {string} startingTextContent What text to show upon creation.
-- @param {table} options Optional Text properties.
-- @param {number} options.maxCharsPerLine Characters written before wrapping.
-- @param {number} options.lineSpacing Space there is between lines, in pixels.
-- @param {boolean} options.wordWrap Whether entire words should wrap or break.
-- @param {string} options.alignment Either "left", "right", or "center".
-- @returns {Text} A new instance of the Text class.
function Core:addText(name, x, y, startingTextContent, options)
  local f = 'addText'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (x                       == nil) then x = 0                          end
  if (y                       == nil) then y = 0                          end
  if (startingTextContent     == nil) then startingTextContent = ""       end
  if (options                 == nil) then options = {}                   end
  if (options.maxCharsPerLine == nil) then options.maxCharsPerLine = 9999 end
  if (options.lineSpacing     == nil) then options.lineSpacing = 0        end
  if (options.wordWrap        == nil) then options.wordWrap = false       end
  if (options.alignment       == nil) then options.alignment = "left"     end
  
  -- Validate: name
  MintCrate.Assert.type(f, 'name', name, 'string')
  MintCrate.Assert.condition(f,
    'name',
    (self._data.fonts[name] ~= nil),
    'does not refer to a valid Font object')
  
  -- Validate: x
  MintCrate.Assert.type(f, 'x', x, 'number')
  
  -- Validate: y
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  -- Validate: startingTextContent
  MintCrate.Assert.type(f, 'startingTextContent', startingTextContent, 'string')
  
  -- Validate: options
  MintCrate.Assert.type(f, 'options', options, 'table')
  
  -- Validate: options.maxCharsPerLine
  MintCrate.Assert.type(f,
    'options.maxCharsPerLine',
    options.maxCharsPerLine,
    'number')
  
  MintCrate.Assert.condition(f,
    'options.maxCharsPerLine',
    (options.maxCharsPerLine > 0),
    'must be a value greater than zero')
  
  -- Validate: options.lineSpacing
  MintCrate.Assert.type(f, 'options.lineSpacing', options.lineSpacing, 'number')
  
  MintCrate.Assert.condition(f,
    'options.lineSpacing',
    (options.lineSpacing >= 0),
    'cannot be a negative value')
  
  -- Validate: options.wordWrap
  MintCrate.Assert.type(f, 'options.wordWrap', options.wordWrap, 'boolean')
  
  -- Validate: options.alignment
  MintCrate.Assert.type(f, 'options.alignment', options.alignment, 'string')
  
  MintCrate.Assert.condition(f,
    'numFrames',
    (
      options.alignment == 'left'
      or options.alignment == 'right'
      or options.alignment == 'center'
    ),
    'must be either "left", "right", or "center"')
  
  -- Retrieve font's glyph width/height
  local font = self._data.fonts[name]
  local glyphWidth = font.charWidth
  local glyphHeight = font.charHeight
  
  -- Create new text
  local text = MintCrate.Text:new(
    self._instances.text,
    self._drawOrders.main,
    name,
    x, y,
    glyphWidth, glyphHeight,
    options.maxCharsPerLine,
    options.lineSpacing,
    options.wordWrap,
    options.alignment
  )
  
  -- Set initial text content
  text:setTextContent(startingTextContent)
  
  -- Store entry for text in instance and draw-order lists
  table.insert(self._instances.text, text)
  table.insert(self._drawOrders.main, text)
  
  -- Return text
  return text
end

-- -----------------------------------------------------------------------------
-- Methods for camera management
-- -----------------------------------------------------------------------------

-- Returns the current X position of the camera.
-- @returns {number} X position of camera.
function Core:getCameraX()
  local f = 'getCameraX'
  MintCrate.Assert.self(f, self)
  
  return self._camera.x
end

-- Returns the current Y position of the camera.
-- @returns {number} Y position of camera.
function Core:getCameraY()
  local f = 'getCameraY'
  MintCrate.Assert.self(f, self)
  
  return self._camera.y
end

-- Sets the current x position of the camera.
-- @param {number} x New x coordinate to place the camera at.
function Core:setCameraX(x)
  local f = 'setCameraX'
  MintCrate.Assert.self(f, self)
  
  -- Validate: x
  MintCrate.Assert.type(f, 'x', x, 'number')
  
  -- Figure out camera bounds
  local x1
  local x2
  
  if (not self._cameraIsBound) then
    x1 = 0
    x2 = self._currentRoom._roomWidth
  else
    x1 = self._bounds.x1
    x2 = self._bounds.x2
  end
  
  -- Bind camera
  boundX = x
  boundX = math.max(boundX, x1)
  boundX = math.min(boundX, x2 - self._baseWidth)
  
  -- Reposition camera
  self._camera.x = boundX
end

-- Sets the current y position of the camera.
-- @param {number} y New y coordinate to place the camera at.
function Core:setCameraY(y)
  local f = 'setCameraY'
  MintCrate.Assert.self(f, self)
  
  -- Validate: y
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  -- Figure out camera bounds
  local y1
  local y2
  
  if (not self._cameraIsBound) then
    y1 = 0
    y2 = self._currentRoom._roomHeight
  else
    y1 = self._bounds.y1
    y2 = self._bounds.y2
  end
  
  -- Bind camera
  boundY = y
  boundY = math.max(boundY, y1)
  boundY = math.min(boundY, y2 - self._baseHeight)
  
  -- Reposition camera
  self._camera.y = boundY
end

-- Centers the camera on a specific point.
-- @param {number} x X coordinate to center the camera at.
function Core:centerCameraX(x)
  local f = 'centerCameraX'
  MintCrate.Assert.self(f, self)
  
  -- Validate: x
  MintCrate.Assert.type(f, 'x', x, 'number')
  
  -- Center camera on point
  self:setCameraX(x - (self._baseWidth / 2))
end

-- Centers the camera on a specific point.
-- @param {number} y Y coordinate to center the camera at.
function Core:centerCameraY(y)
  local f = 'centerCameraY'
  MintCrate.Assert.self(f, self)
  
  -- Validate: y
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  -- Center camera on point
  self:setCameraY(y - (self._baseHeight / 2))
end

-- Moves the camera along the x axis by a specified number of pixels.
-- @param {number} pixels The number of pixels to move the camera by.
function Core:moveCameraX(pixels)
  local f = 'moveCameraX'
  MintCrate.Assert.self(f, self)
  
  -- Validate: pixels
  MintCrate.Assert.type(f, 'pixels', pixels, 'number')
  
  -- Move camera
  self:setCameraX(self._camera.x + pixels)
end

-- Moves the camera along the y axis by a specified number of pixels.
-- @param {number} pixels The number of pixels to move the camera by.
function Core:moveCameraX(pixels)
  local f = 'moveCameraY'
  MintCrate.Assert.self(f, self)
  
  -- Validate: pixels
  MintCrate.Assert.type(f, 'pixels', pixels, 'number')
  
  -- Move camera
  self:setCameraY(self._camera.y + pixels)
end

-- Binds the camera to a specified rectangular region.
-- @param {number} x1 Region top-left X.
-- @param {number} y1 Region top-left Y.
-- @param {number} x2 Region bottom-right X.
-- @param {number} y2 Region bottom-right Y.
function Core:bindCamera(x1, y1, x2, y2)
  local f = 'bindCamera'
  MintCrate.Assert.self(f, self)
  
  -- Validate: x1
  MintCrate.Assert.type(f, 'x1', x1, 'number')
  
  -- Validate: x2
  MintCrate.Assert.type(f, 'x2', x2, 'number')
  
  -- Validate: y1
  MintCrate.Assert.type(f, 'y1', y1, 'number')
  
  -- Validate: y2
  MintCrate.Assert.type(f, 'y2', y2, 'number')
  
  -- Set bounds and indicate that the camera is currently bound
  self._bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
  self._cameraIsBound = true
end

-- Unbinds the camera if previously bound.
function Core:unbindCamera()
  -- Unset bounds and indicate that the camera is currently unbound
  self._cameraBounds = {x1 = 0, x2 = 0, y1 = 0, y2 = 0}
  self._cameraIsBound = false
end

-- -----------------------------------------------------------------------------
-- Methods for managing Tilemaps
-- -----------------------------------------------------------------------------

-- Sets the tilemap graphic/layout for the room.
-- @param {string} tilemapLayoutName The full name of the tilemap.
function Core:setTilemap(tilemapLayoutName)
  local f = 'setTilemap'
  MintCrate.Assert.self(f, self)
  
  -- Validate: tilemapLayoutName
  MintCrate.Assert.type(f, 'tilemapLayoutName', tilemapLayoutName, 'string')
  
  -- Split name to get Tilemap's name and layout
  local nameParts = MintCrate.Util.string.split(tilemapLayoutName, '_')
  
  -- Validate: tilemapLayoutName
  MintCrate.Assert.condition(f,
    "tilemapLayoutName",
    (#nameParts == 2),
    'must be formatted as "tilemap_layout"')
  
  -- Store tilemap and tilemap layout names
  self._tilemapFullName = tilemapLayoutName
  self._tilemapName = nameParts[1]
  self._layoutName = nameParts[2]
  
  -- Validate: tilemapLayoutName
  MintCrate.Assert.condition(f,
    'tilemapLayoutName',
    (self._tilemapName ~= ""),
    'cannot be blank on either side, expected format is "tilemap_layout"')
  
  MintCrate.Assert.condition(f,
    'tilemapLayoutName',
    (self._layoutName ~= ""),
    'cannot be blank on either side, expected format is "tilemap_layout"')
  
  MintCrate.Assert.condition(f,
    'tilemapLayoutName',
    (
      self._data.tilemaps[self._tilemapName]
      and self._data.tilemaps[self._tilemapName].layouts[self._layoutName]
    ),
    'does not refer to a valid Tilemap layout')
end

-- -----------------------------------------------------------------------------
-- Methods for storing and loading data
-- -----------------------------------------------------------------------------

-- Saves a table of game data to a JSON file to the user's app data folder.
-- @param {string} filename Name of the JSON file (without file extension).
-- @param {data} Table of data to encode and save as JSON data.
-- @returns {boolean} Whether the data was saved successfully or not.
-- @returns {string} An error message, if the data failed to save.
function Core:saveData(filename, data)
  local f = 'saveData'
  
  MintCrate.Assert.self(f, self)
  
  -- Validate: filename
  MintCrate.Assert.type(f,
    'filename',
    filename,
    'string'
  )
  
  -- Validate: data
  MintCrate.Assert.type(f,
    'data',
    data,
    'table'
  )
  
  -- Prepare to attempt to save the data
  local success = true
  local msg = ''
  
  -- Attempt to convert table data to JSON string
  local json, msg = self.util.json.encode(data)
  
  -- If conversion failed, flag that the process failed
  if (json == nil) then
    success = false
  -- Otherwise, attempt to save JSON data to file
  elseif (not love.filesystem.write(filename..'.json', json)) then
    success = false
    msg = "Could not write data to filesystem."
  end
  
  -- Return success flag and potential error message
  return success, msg
end

-- Loads a table of game data from a JSON file from the user's app data folder.
-- @param {string} filename Name of the JSON file (without file extension).
-- @returns {table|nil} Decoded JSON data, or nil on read error.
-- @returns {string} An error message, if the data failed to load.
function Core:loadData(filename)
  local f = 'loadData'
  
  MintCrate.Assert.self(f, self)
  
  -- Validate: filename
  MintCrate.Assert.type(f,
    'filename',
    filename,
    'string'
  )
  
  -- Prepare to attempt to load the data
  local data = nil
  local msg = ''
  
  -- Attempt to load JSON data from file
  local json, msg = love.filesystem.read(filename..'.json')
  
  -- If loading succeeded, then attempt to parse JSON string into table data
  if (json ~= nil) then
    -- love.filesystem.read returns number of bytes on success, so reset this
    msg = ''
    
    -- Attempt to parse JSON string
    data, msg = self.util.json.decode(json)
  end
  
  -- Return success flag and potential error message
  return data, msg
end

-- Checks if game data JSON file exists in user's app data folder.
-- @param {string} filename Name of the JSON file (without file extension).
-- @returns {boolean} Wheteher the file exists or not.
function Core:savedDataExists(filename)
  local f = 'savedDataExists'
  
  MintCrate.Assert.self(f, self)
  
  -- Validate: filename
  MintCrate.Assert.type(f,
    'filename',
    filename,
    'string'
  )
  
  -- Check to see if the file exists
  local exists = false
  
  if (love.filesystem.read(filename..'.json')) then
    exists = true
  end
  
  -- Return flag indicating existence of file
  return exists
end

-- -----------------------------------------------------------------------------
-- Game runtime methods
-- -----------------------------------------------------------------------------

-- Performs the main game update code (the game loop).
function Core:sys_update()
  local f = 'sys_update'
  MintCrate.Assert.self(f, self)
  
  -- Cap FPS
  self._fpsCurrentTime = love.timer.getTime()
  if (self._fpsNextTime <= self._fpsCurrentTime) then
    self._fpsNextTime = self._fpsCurrentTime
  else
    love.timer.sleep(self._fpsNextTime - self._fpsCurrentTime)
  end
  
  -- Prepare FPS limiting
  self._fpsNextTime = self._fpsNextTime + self._fpsMinDt
  
  -- Update inputs
  for _, handler in ipairs(self._inputHandlers) do
    handler:_update(self._keystates, self._joystates)
  end
  
  -- Update global mouse position
  self._mousePositions.globalX = self._mousePositions.localX + self._camera.x
  self._mousePositions.globalY = self._mousePositions.localY + self._camera.y
  
  -- Update mouse buttons states
  for btnNumber, btn in ipairs(self._mouseButtons) do
    -- Reset states
    btn.pressed = false
    btn.released = false
    
    -- Get raw mouse state
    local down = false
    if (self._mouseStates[btnNumber]) then down = true end
    
    -- Handle setting held/pressed/released states
    if (down) then
      if (not btn.held) then
        btn.pressed = true
      end
      
      btn.held = true
    else
      if (btn.held) then
        btn.released = true
      end
      
      btn.held = false
    end
  end
  
  -- Reset collision states for actives
  for _, active in ipairs(self._instances.actives) do
    active:_getCollider().collision = false
    active:_getCollider().mouseOver = false
  end
  
  -- Reset collision states for tilemap masks
  if self._tilemapFullName then
    for _, maskCollection in pairs(self:_getTilemapCollisionMasks()) do
      for __, mask in ipairs(maskCollection) do
        mask.collision = false
      end
    end
  end
  
  
  
  -- Handle music looping and fading
  for _, track in pairs(self._data.music) do
    -- Handle looping for non-tracker-module music formats
    if (
      track.source:isPlaying()
      and track.loop
      and type(track.loopStart) ~= "nil"
      and type(track.loopEnd) ~= "nil"
      and track.source:tell("seconds") >= track.loopEnd
    ) then
      track.source:seek(track.loopStart, "seconds")
    end
    
    -- Handle fade-ins
    if (track.fadeInLength and track.source:isPlaying()) then
      -- Fade audio in
      track.volume = math.min(1, track.volume + (1 / track.fadeInLength))
      track.source:setVolume(track.volume * self.masterBgmVolume)
      
      -- Finish fade when volume is maxed
      if (track.volume >= 1) then
        track.fadeInLength = nil
      end
    -- Handle fade-outs
    elseif (track.fadeOutLength and track.source:isPlaying()) then
      -- Fade audio out
      track.volume = math.max(0, track.volume - (1 / track.fadeOutLength))
      track.source:setVolume(track.volume * self.masterBgmVolume)
      
      -- Finish fade when volume is silenced
      if (track.volume <= 0.0001) then
        track.fadeOutLength = nil
        love.audio.stop(track.source)
      end
    end
  end
  
  -- Handle delayed functions
  for i = #self._queuedFunctions, 1, -1 do
    local func = self._queuedFunctions[i]
    
    -- Tick function's wait timer
    func.remainingFrames = func.remainingFrames - 1
    
    -- Remove function if it's been cancelled
    if (func.cancelled) then
      table.remove(self._queuedFunctions, i)
    -- Or, fire it if its timer has run out
    elseif func.remainingFrames <= 0 then
      -- Run the function
      func.callback()
      
      -- If function is set to repeat, then reset its timer
      if (func.repeatValue) then
        func.remainingFrames = func.repeatValue
      -- Otherwise, remove it
      else
        table.remove(self._queuedFunctions, i)
      end
    end
  end
  
  -- Run room update code
  if (self._currentRoom) and self._currentRoom.update then
    self._currentRoom:update()
  end
  
  -- Process animations for active objects
  for _, active in ipairs(self._instances.actives) do
    -- Get active's animation data
    local animation =
      self._data.actives[active:_getName()]
      .animations[active:getAnimationName()]
      
    -- Process active's animation
    active:_animate(animation)
  end
  
  -- Reset keyboard states
  for _, key in pairs(self._keystates) do
    key.pressed = false
    key.released = false
  end
  
end

-- Renders the current room (entities and debug visuals).
function Core:sys_draw()
  local f = 'sys_draw'
  MintCrate.Assert.self(f, self)
  
  -- Clear out-of-bounds areas to black
  love.graphics.clear(0, 0, 0)
  
  -- Clip game area view
  love.graphics.setScissor(
    self._gfxOffsetX * self._gfxScale,
    self._gfxOffsetY * self._gfxScale,
    self._baseWidth  * self._gfxScale,
    self._baseHeight * self._gfxScale
  )
  
  -- Clear the game area with the current room's clear color
  local r, g, b = self._currentRoom:_getRoomBackgroundColor()
  love.graphics.clear(r, g, b)
  
  -- Take snapshot of untransformed graphics state
  love.graphics.push()
  
  -- Scale all graphics to window scale
  love.graphics.scale(self._gfxScale, self._gfxScale)
  
  -- Center the game view in the window (to account for letterboxing)
  love.graphics.translate(
    math.floor(-self._camera.x + self._gfxOffsetX),
    math.floor(-self._camera.y + self._gfxOffsetY)
  )
  
  -- Draw Backdrops
  for _, backdrop in ipairs(self._drawOrders.backdrops) do
    -- If backdrop isn't visible, then skip drawing it
    if (not backdrop._isVisible or backdrop:getOpacity() == 0) then
      goto DrawBackdropDone
    end
    
    -- Get backdrop image and tiling property
    local image = self._data.backdrops[backdrop._name].image
    local isMosaic = self._data.backdrops[backdrop._name].mosaic
    
    -- Set alpha rendering value
    love.graphics.setColor(1, 1, 1, backdrop:getOpacity())
    
    -- Draw backdrop normally if it's not set to tile
    if (not isMosaic) then
      love.graphics.draw(
        image,
        backdrop._x, backdrop._y,
        0,
        backdrop._scaleX, backdrop._scaleY
      )
    -- Otherwise, draw it tiled
    else
      love.graphics.draw(
        image,
        backdrop._quad,
        backdrop._x, backdrop._y,
        0,
        backdrop._scaleX, backdrop._scaleY
      )
    end
    
    -- Reset alpha rendering value
    love.graphics.setColor(1, 1, 1, 1)
    
    ::DrawBackdropDone::
  end
  
  -- Draw Tilemap
  if self._tilemapFullName then
    -- Parse out tilemap name and layout name
    local nameParts = self.util.string.split(self._tilemapFullName, '_')
    local tilemapName = nameParts[1]
    local layoutName = nameParts[2]
    
    -- Retieve tilemap and tilemap layout data
    local tilemap = self._data.tilemaps[tilemapName]
    local layout = self._data.tilemaps[tilemapName].layouts[layoutName]
    
    -- Iterate through tilemap layout, drawing tiles as appropriate
    for row = 1, #layout.tiles do
      for col = 1, #layout.tiles[row] do
        -- Get tile graphic index
        local tileNumber = layout.tiles[row][col]
        
        -- Only draw it if it's not 0 (0 represents the lack of a tile)
        if (tileNumber > 0) then
          love.graphics.draw(
            tilemap.image,
            tilemap.quads[tileNumber],
            (col-1) * tilemap.tileWidth,
            (row-1) * tilemap.tileHeight
          )
        end
      end
    end
  end
  
  -- Draw main entities
  for _, entity in ipairs(self._drawOrders.main) do
    -- Draw Actives
    if (entity._entityType == 'active') then
      local active = entity
      
      -- If active isn't visible, then skip drawing it
      if (not active._isVisible or active:getOpacity() == 0) then
        goto DrawActiveDone
      end
      
      -- Get active's animation data
      local animation =
        self._data.actives[active:_getName()]
        .animations[active:getAnimationName()]
      
      -- If active doesn't have any animation graphics, then skip drawing it
      if (not animation) then
        goto DrawActiveDone
      end
      
      -- Get current animation frame index
      local animationFrameNumber = active:getAnimationFrameNumber()
      
      -- Get graphics-mirroring states
      local flippedX = 1
      local flippedY = 1
      if (active:isFlippedHorizontally()) then flippedX = -1 end
      if (active:isFlippedVertically()  ) then flippedY = -1 end
      
      -- Set alpha rendering value
      love.graphics.setColor(1, 1, 1, active:getOpacity())
      
      -- Draw active
      love.graphics.draw(
        animation.image,
        animation.quads[active:getAnimationFrameNumber()],
        active:getX(), active:getY(),
        math.rad(active:getAngle()),
        (active:getScaleX() * flippedX), (active:getScaleY() * flippedY),
        -animation.offsetX, -animation.offsetY
      )
      
      -- Reset alpha rendering value
      love.graphics.setColor(1, 1, 1, 1)
      
      ::DrawActiveDone::
      
    -- Draw Text
    elseif (entity._entityType == 'text') then
      local text = entity
      
      -- If text isn't visible, then skip drawing it
      if (not text._isVisible or text:getOpacity() == 0) then
        goto DrawTextDone
      end
      
      -- Set alpha rendering value
      love.graphics.setColor(1, 1, 1, text:getOpacity())
      
      -- Draw text
      self:_drawText(
        text:_getTextLines(),
        self._data.fonts[text:_getName()],
        text:getX(), text:getY(),
        text:_getLineSpacing(),
        text:_getAlignment()
      )
      
      -- Reset alpha rendering value
      love.graphics.setColor(1, 1, 1, 1)
      
      ::DrawTextDone::
    end
  end
  
  -- Draw debug graphics for tilemap
  if (
    (self._showTilemapColliisonMasks or self._showTilemapBehaviorValues)
    and self._tilemapFullName
  ) then
    for tileType, maskCollection in pairs(self:_getTilemapCollisionMasks()) do
      for _, mask in ipairs(maskCollection) do
        -- Draw collision masks
        if (self._showTilemapCollisionMasks) then
          -- Draw color overlay
          if (mask.collision) then
            love.graphics.setColor(love.math.colorFromBytes(0, 255, 0, 127))
          else
            love.graphics.setColor(love.math.colorFromBytes(255, 0, 0, 127))
          end
          
          love.graphics.rectangle(
            "fill",
            math.floor(mask.x) + 0.5, math.floor(mask.y) + 0.5,
            math.floor(mask.w) - 1.0, math.floor(mask.h) - 1.0
          )
          
          -- Draw border
          love.graphics.setColor(love.math.colorFromBytes(0, 0, 255))
          
          love.graphics.rectangle(
            "line",
            math.floor(mask.x) + 0.5, math.floor(mask.y) + 0.5,
            math.floor(mask.w) - 1.0, math.floor(mask.h) - 1.0
          )
        end
        
        -- Reset draw color
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Draw collison mask behavior numbers
        if (self._showTilemapBehaviorValues) then
          self:_drawText(
            {tostring(tileType)},
            self._data.fonts["system_counter"],
            mask.x + 2, mask.y + 2
          )
        end
      end
    end
  end
  
  -- Draw debug graphics for Actives
  if (
    self._showActiveCollisionMasks
    or self._showActiveInfo
    or self._showActiveOriginPoints
    or self._showActiveActionPoints
  ) then
    for _, entity in ipairs(self._drawOrders.main) do
      -- Skip if entity isn't an active
      if (entity._entityType ~= 'active') then
        goto DrawActiveDebugGfxDone
      end
      
      local active = entity
      
      -- Draw collision masks
      if (self._showActiveCollisionMasks) then
        -- Retrieve collider data
        local collider = active:_getCollider()
        
        -- Set draw color based on type of collision taking place, if any
        -- Active is colliding with another object, and mouse is over it
        if (collider.collision and collider.mouseOver) then
          love.graphics.setColor(love.math.colorFromBytes(0, 0, 255, 127))
        -- Active is colliding with another object
        elseif (collider.collision) then
          love.graphics.setColor(love.math.colorFromBytes(0, 255, 0, 127))
        -- Mouse is over the active
        elseif (collider.mouseOver) then
          love.graphics.setColor(love.math.colorFromBytes(0, 255, 255, 127))
        -- Active is not colliding with another object, nor is the mouse over it
        else
          love.graphics.setColor(love.math.colorFromBytes(255, 255, 0, 127))
        end
        
        -- Draw rectangular collision mask
        if (collider.s == self._COLLIDER_SHAPES.RECTANGLE) then
          -- Draw mask
          love.graphics.rectangle(
            "fill",
            math.floor(collider.x) + 0.5, math.floor(collider.y) + 0.5,
            math.floor(collider.w) - 1.0, math.floor(collider.h) - 1.0
          )
          
          -- Draw border
          love.graphics.setColor(love.math.colorFromBytes(255, 0, 255))
          
          love.graphics.rectangle(
            "line",
            math.floor(collider.x) + 0.5, math.floor(collider.y) + 0.5,
            math.floor(collider.w) - 1.0, math.floor(collider.h) - 1.0
          )
        -- Otherwise, draw circular collision mask
        else
          -- Draw mask
          love.graphics.circle("fill", collider.x, collider.y, collider.r)
          
          -- Draw border
          love.graphics.setColor(love.math.colorFromBytes(255, 0, 255))
          
          love.graphics.circle("line", collider.x, collider.y, collider.r)
        end
        
        -- Reset draw color
        love.graphics.setColor(1, 1, 1, 1)
      end
      
      -- Draw action points
      if (self._showActiveActionPoints) then
        -- Get action point system image
        local img = self._systemImages["point_action"]
        
        -- Draw action point
        love.graphics.draw(img,
          active:getActionPointX() - math.floor(img:getWidth()/2),
          active:getActionPointY() - math.floor(img:getHeight()/2))
        
        -- TODO: Remove me?
        -- self:_drawText(
          -- "A", self._data.fonts["system_counter"],
          -- active:getActionPointX() - 8 - 4,
          -- active:getActionPointY() - 8 - 3,
          -- self._baseWidth / self._data.fonts["system_counter"].charWidth,
          -- 0, false
        -- )
      end
      
      -- Draw origin points
      if self._showActiveOriginPoints then
        -- Get origin point system image
        local img = self._systemImages["point_origin"]
        
        -- Draw origin point
        love.graphics.draw(img,
          active:getX() - math.floor(img:getWidth()/2),
          active:getY() - math.floor(img:getHeight()/2))
        
        -- TODO: Remove me?
        -- self:_drawText(
          -- "O", self._data.fonts["system_counter"],
          -- active:getX() + 8 - 4,
          -- active:getY() - 8 - 3,
          -- self._baseWidth / self._data.fonts["system_counter"].charWidth,
          -- 0, false
        -- )
      end
      
      -- Draw X,Y position values & animation name
      if (self._showActiveInfo) then
        -- Get zero-padding size
        local pad = math.max(
          string.len(tostring(self._currentRoom:getRoomWidth())),
          string.len(tostring(self._currentRoom:getRoomHeight()))
        )
        
        -- Get x and y coordinates
        local x = self.math.round(active:getX(), 2)
        local y = self.math.round(active:getY(), 2)
        
        -- Split coordinates, and pad with zeroes for consistency
        local xParts = self.util.string.split(tostring(x), ".")
        local yParts = self.util.string.split(tostring(y), ".")
        
        x =
          self.util.string.padLeft(xParts[1], pad, " ") .. "." ..
          self.util.string.padRight((xParts[2] or ''), 2, "0")
        y =
          self.util.string.padLeft(yParts[1], pad, " ") .. "." ..
          self.util.string.padRight((yParts[2] or ''), 2, "0")
        
        -- Draw information overlay
        self:_drawText(
          {
            "X:" .. x,
            "Y:" .. y,
            active:getAnimationName()
          },
          self._data.fonts["system_counter"],
          active:getX(), active:getY() + 8,
          0,
          "center"
        )
      end
      
      ::DrawActiveDebugGfxDone::
    end
  end
  
  -- Draw fade in/out effect
  if (self._currentRoom._fadeLevel < 100) then
    -- Get fade configuration data
    local fadeConf = self._currentRoom._fadeConf[self._currentRoom._currentFade]
    
    -- Set color of fade, including alpha
    love.graphics.setColor(
      fadeConf.fadeColor.r,
      fadeConf.fadeColor.g,
      fadeConf.fadeColor.b,
      1 - (self._currentRoom._fadeLevel / 100)
    )
    
    -- Draw fade
    love.graphics.rectangle(
      "fill",
      self._camera.x, self._camera.y,
      self._baseWidth, self._baseHeight
    )
  end
  
  -- Reset draw color
  love.graphics.setColor(1, 1, 1, 1)
  
  -- Draw camera debug overlay
  if (self._showCameraInfo) then
    -- Get zero-padding size
    local pad = math.max(
      string.len(tostring(self._currentRoom:getRoomWidth())),
      string.len(tostring(self._currentRoom:getRoomHeight()))
    )
    
    -- Prepare text for information overlay
    local strLines = {
      "Camera",
      "X:" .. self.util.string.padLeft(tostring(self._camera.x), pad, " "),
      "Y:" .. self.util.string.padLeft(tostring(self._camera.y), pad, " ")
    }
    
    -- Show that camera is unbound
    if (not self._cameraIsBound) then
      table.insert(strLines, "UNBOUND")
    -- Otherwise, provide information on its current boundaries
    else
      table.insert(strLines,
        "BND1: (" ..
        self.util.string.padLeft(self._cameraBounds.x1, pad, " ") ..
        ", " ..
        self.util.string.padLeft(self._cameraBounds.y1, pad, " ") ..
        ")")
      table.insert(strLines,
        "BND2: (" ..
        self.util.string.padLeft(self._cameraBounds.x2, pad, " ") ..
        ", " ..
        self.util.string.padLeft(self._cameraBounds.y2, pad, " ") ..
        ")")
    end
    
    -- Draw information overlay
    self:_drawText(
      strLines,
      self._data.fonts["system_counter"],
      self._camera.x + self._baseWidth, self._camera.y,
      0,
      "right"
    )
  end
  
  -- Draw FPS debug overlay
  if (self._showFps) then
    self:_drawText(
      {tostring(love.timer.getFPS())},
      self._data.fonts["system_counter"],
      self._camera.x, self._camera.y
    )
  end
  
  -- Draw debug info for current room
  if (self._showRoomInfo) then
    self:_drawText(
      {
        self._currentRoom:getRoomName(),
        self._currentRoom:getRoomWidth() .. " x " ..
          self._currentRoom:getRoomHeight(),
        "ACTS: " .. #self._instances.actives,
        "BAKS: " .. #self._instances.backdrops,
        "TEXT: " .. #self._instances.text
      },
      self._data.fonts["system_counter"],
      self._camera.x,
      self._camera.y + self._baseHeight -
        (5 * self._data.fonts["system_counter"].charHeight)
    )
  end
  
  -- Restore graphics state to previously-taken untransformed snapshot
  love.graphics.pop()
  
  -- Reset the clipping boundary
  love.graphics.setScissor()
end

-- Renders text via a bitmap font.
-- @param {table} textLines The lines of text to be displayed.
-- @param {table} font The bitmap font to write the text with.
-- @param {number} x The X position to write the text at.
-- @param {number} y The Y position to write the text at.
-- @param {number} lineSpacing How much space there is between lines.
-- @param {string} alignment How the text should be aligned.
function Core:_drawText(
  textLines,
  font,
  x, y,
  lineSpacing,
  alignment
)
  -- Default params
  if (lineSpacing     == nil) then lineSpacing = 0        end
  if (alignment       == nil) then alignment = "left"     end
  
  -- Draw lines of text, character-by-character
  for lineNum, line in ipairs(textLines) do
    -- Figure out base offset based on text alignment
    local xOffset = 0
    
    if alignment == "right" then
      xOffset = string.len(line) * font.charWidth
    elseif alignment == "center" then
      xOffset = math.floor(string.len(line) * font.charWidth / 2)
    end
    
    -- Draw characters
    for charPosition, character in ipairs(self.util.string.split(line)) do
      love.graphics.draw(
        font.image,
        font.quads[character],
        x + (font.charWidth * (charPosition-1)) - xOffset,
        y + (font.charHeight * (lineNum-1)) + (lineSpacing * (lineNum-1))
      )
    end
  end
end

-- -----------------------------------------------------------------------------
-- Methods for window size and graphics scale management
-- -----------------------------------------------------------------------------

-- Sets the scaling value for the window and graphics.
-- @param {number} scale The factor to scale the window by (1.0 is normal).
-- @param {boolean} forceResize Forces a resize event to fire.
function Core:setWindowScale(scale, forceResize)
  local f = 'setWindowScale'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (forceResize == nil) then forceResize = false end
  
  -- Validate: scale
  MintCrate.Assert.type(f, 'scale', scale, 'number')
  
  MintCrate.Assert.condition(f,
    'scale',
    (scale > 0),
    'must be a value greater than 0')
  
  MintCrate.Assert.condition(f,
    'scale',
    (self.math.isIntegral(scale)),
    'must be an integer')
  
  -- Validate: forceResize
  MintCrate.Assert.type(f, 'forceResize', forceResize, 'boolean')
  
  -- Resize window
  if (self._windowScale ~= scale or forceResize) then
    -- Store new window scale
    self._windowScale = scale
    
    -- Only resize if game isn't in fullscreen mode
    if (not self._fullscreen) then
      -- Resize the application window
      love.window.setMode(self._baseWidth * scale, self._baseHeight * scale)
      
      -- Force a resize event so that GFX offsets are recalculated correctly
      love.resize(self._baseWidth * scale, self._baseHeight * scale)
    
    -- Otherwise, make a note to resize the window when fullscreen mode is left
    else
      self._fullscreenDirty = true
    end
  end
end

-- Returns the current window scale.
-- @returns {number} Current window scale value.
function Core:getWindowScale()
  local f = 'getWindowScale'
  MintCrate.Assert.self(f, self)
  
  return self._windowScale
end

-- Returns the base resolution width of the game, in pixels.
-- @returns {number} Base game width.
function Core:getBaseWidth()
  local f = 'getBaseWidth'
  MintCrate.Assert.self(f, self)
  
  return self._baseWidth
end

-- Returns the base resolution height of the game, in pixels.
-- @returns {number} Base game height.
function Core:getBaseHeight()
  local f = 'getBaseHeight'
  MintCrate.Assert.self(f, self)
  
  return self._baseHeight
end

-- Tells the application to enter or exit fullscreen mode.
-- @param {boolean} fullscreen Whether the application should be fullscreen.
function Core:setFullscreenMode(fullscreen)
  local f = 'setFullscreenMode'
  MintCrate.Assert.self(f, self)
  
  -- Validate: fullscreen
  MintCrate.Assert.type(f, 'fullscreen', fullscreen, 'boolean')
  
  -- Store new fullscreen state
  self._fullscreen = fullscreen
  
  -- Force a window resize if we're leaving fullscreen but a graphics-scale
  -- change was previously performed while in fullscreen mode
  if (not fullscreen and self._fullscreenDirty) then
    -- Set window scale, of which will call love.window.setMode and will
    -- disable fullscreen mode
    self:setWindowScale(self._windowScale, true)
    
    -- Reset flag
    self._fullscreenDirty = false
  
  -- Otherwise, just enable/disable fullscreen
  else
    love.window.setFullscreen(fullscreen)
  end
end

-- Returns whether the application is currently in fullscreen mode.
-- @returns {boolean} Whether fullscreen mode is enabled.
function Core:isFullscreenEnabled()
  local f = 'isFullscreenEnabled'
  MintCrate.Assert.self(f, self)
  
  return self._fullscreen
end

-- Updates graphics values (for rendering use) when the application is resized.
-- @param {number} w The new application window width.
-- @param {number} h The new application window height.
function Core:sys_resize(w, h)
  local f = 'sys_resize'
  MintCrate.Assert.self(f, self)
  
  -- Validate: w
  MintCrate.Assert.type(f, 'w', w, 'number')
  
  -- Validate: h
  MintCrate.Assert.type(f, 'h', h, 'number')
  
  -- Calculate scale dynamically, but only if fullscreen mode is enabled
  if self._fullscreen then
    local sx = w / self._baseWidth
    local sy = h / self._baseHeight
    
    local scale = 1
    if (sx < sy) then
      scale = sx
    else
      scale = sy
    end
    
    self._gfxScale = scale
  
  -- Otherwise, just set it to be what the user has previously specified
  else
    self._gfxScale = self._windowScale
  end
  
  -- Floor scale so it's integral, as non-integral scaling will result in
  -- graphical artifacts on textures
  self._gfxScale = math.floor(self._gfxScale)
  
  -- Figure out and store the offsets to center the game in the window
  local ox = ((w / self._gfxScale) - self._baseWidth) / 2
  ox       = self.math.round(ox)
  ox       = math.max(0, ox)
  
  local oy = ((h / self._gfxScale) - self._baseHeight) / 2
  oy       = self.math.round(oy)
  oy       = math.max(0, oy)
  
  self._gfxOffsetX = ox
  self._gfxOffsetY = oy
end

-- -----------------------------------------------------------------------------
-- Methods for testing collisions
-- -----------------------------------------------------------------------------

-- Returns whether two Active objects are colliding.
-- @param {Active} activeA The first Active to test.
-- @param {Active} activeB The second Active to test.
-- @returns {boolean} Whether a collission occurred.
function Core:testActiveCollision(activeA, activeB)
  local f = 'testActiveCollision'
  MintCrate.Assert.self(f, self)
  
  -- Validate: activeA
  MintCrate.Assert.type(f, 'activeA', activeA, 'Active')
  
  -- Validate: activeB
  MintCrate.Assert.type(f, 'activeB', activeB, 'Active')
  
  -- Return result of collision test
  return self:_testCollision(activeA:_getCollider(), activeB:_getCollider())
end

-- Returns whether an active is colliding with a tile on the tilemap.
-- @param {Active} active The active to test.
-- @param {number} tileType The tile's behavior value to filter for.
-- @returns {table|boolean} Data about collisions that occurred, or false.
function Core:testMapCollision(active, tileType)
  local f = 'testMapCollision'
  MintCrate.Assert.self(f, self)
  
  -- Validate active
  MintCrate.Assert.type(f, 'active', active, 'Active')
  
  -- Validate tileType
  MintCrate.Assert.type(f, 'tileType', tileType, 'number')
  
  -- Test active against all tilemap collision masks
  local collisions = {}
  
  if (self._tilemapFullName) then
    -- Get all collision masks
    local mapColliders = self:_getTilemapCollisionMasks()[tileType]
    
    for _, collider in ipairs(mapColliders) do
      -- See if active is intersecting with collision mask
      if (self:_testCollision(active:_getCollider(), collider)) then
        -- Store data regarding the collision
        table.insert(collisions, {
          leftEdgeX   = collider.x,
          rightEdgeX  = collider.x + collider.w,
          topEdgeY    = collider.y,
          bottomEdgeY = collider.y + collider.h
        })
      end
    end
  end
  
  -- Return false if no collisions took place
  if (#collisions == 0) then
    return false
  
  -- Otherwise, return collisions
  else
    return collisions
  end
end

-- Returns whether to collider objects are intersecting.
-- @param {table} colliderA The first collider to test.
-- @param {table} colliderB The second collider to test.
-- @returns {boolean} Whether a collision occurred.
function Core:_testCollision(colliderA, colliderB)
  -- Don't test for collision if one or more colliders haven't been defined
  if (
       colliderA.s == self._COLLIDER_SHAPES.NONE
    or colliderB.s == self._COLLIDER_SHAPES.NONE
  ) then
    return false
  end
  
  -- Prepare data for checking collisions
  local collision = false
  
  -- Collision test: both colliders are rectangles
  if (
        colliderA.s == self._COLLIDER_SHAPES.RECTANGLE
    and colliderB.s == self._COLLIDER_SHAPES.RECTANGLE
  ) then
    if (
      colliderA.x < (colliderB.x + colliderB.w)
      and (colliderA.x + colliderA.w) > colliderB.x
      and colliderA.y < (colliderB.y + colliderB.h)
      and (colliderA.y + colliderA.h) > colliderB.y
    ) then
      collision = true
    end
  
  -- Collision test: both colliders are circles
  elseif (
        colliderA.s == self._COLLIDER_SHAPES.CIRCLE
    and colliderB.s == self._COLLIDER_SHAPES.CIRCLE
  ) then
    local dx  = colliderA.x - colliderB.x
    local dy  = colliderA.y - colliderB.y
    collision = (math.sqrt(dx * dx + dy * dy) < (colliderA.r + colliderB.r))
  
  -- Collision test: one collider is a rectangle and the other is a circle
  else
    -- Make things consistent: collider A should always be rectangular, and
    -- collider B should always be circular, so flip them around if necessary
    if (colliderA.s == self._COLLIDER_SHAPES.CIRCLE) then
      colliderA, colliderB = colliderB, colliderA
    end
    
    -- Prepare to test for intersection
    local rect   = colliderA
    local circle = colliderB
    
    local testX = circle.x
    local testY = circle.y
    
    -- Find closest edge
    if (circle.x < rect.x) then
      testX = rect.x
    elseif (circle.x > (rect.x + rect.w)) then
      testX = rect.x + rect.w
    end
    
    if (circle.y < rect.y) then
      testY = rect.y
    elseif (circle.y > (rect.y + rect.h)) then
      testY = rect.y + rect.h
    end
    
    -- Calculate distances based on closest edges
    local distX    = circle.x - testX
    local distY    = circle.y - testY
    local distance = math.sqrt((distX * distX) + (distY * distY))
    
    -- Check for collision
    collision = (distance <= circle.r)
  end
  
  -- If a collision occurred, mark flag in both colliders
  if (collision) then
    colliderA.collision = true
    colliderB.collision = true
  end
  
  -- Return result of collision test
  return collision
end

-- Returns whether the mouse cursor is hovering over an Active object.
-- @param {Active} active The Active to test.
-- @returns {boolean} Whether the mouse cursor is over the Active.
function Core:mouseOverActive(active)
  local f = 'mouseOverActive'
  MintCrate.Assert.self(f, self)
  
  -- Validate: active
  MintCrate.Assert.type(f, 'active', active, 'Active')
  
  -- Prepare to perform check
  local collider = active:_getCollider()
  local mouseX   = self._mousePositions.globalX
  local mouseY   = self._mousePositions.globalY
  local over     = false
  
  -- Don't test for collision if collider hasn't been defined
  if (collider.s == self._COLLIDER_SHAPES.NONE) then
    return false
  end
  
  -- Hover check: collider is a rectangle
  if (collider.s == self._COLLIDER_SHAPES.RECTANGLE) then
    over = (
          mouseX >= collider.x
      and mouseY >= collider.y
      and mouseX < (collider.x + collider.w)
      and mouseY < (collider.y + collider.h)
    )
  
  -- Hover check: collider is a circle
  else
    local dx = mouseX - collider.x
    local dy = mouseY - collider.y
    local d  = math.sqrt((dx * dx) + (dy * dy))
    over     = (d <= collider.r)
  end
  
  -- If mouse is hovering over active, then mark flag in collider
  collider.mouseOver = over
  
  -- Return result of hover test
  return over
end

-- Returns whether an Active object was clicked.
-- @param {number} mouseButton Which mouse button was used to click.
-- @param {Active} active The active to check for being clicked upon.
function Core:wasActiveClicked(mouseButton, active)
  local f = 'wasActiveClicked'
  MintCrate.Assert.self(f, self)
  
  -- Validate: mouseButton
  MintCrate.Assert.type(f, 'mouseButton', mouseButton, 'number')
  
  -- Validate: active
  MintCrate.Assert.type(f, 'active', active, 'Active')
  
  -- Return result of click test
  return (
        self:mousePressed(mouseButton)
    and self:mouseOverActive(active)
  )
end

-- -----------------------------------------------------------------------------
-- Methods for handling mouse input
-- -----------------------------------------------------------------------------

-- Returns the X position of the mouse cursor relative to the entire room size.
-- @returns {number} The room-relative mouse cursor X position.
function Core:getMouseX()
  local f = 'getMouseX'
  MintCrate.Assert.self(f, self)
  
  return self._mousePositions.globalX
end

-- Returns the Y position of the mouse cursor relative to the entire room size.
-- @returns {number} The room-relative mouse cursor Y position.
function Core:getMouseY()
  local f = 'getMouseY'
  MintCrate.Assert.self(f, self)
  
  return self._mousePositions.globalY
end

-- Returns the X position of the mouse cursor relative to the game window.
-- @returns {number} The screen-relative mouse cursor X position.
function Core:getWindowMouseX()
  local f = 'getWindowMouseX'
  MintCrate.Assert.self(f, self)
  
  return self._mousePositions.localX
end

-- Returns the Y position of the mouse cursor relative to the game window.
-- @returns {number} The screen-relative mouse cursor Y position.
function Core:getWindowMouseY()
  local f = 'getWindowMouseY'
  MintCrate.Assert.self(f, self)
  
  return self._mousePositions.localY
end

-- Returns whether a mouse button was pressed on the current frame.
-- @param {number} mouseButton The numeric button to test (see Love docs).
-- @returns {boolean} Whether the mouse button was pressed.
function Core:mousePressed(mouseButton)
  local f = 'mousePressed'
  MintCrate.Assert.self(f, self)
  
  -- Validate: mouseButton
  MintCrate.Assert.type(f, 'mouseButton', mouseButton, 'number')
  
  return self._mouseButtons[mouseButton].pressed
end

-- Returns whether a mouse button was released on the current frame.
-- @param {number} mouseButton The numeric button to test (see Love docs).
-- @returns {boolean} Whether the mouse button was released.
function Core:mouseReleased(mouseButton)
  local f = 'mouseReleased'
  MintCrate.Assert.self(f, self)
  
  -- Validate: mouseButton
  MintCrate.Assert.type(f, 'mouseButton', mouseButton, 'number')
  
  return self._mouseButtons[mouseButton].released
end

-- Returns whether a mouse button is being held down.
-- @param {number} mouseButton The numeric button to test (see Love docs).
-- @returns {boolean} Whether the mouse button is beind held.
function Core:mouseHeld(mouseButton)
  local f = 'mouseHeld'
  MintCrate.Assert.self(f, self)
  
  -- Validate: mouseButton
  MintCrate.Assert.type(f, 'mouseButton', mouseButton, 'number')
  
  return self._mouseButtons[mouseButton].held
end

-- Updates internal mouse values for correctly mapping mouse positions.
-- @param {number} x The X coordinate of the mouse cursor.
-- @param {number} y The Y coordinate of the mouse cursor.
function Core:sys_mousemoved(x, y)
  local f = 'sys_mousemoved'
  MintCrate.Assert.self(f, self)
  
  -- Validate: x
  MintCrate.Assert.type(f, 'x', x, 'number')
  
  -- Validate: y
  MintCrate.Assert.type(f, 'y', y, 'number')
  
  -- Update mouse position values
  self._mousePositions.localX = math.floor(x / self._gfxScale)
  self._mousePositions.localY = math.floor(y / self._gfxScale)
end

-- Sets raw mouse states for button presses.
-- @param {number} button The numeric mouse button (see Love docs).
function Core:sys_mousepressed(button)
  local f = 'sys_mousepressed'
  MintCrate.Assert.self(f, self)
  
  -- Validate: button
  MintCrate.Assert.type(f, 'button', button, 'number')
  
  -- Mark state
  self._mouseStates[button] = true
end

-- Sets raw mouse states for button releases.
-- @param {number} button The numeric mouse button (see Love docs).
function Core:sys_mousereleased(button)
  local f = 'sys_mousereleased'
  MintCrate.Assert.self(f, self)
  
  -- Validate: button
  MintCrate.Assert.type(f, 'button', button, 'number')
  
  -- Mark state
  self._mouseStates[button] = false
end

-- -----------------------------------------------------------------------------
-- Methods for handling keyboard and game controller input
-- -----------------------------------------------------------------------------

-- Creates an Input Handler object to let a player interact with the game.
-- @returns {InputHandler} A new instance of the InputHandler class.
function Core:addInputHandler()
  local f = 'addInputHandler'
  MintCrate.Assert.self(f, self)
  
  -- Create new input handler
  local handler = MintCrate.InputHandler:new()
  
  -- Add input handler to list to be managed
  table.insert(self._inputHandlers, handler)
  
  -- Return input handler
  return handler
end

-- Returns whether a keybaord key was pressed on the current frame.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
-- @returns {boolean} Whether the key was pressed.
function Core:keyPressed(scancode)
  local f = 'keyPressed'
  MintCrate.Assert.self(f, self)
  
  -- Validate: scancode
  MintCrate.Assert.type(f, 'scancode', scancode, 'string')
  
  -- Check if key was pressed
  local pressed = false
  if (
        self._keystates[scancode]
    and self._keystates[scancode].pressed
  ) then
    pressed = true
  end
  
  -- Return key-pressed state
  return pressed
end

-- Returns whether a keybaord key was released on the current frame.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
-- @returns {boolean} Whether the key was released.
function Core:keyReleased(scancode)
  local f = 'keyReleased'
  MintCrate.Assert.self(f, self)
  
  -- Validate: scancode
  MintCrate.Assert.type(f, 'scancode', scancode, 'string')
  
  -- Check if key was released
  local released = false
  if (
        self._keystates[scancode]
    and self._keystates[scancode].released
  ) then
    released = true
  end
  
  -- Return key-released state
  return released
end

-- Returns whether a keybaord key is being held down.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
-- @returns {boolean} Whether the key is being held.
function Core:keyHeld(scancode)
  local f = 'keyHeld'
  MintCrate.Assert.self(f, self)
  
  -- Validate: scancode
  MintCrate.Assert.type(f, 'scancode', scancode, 'string')
  
  -- CHeck if key is being held
  local held = false
  if (
        self._keystates[scancode]
    and self._keystates[scancode].held
  ) then
    held = true
  end
  
  -- Return key-held state
  return held
end

-- Sets raw keyboard states for key presses.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
function Core:sys_keypressed(scancode)
  local f = 'sys_keypressed'
  MintCrate.Assert.self(f, self)
  
  -- Validate: scancode
  MintCrate.Assert.type(f, 'scancode', scancode, 'string')
  
  -- Create new entry in keystate list if key hasn't been pressed previously
  if (not self._keystates[scancode]) then
    self._keystates[scancode] = {pressed=false, released=false, held=false}
  end
  
  -- Indicate that key was just pressed and is being held
  self._keystates[scancode].pressed = true
  self._keystates[scancode].held = true
end

-- Sets raw keyboard states for key releases.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
function Core:sys_keyreleased(scancode)
  local f = 'sys_keyreleased'
  MintCrate.Assert.self(f, self)
  
  -- Validate: scancode
  MintCrate.Assert.type(f, 'scancode', scancode, 'string')
  
  -- Create new entry in keystate list if key hasn't been released previously
  if (not self._keystates[scancode]) then
    self._keystates[scancode] = {pressed=false, released=false, held=false}
  end
  
  -- Indicate that key was just released and is not being held
  self._keystates[scancode].released = true
  self._keystates[scancode].held = false
end

-- Sets raw gamepad states for gamepad button presses.
-- @param {Joystick} joystick The physical device on which a button was pressed.
-- @param {number} button The joystick button that was pressed (see Love docs).
function Core:sys_gamepadpressed(joystick, button)
  local f = 'sys_gamepadpressed'
  MintCrate.Assert.self(f, self)
  
  -- Validate: joystick
  MintCrate.Assert.type(f, 'joystick', joystick, 'Joystick')
  
  -- Validate: button
  MintCrate.Assert.type(f, 'button', button, 'number')
  
  -- Retrieve ID of joystick
  local joystickId = joystick:getID()
  
  -- Create new entry in joystick list if it hasn't sent an input previously
  if (not self._joystates[joystickId]) then
    self._joystates[joystickId] = {}
  end
  
  -- Indicate that the joystick button is being held
  self._joystates[joystickId][button] = true
end

-- Sets raw gamepad states for gamepad button releases.
-- @param {Joystick} joystick The physical device on which a button was pressed.
-- @param {number} button The joystick button that was pressed (see Love docs).
function Core:sys_gamepadreleased(joystick, button)
  local f = 'sys_gamepadreleased'
  MintCrate.Assert.self(f, self)
  
  -- Validate: joystick
  MintCrate.Assert.type(f, 'joystick', joystick, 'Joystick')
  
  -- Validate: button
  MintCrate.Assert.type(f, 'button', button, 'number')
  
  -- Retrieve ID of joystick
  local joystickId = joystick:getID()
  
  -- Create new entry in joystick list if it hasn't sent an input previously
  if (not self._joystates[joystickId]) then
    self._joystates[joystickId] = {}
  end
  
  -- Indicate that joystick button is not being held
  self._joystates[joystickId][button] = false
end

-- -----------------------------------------------------------------------------
-- Methods for handling audio
-- -----------------------------------------------------------------------------

-- Plays a sound resource.
-- @param {string} soundName Name of the sound resource (from defineSounds()).
-- @param {table} options Optional sound properties.
-- @param {number} options.volume Volume level, between 0 and 1.
-- @param {number} options.pitch Pitch rate, between 0.1 and 30.
function Core:playSound(soundName, options)
  local f = 'playSound'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (options == nil) then options = {} end
  if (options.volume == nil) then options.volume = 1 end
  if (options.pitch == nil) then options.pitch = 1 end
  
  -- Validate: soundName
  MintCrate.Assert.type(f, 'soundName', soundName, 'string')
  
  MintCrate.Assert.condition(f,
    'soundName',
    (self._data.sounds[soundName] ~= nil),
    'does not refer to a valid sound file')
  
  -- Validate: options
  MintCrate.Assert.type(f, 'options', options, 'table')
  
  -- Validate: options.volume
  MintCrate.Assert.type(f, 'options.volume', options.volume, 'number')
  
  -- Validate: options.pitch
  MintCrate.Assert.type(f, 'options.pitch', options.pitch, 'number')
  
  -- Constrain volume/pitch values
  local volume = self.math.clamp(options.volume, 0, 1)
  local pitch = self.math.clamp(options.pitch, 0.1, 30)
  
  -- Retrieve sound data
  local sound = self._data.sounds[soundName]
  
  -- Set sound's local volume
  sound.volume = volume
  sound.source:setVolume(sound.volume * self.masterSfxVolume)
  
  -- Set sound source pitch
  sound.source:setPitch(pitch)
  
  -- Stop sound in case it's currently already playing
  love.audio.stop(sound.source)
  
  -- Play sound
  love.audio.play(sound.source)
end

-- Stops any currently-playing sounds.
function Core:stopAllSounds()
  local f = 'stopAllSounds'
  MintCrate.Assert.self(f, self)
  
  -- Stop all sounds
  for _, sound in pairs(self._data.sounds) do
    love.audio.stop(sound.source)
  end
end

-- Starts playback of the currently-set music track.
-- @param {string} trackName The name of the song to play (from defineMusic).
-- @param {number} fadeLength How much to fade/xfade in the song, in frames.
function Core:playMusic(trackName, fadeLength)
  local f = 'playMusic'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (trackName  == nil) then trackName = "" end
  if (fadeLength == nil) then fadeLength = 0 end
  
  -- Validate: trackName
  MintCrate.Assert.type(f, 'trackName', trackName, 'string')
  
  -- Use previously-played track if one wasn't specified
  if (trackName == "" and self._currentMusic) then
    trackName = self._currentMusic
  end
  
  -- Validate: trackName
  MintCrate.Assert.condition(f,
    'trackName',
    (self._data.music[trackName] ~= nil),
    'does not refer to a valid music file')
  
  -- Validate: fadeLength
  MintCrate.Assert.type(f, 'fadeLength', fadeLength, 'number')
  
  MintCrate.Assert.condition(f,
    'fadeLength',
    (fadeLength >= 0),
    'cannot be a negative value')
  
  -- Play track (if it's not already playing)
  if (trackName ~= "") then
    -- Get currently-playing and to-be-switched-to music tracks
    local oldTrack = self._data.music[self._currentMusic]
    local newTrack = self._data.music[trackName]
    
    -- Play new track and stop old one if one's already playing
    if (self._currentMusic ~= trackName) then
      self:_playMusic(trackName, fadeLength)
      self:_stopMusic(self._currentMusic, fadeLength)
    
    -- Otherwise, just play the new track
    elseif (oldTrack.fadeOutLength or not oldTrack.source:isPlaying()) then
      self:_playMusic(trackName, fadeLength)
    end
    
    -- Keep record of what track is being played
    self._currentMusic = trackName
  end
end

-- Pauses playback of the currently-set music track.
function Core:pauseMusic()
  local f = 'pauseMusic'
  MintCrate.Assert.self(f, self)
  
  -- Get current track
  local track = self._data.music[self._currentMusic]
  
  -- Pause track
  love.audio.pause(track.source)
end

-- Resumes playback of the currently-set music track.
function Core:resumeMusic()
  local f = 'resumeMusic'
  MintCrate.Assert.self(f, self)
  
  -- Get current track
  local track = self._data.music[self._currentMusic]
  
  -- Resume track playback if it's not already playing
  if (not track.source:isPlaying()) then
    love.audio.play(self._data.music[self._currentMusic].source)
  end
end

-- Stops playback of the currently-set music track.
-- @param {number} fadeLength How much to fade out the song, in frames.
function Core:stopMusic(fadeLength)
  local f = 'stopMusic'
  MintCrate.Assert.self(f, self)
  
  -- Default params
  if (fadeLength == nil) then fadeLength = 0 end
  
  -- Validate: fadeLength
  MintCrate.Assert.type(f, 'fadeLength', fadeLength, 'number')
  
  MintCrate.Assert.condition(f,
    'fadeLength',
    (fadeLength >= 0),
    'cannot be a negative value')
  
  -- Stop music track
  self:_stopMusic(self._currentMusic, fadeLength)
end

-- Internal function for playing music.
-- @param {string} trackName The name of the song to play (from defineMusic).
-- @param {number} fadeLength How much to fade in the song, in frames.
function Core:_playMusic(trackName, fadeLength)
  -- Default params
  if (fadeLength == nil) then fadeLength = 0 end
  
  -- Get music track data
  local track = self._data.music[trackName]
  
  -- Stop current track and reset fade lengths
  love.audio.stop(track.source)
  track.fadeInLength = nil
  track.fadeOutLength = nil
  
  -- Set local volume: no fade specified
  if (fadeLength == 0) then
    track.volume = 1
  
  -- Set local volume: fade specified
  else
    track.volume = 0
    track.fadeInLength = fadeLength
  end
  
  -- Set music source volume
  track.source:setVolume(track.volume * self.masterBgmVolume)
  
  -- Play music track
  love.audio.play(track.source)
end

-- Internal function for stopping music.
-- @param {string} trackName The name of the song to play (from defineMusic).
-- @param {number} fadeLength How much to fade out the song, in frames.
function Core:_stopMusic(trackName, fadeLength)
  -- Get music track data
  local track = self._data.music[trackName]
  
  -- Reset fade lengths
  track.fadeInLength = nil
  track.fadeOutLength = nil
  
  -- Stop audio immediately if it doesn't need to fade out
  if (fadeLength == 0) then
    love.audio.stop(track.source)
  
  -- Otherwise, set its fade value so it'll get faded out in the update function
  else
    track.fadeOutLength = fadeLength
  end
end

-- Gets the current master/global sound effect volume.
-- @returns {number} The current master/global sound effect volume.
function Core:getMasterSoundVolume()
  local f = 'getMasterSoundVolume'
  MintCrate.Assert.self(f, self)
  
  return self.masterSfxVolume
end

-- Sets the current master/global sound effect volume.
-- @param {number} newVolume New volume level, between 0 and 1.
function Core:setMasterSoundVolume(newVolume)
  local f = 'setMasterSoundVolume'
  MintCrate.Assert.self(f, self)
  
  -- Validate: newVolume
  MintCrate.Assert.type(f, 'newVolume', newVolume, 'number')
  
  -- Constrain volume value
  self.masterSfxVolume = self.math.clamp(newVolume, 0, 1)
  
  -- Set all sound source volumes
  for _, sound in pairs(self._data.sounds) do
    sound.source:setVolume(sound.volume * self.masterSfxVolume)
  end
end

-- Gets the current master/global music volume.
-- @returns {number} The current master/global music volume.
function Core:getMasterMusicVolume()
  local f = 'getMasterMusicVolume'
  MintCrate.Assert.self(f, self)
  
  return self.masterBgmVolume
end

-- Sets the current master/global music volume.
-- @param {number} newVolume New volume level, between 0 and 1.
function Core:setMasterMusicVolume(newVolume)
  local f = 'setMasterMusicVolume'
  MintCrate.Assert.self(f, self)
  
  -- Validate: newVolume
  MintCrate.Assert.type(f, 'newVolume', newVolume, 'number')
  
  -- Constrain volume value
  self.masterBgmVolume = self.math.clamp(newVolume, 0, 1)
  
  -- Set all music track source volumes
  for _, track in pairs(self._data.music) do
    track.source:setVolume(track.volume * self.masterBgmVolume)
  end
end

-- Gets the current master/global music pitch rate.
-- @returns {number} The current master/global music pitch rate.
function Core:getMasterMusicPitch()
  local f = 'getMasterMusicPitch'
  MintCrate.Assert.self(f, self)
  
  return self.masterBgmPitch
end

-- Sets the current master/global music pitch rate.
-- @param {number} newVolume New pitch rate, between 0.1 and 30.
function Core:setMasterMusicPitch(newPitch)
  local f = 'setMasterMusicPitch'
  MintCrate.Assert.self(f, self)
  
  -- Validate: newPitch
  MintCrate.Assert.type(f, 'newPitch', newPitch, 'number')
  
  -- Constrain pitch value
  self.masterBgmPitch = self.math.clamp(newPitch, 0.1, 30)
  
  -- Set music track source source pitches
  for _, track in pairs(self._data.music) do
    track.source:setPitch(self.masterBgmPitch)
  end
end

-- -----------------------------------------------------------------------------
-- Methods for displaying debug data overlays in the game
-- -----------------------------------------------------------------------------

-- Shows/hides an overlay that shows the current frames-per-second rate.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setFpsVisibility(enabled)
  local f = 'setFpsVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showFps = enabled
end

-- Shows/hides an overlay that shows information regarding the current room.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setRoomInfoVisibility(enabled)
  local f = 'setRoomInfoVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showRoomInfo = enabled
end

-- Shows/hides an overlay that shows information regarding the camera.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setCameraInfoVisibility(enabled)
  local f = 'setCameraInfoVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showCameraInfo = enabled
end

-- Shows/hides an overlay that displays collision masks for tilemaps.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setTilemapCollisionMaskVisibility(enabled)
  local f = 'setTilemapCollisionMaskVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showTilemapCollisionMasks = enabled
end

-- Shows/hides an overlay that displays behavior value numbers for tilemaps.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setTilemapBehaviorValueVisibility(enabled)
  local f = 'setTilemapBehaviorValueVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showTilemapBehaviorValues = enabled
end

-- Shows/hides an overlay that displays collision masks for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setActiveCollisionMaskVisibility(enabled)
  local f = 'setActiveCollisionMaskVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showActiveCollisionMasks = enabled
end

-- Shows/hides an overlay that displays data for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setActiveInfoVisibility(enabled)
  local f = 'setActiveInfoVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showActiveInfo = enabled
end

-- Shows/hides an overlay that visualizes the origin point for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setOriginPointVisibility(enabled)
  local f = 'setOriginPointVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showActiveOriginPoints = enabled
end

-- Shows/hides an overlay that visualizes the action point for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Core:setActionPointVisibility(enabled)
  local f = 'setActionPointVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self._showActiveActionPoints = enabled
end

-- Shows/hides all debug overlays.
-- @param {boolean} enabled Whether the overlays should be shown or not.
function Core:setAllDebugOverlayVisibility(enabled)
  local f = 'setAllDebugOverlayVisibility'
  MintCrate.Assert.self(f, self)
  
  -- Validate: enabled
  MintCrate.Assert.type(f, 'enabled', enabled, 'boolean')
  
  -- Set overlay visibility
  self:setFpsVisibility(enabled)
  self:setRoomInfoVisibility(enabled)
  self:setCameraInfoVisibility(enabled)
  self:setTilemapCollisionMaskVisibility(enabled)
  self:setTilemapBehaviorValueVisibility(enabled)
  self:setActiveCollisionMaskVisibility(enabled)
  self:setActiveInfoVisibility(enabled)
  self:setOriginPointVisibility(enabled)
  self:setActionPointVisibility(enabled)
end

-- -----------------------------------------------------------------------------

return Core