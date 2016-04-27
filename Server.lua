--[[

      RedWeb server
      by DvgCraft

      Wireless modem required

      VERSION 1.0
      LONG V  0.9.11
      DATE    27-04-2016

]]--

-- Variables
local tArgs = {...}
local running = true

local serverPath = "/server.cfg"
local usage = "Usage:\nRedWebServer"
local c = {
  bg = colors.white,
  txt = colors.black,
  sBg = term.isColor() and colors.pink or (_CC_VERSION and colors.lightGray or colors.black),
  sTxt = term.isColor() and colors.lightGray or (_CC_VERSION and colors.lightGray or colors.black),
  btnBg = term.isColor() and colors.red or colors.black,
  btnTxt = colors.white,
}
local headeropt = {
  bgcolor = term.isColor() and colors.red or colors.black,
  size = 3,
  btns = {
    top = { "Servers", "Log", "Register" },
    bgcolor = term.isColor() and colors.red or colors.black,
    txtcolor = colors.white,
  }
}

local domains = {}
local tab = 1
local btns = {}
local log = {}
local inputting = false
local input = { "", "", "", "" }
local registerSuccess = ""

local w, h = term.getSize()

-- API Functions
local function inAny( checkIn, checkFor ) -- *Modified* from dvg API (github.com/Dantevg/DvgApps)
  if checkIn == nil or type( checkIn ) ~= "table" or checkFor == nil then
    error("Expected table, value")
  end
  for k, v in pairs( checkIn ) do
    if k == checkFor then return k end
  end --End for loop
  return false
end

local function header( text, opt ) -- From dvgapps API v0.9.17.20 (github.com/Dantevg/DvgApps)
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

local function read( input, exitEvent, exitParam, exitVal ) -- From dvg API (github.com/Dantevg/DvgApps)
  if ( input and type(input) ~= "string" ) or ( exitEvent and type( exitEvent ) ~= "string" ) or (exitParam and (type(exitParam)~="number" or exitParam>5) ) then
    error( "Expected [string input [,string exitEvent [,number exitParam, any exitVal]]" )
  end -- Input: string,  exitEvent: string,  exitParam: number < 6,  exitVal: any

  local input = input or ""
  while true do
    local p = {os.pullEvent()}
    local event = p[1]
    table.remove( p, 1 )

    if event == "key" then
      if exitEvent == "key" and (not exitParam or p[exitParam] == exitVal) then
        return input, false, false
      else
        if p[1] == keys.backspace then
          return input:sub( 1,-2 ), false, true
        elseif p[1] == keys.enter then
          return input, true, false
        end
      end -- End if exitEvent

    elseif event == "char" then
      if exitEvent == "char" then
        if not exitParam or p[exitParam] == exitVal then return input, false, false end
      else
        return input..p[1], false, true
      end

    elseif event == exitEvent then
      if not exitParam or p[exitParam] == exitVal then return input, false, false end

    end -- End if event
  end -- End while true
end

local function fill( text, to, char ) -- From dvg API (github.com/Dantevg/DvgApps)
  if type( text ) ~= "string" or type( to ) ~= "number" then
    error( "Expected string, number [,string]" )
  end
  if char and type( char ) ~= "string" then
    error( "Expected string, number [,string]" )
  end
  while #text <= to do
    if char then
      text = text..char
    else
      text = text.." "
    end
  end
  return text
end

local function center( text, y ) -- From dvg API (github.com/Dantevg/DvgApps)
  local curX, curY = term.getCursorPos()
  local w, _ = term.getSize()
  x = math.ceil( ( w/2 ) - ( string.len(text)/2 ) + 1 )
  term.setCursorPos( x, y and y or curY )
  write( text )
  term.setCursorPos( curX,curY )
end

