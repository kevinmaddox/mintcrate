package.path = package.path .. "../?.lua"
require("mintcrate.loader")

require("rooms.splash")
require("rooms.title")
require("rooms.game")

require("objects.button")
require("objects.physicsobject")

-- Initialization --------------------------------------------------------------

function love.load()
  mint = MintCrate:new(
    240, 160,
    -- Splash,
    -- Title,
    Game,
    {
      windowScale = 2,
      windowTitle = "MintCrate Example - Azure Flight",
      pathPrefix = "../../"
      -- icon = "icon.png"
    }
  )
  
  mint:init()
  
  mint:defineColorKeys({
    {r =  134, g = 171, b = 125},
    {r =   88, g = 138, b = 103},
  })
  
  -- Inputs
  input = mint:addInputHandler()
  input:setJoystickNumber(1)
  input:mapKeyboardInput('fire1', 'x')
  
  -- Actives
  mint:defineActives({
    -- 64px Button
    {name = 'button-64'},
    {name = 'button-64_collider', width = 64, height = 24},
    {name = 'button-64_active-up'},
    {name = 'button-64_active-down'},
    {name = 'button-64_inactive-up'},
    {name = 'button-64_inactive-down'},
    
    -- 128px Button
    {name = 'button-128'},
    {name = 'button-128_collider', width = 128, height = 24},
    {name = 'button-128_active-up'},
    {name = 'button-128_active-down'},
    
    -- Danger!! icons
    {name = 'danger-down'},
    {name = 'danger-down_default'},
    {name = 'danger-up'},
    {name = 'danger-up_default'},
    
    -- Harpy
    {name = 'harpy'},
    -- {name = 'harpy_collider'},
    {name = 'harpy_default'},
    {name = 'harpy_fall'},
    {name = 'harpy_flap', frameCount = 6, frameDuration = 2, offset = {-1, 0}},
    {name = 'harpy_hit01'},
    {name = 'harpy_hit02'},
    {name = 'harpy_hit03'},
    {name = 'harpy_hit04'},
    {name = 'harpy_hit05'},
    
    -- Platform posts
    {name = 'post-top'},
    {name = 'post-top_default'},
    {name = 'post-pole'},
    {name = 'post-pole_default'},
    
    -- Rocks
    {name = 'rock'},
    {name = 'rock_default'}
  })
  
  -- Backdrops
  mint:defineBackdrops({
    {name = 'harpy'},
    {name = 'menu-bg', mosaic = true},
    {name = 'logo'},
    {name = 'logo-shadow'},
    {name = 'mountains'},
    {name = 'ready'}
  })
  
  -- Fonts
  mint:defineFonts({
    {name = 'ui-main'},
    {name = 'ui-main-inactive'}
  })
  
  -- Music
  mint:defineMusic({
    -- {name = 'select-your-whatever-ex'},
    {name = 'tangent'}
  })
  
  -- Sounds
  mint:defineSounds({
    {name = 'button-down'},
    {name = 'button-up'},
    {name = 'flap'}
  })
  
  -- Global vars
  globals = {
    enteringFromSplashScreen = true,
    musicOn = true,
    sfxOn = true
  }
  
  -- Loading complete
  mint:ready()
end

-- Game loop & render ----------------------------------------------------------

function love.update()
  -- Debug controls
  if mint:keyPressed("d") then mint:showAllDebugOverlays() end
  for i=1, 4 do if mint:keyPressed(i) then mint:setWindowScale(i) end end
  if mint:keyPressed('f') then mint:setFullscreen(not mint:getFullscreen()) end
  if mint:keyPressed('escape') then mint:quit() end
  
  mint:sys_update()
end

function love.draw()
  mint:sys_draw()
end

-- Forward system events to MintCrate ------------------------------------------

function love.resize(w, h)
  mint:sys_resize(w, h)
end

function love.keypressed(key, scancode, isrepeat)
  mint:sys_keypressed(scancode)
end

function love.keyreleased(key, scancode)
  mint:sys_keyreleased(scancode)
end

function love.gamepadpressed(joystick, button)
  mint:sys_gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
  mint:sys_gamepadreleased(joystick, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
  mint:sys_mousemoved(x, y)
end

function love.mousepressed(x, y, button, istouch, presses)
  mint:sys_mousepressed(button)
end

function love.mousereleased(x, y, button, istouch, presses)
  mint:sys_mousereleased(button)
end