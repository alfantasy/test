require "lib.moonloader"
local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8
-- �������������������
--[[
function isMonetLoader() return MONET_VERSION ~= nil end
if MONET_DPI_SCALE == nil then MONET_DPI_SCALE_2 = 1.0 else MONET_DPI_SCALE_2 = MONET_DPI_SCALE / 1.25 end

if isMonetLoader() then
	widgets = require('widgets')
end

]]

local bitex = require('bitex')
local memory = require "memory"
local ffi = require 'ffi'
local fa = require('fAwesome6_solid')
local imgui = require('mimgui')
local inicfg = require 'inicfg'
local MainIni = inicfg.load({
    settings = {
		show_actions_menu = true,
        colored_id = true,
        colored_nickname = true,
        colored_score = true,
        colored_ping = true,
		
    }
}, "MimguiScoreboard.ini")
local new = imgui.new
local renderTAB, renderSettings = new.bool(), new.bool()
local inputField = new.char[256]()
local checkbox1 = new.bool(MainIni.settings.colored_id)
local checkbox2 = new.bool(MainIni.settings.colored_nickname)
local checkbox3 = new.bool(MainIni.settings.colored_score)
local checkbox4 = new.bool(MainIni.settings.colored_ping)
local checkbox5 = new.bool(MainIni.settings.show_actions_menu)
local sizeX, sizeY = getScreenResolution()

EXPORTS = {}

local tag = "{87CEEB}[SC-AT]  {4169E1}" -- ��������� ����������, ������� ������������ ��� AT

function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end 
	
	sampAddChatMessage(tag .. '������������� ScoreBoard.',-1)
	
	sampRegisterChatCommand('tab', function()
		renderTAB[0] = not renderTAB[0]
    end)
	
	while true do
		wait(0)
		
		--[[if isMonetLoader() then 
		
			if isWidgetDoubletapped(WIDGET_PLAYER_INFO) then
				--sendUpdateScoresRPC()
				renderTAB[0] = not renderTAB[0]
			end
			
		end]]
		
	end
	
end

imgui.OnInitialize(function()

    imgui.GetIO().IniFilename = nil
	
	fa.Init(24)
	
end)

