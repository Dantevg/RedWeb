os.loadAPI( "/.DvgFiles/APIs/dvgapps" )

local menu = dvgapps.cfg.loadFile( "/.DvgFiles/data/RedWeb/settings.cfg" )
menu.valPos, menu.indicator = 46, false
headeropt = { bgcolor = colors.red, size = 3 }

while menu.running do
  dvg.bg( colors.white )
  dvgapps.header( "RedWeb settings", headeropt )
  dvgapps.cfg.printMenu( menu, headeropt )
  local event, button, x, y = os.pullEvent( "mouse_click" )
  menu = dvgapps.cfg.mouseClicked( menu, x, y, headeropt )
end
