os.loadAPI( "/.DvgFiles/APIs/dvgapps" )
local menu = dvgapps.cfg.loadFile( "/.DvgFiles/data/RedWeb/settings.cfg" )
headeropt = { bgcolor = colors.red, size = 3 }
while menu.running do
  dvg.bg( colors.white )
  dvgapps.header( "RedWeb", headeropt )
  dvgapps.cfg.printMenu( menu, headeropt )
  local event, key = os.pullEvent( "key" )
  menu = dvgapps.cfg.keyPressed( menu, key, headeropt )
end