-- UI Functions
function drawInterface()
  term.setBackgroundColor( c.bg )
  term.clear()
  btns = header( "RedWeb Server", headeropt )

  term.setBackgroundColor( c.btnBg )
  term.setTextColor( c.btnTxt )
  for i = 1, 3 do
    term.setCursorPos( w-6, h-4+i )
    if i == 2 then print( "  +  " ) else print( "     " ) end
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
  term.setBackgroundColor( c.bg )
  term.setTextColor( c.txt )
  term.setCursorPos( btns.top[1].s, 1 )
  print( "         ")
  term.setCursorPos( btns.top[1].s, 2 )
  print( " Servers " )
  term.setCursorPos( btns.top[1].s, 3 )
  print( "         ")

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
  term.setBackgroundColor( c.bg )
  term.setTextColor( c.txt )
  term.setCursorPos( btns.top[2].s, 1 )
  print( "     ")
  term.setCursorPos( btns.top[2].s, 2 )
  print( " Log " )
  term.setCursorPos( btns.top[2].s, 3 )
  print( "     ")

  term.setCursorPos( 1,5 )
  term.setBackgroundColor( c.bg )
  term.setTextColor( c.txt )
  for i = 1, #log do
    print( " "..log[i] )
  end
end

function printRegister()
  term.setBackgroundColor( c.bg )
  term.setTextColor( c.txt )
  term.setCursorPos( btns.top[3].s, 1 )
  print( "          ")
  term.setCursorPos( btns.top[3].s, 2 )
  print( " Register " )
  term.setCursorPos( btns.top[3].s, 3 )
  print( "          ")

  term.setCursorPos( 2,5 )
  term.setBackgroundColor( c.bg )
  term.setTextColor( c.txt )

  term.setCursorPos( 2,5 )
  print( "Domain name:" )
  term.setBackgroundColor( c.sBg )
  term.setCursorPos( 2,6 )
  print( " "..fill( input[1], 35 ) )

  term.setBackgroundColor( c.bg )
  term.setCursorPos( 2,9 )
  print( "Base folder path:" )
  term.setBackgroundColor( c.sBg )
  term.setCursorPos( 2,10 )
  print( "/"..fill( input[2], 35 ) )

  term.setBackgroundColor( c.bg )
  term.setCursorPos( 2,13 )
  print( "Company name:" )
  term.setBackgroundColor( c.sBg )
  term.setCursorPos( 2,14 )
  print( " "..fill( input[3], 35 ) )

  term.setBackgroundColor( c.bg )
  term.setCursorPos( 2,17 )
  print( "Additional info file:" )
  term.setBackgroundColor( c.sBg )
  term.setCursorPos( 2,18 )
  print( "/"..fill( input[4], 35 ) )
end

function notify( txt )
  term.setCursorPos( 1, 8 )
  term.setBackgroundColor( c.btnBg )
  term.setTextColor( c.btnTxt )
  print( string.rep( " ", w ) )
  print( string.rep( " ", w ) )
  print( string.rep( " ", w ) )
  print( string.rep( " ", w ) )
  print( string.rep( " ", w ) )
  center( txt, 10 )
end