local Scoreboard = imgui.OnFrame(
    function() return renderTAB[0] end,
    function(player)
	
		imgui.GetStyle().ScrollbarSize = 10 
		
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(1100 , 573 ), imgui.Cond.FirstUseEver)
		imgui.Begin("##Begin", renderTAB, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove )

		imgui.GetStyle().FrameRounding = 10.0 
		imgui.GetStyle().ScrollbarSize = imgui.GetStyle().ScrollbarSize * 2
		if imgui.Button(fa.GEAR, imgui.ImVec2(50,50)) then	
			renderSettings[0] = true
			renderTAB[0] = false
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8'������� ���������')
		end
		
		imgui.SameLine()
		
		imgui.GetStyle().FrameRounding = 20.0 
		
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 1000 )

		if imgui.Button(' ' .. u8(sampGetCurrentServerName()) .. ' | '..sampGetPlayerCount(false) .. ' Players') then
			imgui.OpenPopup(fa.GLOBE .. u8' ���������� � �������')
		end
		if imgui.BeginPopupModal(fa.GLOBE .. u8' ���������� � �������', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			
			imgui.Text(u8'��������: ' .. u8(sampGetCurrentServerName()))
			imgui.SameLine()
			imgui.PushItemWidth(10 )
			if imgui.Button(fa.COPY .. '##copy_name') then
				setClipboardText(u8(sampGetCurrentServerName()))
			end
			
			local ip, port = sampGetCurrentServerAddress()
			imgui.Text(u8'��: ' .. ip .. ':' .. port)
			imgui.SameLine()
			imgui.PushItemWidth(10 )
			if imgui.Button(fa.COPY .. '##copy_ip') then
				setClipboardText(ip .. ':' .. port)
			end
			
			imgui.Text(u8'������� � �������: ' .. sampGetPlayerCount(false))
			
			if imgui.Button(fa.CIRCLE_XMARK .. u8' �������', imgui.ImVec2(250 , 25 )) then
				imgui.CloseCurrentPopup()
			end
			
			imgui.End()
		end	
		
		imgui.SameLine()
		
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 215 )
		imgui.PushItemWidth(135 )
		imgui.GetStyle().FrameRounding = 3.0 
		imgui.InputTextWithHint(u8'', u8'����� ID/Nick', inputField, 256)
		imgui.GetStyle().FrameRounding = 5.0 
		imgui.SameLine()
		
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 65 )
		if imgui.Button(fa.CIRCLE_XMARK, imgui.ImVec2(50,50)) then	
			renderSettings[0] = false
			renderTAB[0] = false
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8'������� ��B')
		end
	
		imgui.GetStyle().FrameRounding = 20.0 
	
		imgui.Separator()

		if imgui.BeginChild('##binder_edit', imgui.ImVec2(1100 , 573 ), false) then


			if MainIni.settings.show_actions_menu then

				imgui.Columns(5)
				
				imgui.SetColumnWidth(-1, 70 ) imgui.CenterColumnText('ID') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 700 ) imgui.CenterColumnText('Nickname') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 80 ) imgui.CenterColumnText('Score') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 80 ) imgui.CenterColumnText('Ping') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 80 ) imgui.CenterColumnText('Action') imgui.NextColumn()
		
			else
				imgui.Columns(4)
				
				imgui.SetColumnWidth(-1, 70 ) imgui.CenterColumnText('ID') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 700 ) imgui.CenterColumnText('Nickname') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 80 ) imgui.CenterColumnText('Score') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 80 ) imgui.CenterColumnText('Ping') imgui.NextColumn()
			
			end
		
			if u8:decode(ffi.string(inputField)) == "" then
				imgui.Separator()
				local my_id = select(2, sampGetPlayerIdByCharHandle(playerPed))
				drawScoreboardPlayer(my_id)
				for id = 0, sampGetMaxPlayerId(false) do
					if my_id ~= id and sampIsPlayerConnected(id) then
						imgui.Separator()
						drawScoreboardPlayer(id)
					end
				end
			else
				for idd = 0, sampGetMaxPlayerId(false) do
					if sampIsPlayerConnected(idd) then
						if tostring(idd):find(ffi.string(inputField):gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"))
						   or string.rlower(sampGetPlayerNickname(idd)):find(string.rlower(u8:decode(ffi.string(inputField))):gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")) then
							imgui.Separator()
							drawScoreboardPlayer(idd)
						end
					end
				end
			end
			
			
			imgui.NextColumn()
			imgui.Columns(1)
			imgui.Separator()
		
		imgui.EndChild() end
		
		imgui.End()
		
    end
)
local Settings = imgui.OnFrame(
    function() return renderSettings[0] end,
    function(player2)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(800 , 573 ), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'�������� ����', renderSettings, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		

		if imgui.Button(fa.CIRCLE_LEFT) then	
			renderSettings[0] = false
			renderTAB[0] = true
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8'������� ���������')
		end
		
		imgui.SameLine()
		
		imgui.CenterText(fa.GEAR .. u8" ���������")	

		imgui.SameLine()
		
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 30 )
		if imgui.Button(fa.CIRCLE_XMARK) then	
			renderSettings[0] = false
			renderTAB[0] = false
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8'�������')
		end
		
		imgui.Separator()
		imgui.CenterText(fa.PALETTE .. u8(" ����� ��������� � ����������� �� ������ ������:"))
		if imgui.Checkbox(u8' ������� ID', checkbox1) then
			MainIni.settings.colored_id = checkbox1[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		
		if imgui.Checkbox(u8' ������� NickName', checkbox2) then
			MainIni.settings.colored_nickname = checkbox2[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		
		if imgui.Checkbox(u8' ������� Score', checkbox3) then
			MainIni.settings.colored_score = checkbox3[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		
		if imgui.Checkbox(u8' ������� Ping', checkbox4) then
			MainIni.settings.colored_ping = checkbox4[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end

		imgui.Separator()
		
		imgui.CenterText(fa. BARS.. u8' ���� ��������������. Settings')
		if imgui.Checkbox(u8' ���������� ���� ��������������', checkbox5) then
			MainIni.settings.show_actions_menu = checkbox5[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		imgui.End()
		
    end
)

function drawScoreboardPlayer(id)

	local nickname = u8(sampGetPlayerNickname(id))
	local score = sampGetPlayerScore(id)
	local ping = sampGetPlayerPing(id)
	local color = sampGetPlayerColor(id)
	local r, g, b = bitex.bextract(color, 16, 8), bitex.bextract(color, 8, 8), bitex.bextract(color, 0, 8)
	local imgui_RGBA = imgui.ImVec4(r / 255, g / 255, b / 255, 1)
	
	
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(id)).x / 2)
	if MainIni.settings.colored_id then 
		imgui.TextColored(imgui_RGBA, tostring(id))
	else
		imgui.Text(tostring(id))
	end
	imgui.NextColumn()
	
	if MainIni.settings.colored_nickname then 
		imgui.TextColored(imgui_RGBA, ' '..nickname)
	else
		imgui.Text(' '..nickname)
	end
	imgui.NextColumn()	
	
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(score)).x / 2)
	if MainIni.settings.colored_score then 
		imgui.TextColored(imgui_RGBA, tostring(score))
	else
		imgui.Text(tostring(score))
	end
	imgui.NextColumn()
	
	if MainIni.settings.colored_ping then 
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(ping)).x / 2)
		imgui.TextColored(imgui_RGBA, tostring(ping))
	else	
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(ping)).x / 2)
		imgui.Text(tostring(ping))
	end
	imgui.NextColumn()
	
	if MainIni.settings.show_actions_menu then
	
		imgui.SetWindowFontScale(0.8) 

		if imgui.Button(fa.COPY.."##"..id, imgui.ImVec2(22 ,22.5 )) then
			setClipboardText(tostring(nickname))
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"����������� ��� "..nickname..u8" � �����")
		end

		imgui.SetWindowFontScale(1.0) 
	
		imgui.NextColumn()
	
	end

	
	
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterColumnButton(text)

	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	
    if imgui.Button(text) then
		return true
	else
		return false
	end
