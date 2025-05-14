-- -----------------------------------------------------------------------------
-- MintCrate - Engine
-- Engine core.
-- -----------------------------------------------------------------------------

local Engine = {}

-- -----------------------------------------------------------------------------
-- Constructor
-- -----------------------------------------------------------------------------

-- Creates an instance of the Engine class.
-- @param {number} baseWidth The game's unscaled, base width resolution.
-- @param {number} baseHeight The game's unscaled, base height resolution.
-- @param {Room} startingRoom The room to initially load into.
-- @param {table} options Additional/optional parameters for configuration.
-- @param {number} options.windowScale Starting graphical scale of the window.
-- @param {string} options.windowTitle Title shown on the window title bar.
-- @param {string} options.windowIconPath Icon shown on the window title bar.
-- @param {string} options.pathPrefix For edge-case project directory setups.
-- @returns {Engine} A new instance of the Engine class.
function Engine:new(
  baseWidth,
  baseHeight,
  startingRoom,
  options
)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  
  options = options or {}
  
  -- Initialize Love
  love.graphics.setLineStyle("rough")
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Constants
  o._COLLIDER_SHAPES = {RECTANGLE = 0, CIRCLE = 1}
  
  -- Resource directory paths
  o._resPaths = {
    actives = "res/actives/",
    backdrops = "res/backdrops/",
    fonts = "res/fonts/",
    music = "res/music/",
    sounds = "res/sounds/",
    tilemaps = "res/tilemaps/"
  }
  
  -- Base game width/height
  o._baseWidth = baseWidth
  o._baseHeight = baseHeight
  
  -- Window values
  self._windowTitle = options.windowTitle or ""
  self._windowIconPath = options.windowIconPath or ""
  
  -- Graphics scaling values
  o._windowScale = options.windowScale or 1 -- Unaffected by fullscreen
  o._gfxScale = o._windowScale -- The actual graphics scaling value
  o._fullscreen = false
  o._fullscreenDirty = false -- Indicates scale was changed in fullscreen mode
  
  -- Graphics offset values (important for graphics scaling)
  o._gfxOffsetX = 0
  o._gfxOffsetY = 0
  
  -- Holds RGB value sets for color keying
  o._colorKeyColors = {}
  
  -- System graphics for debugging purposes
  o._systemImages = {}
  o._systemFonts = {}
  
  -- Stores input handlers for managing player input
  o._inputHandlers = {}
  o._keystates = {}
  o._joystates = {}
  o._keyboard = {}
  
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

  -- Debug functionality
  o._showFps = false
  o._showRoomInfo = false
  
  o._showActiveCollisionMasks = false
  o._showActiveInfo = false
  o._showActiveOriginPoints = false
  o._showActiveActionPoints = false

  -- FPS limiter
  o._fpsMinDt = 1 / 60
  o._fpsNextTime = love.timer.getTime()
  o._fpsCurrentTime = o._fpsNextTime

  -- Room/gamestate management
  o._startingRoom = startingRoom
  
  -- Game data
  o._data = {
    actives = {},
    backdrops = {},
    fonts = {},
    tilemaps = {},
    sounds = {},
    music = {}
  }
  
  o._instances = {
    actives = {},
    backdrops = {},
    text = {},
    tiles = {}
  }
  
  -- TODO: Implement <close> var to autorun init() when Love 12 comes out
  
  return o
end

-- -----------------------------------------------------------------------------
-- General system methods
-- -----------------------------------------------------------------------------

-- Prepares the game engine for use after instantiation.
function Engine:init()
  if self._windowTitle ~= "" then
    love.window.setTitle(self._windowTitle)
  end
  
  if self._windowIconPath ~= "" then
    local icon = love.image.newImageData(self._windowIconPath)
    love.window.setIcon(icon)
  end
  
  self:setWindowScale(self._windowScale, true)
end

-- Signifies that all loading has been completed and the game should run.
function Engine:ready()
  -- Load system images
  self._systemImages = {
    point_origin = self:_loadImage(self._sysImgPath.."point_origin", true),
    point_action = self:_loadImage(self._sysImgPath.."point_action", true)
  }
  
  -- Load system fonts
  self._data.fonts["system_boot"]    = self:_loadFont("system_boot")
  self._data.fonts["system_dialog"]  = self:_loadFont("system_dialog")
  self._data.fonts["system_counter"] = self:_loadFont("system_counter")
  
  self:changeRoom(self._startingRoom)
end

-- Terminates the application.
function Engine:quit()
  love.event.quit()
end

-- -----------------------------------------------------------------------------
-- Methods for loading game resources
-- -----------------------------------------------------------------------------

-- Specifies paths for loading resource files (all paths must end with a slash).
-- @param {table} resourcePaths Paths for where to find resource files.
-- @param {table} resourcePaths.actives Path for Actives.
-- @param {table} resourcePaths.backdrops Path for Backdrops.
-- @param {table} resourcePaths.fonts Path for Fonts.
-- @param {table} resourcePaths.music Path for Music.
-- @param {table} resourcePaths.sounds Path for Sounds.
-- @param {table} resourcePaths.tilemaps Path for Tilemaps.
function Engine:setResourcePaths(resourcePaths)
  for resType, path in pairs(resourcePaths) do
    self._resPaths[resType] = path
  end
end

-- Specifies which color(s) should become transparent when loading images.
-- @param {table} rgbSets Table of {r,g,b} tables, indicating the color keys.
function Engine:defineColorKeys(rgbSets)
  self._colorKeyColors = rgbSets
end