-- Operating Functions
function register()
  term.setCursorBlink( true )
  inputting = (y-2) / 4
  while true do
    term.setCursorPos( 2, y )
    term.setBackgroundColor( c.sBg )
    if inputting == 2 or inputting == 4 then
      print( "/"..fill( input[inputting], 35 ) )
    else
      print( " "..fill( input[inputting], 35 ) )
    end
    term.setCursorPos( 3+#input[inputting], y )
    input[inputting], confirm, continue = read( input[inputting], "mouse_click" )
    if not continue then
      term.setCursorBlink( false )
      break
    end
  end
end

function sendRegister()
  if input[1] == "" or input[2] == "" or input[3] == "" then return end
  local info = ""
  if input[4] ~= "" then
    if not fs.exists( input[4] ) then error( "Additional info file does not exist" ) end
    local file = fs.open( input[4], "r" )
    info = file.readAll()
    file.close()
  end
  rednet.broadcast( {domain=input[1], company=input[3], info = info}, "DVG_REDWEB_IDS_REGISTER_REQUEST" )
  local ID, msg = rednet.receive( "DVG_REDWEB_IDS_REGISTER_ANSWER", 1 )
  if not msg then
    error( "Could not connect to IDS" )
  elseif type( msg ) == "string" then
    error( msg )
  else
    domains[input[1]] = input[2]
    local file = fs.open( serverPath, "w" )
    file.write( textutils.serialize( domains ) )
    file.close()
    notify( "Registered "..input[1].." in folder "..input[2] )
    os.pullevent()
  end
end
function sendRemove( name )
  notify( "Delete "..name.."? y/n" )
  term.setBackgroundColor( c.bg )
  local _, char = os.pullEvent( "char" )
  if char:lower() == "y" then
    rednet.broadcast( name, "DVG_REDWEB_IDS_REMOVE_REQUEST" )
    local ID, msg = rednet.receive( "DVG_REDWEB_IDS_REMOVE_ANSWER", 1 )
    if not msg then
      error( "Could not connect to IDS" )
    elseif type( msg ) == "string" then
      error( msg )
    else
      local path = domains[name]
      domains[name] = nil
      local file = fs.open( serverPath, "w" )
      file.write( textutils.serialize( domains ) )
      file.close()
      notify( "Removed "..name.." from folder "..path )
      os.pullEvent()
    end
  end
end

function webpage( info )
  if not info.path or info.path == "" then info.path = "index" end

  if not fs.exists( domains[info.domain].."/"..info.path ) then --Does not exist
    local _,_, ext = string.find( info.path, "%w+(%.+%w+)" )
    if ext ~= nil and ext ~= "" then
      if fs.exists( domains[info.domain].."/"..info.path..".lua" ) then
        info.path = "index.lua"
      else
        rednet.send( info.ID, "ERR URL not found", "DVG_REDWEB_WEBSITE_ANSWER" )
        table.insert( log, "LOG  URL not found" )
      end
    else
      rednet.send( info.ID, "ERR URL not found", "DVG_REDWEB_WEBSITE_ANSWER" )
      table.insert( log, "LOG  URL not found" )
    end

  else --Return webpage
    local file = fs.open( domains[info.domain].."/"..info.path, "r" )
    rednet.send( info.ID, file.readAll(), "DVG_REDWEB_WEBSITE_ANSWER" )
    table.insert( log, "LOG  Sent "..info.domain.."/"..info.path.." to ID "..info.ID )
    file.close()
  end
end

-- Handling Functions
function handleMsg( msg )
  _,_, msg.domain, msg.path = msg.url:find( "([^/]+)([^%?]*)" ) -- doma.in / path/to/file
  table.insert(  log, "LOG  Got request for ".. msg.domain ..( msg.path and "/".. msg.path or "" )  )

  if not inAny( domains, msg.domain ) then
    rednet.send( msg.ID, "ERR Domain not registered", "DVG_REDWEB_WEBSITE_ANSWER" )
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

  elseif y >= h-5 and y <= h-1 and x <= w-2 and x >= w-6 then -- Button pressed
    if tab == 3 then
      sendRegister()
    else
      tab = 3
    end

  elseif tab == 3 then -- Registering
    if x >= 2 and x <= 41 and y == 6 or y == 10 or y == 14 or y == 18 then
      register()
    else
      term.setCursorBlink( false )
      inputting = false
    end

  elseif tab == 1 then -- Server list
    local i = 1
    for k, v in pairs( domains ) do
      if y == 4 + i then
        sendRemove( k )
        break
      end
      i = i + 1
    end -- End for

  end -- End if
end

-- Run
local file = fs.open( assert( fs.exists(serverPath) and serverPath or false, "No such server.cfg file: "..serverPath ), "r" )
domains = assert( textutils.unserialize( assert(file.readAll(),"Could not read server.cfg") ), "Corrupt server.cfg" )
file.close()

table.insert( log, "LOG  Starting server" )

while running do
  drawInterface()
  event, id, x, y = os.pullEvent()

  if event == "mouse_click" then
    handleClick( x, y )
  elseif event == "rednet_message" and y == "DVG_REDWEB_WEBSITE_REQUEST" then
    handleMsg( x )
  end
end --End while

term.setBackgroundColor( colors.black )
term.setTextColor( colors.white )
term.clear()
term.setCursorPos( 1,1 )