end

local russian_characters = {
	[168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
}
function string.rlower(s)
	s = s:lower()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:lower()
	local output = ''
	for i = 1, strlen do
		 local ch = s:byte(i)
		 if ch >= 192 and ch <= 223 then -- upper russian characters
			  output = output .. russian_characters[ch + 32]
		 elseif ch == 168 then -- �
			  output = output .. russian_characters[184]
		 else
			  output = output .. string.char(ch)
		 end
	end
	return output
end
--if not isMonetLoader() then

-- function onWindowMessage(msg, wparam, lparam)
-- 	if(msg == 0x100 or msg == 0x101) then
-- 		if (wparam == VK_ESCAPE and renderTAB[0]) and not isPauseMenuActive() then
-- 			consumeWindowMessage(true, false)
-- 			if (msg == 0x101) then
-- 				renderTAB[0] = false
-- 			end
-- 		elseif (wparam == VK_ESCAPE and renderSettings[0]) and not isPauseMenuActive() then
-- 			consumeWindowMessage(true, false)
-- 			if (msg == 0x101) then
-- 				renderSettings[0] = false
-- 			end
-- 		elseif wparam == VK_TAB and not isKeyDown(VK_TAB) and not isPauseMenuActive() then
-- 			if not renderTAB[0] then
-- 				if not sampIsChatInputActive() then
-- 					renderTAB[0] = true
-- 				end
-- 			else
-- 				renderTAB[0] = false
-- 			end
-- 			consumeWindowMessage(true, false)
-- 		end
-- 	end
-- end

function EXPORTS.ActiveScoreBoard()
	renderTAB[0] = not renderTAB[0]
end


return EXPORTS
--end

