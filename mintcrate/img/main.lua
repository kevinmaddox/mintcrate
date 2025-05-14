--[[

  This script encodes the MintCrate system image files into Base64 strings,
  which are then stored in Lua files. They are then referenced, loaded, and
  decoded by the engine during initialization.
  
  The impetus for storing them as Lua files is so that they can be loaded via
  the require() function. This is done so that MintCrate can be stored in a
  directory outside of the game directory, as love.image.newImageData() cannot
  access files outside of said directory.
  
  Truthfully, you shouldn't be doing such a thing, anyway. I did this purely so
  that the example files can reference the library correctly. Regardless, that's
  what's going on here.
  
  Because this is a Love application, you should traverse up a directory and run
  this script as such:
  
  love img
  
  This script should never have to be run unless the images are modified for
  whatever reason, which likely will never happen.

--]]

-- Name, width, height
images = {
  {"point_action",   "png"},
  {"point_origin",   "png"},
  {"system_boot",    "png"},
  {"system_counter", "png"},
  {"system_dialog",  "png"}
}

function love.load()
  local encodedPath = "encoded/"
  
  for _, image in ipairs(images) do
    local imgData = love.image.newImageData(image[1].."."..image[2])
    local imgFile = imgData:encode("png")
    local imgString = imgFile:getString()
    local imgB64 = love.data.encode("string", "base64", imgString)
    
    local file = io.open("img/"..encodedPath..image[1]..".lua", "w")
    file:write("return \"" .. imgB64 .. "\"")
    file:close()
  end

  print("Done.")
  love.event.quit()
end