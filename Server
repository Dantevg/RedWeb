--[[

      RedWeb server
      by DvgCraft

      Wireless modem required

      VERSION 1.0
      LONG V  0.9.7 (client 0.9.6, IDS 0.9.5)
      DATE    16-03-2016

]]--

-- Variables
local tArgs = {...}
local running = true

local serverPath = "/server.cfg"
local usage = "Usage:\nRedWebServer [-nostart]"
local c = {
  bg = colors.white,
  sBg = colors.pink,
  txt = colors.black,
  sTxt = colors.lightGray,
}
local headeropt = {
  bgcolor = term.isColor() and colors.red or colors.black,
  size = 3,
  btns = {
    top = { "Servers", "Log", "Register" },
    bgcolor = colors.white,
    txtcolor = colors.black,
  }
}

local domains = {}
local tab = 1
local btns = {}
local log = {}
local serverRunning = false
local inputting = false
local input = { [7] = "", [12] = "", [17] = "" }

local w, h = term.getSize()

-- Functions
function inAny( checkIn, checkFor ) -- *Modified* from Dvg API (github.com/Dantevg/DvgApps)
  if checkIn == nil or type( checkIn ) ~= "table" or checkFor == nil then
    error("Expected table, value")
  end
  for k, v in pairs( checkIn ) do
    if k == checkFor then return k end
  end --End for loop
  return false
end

function header( text, opt ) -- From dvgapps API v0.9.17.20 (github.com/Dantevg/DvgApps)
  if type( text ) ~= "string" or type( opt ) ~= "table" then
    error( "Expected string, table" )
  end

  local w = term.getSize()
  term.setCursorPos( 1,1 )
  term.setBackgroundColor( opt.bgcolor and opt.bgcolor or colors.blue )
  term.setTextColor( opt.txtcolor and opt.txtcolor or colors.white )

  if not opt.size then opt.size = 1 end
  for i = 1, opt.size do
    print( string.rep(" ",w) )
  end
  if opt.size == 1 then
    term.setCursorPos( 1,1 )
  else
    term.setCursorPos( 1,2 )
  end
  if opt.action then
    write( "  "..opt.action.." "..text )
  else
    write( "  x "..text )
  end

  if opt.btns then
    local btnsPos = { top = {}, bottom = {} }
    term.setBackgroundColor( opt.btns.bgcolor and opt.btns.bgcolor or colors.lightBlue )
    term.setTextColor( opt.btns.txtcolor and opt.btns.txtcolor or colors.white )

    local function printBtns( place )
      local pos = w + 1
      if place == "bottom" then pos = 2 end
      for i = 1, #opt.btns[place] do
        if type( opt.btns[place][i] ) ~= "number" then
          if place ~= "bottom" then
            pos = pos - #opt.btns[place][i] - 3
          end
          if opt.size == 1 then
            term.setCursorPos( pos, 1 )
          elseif place == "top" then
            term.setCursorPos( pos, 2 )
          elseif place == "bottom" then
            term.setCursorPos( pos, 4 )
          end
          write( " "..opt.btns[place][i].." " )
          btnsPos[place][i] = {}
          btnsPos[place][i].s, btnsPos[place][i].e = pos, pos + #opt.btns[place][i] + 2
          if place == "bottom" then
            pos = pos + #opt.btns[place][i] + 3
          end
        else
          if place == "bottom" then
            pos = pos + opt.btns[place][i] - 1
          else
            pos = pos - opt.btns[place][i] + 1
          end
        end -- End if type
      end -- End for loop
    end -- End function

    if opt.btns.top then printBtns( "top" ) end
    if opt.size == 5 and opt.btns.bottom then printBtns( "bottom" ) end

    return btnsPos
  end -- End if opt.btns
end

function drawInterface()
  term.setBackgroundColor( c.bg )
  term.clear()
  btns = header( "RedWeb Server", headeropt )

  term.setBackgroundColor( colors.gray )
  term.setTextColor( colors.white )
  for i = 1, 3 do
    term.setCursorPos( w-8, h-4+i )
    if i == 2 then print( " START " ) else print( "       " ) end
  end

  if tab == 1 then
    printServers()
  elseif tab == 2 then
    printLog()
  elseif tab == 3 then
    printRegister()
  end
end

function printServers()
  term.setCursorPos( btns.top[1].s, 2 )
  term.setBackgroundColor( c.sBg )
  term.setTextColor( c.txt )
  print( " Servers " )

  term.setBackgroundColor( c.bg )
  term.setCursorPos( 1,5 )
  for var, val in pairs( domains ) do
    term.setTextColor( c.txt )
    write( " "..var )
    term.setTextColor( c.sTxt )
    print( " "..val )
  end
end

function printLog()
  term.setCursorPos( btns.top[2].s, 2 )
  term.setBackgroundColor( c.sBg )
  term.setTextColor( c.txt )
  print( " Log " )

  term.setCursorPos( 1,5 )
  term.setBackgroundColor( c.bg )
  term.setTextColor( c.txt )
  for i = 1, #log do
    print( " "..log[i] )
  end
end

