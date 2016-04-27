--[[

      RedWeb IDS
      by DvgCraft

      Wireless modem required

      VERSION 1.0
      LONG V  0.9.7
      DATE    27-04-2016

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
  if string.sub( code, 1,14 ) == "DVG_REDWEB_IDS" then -- For us

    if code == "DVG_REDWEB_IDS_REQUEST" then -- Request server ID
      print( "LOG  Getting IDS Request from "..id )
      _,_,domain = msg:find( "([^/]+)" ) -- domain.name / ...
      if database[domain] then
        rednet.send( id, database[domain].id, "DVG_REDWEB_IDS_ANSWER" )
        print( "LOG  Returning ID "..database[domain].id.." of "..msg )
      else
        rednet.send( id, "Domain does not exist", "DVG_REDWEB_IDS_ANSWER" )
        print( "LOG  Can't find ID for "..msg )
      end
    elseif code == "DVG_REDWEB_IDS_REGISTER_REQUEST" then -- Register process
      print( "LOG  Getting register request.\n     ID:      "..id.."\n     Domain:  "..msg.domain.."\n     Company: "..msg.company )
      if not database[msg.domain] then
        database[msg.domain] = { id=id, company=msg.company, date=os.day(), info=msg.info }
        rednet.send( id, true, "DVG_REDWEB_IDS_REGISTER_ANSWER" )
        print( "LOG  Registered "..msg.domain.." for "..id )
      else
        rednet.send( id, "Domain already taken", "DVG_REDWEB_IDS_REGISTER_ANSWER" )
        print( "LOG  Requested domain register already taken" )
      end
    elseif code == "DVG_REDWEB_IDS_REMOVE_REQUEST" then -- Domain remove
      print( "LOG  Getting remove request from "..id.." for "..msg )
      if database[msg] then
        database[msg] = nil
        rednet.send( id, true, "DVG_REDWEB_IDS_REMOVE_ANSWER" )
        print( "LOG  Removed "..msg.." for "..id )
      else
        rednet.send( id, "Domain does not exist", "DVG_REDWEB_IDS_REMOVE_ANSWER" )
        print( "LOG  Requested domain to remove does not exist" )
      end
    end -- End if code

  end
  saveDb()
  print( "LOG  Saving Database" )
end