-- Loads an image resource from a file with color-keying support.
-- @param {string} imagePath Relative path of the image file.
-- @param {boolean} isEngineResource Whether the file is an engine resource.
-- @returns {Source} Chroma-keyed image resource.
function Engine:_loadImage(imagePath, isEngineResource)
  isEngineResource = isEngineResource or false
  
  local imageData
  -- Load Base64 image if it's an engine resource
  if isEngineResource then
    local imageB64 = require(imagePath)
    local imageDecoded = love.data.decode("data", "base64", imageB64)
    local imageFile = love.filesystem.newFileData(imageDecoded, 'img.png')
    imageData = love.image.newImageData(imageFile)
  -- Otherwise, load as normal
  else
    -- Figure out file extension
    for _, ext in ipairs({'png', 'jpg'}) do
      if love.filesystem.getInfo(imagePath..'.'..ext) then
        imagePath = imagePath..'.'..ext
        break
      end
    end
    imageData = love.image.newImageData(imagePath)
  end
  
  
  -- Set color keys
  local colorKeyColors = self._colorKeyColors
  if isEngineResource then
    colorKeyColors = {
      {r =  82, g = 173, b = 154},
      {r = 140, g = 222, b = 205}
    }
  end
  
  -- Load and color key image
  for _, ckc in ipairs(colorKeyColors) do
    imageData:mapPixel(function(x, y, r, g, b, a)
      local rb, gb, bb = love.math.colorToBytes(r, g, b)
      if rb == ckc.r and gb == ckc.g and bb == ckc.b then a = 0 end
      return r,g,b,a
    end)
  end
  
  return love.graphics.newImage(imageData)
end

-- Defines the active object entities that can be created during gameplay.
-- @param {table} data A table of active object definitions (see docs).
function Engine:defineActives(data)
  for _, item in ipairs(data) do
    -- Active's base name
    if not string.find(item.name, '_') then
      self._data.actives[item.name] = { animations = {} }
    -- Active's collider data
    elseif string.find(item.name, 'collider') then
      local activeName = self.util.string.split(item.name, '_')[1]
      self._data.actives[activeName].collider = {
        width = item.width or 0,
        height = item.height or 0,
        radius = item.radius or 0,
        offsetX = item.ox or 0,
        offsetY = item.oy or 0,
        shape = self._COLLIDER_SHAPES.RECTANGLE
      }
      if item.circle then
        self._data.actives[activeName].collider.shape =
          self._COLLIDER_SHAPES.CIRCLE
      end
    -- Active's sprites/animations
    else
      local activeName = self.util.string.split(item.name, '_')[1]
      local animationName = self.util.string.split(item.name, '_')[2]
      
      -- Specify default animation (the first one the user defines)
      if not self._data.actives[activeName].initialAnimation then
        self._data.actives[activeName].initialAnimation = animationName
      end
      
      -- Load and store animation images
      local animation = {
        image = self:_loadImage(self._resPaths.actives .. item.name),
        quads = {},
        offsetX = item.ox or 0,
        offsetY = item.oy or 0,
        transformX = item.tx or 0,
        transformY = item.ty or 0,
        actionX = item.ax or 0,
        actionY = item.ay or 0,
        frameCount = item.frCount or 1,
        frameDuration = item.frDuration or -1
      }
      
      animation.frameWidth = animation.image:getWidth() / animation.frameCount
      animation.frameHeight = animation.image:getHeight()
      
      -- Generate quads
      for
        x = 0,
        animation.image:getWidth() - animation.frameWidth,
        animation.frameWidth
      do
        table.insert(animation.quads, love.graphics.newQuad(
          x, 0,
          animation.frameWidth, animation.frameHeight,
          animation.image:getDimensions()
        ))
      end
      
      self._data.actives[activeName].animations[animationName] = animation
    end
  end
end

-- Defines the backdrop object entities that can be created during gameplay.
-- @param {table} data A table of backdrop object definitions (see docs).
function Engine:defineBackdrops(data)
  for _, item in ipairs(data) do
    local image = self:_loadImage(self._resPaths.backdrops .. item.name)
    if item.mosaic then image:setWrap("repeat", "repeat") end
    self._data.backdrops[item.name] = {
      image = image
    }
  end
end

-- Defines the fonts that can be used to create text objects during gameplay.
-- @param {table} data A table of bitmap font definitions (see docs).
function Engine:defineFonts(data)
  for _, item in ipairs(data) do
    self._data.fonts[item.name] = self:_loadFont(item.name)
  end
end

-- Loads an bitmap font image into a font data structure.
-- @param {string} fontName The name of the font image (without extension).
function Engine:_loadFont(fontName)
  local path = self._resPaths.fonts
  local isEngineResource = false
  if (string.find(fontName, "system_")) then
    path = self._sysImgPath
    isEngineResource = true
  end
  local font = {
    image = self:_loadImage(path..fontName, isEngineResource),
    quads = {}
  }
  
  font.charWidth = font.image:getWidth() / 32
  font.charHeight = font.image:getHeight() / 3
  
  -- Generate quads
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
        (col - 1) * font.charWidth,
        (row - 1) * font.charHeight,
        font.charWidth, font.charHeight,
        font.image:getDimensions()
      )
    end
  end
  
  return font
end

-- Defines the sounds that can be played during gameplay.
-- @param {table} data A table of sound resource definitions (see docs).
function Engine:defineSounds(data)
  for _, item in ipairs(data) do
    local path = self._resPaths.sounds .. item.name
    
    -- Figure out file extension
    for _, ext in ipairs({'wav', 'ogg'}) do
      if love.filesystem.getInfo(path..'.'..ext) then
        path = path..'.'..ext
        break
      end
    end
    
    -- Load sound
    self._data.sounds[item.name] = love.audio.newSource(path, "static")
  end
end

-- Defines the music that can be played during gameplay.
-- @param {table} data A table of music resource definitions (see docs).
function Engine:defineMusic(data)
  for _, item in ipairs(data) do
    local path = self._resPaths.music .. item.name
    
    -- Figure out file extension
    for _, ext in ipairs({'ogg', 'it', 'xm', 'mod', 's3m'}) do
      if love.filesystem.getInfo(path..'.'..ext) then
        path = path..'.'..ext
        break
      end
    end
    
    local music = {
      source = love.audio.newSource(path, "stream"),
      loop = item.loop or false,
      loopStart = item.loopStart or nil,
      loopEnd = item.loopEnd or nil
    }
    
    if (
      music.loop and
      (type(music.loopStart) == "nil" or type(music.loopEnd) == "nil")
    ) then
      music.source:setLooping(true)
    end
    
    self._data.music[item.name] = music
  end
end

