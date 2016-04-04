--[[

      RedWeb browser
      by DvgCraft

      Requirements:
      - Wireless modem
      - Advanced computer
      - IDS and webserver

      VERSION  0.9.10.1
      DATE     04-04-2016

      Protocols:
      - redweb://
      - app://
      - web://

]]--

-- Variables
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

local error = ""
local protocol = ""
local url = ""
local goto = ""

-- Functions
function mainInterface()
  term.setTextColor( c.maintxt )
  dvg.bg( c.mainbg )
  dvg.center( "RedWeb browser", 7 )
  dvg.center( "EXIT     SETTINGS", 14 )
  dvg.center( "While in webpage view, press "..rwSettings.exitKey.val.." to exit", 19 )

  term.setBackgroundColor( c.inputbg )
  dvg.center( "                                         ", 10 )

  term.setCursorPos( 7,10 )
  term.setBackgroundColor( c.inputbg )
  term.setTextColor( c.sinputtxt )
  write( protocol and protocol.."://" )
  term.setTextColor( c.inputtxt )
  write( url and url )

  if error ~= "" then
    term.setTextColor( c.errortxt )
    dvg.center( " "..error.." ", 17 )
  end
  error = ""
end

function handleInput( input )
  protocol, url = rw.separate( input, false )

  webpage, success = rw.getWebpage( protocol, url )
  if success then
    return rw.doWebpage( webpage )
  else
    error = webpage
  end -- End if success
end

-- Run
for i = 1, #dvg.sides do -- Open modems on all sides
  rednet.open( dvg.sides[i] )
end

local file = fs.open( path.."/settings.cfg", "r" ) -- Open settings and save in global var
rwSettings = textutils.unserialize( file.readAll() )
file.close()

while running do
  if goto and goto ~= "" then
    goto = handleInput( goto )
  else

    mainInterface()
    local event, button, x, y = os.pullEvent( "mouse_click" )
    if y == 14 then
      if x >= 18 and x <= 21 then
        running = false
        term.setBackgroundColor( colors.black )
        term.clear()
        term.setCursorPos( 1,1 )
      elseif x >= 27 and x <= 34 then
        rw.doWebpage( "redweb", "settings" )
      end

    elseif y == 10 and x >= 6 and x <= 46 then
      term.setCursorPos( 7,10 )
      dvg.printColor( protocol.."://"..url, c.sinputtxt )
      term.setCursorPos( 7,10 )
      term.setTextColor( c.inputtxt )
      input = read()
      handleInput( input )
    end -- End if y

  end -- End if goto
end