function printRegister()
  term.setCursorPos( btns.top[3].s, 2 )
  term.setBackgroundColor( c.sBg )
  term.setTextColor( c.txt )
  print( " Register " )

  term.setCursorPos( 2,5 )
  term.setBackgroundColor( c.bg )
  term.setTextColor( c.txt )

  term.setCursorPos( 2,5 )
  print( "Domain name:" )
  term.setBackgroundColor( c.sBg )
  term.setCursorPos( 2,7 )
  print( "                                        " )

  term.setBackgroundColor( c.bg )
  term.setCursorPos( 2,10 )
  print( "Base folder path:" )
  term.setBackgroundColor( c.sBg )
  term.setCursorPos( 2,12 )
  print( "/                                       " )

  term.setBackgroundColor( c.bg )
  term.setCursorPos( 2,15 )
  print( "Company name:" )
  term.setBackgroundColor( c.sBg )
  term.setCursorPos( 2,17 )
  print( "                                        " )
end

function register()
  rednet.send( IDS, domain, "DVG_REDWEB_IDS_REGISTER_REQUEST" )
  local ID, msg = rednet.receive( "DVG_REDWEB_IDS_REGISTER_ANSWER", 1 )
  if not msg then
    error( "Could not connect to IDS" )
  elseif type( msg ) == "string" then
      error( msg )
  else
    domains[domain] = folder
    local file = fs.open( serverPath, "w" )
    file.write( domains )
    file.close()
    print( "Successfully registered "..domain.." with base folder "..folder )
  end
end

function webpage( info )
  if not info.path or info.path == "" then info.path = "index" end

  if not fs.exists( domains[info.domain].."/"..info.path ) then --Does not exist
    local _,_, ext = string.find( info.path, "%w+(%.+%w+)" )
    if ext ~= nil and ext ~= "" then
      if fs.exists( domains[info.domain].."/"..info.path..".lua" ) then
        info.path = "index.lua"
      end
    end
    rednet.send( info.ID, "ERR URL not found", "DVG_REDWEB_WEBSITE_ANSWER" )
    table.insert( log, "LOG  URL not found" )
  else --Return webpage
    local file = fs.open( domains[info.domain].."/"..info.path, "r" )
    rednet.send( info.ID, file.readAll(), "DVG_REDWEB_WEBSITE_ANSWER" )
    table.insert( log, "LOG  Sent "..info.domain.."/"..info.path.." to ID "..info.ID )
  end
end

function handleMsg( msg )
  if not serverRunning then return end
  _,_, msg.domain, msg.path = msg.url:find( "([^/]+)([^%?]*)" ) -- doma.in / path/to/file
  table.insert(  log, "LOG  Got request for ".. msg.domain ..( msg.path and "/".. msg.path or "" )  )

  if not inAny( domains, msg.domain ) then
    rednet.send( msg.ID, " ERR Domain not registered", "DVG_REDWEB_WEBSITE_ANSWER" )
    table.insert( log, "ERR  Domain not registered" )
  elseif not fs.isDir( domains[msg.domain] ) then
    rednet.send( msg.ID, "ERR Error with server configuration", "DVG_REDWEB_WEBSITE_ANSWER" )
    table.insert( log, "ERR  Could not find folder for domain: "..msg.domain )
  else
    webpage( msg )
  end --End if
end

function handleClick( x, y )
  if y == 2 then -- Header
    if x >= 1 and x <= 4 then -- "x" pressed
      running = false return nil
    else
      for i = 1, #btns.top do
        if x >= btns.top[i].s and x <= btns.top[i].e then tab = i break end
      end
    end -- End if x

  elseif y >= h-5 and y <= h-1 and x >= w-8 and x <= w-1 and not serverRunning then -- Start button
    serverRunning = true
    table.insert( log, "LOG  Server running" )

  elseif tab == 3 then -- Registering
    if x >= 2 and x <= 41 and y == 7 or y == 12 or y == 17 then
      term.setCursorPos( 3, y )
      term.setCursorBlink( true )
      inputting = y
    else
      term.setCursorBlink( false )
      inputting = false
    end

  end -- End if
end

function handleKey( key )
  if key == keys.backspace then
    input[inputting] = string.sub( input[inputting], 1, -1 )
  else
    input[inputting] = input[inputting]..keys.getName( key )
  end
end

-- Run
local file = fs.open( assert( fs.exists(serverPath) and serverPath or false, "No such server.cfg file: "..serverPath ), "r" )
domains = assert( textutils.unserialize( assert(file.readAll(),"Could not read server.cfg") ), "Corrupt server.cfg" )
file.close()

if tArgs[1] ~= "-nostart" then
  serverRunning = true
  table.insert( log, "LOG  Server running" )
end

while running do
  drawInterface()
  event, id, x, y = os.pullEvent()

  if event == "mouse_click" then
    handleClick( x, y )
  elseif event == "rednet_message" then
    if y == "DVG_REDWEB_WEBSITE_REQUEST" then handleMsg( x ) end
  elseif event == "key" and inputting then
    handleKey( id )
  end
end --End while

term.setBackgroundColor( colors.black )
term.setTextColor( colors.white )
term.clear()
term.setCursorPos( 1,1 )