-- Defines the tilemaps that can be set during gameplay.
-- @param {table} data A table of tilemap definitions (see docs).
function Engine:defineTilemaps(data)
  for _, item in ipairs(data) do
    -- Tilemap's base name (refers to the image file)
    if not string.find(item.name, '_') then
      local tilemap = {
        image = self:_loadImage(self._resPaths.tilemaps .. item.name),
        quads = {},
        tileWidth = item.tileWidth,
        tileHeight = item.tileHeight,
        layouts = {}
      }
      
      for y = 0, tilemap.image:getHeight(), tilemap.tileHeight do
        for x = 0, tilemap.image:getWidth(), tilemap.tileWidth do
          if x < tilemap.image:getWidth() and y < tilemap.image:getHeight() then
            table.insert(tilemap.quads, love.graphics.newQuad(
              x, y,
              tilemap.tileWidth, tilemap.tileHeight,
              tilemap.image:getDimensions()
            ))
          end
        end
      end
      
      self._data.tilemaps[item.name] = tilemap
    -- Tilemap's actual map data files
    else
      local tilemapName = self.util.string.split(item.name, '_')[1]
      local layoutName = self.util.string.split(item.name, '_')[2]
      
      -- Load and store tilemap layouts
      local path = string.gsub(self._resPaths.tilemaps, "/", ".")
      local tilemapData = require(path .. item.name)
      self._data.tilemaps[tilemapName].layouts[layoutName] = {
        tiles = tilemapData.tiles
      }
      
      self:_generateCollisionMap(tilemapName, layoutName, tilemapData.behaviors)
    end
  end
end

