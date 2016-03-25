--[[

      RedWeb browser
      by DvgCraft

      Wireless modem and server required

      VERSION 1.0
      LONG V  0.9.8 (server 0.9.7, IDS 0.9.5)
      DATE    24-03-2016

      Protocols:
      - redweb://
      - web://
      - app://

--]]

-- Variables
local arg = {...}
local path = "/.DvgFiles/data/RedWeb"
local running = true

local c = {
  mainbg = colors.red,
  maintxt = colors.white,
  errortxt = colors.red,
  inputbg = colors.white,
  inputtxt = colors.black,
  sinputtxt = colors.lightGray,
}
local s = {}
local IDS = 0
local webServer = 0

local error = nil

local protocol = "redweb"
local url = "home"
local args = ""
local webpage = ""

local returnVal = {}

-- Functions
function separate( url )
  _, _, protocol, url = string.find( url, "(%a+)://(.+)" ) -- protocol :// url
  if not url then
    protocol, _, _, url = "web", string.find( url, "(.+)" )
  end
end

function mainInterface()
  term.setTextColor( c.maintxt )
  dvg.bg( c.mainbg )
  dvg.center( "RedWeb browser", 7 )
  dvg.center( "EXIT     SETTINGS", 14 )
  dvg.center( "While in webpage view, press "..s.exitKey.val.." to exit", 19 )

  term.setBackgroundColor( c.inputbg )
  dvg.center( "                                         ", 10 )

  term.setCursorPos( 7,10 )
  term.setBackgroundColor( c.inputbg )
  term.setTextColor( c.sinputtxt )
  write( protocol and protocol.."://" )
  term.setTextColor( c.inputtxt )
  write( url and url )

  if error then
    term.setTextColor( c.errortxt )
    dvg.center( " "..error.." ", 17 )
  end
  error = nil
end

function getWebpage()
  if protocol ~= "redweb" and protocol ~= "web" and protocol ~= "app" then
    return "Invalid protocol. (redweb, web, app)"
  end

  if protocol == "redweb" then

    if url == "home" then
      return "" -- run itself redweb://home
    elseif url == "settings" then
      shell.run( path.."/settings" )
      return ""
    end

  elseif protocol == "web" then

    rednet.broadcast( url, "DVG_REDWEB_IDS_REQUEST" )
    local ID, webServer = rednet.receive( "DVG_REDWEB_IDS_ANSWER", 1 )
    if not webServer then
      return "ID server offline"
    elseif type( webServer ) == "string" then
      return webServer
    end

    rednet.send( webServer, {ID=os.getComputerID(), url=url}, "DVG_REDWEB_WEBSITE_REQUEST" )
    _, webpage = rednet.receive( "DVG_REDWEB_WEBSITE_ANSWER", 1 )
    if not webpage then
      return "Webserver offline"
    elseif type( webpage ) == "string" and webpage:sub( 1,3 ) == "ERR" then
      return webpage
    end

  elseif protocol == "app" then

    local _,_, app, path = url:find( "([^/]+)([^%?]*)" ) -- doma.in / path/to/file
    if fs.isDir( "/.DvgFiles/data/"..app ) then
      if path and path ~= "" then -- No path specified
        if fs.exists( "/.DvgFiles/data/"..app.."/"..app ) then -- /data/{name}/{name}
          shell.run( "/.DvgFiles/data/"..app.."/"..app )
        elseif fs.exists( "/.DvgFiles/data/"..app.."/run" ) then -- /data/{name}/run
          shell.run( "/.DvgFiles/data/"..app.."/run" )
        end
      else -- Path specified
        if fs.exists( "/.DvgFiles/data/"..app.."/"..path ) then
          shell.run( "/.DvgFiles/data/"..app.."/"..path )
        end
      end
    end

  end --End if protocol
end

function doWebpage()
  error = getWebpage()
  if error then return end

  fWebpage = loadstring( webpage )
  local function runWebpage()
    returnVal = {fWebpage()}
  end
  local function getExit()
    while true do
      local event, key = os.pullEvent( "key" )
      if key == keys[ s.exitKey.val ] then
        break
      end
    end
  end
  parallel.waitForAny( getExit, runWebpage )
end

-- Run
for i = 1, #dvg.sides do -- Open modems on all sides
  rednet.open( sides[i] )
end

local file = fs.open( path.."/settings.cfg", "r" )
s = textutils.unserialize( file.readAll() )
file.close()

if #arg > 0 then
  separate( arg[1] )
  doWebpage()
  return returnVal
end

while running do
  mainInterface()
  local event, button, x, y = os.pullEvent( "mouse_click" )
  if y == 14 then

    if x >= 18 and x <= 21 then
      running = false
      term.setBackgroundColor( colors.black )
      term.clear()
      term.setCursorPos( 1,1 )
    elseif x >= 27 and x <= 34 then
      shell.run( path.."/settings" )
    end

  elseif y == 10 and x >= 6 and x <= 46 then

    term.setCursorPos( 7,10 )
    dvg.printColor( protocol.."://"..url, c.sinputtxt )
    term.setCursorPos( 7,10 )
    term.setTextColor( c.inputtxt )
    input = read()
    separate( input )
    doWebpage()

  end
end
return returnVal
