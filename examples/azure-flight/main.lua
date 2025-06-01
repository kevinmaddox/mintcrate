package.path = package.path .. "../?.lua"
require("mintcrate.loader")
require("level")

-- Initialization --------------------------------------------------------------

function love.load()
  mint = MintCrate:new(
    320, 240,
    Level,
    {
      windowScale = 2,
      windowTitle = "MintCrate - Platformer Example",
      pathPrefix = "../../"
      -- icon = "icon.png"
    }
  )
  
  mint:init()
  
  mint:defineColorKeys({
    {r =  255, g = 0, b = 255},
  })
  
  -- Inputs
  input = mint:addInputHandler()
  input:setJoystickNumber(1)
  input:mapKeyboardInput('up',    'up')
  input:mapKeyboardInput('down',  'down')
  input:mapKeyboardInput('left',  'left')
  input:mapKeyboardInput('right', 'right')
  input:mapKeyboardInput('fire1', 'x')
  input:mapKeyboardInput('fire2', 'z')
  
  -- Actives
  mint:defineActives({
  
  })
  
  -- Backdrops
  mint:defineBackdrops({
    {name = 'mountains'},
  })
  
  -- Fonts
  -- mint:defineFonts({
    -- {name = 'pixel'}
  -- })
  
  -- Music
  -- mint:defineMusic({
    -- {name = 'select-your-whatever'},
    -- {name = 'spirit-blue'}
  -- })
  
  -- Sounds
  -- mint:defineSounds({
    -- {name = 'dkick'},
    -- {name = 'strongest'}
  -- })
  
  -- Loading complete
  mint:ready()
end

-- Game loop & render ----------------------------------------------------------

function love.update()
  -- Debug controls
  if mint:keyPressed("d") then mint:showAllDebugOverlays() end
  for i=1, 4 do if mint:keyPressed(i) then mint:setWindowScale(i) end end
  if mint:keyPressed('f') then mint:setFullscreen(not mint:getFullscreen()) end
  
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