-- Algorithmically generates a relatively-efficient collision map for a tilemap.
-- @param {string} tilemapName The tilemap graphic name.
-- @param {string} layoutName The tilemap layout name.
-- @param {table} behaviorMap The associated behavior map for the tilemap.
function Engine:_generateCollisionMap(tilemapName, layoutName, behaviorMap)
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
  
  local layout = self._data.tilemaps[tilemapName].layouts[layoutName]
  layout.collisionMasks = {}
  local bMap = behaviorMap
  
  -- Generate simple behavior map if none was provided
  if not bMap then
    bMap = {}
    for row = 1, #layout.tiles do
      bMap[row] = {}
      for col = 1, #layout.tiles[row] do
        local tileNumber = layout.tiles[row][col]
        if tileNumber == 0 then
          bMap[row][col] = 0
        else
          bMap[row][col] = 1
        end
      end
    end
  end
  
  -- Generate collision map
  for row = 1, #bMap do
    for col = 1, #bMap[row] do
      local tileType = bMap[row][col]
      
      -- Skip if empty tile
      if tileType == 0 then
        goto ColumnComplete
      end
      
      -- If tile found, perform a two-step scan for a full quad
      local start = {row = row, col = col}
      local stop  = {row = row, col = col}
      
      -- Find ending column
      for scanCol = start.col+1, #bMap[row] do
        local scanTileType = bMap[row][scanCol]
        if scanTileType == 0 or scanTileType ~= tileType then
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
          if done then break end
        end
        
        if done then break end
        
        stop.row = scanRow
      end
      
      -- Remove from collision data map
      for remRow = start.row, stop.row do
        for remCol = start.col, stop.col do
          bMap[remRow][remCol] = 0
        end
      end
      
      -- Store as collision mask
      if not layout.collisionMasks[tileType] then
        layout.collisionMasks[tileType] = {}
      end
      
      table.insert(layout.collisionMasks[tileType], {
        s = self._COLLIDER_SHAPES.RECTANGLE,
        x = start.col - 1,
        y = start.row - 1,
        w = stop.col - start.col + 1,
        h = stop.row - start.row + 1,
        -- behavior = tileType,
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
function Engine:_getTilemapCollisionMasks()
  return self._data.tilemaps[self._currentRoom:_getTilemapName()]
    .layouts[self._currentRoom:_getLayoutName()].collisionMasks
end

-- -----------------------------------------------------------------------------
-- Methods for room management
-- -----------------------------------------------------------------------------

-- Changes the currently-active scene/level of the game (game state).
-- @param {Room} room The room to load.
function Engine:changeRoom(room)
  -- Wipe all current entity instances.
  for key, _ in pairs(self._instances) do
    self._instances[key] = {}
  end
  
  -- Reset camera.
  self._camera = {x = 0, y = 0}
  
  -- Stop all audio.
  self:stopAllSounds()
  self:stopMusic()
  
  -- Change to new room and default its size to the base application size.
  self._currentRoom = room:new()
  
  -- Throw warning message to console is room is smaller than game resolution.
  if self._currentRoom._roomWidth < self._baseWidth then
    print("WARNING: Room width is smaller than game resolution")
  end
  if self._currentRoom._roomHeight < self._baseHeight then
    print("WARNING: Room height is smaller than game resolution")
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
function Engine:addActive(name, x, y)
  local collider = self._data.actives[name].collider or {}
  
  local active = MintCrate.Active:new(
    self._instances.actives,
    name,
    x, y,
    collider.shape,
    collider.offsetX or 0, collider.offsetY or 0,
    collider.width or 0, collider.height or 0,
    collider.radius or 0,
    self._data.actives[name].initialAnimation
  )
  
  table.insert(self._instances.actives, active)
  
  return active
end

-- Creates a Backdrop object to be manipulated by the currently-active room.
-- @param {string} name The name of the Backdrop (from defineBackdrops).
-- @param {number} x The starting X position of the backdrop.
-- @param {number} y The ending X position of the backdrop.
-- @param {number} width The width of the backdrop.
-- @param {number} height The height of the backdrop.
-- @returns {Backdrop} A new instance of the Backdrop class.
function Engine:addBackdrop(name, x, y, width, height)
  local image = self._data.backdrops[name].image
  width = width or image:getWidth()
  height = height or image:getHeight()
  
  local backdrop = MintCrate.Backdrop:new(
    self._instances.backdrops,
    name, x, y,
    width, height,
    love.graphics.newQuad(0, 0, width, height, image:getDimensions())
  )
  
  table.insert(self._instances.backdrops, backdrop)
  
  return backdrop
end

-- Creates a Text object to be manipulated by the currently-active room.
-- @param {string} name The name of the Font (from defineFonts()).
-- @param {number} x The starting X position of the Text object.
-- @param {number} y The starting Y position of the Text object.
-- @param {string} startingTextContent What text to show upon creation.
-- @param {number} maxCharsPerLine How many characters written before wrapping.
-- @param {number} lineSpacing How much space there is between lines, in pixels.
-- @param {boolean} wordWrap Whether entire words should wrap or break mid-word.
-- @returns {Text} A new instance of the Text class.
function Engine:addText(name, x, y, startingTextContent,
  maxCharsPerLine, lineSpacing, wordWrap
)
  maxCharsPerLine = maxCharsPerLine or 9999
  lineSpacing = lineSpacing or 0
  wordWrap = wordWrap or false
  
  local text = MintCrate.Text:new(
    self._instances.text,
    name,
    x, y,
    maxCharsPerLine, lineSpacing, wordWrap
  )
  
  text:setTextContent(startingTextContent)
  
  table.insert(self._instances.text, text)
  
  return text
end

-- -----------------------------------------------------------------------------
-- Methods for camera management
-- -----------------------------------------------------------------------------

-- Returns the current X position of the camera.
-- @returns {number} X position of camera.
function Engine:getCameraX()
  return self._camera.x
end

-- Returns the current Y position of the camera.
-- @returns {number} Y position of camera.
function Engine:getCameraY()
  return self._camera.y
end

-- Sets the current position of the camera.
-- @param {number} x New X coordinate to place the camera at.
-- @param {number} y New Y coordinate to place the camera at.
function Engine:setCamera(x, y)
  local boundX = x
  boundX = math.max(boundX, 0);
  boundX = math.min(boundX, self._currentRoom._roomWidth - self._baseWidth);
  
  local boundY = y
  boundY = math.max(boundY, 0);
  boundY = math.min(boundY, self._currentRoom._roomHeight - self._baseHeight);
  
  -- Force camera to be 0 for axis if room size is smaller than window size
  if self._currentRoom._roomWidth  <= self._baseWidth  then boundX = 0 end
  if self._currentRoom._roomHeight <= self._baseHeight then boundY = 0 end
  
  self._camera.x = boundX
  self._camera.y = boundY
end

-- Centers the camera on a specific point.
-- @param {number} x X coordinate to center the camera at.
-- @param {number} y Y coordinate to center the camera at.
function Engine:centerCamera(x, y)
  self:setCamera(
    x - self.math.round(self._baseWidth / 2),
    y - self.math.round(self._baseHeight / 2)
  )
end

-- -----------------------------------------------------------------------------
-- Game runtime methods
-- -----------------------------------------------------------------------------

-- Performs the main game update code (the game loop).
function Engine:sys_update()
  -- Cap FPS
  self._fpsCurrentTime = love.timer.getTime()
  if self._fpsNextTime <= self._fpsCurrentTime then
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
  
  -- Update mouse
  -- Global mouse position.
  self._mousePositions.globalX = self._mousePositions.localX + self._camera.x
  self._mousePositions.globalY = self._mousePositions.localY + self._camera.y
  
  -- Update mouse buttons.
  for btnNumber, btn in ipairs(self._mouseButtons) do
    btn.pressed = false
    btn.released = false
    
    -- Get raw mouse state.
    local down = false
    if (self._mouseStates[btnNumber]) then down = true end
    
    -- Handle setting held/pressed/released values.
    if down then
      if not btn.held then btn.pressed = true end
      btn.held = true
    else
      if btn.held then btn.released = true end
      btn.held = false
    end
  end
  
  -- Reset collision states
  for _, active in ipairs(self._instances.actives) do
    active:_getCollider().collision = false
  end
  
  if self._currentRoom:_getTilemapLayoutName() then
    for _, maskCollection in pairs(self:_getTilemapCollisionMasks()) do
      for __, mask in ipairs(maskCollection) do
        mask.collision = false
      end
    end
  end
  
  -- Loop music
  if (
    self._currentMusic and
    self._currentMusic.source:isPlaying() and
    self._currentMusic.loop and
    type(self._currentMusic.loopStart) ~= "nil" and
    type(self._currentMusic.loopEnd) ~= "nil" and
    self._currentMusic.source:tell("seconds") >= self._currentMusic.loopEnd
  ) then
    self._currentMusic.source:seek(self._currentMusic.loopStart, 'seconds')
  end
  
  -- Run room update code
  if self._currentRoom then
    self._currentRoom:update()
  end
  
  -- Reset keyboard states
  for _, key in pairs(self._keystates) do
    key.pressed = false
    key.released = false
  end
end

-- Renders the current room (entities and debug visuals).
function Engine:sys_draw()
  love.graphics.setScissor(
    self._gfxOffsetX * self._gfxScale,
    self._gfxOffsetY * self._gfxScale,
    self._baseWidth * self._gfxScale,
    self._baseHeight * self._gfxScale
  )
  
  love.graphics.push()
  
  love.graphics.scale(self._gfxScale, self._gfxScale)
  
  love.graphics.translate(
    -self._camera.x + self._gfxOffsetX,
    -self._camera.y + self._gfxOffsetY
  )
  
  -- Draw backdrops
  for _, backdrop in ipairs(self._instances.backdrops) do
    love.graphics.draw(self._data.backdrops[backdrop._name].image,
      backdrop._quad, backdrop._x, backdrop._y)
  end
  
  -- Draw tilemap
  if self._currentRoom:_getTilemapLayoutName() then
    local fullName = self._currentRoom:_getTilemapLayoutName()
    local tilemapName = self.util.string.split(fullName, '_')[1]
    local layoutName = self.util.string.split(fullName, '_')[2]
    
    local tilemap = self._data.tilemaps[tilemapName]
    local layout = self._data.tilemaps[tilemapName].layouts[layoutName]
    
    for row = 1, #layout.tiles do
      for col = 1, #layout.tiles[row] do
        local tileNumber = layout.tiles[row][col]
        if tileNumber > 0 then
          love.graphics.draw(
            tilemap.image,
            tilemap.quads[tileNumber],
            (col-1) * tilemap.tileWidth, (row-1) * tilemap.tileHeight
          )
        end
      end
    end
  end
  
  -- Draw actives
  for _, active in ipairs(self._instances.actives) do
    local animation = self._data.actives[active:_getName()]
      .animations[active:getAnimationName()]
    if not animation then goto DrawActiveDone end
    local animationFrameNumber = active:getAnimationFrameNumber()
    
    active:_animate(animation)
    
    if active:getOpacity() == 0 then
      goto DrawActiveDone
    end
    
    local flippedX = 1
    if active:isFlippedHorizontally() then flippedX = -1 end
    local flippedY = 1
    if active:isFlippedVertically() then flippedY = -1 end
    
    love.graphics.setColor(1, 1, 1, active:getOpacity())
    love.graphics.draw(
      animation.image,
      animation.quads[active:getAnimationFrameNumber()],
      active:getX(), active:getY(),
      math.rad(active:getAngle()),
      (active:getScaleX() * flippedX), (active:getScaleY() * flippedY),
      -animation.offsetX, -animation.offsetY
    )
    love.graphics.setColor(1, 1, 1, 1)
    
    ::DrawActiveDone::
  end
  
  -- Draw text
  for _, text in ipairs(self._instances.text) do
    self:_drawText(
      text:getTextContent(),
      self._data.fonts[text:_getName()],
      text:getX(), text:getY(),
      text:_getMaxCharsPerLine(),
      text:_getLineSpacing(),
      text:_getWordWrap()
    )
  end
  
  -- Draw debug graphics for Tilemap
  if (
    (self._showTilemapColliisonMasks or self._showTilemapBehaviorValues) and
    self._currentRoom:_getTilemapLayoutName()
  ) then
    for tileType, maskCollection in pairs(self:_getTilemapCollisionMasks()) do
      for _, mask in ipairs(maskCollection) do
        -- Draw collision masks
        if self._showTilemapCollisionMasks then
          if mask.collision then
            love.graphics.setColor(love.math.colorFromBytes(0, 255, 0, 127))
          else
            love.graphics.setColor(love.math.colorFromBytes(255, 0, 0, 127))
          end
          
          love.graphics.rectangle(
            "fill",
            mask.x + 0.5, mask.y + 0.5,
            mask.w - 1.0, mask.h - 1.0
          )
          
          love.graphics.setColor(love.math.colorFromBytes(0, 0, 255))
          
          love.graphics.rectangle(
            "line",
            mask.x + 0.5, mask.y + 0.5,
            mask.w - 1.0, mask.h - 1.0
          )
        end
        
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Draw collison mask behavior numbers
        if self._showTilemapBehaviorValues then
          self:_drawText(
            tileType, self._data.fonts["system_counter"],
            mask.x + 2, mask.y + 2,
            3, 0, false
          )
        end
      end
    end
  end
  
  -- Draw debug graphics for Actives
  if (
    self._showActiveCollisionMasks or
    self._showActiveInfo or
    self._showActiveOriginPoints or
    self._showActiveActionPoints
  ) then
    for _, active in ipairs(self._instances.actives) do
      local animation = self._data.actives[active:_getName()]
        .animations[active:getAnimationName()]
      
      -- Draw collision masks
      if self._showActiveCollisionMasks then
        local collider = active:_getCollider()
        if (collider.collision and collider.mouseOver) then
          love.graphics.setColor(love.math.colorFromBytes(0, 0, 255, 127))
        elseif (collider.collision) then
          love.graphics.setColor(love.math.colorFromBytes(0, 255, 0, 127))
        elseif (collider.mouseOver) then
          love.graphics.setColor(love.math.colorFromBytes(0, 255, 255, 127))
        else
          love.graphics.setColor(love.math.colorFromBytes(255, 255, 0, 127))
        end
        
        if (collider.s == self._COLLIDER_SHAPES.RECTANGLE) then
          love.graphics.rectangle(
            "fill",
            collider.x + 0.5, collider.y + 0.5,
            collider.w - 1.0, collider.h - 1.0
          )
          
          love.graphics.setColor(love.math.colorFromBytes(255, 0, 255))
          
          love.graphics.rectangle(
            "line",
            collider.x + 0.5, collider.y + 0.5,
            collider.w - 1.0, collider.h - 1.0
          )
        else
          love.graphics.circle("fill", collider.x, collider.y, collider.r)
          love.graphics.setColor(love.math.colorFromBytes(255, 0, 255))
          love.graphics.circle("line", collider.x, collider.y, collider.r)
        end
        
        love.graphics.setColor(1, 1, 1, 1)
      end
      
      -- Draw action points
      if self._showActiveActionPoints then
        local img = self._systemImages["point_action"]
        
        love.graphics.draw(img,
          active:getActionPointX() - math.floor(img:getWidth()/2),
          active:getActionPointY() - math.floor(img:getHeight()/2))
        
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
        local img = self._systemImages["point_origin"]
        
        love.graphics.draw(img,
          active:getX() - math.floor(img:getWidth()/2),
          active:getY() - math.floor(img:getHeight()/2))
        
        -- self:_drawText(
          -- "O", self._data.fonts["system_counter"],
          -- active:getX() + 8 - 4,
          -- active:getY() - 8 - 3,
          -- self._baseWidth / self._data.fonts["system_counter"].charWidth,
          -- 0, false
        -- )
      end
      
      -- Draw X,Y position values & animation name
      if self._showActiveInfo then
        local pad = math.max(
          string.len(tostring(self._currentRoom:getWidth())),
          string.len(tostring(self._currentRoom:getHeight()))
        )
        
        local x = self.math.round(active:getX(), 2)
        local y = self.math.round(active:getY(), 2)
        
        local xParts = self.util.string.split(x, ".")
        local yParts = self.util.string.split(y, ".")
        
        x =
          self.util.string.padLeft(xParts[1], pad, " ") .. "." ..
          self.util.string.padRight(xParts[2], 2, "0")
        y =
          self.util.string.padLeft(yParts[1], pad, " ") .. "." ..
          self.util.string.padRight(yParts[2], 2, "0")
        
        local str =
          "X:" .. x .. "\n" ..
          "Y:" .. y .. "\n" ..
          active:getAnimationName()
        
        self:_drawText(
          str, self._data.fonts["system_counter"],
          active:getX() + 8, active:getY() + 8,
          self._baseWidth / self._data.fonts["system_counter"].charWidth,
          0, false
        )
      end
    end
  end
  
  -- Draw FPS debug overlay
  if self._showFps then
    self:_drawText(
      love.timer.getFPS(),
      self._data.fonts["system_counter"],
      self._camera.x, self._camera.y,
      self._baseWidth / self._data.fonts["system_counter"].charWidth,
      0, false
    )
  end
  
  -- Draw debug info for current room
  if self._showRoomInfo then
    self:_drawText(
      "ACTS: "..#self._instances.actives..
      "\nBAKS: "..#self._instances.backdrops..
      "\nTXTS: "..#self._instances.text,
      self._data.fonts["system_counter"],
      self._camera.x, self._camera.y + 8,
      self._baseWidth / self._data.fonts["system_counter"].charWidth,
      0, false
    )
  end
  
  love.graphics.pop()
  
  love.graphics.setScissor()
end

-- Renders text via a bitmap font.
-- @param {string} textContent The text to be displayed.
-- @param {table} font The bitmap font to write the text with.
-- @param {number} x The X position to write the text at.
-- @param {number} y The Y position to write the text at.
-- @param {number} maxCharsPerLine How many characters written before wrapping.
-- @param {number} lineSpacing How much space there is between lines.
-- @param {boolean} wordWrap Whether entire words should wrap or break mid-word.
function Engine:_drawText(
  textContent,
  font,
  x, y,
  maxCharsPerLine, lineSpacing, wordWrap
)
  maxCharsPerLine = maxCharsPerLine or 9999
  lineSpacing = lineSpacing or 0
  wordWrap = wordWrap or false
  
  textContent = string.gsub(textContent, "\n", " \n ")
  local words = self.util.string.split(textContent, " ")
  
  local line = 0
  local position = 0
  
  -- Copy each word to canvas, letter-by-letter.
  for i, word in ipairs(words) do
    -- Wrap words, but only if they're not longer than the max chars per line.
    -- If they are, then the word itself needs to break rather than being moved
    -- to the next line.
    if
      wordWrap
      and string.len(word) <= maxCharsPerLine
      and (position + string.len(word)) > maxCharsPerLine
    then
      position = 0
      line = line + 1
    end
    
    -- Copy each letter of the word to the canvas.
    for _, character in ipairs(self.util.string.split(word)) do
      -- Break line if line break character encountered.
      if character == "\n" then
        position = 0
        line = line + 1
        goto LetterDrawn
      end
      
      -- Ignore spaces as the first character of the line. This is needed to
      -- avoid spaces from wrapping when word wrap is enabled.
      if position == 0 and character == " " and wordWrap then
        goto LetterDrawn
      end
      
      -- Copy character tile to canvas.
      love.graphics.draw(
        font.image,
        font.quads[character],
        x + (font.charWidth * position),
        y + (font.charHeight * line) + (lineSpacing * line)
      )
      
      -- Increment drawing position, wrapping to next line as needed.
      position = position + 1
      if position == maxCharsPerLine then
        position = 0
        line = line + 1
      end
      
      ::LetterDrawn::
    end
    
    -- Add space after word (except for the last word).
    if i < #words and position > 0 then
      -- Copy character tile to canvas.
      love.graphics.draw(
        font.image,
        font.quads[" "],
        x + (font.charWidth * position),
        y + (font.charHeight * line) + (lineSpacing * line)
      )
      
      -- Increment drawing position, wrapping to next line as needed.
      position = position + 1
      if position == maxCharsPerLine then
        position = 0
        line = line + 1
      end
    end
  end
end

-- -----------------------------------------------------------------------------
-- Methods for window size and graphics scale management
-- -----------------------------------------------------------------------------

-- Sets the scaling value for the window and graphics.
-- @param {number} scale The factor to scale the window by (1.0 is normal).
-- @param {boolean} forceResize Forces a resize event to fire.
function Engine:setWindowScale(scale, forceResize)
  if self._windowScale ~= scale or forceResize then
    self._windowScale = scale
    
    if not self._fullscreen then
      -- Resize the application window
      love.window.setMode(self._baseWidth * scale, self._baseHeight * scale)
      -- Force a resize event so that GFX offsets are recalculated correctly
      love.resize(self._baseWidth * scale, self._baseHeight * scale)
    else
      self._fullscreenDirty = true
    end
  end
end

-- Returns the current window scale.
-- @returns {number} Current window scale value.
function Engine:getWindowScale()
  return self._windowScale
end

-- Returns the base resolution width of the game, in pixels.
-- @returns {number} Base game width.
function Engine:getScreenWidth()
  return self._baseWidth
end

-- Returns the base resolution height of the game, in pixels.
-- @returns {number} Base game height.
function Engine:getScreenHeight()
  return self._baseHeight
end

-- Tells the application to enter or exit fullscreen mode.
-- @param {boolean} fullscreen Whether the application should be fullscreen.
function Engine:setFullscreen(fullscreen)
  self._fullscreen = fullscreen
  if not fullscreen and self._fullscreenDirty then
    self:setWindowScale(self._windowScale, true)
    self._fullscreenDirty = false
  else
    love.window.setFullscreen(fullscreen)
  end
end

-- Returns whether the application is currently in fullscreen mode.
-- @returns {boolean} Whether fullscreen mode is enabled.
function Engine:getFullscreen()
  return self._fullscreen
end

-- Updates graphics values (for rendering use) when the application is resized.
-- @param {number} w The new application window width.
-- @param {number} h The new application window height.
function Engine:sys_resize(w, h)
  -- Calculate scale dynamically, but only if fullscreen mode is enabled.
  if self._fullscreen then
    local sx = w / self._baseWidth
    local sy = h / self._baseHeight
    
    local scale = 1
    if sx < sy then
      scale = sx
    else
      scale = sy
    end
    
    self._gfxScale = scale
  -- Otherwise, just set it to be what the user has specified.
  else
    self._gfxScale = self._windowScale
  end
  
  -- Determine the offsets to center the game in the window.
  local ox = ((w / self._gfxScale) - self._baseWidth) / 2
  ox = self.math.round(ox)
  ox = math.max(0, ox)
  
  local oy = ((h / self._gfxScale) - self._baseHeight) / 2
  oy = self.math.round(oy)
  oy = math.max(0, oy)
  
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
function Engine:testActiveCollision(activeA, activeB)
  return self:_testCollision(activeA:_getCollider(), activeB:_getCollider())
end

-- Returns whether an active is colliding with a tile on the tilemap.
-- @param {Active} active The active to test.
-- @param {number} tileType The tile's behavior value to filter for.
-- @returns {table|boolean} Data about collisions that occurred, or false.
function Engine:testMapCollision(active, tileType)
  local collisions = {}
  
  if self._currentRoom:_getTilemapLayoutName() then
    local mapColliders = self:_getTilemapCollisionMasks()[tileType]
    
    for _, collider in ipairs(mapColliders) do
      if self:_testCollision(active:_getCollider(), collider) then
        table.insert(collisions, {
          leftEdgeX   = collider.x,
          rightEdgeX  = collider.x + collider.w,
          topEdgeY    = collider.y,
          bottomEdgeY = collider.y + collider.h
        })
      end
    end
  end
  
  if #collisions == 0 then collisions = false end
  
  return collisions
end

-- Returns whether to collider objects are intersecting.
-- @param {table} colliderA The first collider to test.
-- @param {table} colliderB The second collider to test.
-- @returns {boolean} Whether a collision occurred.
function Engine:_testCollision(colliderA, colliderB)
  local collision = false
  
  -- Both colliders are rectangles.
  if (
    colliderA.s == self._COLLIDER_SHAPES.RECTANGLE and
    colliderB.s == self._COLLIDER_SHAPES.RECTANGLE
  ) then
    if (
      colliderA.x < (colliderB.x + colliderB.w) and
      (colliderA.x + colliderA.w) > colliderB.x and
      colliderA.y < (colliderB.y + colliderB.h) and
      (colliderA.y + colliderA.h) > colliderB.y
    ) then
      collision = true
    end
  -- Both colliders are circles.
  elseif (
    colliderA.s == self._COLLIDER_SHAPES.CIRCLE and
    colliderB.s == self._COLLIDER_SHAPES.CIRCLE
  ) then
    local dx = colliderA.x - colliderB.x
    local dy = colliderA.y - colliderB.y
    collision = (math.sqrt(dx * dx + dy * dy) < (colliderA.r + colliderB.r))
  -- One collider is a rectangle and the other is a circle.
  else
    -- Make things consistent.
    if (colliderA.s == self._COLLIDER_SHAPES.CIRCLE) then
      colliderA, colliderB = colliderB, colliderA
    end
    
    local rect = colliderA
    local circle = colliderB
    
    local testX = circle.x
    local testY = circle.y
    
    -- Find closest edge.
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
    
    -- Calculate distances based on closest edges.
    local distX = circle.x - testX
    local distY = circle.y - testY
    local distance = math.sqrt((distX * distX) + (distY * distY))
    
    -- Collision check.
    collision = (distance <= circle.r)
  end
  
  if (collision) then
    colliderA.collision = true
    colliderB.collision = true
  end
  
  return collision
end

-- Returns whether the mouse cursor is hovering over an Active object.
-- @param {Active} active The Active to test.
-- @returns {boolean} Whether the mouse cursor is over the Active.
function Engine:mouseOverActive(active)
  local collider = active:_getCollider()
  local mouseX = self._mousePositions.globalX
  local mouseY = self._mousePositions.globalY
  
  local over = false
  
  if (collider.s == self._COLLIDER_SHAPES.RECTANGLE) then
    over = (
      mouseX >= collider.x and
      mouseY >= collider.y and
      mouseX < (collider.x + collider.w) and
      mouseY < (collider.y + collider.h)
    )
  else
    local dx = mouseX - collider.x
    local dy = mouseY - collider.y
    local d = math.sqrt((dx * dx) + (dy * dy))
    over = (d <= collider.r)
  end
  
  collider.mouseOver = over
  
  return over
end

-- -----------------------------------------------------------------------------
-- Methods for handling mouse input
-- -----------------------------------------------------------------------------

-- Returns the X position of the mouse cursor relative to the entire room size.
-- @returns {number} The room-relative mouse cursor X position.
function Engine:getMouseX()
  return self._mousePositions.globalX
end

-- Returns the Y position of the mouse cursor relative to the entire room size.
-- @returns {number} The room-relative mouse cursor Y position.
function Engine:getMouseY()
  return self._mousePositions.globalY
end

-- Returns the X position of the mouse cursor relative to the game window.
-- @returns {number} The screen-relative mouse cursor X position.
function Engine:getRelativeMouseX()
  return self._mousePositions.localX
end

-- Returns the Y position of the mouse cursor relative to the game window.
-- @returns {number} The screen-relative mouse cursor Y position.
function Engine:getRelativeMouseY()
  return self._mousePositions.localY
end

-- Returns whether a mouse button was pressed on the current frame.
-- @param {number} mouseButton The numeric button to test (see Love docs).
-- @returns {boolean} Whether the mouse button was pressed.
function Engine:mousePressed(mouseButton)
  return self._mouseButtons[mouseButton].pressed
end

-- Returns whether a mouse button was released on the current frame.
-- @param {number} mouseButton The numeric button to test (see Love docs).
-- @returns {boolean} Whether the mouse button was released.
function Engine:mouseReleased(mouseButton)
  return self._mouseButtons[mouseButton].released
end

-- Returns whether a mouse button is being held down.
-- @param {number} mouseButton The numeric button to test (see Love docs).
-- @returns {boolean} Whether the mouse button is beind held.
function Engine:mouseHeld(mouseButton)
  return self._mouseButtons[mouseButton].held
end

-- Updates internal mouse values for correctly mapping mouse positions.
-- @param {number} x The X coordinate of the mouse cursor.
-- @param {number} y The Y coordinate of the mouse cursor.
function Engine:sys_mousemoved(x, y)
  self._mousePositions.localX = math.floor(x / self._gfxScale)
  self._mousePositions.localY = math.floor(y / self._gfxScale)
end

-- Sets raw mouse states for button presses.
-- @param {number} button The numeric mouse button (see Love docs).
function Engine:sys_mousepressed(button)
  self._mouseStates[button] = true
end

-- Sets raw mouse states for button releases.
-- @param {number} button The numeric mouse button (see Love docs).
function Engine:sys_mousereleased(button)
  self._mouseStates[button] = false
end

-- -----------------------------------------------------------------------------
-- Methods for handling keyboard and game controller input
-- -----------------------------------------------------------------------------

-- Creates an Input Handler object to let a player interact with the game.
-- @returns {InputHandler} A new instance of the InputHandler class.
function Engine:addInputHandler()
  local handler = MintCrate.InputHandler:new()
  table.insert(self._inputHandlers, handler)
  return handler
end

-- Returns whether a keybaord key was pressed on the current frame.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
-- @returns {boolean} Whether the key was pressed.
function Engine:keyPressed(scancode)
  scancode = tostring(scancode)
  return (self._keystates[scancode] and self._keystates[scancode].pressed)
end

-- Returns whether a keybaord key was released on the current frame.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
-- @returns {boolean} Whether the key was released.
function Engine:keyReleased(scancode)
  scancode = tostring(scancode)
  return (self._keystates[scancode] and self._keystates[scancode].released)
end

-- Returns whether a keybaord key is being held down.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
-- @returns {boolean} Whether the key is being held.
function Engine:keyHeld(scancode)
  scancode = tostring(scancode)
  return (self._keystates[scancode] and self._keystates[scancode].held)
end

-- Sets raw keyboard states for key presses.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
function Engine:sys_keypressed(scancode)
  if not self._keystates[scancode] then
    self._keystates[scancode] = {pressed=false, released=false, held=false}
  end
  self._keystates[scancode].pressed = true
  self._keystates[scancode].held = true
end

-- Sets raw keyboard states for key releases.
-- @param {string} scancode The scancode of the keyboard input (see Love docs).
function Engine:sys_keyreleased(scancode)
  if not self._keystates[scancode] then
    self._keystates[scancode] = {pressed=false, released=false, held=false}
  end
  self._keystates[scancode].released = true
  self._keystates[scancode].held = false
end

-- Sets raw gamepad states for gamepad button presses.
-- @param {Joystick} joystick The physical device on which a button was pressed.
-- @param {number} button The joystick button that was pressed (see Love docs).
function Engine:sys_gamepadpressed(joystick, button)
  local joystickId = joystick:getID()
  if not self._joystates[joystickId] then self._joystates[joystickId] = {} end
  self._joystates[joystickId][button] = true
end

-- Sets raw gamepad states for gamepad button releases.
-- @param {Joystick} joystick The physical device on which a button was pressed.
-- @param {number} button The joystick button that was pressed (see Love docs).
function Engine:sys_gamepadreleased(joystick, button)
  local joystickId = joystick:getID()
  if not self._joystates[joystickId] then self._joystates[joystickId] = {} end
  self._joystates[joystickId][button] = false
end

-- -----------------------------------------------------------------------------
-- Methods for handling audio
-- -----------------------------------------------------------------------------

-- Plays a sound resource.
-- @param {string} soundName Name of the sound resource (from defineSounds()).
function Engine:playSound(soundName)
  love.audio.stop(self._data.sounds[soundName])
  love.audio.play(self._data.sounds[soundName])
end

-- Stops any currently-playing sounds.
function Engine:stopAllSounds()
  for _, sound in ipairs(self._data.sounds) do
    love.audio.stop(sound)
  end
end

-- Sets a music resource to be the active music track.
-- @param {string} musicName Name of the music resource (from defineMusic()).
function Engine:setMusic(musicName)
  self._currentMusic = self._data.music[musicName]
end

-- Starts playback of the currently-set music track.
function Engine:playMusic()
  if (self._currentMusic) then
    love.audio.stop(self._currentMusic.source)
    love.audio.play(self._currentMusic.source)
  end
end

-- Pauses playback of the currently-set music track.
function Engine:pauseMusic()
  if (self._currentMusic) then love.audio.pause(self._currentMusic.source) end
end

-- Resumes playback of the currently-set music track.
function Engine:resumeMusic()
  if (self._currentMusic) then love.audio.resume(self._currentMusic.source) end
end

-- Stops playback of the currently-set music track.
function Engine:stopMusic()
  if (self._currentMusic) then love.audio.stop(self._currentMusic.source) end
end

-- -----------------------------------------------------------------------------
-- Methods for displaying debug data overlays in the game
-- -----------------------------------------------------------------------------

-- Toggles an overlay that shows the current frames-per-second rate.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showFps(enabled)
  if type(enabled) == "nil" then
    self._showFps = not self._showFps
  else
    self._showFps = enabled
  end
end

-- Toggles an overlay that shows information regarding the current room.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showRoomInfo(enabled)
  if type(enabled) == "nil" then
    self._showRoomInfo = not self._showRoomInfo
  else
    self._showRoomInfo = enabled
  end
end

-- Toggles an overlay that displays collision masks for tilemaps.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showTilemapCollisionMasks(enabled)
  if type(enabled) == "nil" then
    self._showTilemapCollisionMasks = not self._showTilemapCollisionMasks
  else
    self._showTilemapCollisionMasks = enabled
  end
end

-- Toggles an overlay that displays behavior value numbers for tilemaps.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showTilemapBehaviorValues(enabled)
  if type(enabled) == "nil" then
    self._showTilemapBehaviorValues = not self._showTilemapBehaviorValues
  else
    self._showTilemapBehaviorValues = enabled
  end
end

-- Toggles an overlay that displays collision masks for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showActiveCollisionMasks(enabled)
  if type(enabled) == "nil" then
    self._showActiveCollisionMasks = not self._showActiveCollisionMasks
  else
    self._showActiveCollisionMasks = enabled
  end
end

-- Toggles an overlay that displays data for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showActiveInfo(enabled)
  if type(enabled) == "nil" then
    self._showActiveInfo = not self._showActiveInfo
  else
    self._showActiveInfo = enabled
  end
end

-- Toggles an overlay that visualizes the origin point for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showOriginPoints(enabled)
  if type(enabled) == "nil" then
    self._showActiveOriginPoints = not self._showActiveOriginPoints
  else
    self._showActiveOriginPoints = enabled
  end
end

-- Toggles an overlay that visualizes the action point for Active instances.
-- @param {boolean} enabled Whether the overlay should be shown or not.
function Engine:showActionPoints(enabled)
  if type(enabled) == "nil" then
    self._showActiveActionPoints = not self._showActiveActionPoints
  else
    self._showActiveActionPoints = enabled
  end
end

-- Toggles all debug overlays.
-- @param {boolean} enabled Whether the overlays should be shown or not.
function Engine:showAllDebugOverlays(enabled)
  self:showFps(enabled)
  self:showRoomInfo(enabled)
  self:showTilemapCollisionMasks(enabled)
  self:showTilemapBehaviorValues(enabled)
  self:showActiveCollisionMasks(enabled)
  self:showActiveInfo(enabled)
  self:showOriginPoints(enabled)
  self:showActionPoints(enabled)
end

-- -----------------------------------------------------------------------------

return Engine