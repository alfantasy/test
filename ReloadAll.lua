script_name('ML-ReloadAll')
script_version_number(1)
script_version('1.0')
script_author('The MonetLoader Team')
script_description('Reloads all scripts by swiping right on radar.')
script_properties('work-in-pause', 'forced-reloading-only')

local widgets = require('widgets') -- for WIDGET_(...)

function main()
  while true do
    wait(0)
	  if isWidgetSwipedRight(WIDGET_RADAR) then
      printStringNow('Reload all', 1000)
      reloadScripts()
	  end
  end
end