--[[

      RedWeb IDS
      by DvgCraft

      Wireless modem required

      VERSION 1.0
      LONG V  0.9.5 (client 0.9.6, server 0.9.7)
      DATE    06-03-2016

]]--

-- Variables
local dbPath = "/disk/RedWeb/database.db"

local database = {}
local domain = ""

-- Functions
function saveDb()
  local file = fs.open( dbPath, "w" )
  file.write( textutils.serialize( database ) )
  file.close()
end

-- Run
print( "RedWeb IDS running" )

write( "Starting host... " )
rednet.host( "DVG_REDWEB", "IDS" )
print( "Done." )

write( "Loading database... " )
local file = assert( fs.open( dbPath, "r" ), "Could not find database on path: "..dbPath )
database = assert( textutils.unserialize( assert(file.readAll(),"Fail.\nCould not read database.") ), "Fail.\nCorrupt database." )
file.close()
print( "Done." )
print()

while true do
  domain = ""
  id, msg, code = rednet.receive()
  if code:sub( 1,14 ) == "DVG_REDWEB_IDS" then -- For us

    if code == "DVG_REDWEB_IDS_REQUEST" then -- Request server ID
      print( "LOG  Getting IDS Request from "..id )
      _,_,domain = msg:find( "([^/]+)" ) -- domain.name / ...
      if database[domain] then
        rednet.send( id, database[domain], "DVG_REDWEB_IDS_ANSWER" )
        print( "LOG  Returning ID "..database[domain].." from "..msg )
      else
        rednet.send( id, "Domain does not exist", "DVG_REDWEB_IDS_ANSWER" )
        print( "LOG  Can't find ID for "..msg )
      end
    elseif code == "DVG_REDWEB_IDS_REGISTER_REQUEST" then -- Register process
      print( "LOG  Getting register request.\n     ID:     "..id.."\n     Domain: "..msg )
      if not database[msg] then
        database[msg] = id
        rednet.send( id, true, "DVG_REDWEB_IDS_REGISTER_ANSWER" )
        print( "LOG  Registered "..msg.." for "..id )
      else
        rednet.send( id, "Domain already taken", "DVG_REDWEB_IDS_REGISTER_ANSWER" )
        print( "LOG  Requested domain register already taken" )
      end
    end

  end
  saveDb()
  print( "LOG  Saving Database" )
end
