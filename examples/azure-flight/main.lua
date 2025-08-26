package.path = package.path .. "../?.lua"
require("mintcrate.loader")

require("rooms.splash")
require("rooms.title")
require("rooms.game")

require("objects.button")
require("objects.physicsobject")
require("objects.watersplash")

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
      pathPrefix = "../../",
      windowIconPath = "icon.png"
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
    {name = 'harpy_collider', circle=true, radius=4},
    {name = 'harpy_default', offset = {-10, -8}},
    {name = 'harpy_fall', offset = {-10, -8}},
    {name = 'harpy_flap', frameCount = 6, frameDuration = 2, offset = {-11, -9}},
    {name = 'harpy_hit01', offset = {-10, -10}},
    {name = 'harpy_hit02', offset = {-10, -10}},
    {name = 'harpy_hit03', offset = {-10, -10}},
    {name = 'harpy_hit04', offset = {-10, -10}},
    {name = 'harpy_hit05', offset = {-10, -10}},
    
    -- Platform posts
    {name = 'post-top'},
    {name = 'post-top_default', offset={-14, -4}},
    {name = 'post-pole'},
    {name = 'post-pole_default', offset={-3, -8}},
    
    -- Boulders
    {name = 'boulder'},
    {name = 'boulder_collider', circle=true, radius=12},
    {name = 'boulder_default', offset={-12,-12}},
    
    -- Water line
    {name = 'water'},
    {name = 'water_default'},
    
    -- Water splash
    {name = 'splash'},
    {name = 'splash_default', offset = {-13, -30}},
    
    -- Water droplets
    {name='droplet'},
    {name='droplet_01', offset={-1,-2}},
    {name='droplet_02', offset={-1,-2}},
    {name='droplet_03', offset={-1,-2}},
    
    -- Stars
    {name='star'},
    {name='star_01', offset={-2,-2}},
    {name='star_02', offset={-4,-4}},
    {name='star_03', offset={-3,-3}},
    {name='star_04', offset={-5,-2}},
    
    -- Screen flash/dim overlays
    {name='overlay'},
    {name='overlay_white'},
    {name='overlay_black'},
    
    -- Shadow
    {name='shadow-top'},
    {name='shadow-top_default', offset={-10,-2}},
    {name='shadow-bottom'},
    {name='shadow-bottom_default', offset={-10,0}},
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
    {name = 'ui-main-inactive'},
    {name = 'ui-gold-numbers'},
    {name = 'title-high-score'}
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
    {name = 'flap'},
    {name = 'impact'},
    {name = 'impact-big'},
    {name = 'splash'},
    {name = 'splash-big'},
    {name = 'tread'}
  })
  
  -- Global vars
  globals = {
    enteringFromSplashScreen = true,
    musicOn = true,
    sfxOn = true
  }
  
  -- Load previously-saved high score
  local loadedData = mint:loadData('hiscore')
  globals.highScore = loadedData.highScore or 0
  
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