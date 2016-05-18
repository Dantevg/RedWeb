--[[

      RedWeb browser
      by DvgCraft

      Requirements:
      - Wireless modem
      - Advanced computer
      - IDS and webserver

      VERSION  0.9.14.1
      DATE     18-05-2016

      Protocols:
      - app://
      - web://
      - search://

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
local shades = {
  [1] = colors.pink,
  [2] = colors.white,
}

local error = {}
local protocol = ""
local url = ""
local goto = ""

-- Functions
local function receive( sProtocolFilter, nTimeout ) -- From rednet API
    -- The parameters used to be ( nTimeout ), detect this case for backwards compatibility
    if type(sProtocolFilter) == "number" and nTimeout == nil then
        sProtocolFilter, nTimeout = nil, sProtocolFilter
    end

    -- Start the timer
	local timer = nil
	local sFilter = nil
	if nTimeout then
		timer = os.startTimer( nTimeout )
		sFilter = nil
	else
		sFilter = "rednet_message"
	end

	-- Wait for events
	while true do
		local sEvent, p1, p2, p3 = os.pullEvent( sFilter )
		if sEvent == "rednet_message" then
		    -- Return the first matching rednet_message
			local nSenderID, message, sProtocol = p1, p2, p3
			if sProtocolFilter == nil or sProtocol == sProtocolFilter then
          os.cancelTimer( timer )
    			return nSenderID, message, sProtocol
    	    end
		elseif sEvent == "timer" then
		    -- Return nil if we timeout
		    if p1 == timer then
    			return nil
    		end
		end
	end
end

function mainInterface()
  term.setTextColor( c.maintxt )
  dvg.bg( c.mainbg )
  dvg.center( "RedWeb browser", 5 )
  dvg.center( "EXIT     SETTINGS", 16 )
  dvg.center( "While in webpage view, press "..rwSettings.exitKey.val.." to exit", 19 )

  term.setBackgroundColor( c.inputbg )
  dvg.center( "                                         ", 9 )

  term.setCursorPos( 7,9 )
  term.setBackgroundColor( c.inputbg )
  term.setTextColor( c.sinputtxt )
  write( protocol ~= "" and protocol.."://" or "" )
  term.setTextColor( c.inputtxt )
  write( url ~= "" and url or "" )

  term.setTextColor( c.errortxt )
  for i = 1, math.min( #error, 3 ) do
    term.setBackgroundColor( shades[ error[i].state ] )
    dvg.center( " "..error[i].txt.." ", 4-i )
  end
end

function getInput()
  local input = (protocol ~= "" and protocol.."://" or "").. (url ~= "" and url or "")
  local oldInput = ""
  local list = {}
  local num = 0

  while true do
    term.setCursorPos( 7,9 )
    term.setBackgroundColor( c.mainbg )
    term.clearLine()
    term.setBackgroundColor( c.inputbg )
    dvg.center( "                                         ", 9 )
    term.setCursorPos( 7,9 )
    write( input )

    if input ~= "" and rwSettings.liveSearch.val then
      if input ~= oldInput then
        rednet.broadcast( input, "DVG_REDWEB_IDS_SEARCH_REQUEST" )
        _, list = receive( "DVG_REDWEB_IDS_SEARCH_ANSWER", 0.1 )
      end
      term.setTextColor( c.sinputtxt )
      for i = 1, 5 do
        if list and list[i] then term.setBackgroundColor( c.inputbg ) else term.setBackgroundColor( c.mainbg ) end
        dvg.center( dvg.fill( " "..(list[i] and list[i] or ""), 40 ), 9+i )
      end
      term.setTextColor( c.inputtxt )
    elseif rwSettings.liveSearch.val then
      term.setBackgroundColor( c.mainbg )
      for i = 1, 5 do
        dvg.center( string.rep(" ", 41), 9+i )
      end
    end -- End if input ~= ""

    oldInput = input
    term.setCursorBlink( true )
    input, enterPressed, continue, event, param = dvg.read( input, "mouse_click" )
    term.setCursorBlink( false )

    if event == "timer" then
      for i, v in ipairs( error ) do
        if v.timer == param[1] then
          v.state = v.state - 1
          if v.state > 0 then
            v.timer = os.startTimer( 0.2 )
          else
            table.remove( error, i )
          end
          break
        end -- End if v.timer finished
      end -- End for
    end -- End if timer

    if not continue then
      os.queueEvent( event, unpack(param) )
      return input, enterPressed
    end
  end -- End while true

end

function handleInput( input )
  protocol, url = rw.separate( input, false )

  webpage, success = rw.getWebpage( protocol, url )
  if success then
    term.setBackgroundColor( colors.white )
    term.clear()
    local goto, status = rw.doWebpage( webpage )
    if status == false then
      if #goto > 0 then
        table.insert(  error, 1, { txt = goto, timer = os.startTimer(tonumber(rwSettings.errorTime.val)), state = 2 }  )
      end
      return ""
    else
      return goto
    end
  else
    if #webpage > 0 then
      table.insert(  error, 1, { txt = webpage, timer = os.startTimer(tonumber(rwSettings.errorTime.val)), state = 2 }  )
    end
    return ""
  end -- End if success
end

-- Run
if dvg.version < "2.15.3" then
  print( "Please update dvg API v"..dvg.version.." to at least v2.15.3" )
  print( "Update now? y/n" )
  input = read():lower()
  if input == "y" then
    shell.run( "/.DvgFiles/update dvg" )
  end
  os.reboot()
end
if not dvgapps then
  print( "Dvgapps API required" )
  print( "Install now? y/n" )
  input = read():lower()
  if input == "y" then
    shell.run( "/.DvgFiles/update dvgapps" )
  end
  os.reboot()
end
dvg.openRednet()

local file = fs.open( path.."/settings.cfg", "r" ) -- Open settings and save in global var
_G["rwSettings"] = textutils.unserialize( file.readAll() )
file.close()

while running do
  for i = #error, 1, -1 do
    if error[i].state <= 0 then
      table.remove( error, i )
    end
  end
  if goto and goto ~= "" then
    goto = handleInput( goto )
  else

    mainInterface()
    local event, button, x, y = os.pullEvent()

    if event == "mouse_click" then
      if y == 16 and x >= 18 and x <= 21 then
        running = false
        term.setBackgroundColor( colors.black )
        term.clear()
        term.setCursorPos( 1,1 )
      elseif y == 16 and x >= 27 and x <= 34 then
        shell.run( path.."/settings" )
        local file = fs.open( path.."/settings.cfg", "r" ) -- Open settings and save in global var
        _G["rwSettings"] = textutils.unserialize( file.readAll() )
        file.close()
      elseif y == 9 and x >= 6 and x <= 46 then
        term.setCursorPos( 7,8 )
        dvg.printColor( (protocol ~= "" and protocol.."://" or "") .. (url ~= "" and url or ""), c.sinputtxt )
        term.setCursorPos( 7,8 )
        term.setTextColor( c.inputtxt )
        local input, enterPressed = getInput()
        if enterPressed then
          goto = handleInput( input )
        end
      end -- End if y

    elseif event == "timer" then
      for i, v in ipairs( error ) do
        if v.timer == button then
          v.state = v.state - 1
          if v.state > 0 then
            v.timer = os.startTimer( 0.2 )
          end
          break
        end -- End if v.timer finished
      end -- End for
    end -- End if event

  end -- End if goto
end
