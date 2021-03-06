--[[

      RedWeb (rw) API
      by DvgCraft

      VERSION  0.9.14
      DATE     25-04-2016

]]--

--[[ URL Explanation
                              URL
      |------------------------------------------------|
      protocol                      URL
      |------|     |-----------------------------------|
      protocol       domain          path         args
      |------|     |-------|   |--------------| |------|
       web     ://  bank.cc  /  files/usr/john   doThis
]]--

-- Variables
path = "/.DvgFiles/data/RedWeb"

-- Functions
function separate( url, getPath )
  if getPath then
    local _,_, domain, path, args = string.find( url, "([^/]+)(%S*)(.*)" ) -- doma.in / path/to/file arg1 arg2
    return domain, path, args:sub( 2 )
  else
    local _,_, protocol, newUrl = string.find( url, "(%a+)://(.+)" ) -- protocol :// url
    if not newUrl then
      return "web", url
    else
      return protocol, newUrl
    end
  end
end

function getWebpage( protocol, url )
  if protocol ~= "web" and protocol ~= "app" then
    return "Invalid protocol. (web, app)", false
  end

  local webpage = ""

  if protocol == "web" then

    rednet.broadcast( url, "DVG_REDWEB_IDS_REQUEST" )
    local ID, webServer = rednet.receive( "DVG_REDWEB_IDS_ANSWER", 1 )
    if not webServer then
      return "ID server offline", false
    elseif type( webServer ) == "string" then
      return webServer, false
    end

    rednet.send( webServer, {ID=os.getComputerID(), url=url}, "DVG_REDWEB_WEBSITE_REQUEST" )
    _, webpage = rednet.receive( "DVG_REDWEB_WEBSITE_ANSWER", 1 )
    if not webpage then
      return "Webserver offline", false
    elseif type( webpage ) == "string" and webpage:sub( 1,3 ) == "ERR" then
      return webpage:sub( 5 ), false
    end
    return webpage, true

  elseif protocol == "app" then

    local domain, path = separate( url, true )
    if fs.isDir( "/.DvgFiles/data/"..app ) then
      local file = ""
      if not path or path == "" then -- No path specified
        if fs.exists( "/.DvgFiles/data/"..app.."/"..app ) then -- /data/{name}/{name}
          file = fs.open( "/.DvgFiles/data/"..app.."/"..app, "r" )
        elseif fs.exists( "/.DvgFiles/data/"..app.."/run" ) then -- /data/{name}/run
          file = fs.open( "/.DvgFiles/data/"..app.."/run", "r" )
        else
          return "No such app", false
        end
      else -- Path specified
        if fs.exists( "/.DvgFiles/data/"..app.."/"..path ) then
          file = fs.open( "/.DvgFiles/data/"..app.."/"..path, "r" )
        else
          return "No such file", false
        end
      end -- End if path
      webpage = file.readAll()
      file.close()
      return webpage, true
    end

  end --End if protocol
end

function doWebpage( webpage )
  fWebpage = loadstring( webpage )
  local goto, err = "", ""

  local function runWebpage()
    if rwSettings.protectFs.val == true then
      oldMakeDir, oldMove, oldCopy, oldDelete, oldOpen = fs.makeDir, fs.move, fs.copy, fs.delete, fs.open
      fs.makeDir, fs.move, fs.copy, fs.delete = nil
      fs.open = function( path, mode ) if mode~="r" and mode~="rb" then return nil else return oldOpen(path,mode) end end
    end
    status, goto = pcall( fWebpage )
    if rwSettings.protectFs.val == true then
      fs.makeDir, fs.move, fs.copy, fs.delete, fs.open = oldMakeDir, oldMove, oldCopy, oldDelete, oldOpen
    end
  end

  local function getExit()
    while true do
      local event, key = os.pullEvent( "key" )
      if key == keys[ rwSettings.exitKey.val ] then
        break
      end
    end
  end

  parallel.waitForAny( getExit, runWebpage )
  if status then
    return goto, true
  else
    return goto, false
  end
end
