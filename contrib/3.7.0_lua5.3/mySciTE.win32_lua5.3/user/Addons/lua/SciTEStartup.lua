-- Windows requires this for us to immediately see all lua output.
io.stdout:setvbuf("no")
--print("startupScript_reload")

defaultHome = props["SciteDefaultHome"].."\\user"
package.path =  package.path ..";"..defaultHome.."\\Addons\\?.lua;".. ";"..defaultHome.."\\Addons\\lua\\lua\\?.lua;"
package.path=package.path..";C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.lua"
package.path = package.path .. ";"..defaultHome.."\\Addons\\lua\\mod-extman\\?.lua;"
package.cpath = package.cpath .. ";"..defaultHome.."\\Addons\\lua\\c\\?.dll;"

--lua >=5.2.x renamed functions: 
local unpack = table.unpack or unpack
math.mod=math.fmod or math.mod
string.gfind=string.gmatch or string.gfind
--lua >=5.2.x replaced table.getn(x) with #x

-- Load extman.lua
dofile(defaultHome..'\\Addons\\lua\\mod-extman\\extman.lua')

-- Load "eventmanager.lua"
dofile(defaultHome..'\\Addons\\lua\\mod-extman\\eventmanager.lua')
-- ################################

-- Load mod-mitchell 
package.path = package.path .. ";"..defaultHome.."\\Addons\\lua\\mod-mitchell\\?.lua;"
dofile(defaultHome..'\\Addons\\lua\\mod-mitchell\\scite.lua')

-- Load mod-macros
package.path = package.path .. ";"..defaultHome.."\\Addons\\lua\\mod-macros\\?.lua;"
dofile(defaultHome..'\\Addons\\lua\\mod-macros\\macros.lua')

-- Load Orthospell 
--package.path = package.path .. ";"..defaultHome.."\\Addons\\lua\\mod-hunspell\\?.lua;"
--dofile(defaultHome..'\\Addons\\lua\\mod-orthospell\\orthospell.lua')

-- Load Sidebar (which uses "eventmanager.lua")
package.path = package.path .. ";"..defaultHome.."\\Addons\\lua\\mod-sidebar\\?.lua;"
dofile(defaultHome..'\\Addons\\lua\\mod-sidebar\\URL_detect.lua')

-- ##################  Lua Samples #####################
-- ###############################################

function markLinks()
--
-- search for textlinks and highlight them. See Indicators@http://www.scintilla.org/ScintillaDoc.html
--
	local marker=10
	editor.IndicStyle[marker] = INDIC_COMPOSITIONTHIN
	editor.IndicFore[marker]  = 0xBE3333
	
	prefix="http[:|s]+//"  -- Rules: Begins with http(s):// 
	body="[a-zA-Z0-9]?." 	-- followed by a word  (eg www or the domain)
	suffix="[^ \r\n\t\"\'<]+" 	-- ends with space, newline,tab < " or '
	mask=prefix..body..suffix 
	EditorClearMarks(marker) -- common.lua
	local s,e = editor:findtext( mask, SCFIND_REGEXP, 0)
	while s do
		EditorMarkText(s, e-s, marker) -- common.lua
		s,e =  editor:findtext( mask, SCFIND_REGEXP, s+1)
	end
	
	scite.SendEditor(SCI_SETCARETFORE, 0x615DA1) -- Neals funny bufferSwitch Cursor colors :) 
end

scite_OnOpenSwitch(markLinks)

-- scite.MenuCommand(IDM_MONOFONT) -- Test MenuCommand
