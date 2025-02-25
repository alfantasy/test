require 'lib.moonloader'
local imgui = require 'mimgui' -- ������������� ���������� Moon ImGUI
local encoding = require 'encoding' -- ������ � �����������
local sampev = require 'lib.samp.events' -- ���������� ������� SA:MP � ������������/���������/�������� �.�. �������
local mim_addons = require 'mimgui_addons' -- ���������� ������� ��� ���������� mimgui
local fa = require 'fAwesome6_solid' -- ������ � ������� �� ������ FontAwesome 6
local inicfg = require 'inicfg' -- ������ � ��������
local ffi = require 'ffi'
local atlibs = require 'libsfor'
local toast_ok, toast = pcall(import, 'lib/mimtoasts.lua') -- ���������� �����������.
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ���������� ��������� U8 ��� �������, �� � ����� ���������� (��� ����������)

-- ## ���� ��������� ���������� ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- ��������� ����������, ������� ������������ ��� AT
-- ## ���� ��������� ���������� ## --

-- ## mimgui ## --
local new = imgui.new

EXPORTS = {}

function Tooltip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8(text))
        imgui.EndTooltip()
    end 
end

imgui.OnInitialize(function()   
    imgui.GetIO().IniFilename = nil
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	imgui.GetIO().Fonts:Clear()
	imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '/lib/mimgui/trebucbd.ttf', 24.0, _, glyph_ranges)
	fa.Init(24)
end)
-- ��� �������� �����

local sw, sh = getScreenResolution()
-- ## mimgui ## --

-- ## ������� ������� � ���������� VARIABLE ## --
local directIni = 'AdminTool/repsettings.ini'

local config = inicfg.load({
    main = {
        prefix_answer = false,
        prefix_for_answer = ' // �������� ���� �� ������� RDS <3',
    },
    bind_name = {},
    bind_text = {},
}, directIni)
inicfg.save(config, directIni)

function save()  
    inicfg.save(config, directIni)
    return true
end

local elements = {
    repwindow = new.bool(false),
    answer = new.char[1024](),
    prefix_for_answer = new.char[256](),
    prefix_answer = new.bool(config.main.prefix_answer),
    binder_name = new.char[256](),
    binder_text = new.char[65536](),
    select_menu = 0,
    select_category = 0,
}
-- ## ������� ������� � ���������� VARIABLE ## --

-- ## ���� � �������� ## --
local questions = {
    ["reporton"] = {
		[u8"����� �����"] = "������ ����� ������� ����.",
        [u8"������ ������ �� ������"] = "�����(�) ������ �� ����� ������!",
		[u8"��� ��������"] = "��������� �����, ������ ������ ���!",
		[u8"��� ����� ���� � �������"] = "������ ���������� ��������� � ���������.",
		[u8"������ �� ������"] = "������ ������ �� �������������� �� ����� https://forumrds.ru",
		[u8"������ �� ������"] = "�� ������ �������� ������ �� ������ �� ����� https://forumrds.ru",
        [u8"������ �� ���-����"] = "�� ������ �������� ������ �� ����� https://forumrds.ru",
		[u8"������� ���"] = "������� ���",
		[u8"��������"] = "��������",
		[u8"��������� �������������������"] = "��������� ������������������� �� Russian Drift Server!",
		[u8"����� ������ �� ������"] = "�� ���� ��������� �� ������� ������",
		[u8"����� ����"] = " ������ ����� ����",
		[u8"����� �� � ����"] = "������ ����� �� � ����",
		[u8"��������� ������/������"] = "�������� ���� ������/������",
		[u8"��������� ID"] = "�������� ID ����������/������ � /report",
		[u8"����� �������"] = "������ ����� �������",
		[u8"��������"] = "��������",
		[u8"�� �� ��������"] = "GodMode (������) �� ������� �� ��������",
		[u8"��� ������"] = "� ������ ������ ����� � ������������� �� ��������.",
		[u8"������ ����� ���������"] = "������ ����� ��� ���������.",
		[u8"��� ����� ���������"] = "������ ��� ����� ����� ���������.",
		[u8"������ ����� ����������"] = "������ ������ ����� ����� ����������.",
		[u8"�����������"] = "������ ����, ��������� �����.",
        [u8"���������"] = "���������",
		[u8"�����"] = "�����",
		[u8"��"] = "��",
		[u8"���"] = "���",
		[u8"�� ���������"] = "�� ���������",
		[u8"�� �����"] = "�� �����",
		[u8"������ ���������"] = "�� ���������",
		[u8"�� ������"] = "�� ������",
		[u8"��� ���"] = "������ ����� - ��� ���",
		[u8"�����������"] = "���������� ���������"

    },
	["HelpHouses"] = {
		[u8"��� �������� ������ � ������"] = "/hpanel -> ����1-3 -> �������� -> ������ ���� -> ��������� ������",
		[u8"� ����� ��� �������"] = "/hpanel -> ����1-3 -> �������� -> ������� ��� ����������� || /sellmyhouse (������)",
		[u8"��� ������ ���"] = "�������� �� ����� (�������, �� �������) � ������� F.",
        [u8"��� ������� ���� ����"] = "/hpanel"
	},
	["HelpCmd"] = {
		[u8"������� VIP`�"] = "������ ���������� ����� ����� � /help -> 7 �����",
        [u8"���������� � �����"] = "������ ���������� ����� ������ � ���������",
		[u8"���������� Premuim"] = "������ ����� � ����������� Premuim VIP (/help -> 7)",
		[u8"���������� Diamond"] = "������ ����� � ����������� Diamond VIP (/help -> 7) ",
		[u8"���������� Platinum"] = "������ ����� � ����������� Platinum VIP (/help -> 7)",
		[u8"���������� ������"] = "������ ����� � ����������� ������� VIP (/help -> 7)",
		[u8"������� ��� �������"] = "������ ���������� ����� ����� � /help -> 8 �����",
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 14 �����",
		[u8"��� �������� �������"] = "������� �����, ��� �� /help -> 18 �����"
	},
	["HelpGangFamilyMafia"] = {
		[u8"��� ������� ���� �����"] = "/menu (/mm) - ALT/Y -> ������� ����",
		[u8"��� ������� ���� �����"] = "/fpanel ",
		[u8"��� ��������� ������"] = "/guninvite (�����) || /funinvite (�����)",
		[u8"��� ���������� ������"] = "/ginvite (�����) || /finvite (�����)",
		[u8"��� �������� �����/�����"] = "/gleave (�����) || /fleave (�����)",
        [u8"��� ������ ����"] = "/grank IDPlayer ����",
		[u8"��� �������� �����"] = "/leave",
		[u8"��� ������ �������"] = "/gvig // ������ ���� �������",
	},
	["HelpTP"] = {
		[u8"��� �� � ���������"] = "tp -> ������ -> ����������",
		[u8"��� �� � ��������������"] = "/tp -> ������ -> ���������� -> ��������������",
		[u8"��� �� � ����"] = "/bank || /tp -> ������ -> ����",
		[u8"��� ���� ��"] = "/tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����)",
        [u8"��� �� �� ������"] = "/tp -> ������"
	},
	["HelpSellBuy"] = {
		[u8"��� ������� ����"] = "������� ���������� ��� ������ ����� �� /trade. ����� �������, ������� F ����� �����",
		[u8"��� �������� ������"] = "����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������",
		[u8"� ��� ������� �����"] = "/sellmycar IDPlayer ����1-5 ����� || /car -> ����1-5 -> ������� �����������",
        [u8"� ��� ������� ������"] = "/biz > ������� ������ �����������",
		[u8"��� �������� ������"] = "/givemoney IDPlayer money",
		[u8"��� �������� ����"] = "/givescore IDPlayer score",
		[u8"��� �������� �����"] = "/giverub IDPlayer rub | � ������� VIP (/help -> 7)",
		[u8"��� �������� �����"] = "/givecoin IDPlayer coin | � ������� VIP (/help -> 7)",
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 14 �����",
	},
	["HelpBuz"] = {
		[u8"���� ������"] = "������� /cpanel ", 
		[u8"������� ������"] = "/biz > ������� ������ �����������",
		[u8"���� ����������"] = "������� /biz ",
		[u8"���� �����"] = "������� /clubpanel ",
		[u8"���������� ���������"] = "������� /help -> 9",
	},
	["HelpDefault"] = {
		[u8"IP RDS 01"] = "46.174.52.246:7777",
		[u8"IP RDS 02"] = "46.174.55.87:7777",
		[u8"IP RDS 03"] = "46.174.49.170:7777",
		[u8"IP RDS 04"] = "46.174.55.169:7777",
		[u8"IP RDS 05"] = "62.122.213.75:7777",
		[u8"���� � ������� HTML"] = "https://colorscheme.ru/html-colors.html",
		[u8"���� � ������� HTML 2"] = "https://htmlcolorcodes.com",
		[u8"��� ��������� ����"] = "���� � ���� HTML {RRGGBB}. ������� - 008000. ����� {} � ������ ���� ����� ������ {008000}�������",
		[u8"������ �� ���.������"] = "https://vk.com/dmdriftgta | ������ �������",
        [u8"������ �� �����"] = "https://forumrds.ru | ����� �������",
        [u8"��� �������� ���/������"] = "�������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ����",
		[u8"��� ����� ��������� ������"] = "����������� ������� /car",
		[u8"��� �������� ����"] = '������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����',
		[u8"��� �������� ������"] = "������ ���������� �� ���� �����. ����� ������������ �� /garage",
		[u8"��� ������ ����"] = "��� ����, ����� ������ ����, ����� ������ /capture",
		[u8"��� ������ ���/����"] = "/passive ",
		[u8"/statpl"] = "����� ���������� ������, ����, �����, �����, ����� - /statpl",
		[u8"����� ������"] = "/mm -> �������� -> ������� ������",
		[u8"����� �����"] = "/mm -> ������������ �������� -> ��� ����������",
        [u8"��� ����� ������"] = "/menu (/mm) - ALT/Y -> ������",
		[u8"��� ����� ��������"] = "/menu (/mm) - ALT/Y -> ��������",
        [u8"��� ������� ����"] = "/mm (/mn) || Alt/Y",
		[u8"��� ������ �����"] = "/menu (/mm) - ALT/Y -> �/� -> ������",
		[u8"���� ����� �������"] = "/kill | /tp | /spawn",
		[u8"��� ������� �� �����/����"] = "/join | ���� ������������� �������, ������� �� �����",
		[u8"����������� ���"] = "/dt 0-990 / ����������� ���",
        [u8"�������� ������/�������"] = "/quests | /dquest | /bquest",
		[u8"�������� � �������"] = "�������� � �������."
	},
	["HelpSkins"] = {
		[u8"���� �� �������"] = " https://gtaxmods.com/skins-id.html.",
		[u8"����"] = "65-267, 280-286, 288, 300-304, 306, 307, 309-311",
		[u8"�������"] = "102-104",
		[u8"����"] = "105-107",
		[u8"�����"] = "117-118, 120",
		[u8"������"] = "108-110",
		[u8"��.�����"] = "111-113",
		[u8"�������"] = "114-116",
		[u8"�����"] = "124-127"
	},
	["HelpSettings"] = {
		[u8"�����/������ �������"] = "/menu (ALT/Y) -> ��������� -> 1 �����.",
		[u8"���������� �������� �� �����"] = "/menu (ALT/Y) -> ��������� -> 2 �����.",
		[u8"On/Off ������ ���������"] = "/menu (ALT/Y) -> ��������� -> 3 �����.",
		[u8"������� �� ��������"] = "/menu (ALT/Y) -> ��������� -> 4 �����.",
		[u8"���������� ���������� DM Stats"] = "/menu (ALT/Y) -> ��������� -> 5 �����.",
		[u8"������ ��� ������������"] = "/menu (ALT/Y) -> ��������� -> 6 �����.",
		[u8"���������� ���������"] = "/menu (ALT/Y) -> ��������� -> 7 �����.",
		[u8"���������� Drift Lvl"] = "/menu (ALT/Y) -> ��������� -> 8 �����.",
		[u8"����� � ����/���� �����"] = "/menu (ALT/Y) -> ��������� -> 9 �����.",
		[u8"����� �������� ����"] = "/menu (ALT/Y) -> ��������� -> 10 �����.",
		[u8"On/Off ����������� � �����"] = "/menu (ALT/Y) -> ��������� -> 11 �����.",
		[u8"����� �� �� TextDraw"] = "/menu (ALT/Y) -> ��������� -> 12 �����.",
		[u8"On/Off ����"] = "/menu -> ��������� (ALT/Y) -> 13 �����.",
		[u8"On/Off FPS ����������"] = "/menu (ALT/Y) -> ��������� -> 15 �����.",
		[u8"On/Off �����������"] = "/menu (ALT/Y) -> ��������� -> 16 �����",
		[u8"On/Off �����.�����"] = "/menu (ALT/Y) -> ��������� -> 17 �����",
		[u8"On/Off ����.�����"] = "/menu (ALT/Y) -> ��������� -> 18 �����",
		[u8"On/Off ���.������ ��� �����"] = "/menu (ALT/Y) -> ��������� -> 19 �����",
		[u8"������ ��.����"] = "/menu (ALT/Y) -> ��������� -> 20 �����",
	}
}
-- ## ���� � �������� ## --
function main()
    while not isSampAvailable() do wait(0) end
    
    if toast_ok then 
        toast.Show(u8"AT Reports ���������������.", toast.TYPE.INFO, 5)
    else 
        sampAddChatMessage(tag .. 'AdminTool Reports ������� ���������������. ���������: /tool', -1)
        sampAddChatMessage(tag .. "����� � ��������� �����������", -1)
    end

    while true do
        wait(0)
        
    end
end

function ToClipboard(v) 
    if imgui.IsItemClicked() then  
        setClipboardText(v)
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if id == 2349 then  
        if text:match("�����: {......}(%S+)") and text:match("������:\n{......}(.*)\n\n{......}") then
            nick_rep = text:match("�����: {......}(%S+)")
            text_rep = text:match("������:\n{......}(.*)\n\n{......}")	
			pid_rep = atlibs.playernickname(nick_rep)
			if pid_rep == nil then  
				pid_rep = "None"
			end
            rep_text = u8:encode(text_rep)
            id_punish = rep_text:match("(%d+)")
        end
        if not elements.repwindow[0] then  
            elements.repwindow[0] = true  
        end  
        return false
    else 
        elements.repwindow[0] = false
    end
end

local ReportsAT = imgui.OnFrame( 
    function() return elements.repwindow[0] end, 
    function(player) 

        royalblue()

        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(750, 420), imgui.Cond.FirstUseEver)

        imgui.Begin("##Reports Window", elements.repwindow, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.MenuBar)
            imgui.BeginMenuBar()
                imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5,0.5))
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 10)
                if imgui.Button(fa.BELL .. '##BackWind', imgui.ImVec2(50, 0)) then     
                    elements.select_menu = 0
                end 
                imgui.Spacing()
                imgui.Text(u8('     ����� �������: ' .. u8:decode(rep_text)))
                imgui.PopStyleVar(1)
                imgui.PopStyleVar(1)
                imgui.SetCursorPosX((imgui.GetWindowWidth() - 100))
                if elements.select_menu == 1 or elements.select_menu == 2 then  
                    if imgui.Button(fa.ARROW_LEFT .. '##BackButton', imgui.ImVec2(50,0)) then  
                        elements.select_menu = 0
                    end
                end
            imgui.EndMenuBar()
            if elements.select_menu == 0 then
                imgui.StrCopy(elements.prefix_for_answer, config.main.prefix_for_answer)
                if (nick_rep and pid_rep and rep_text) then  
                    imgui.Text(u8"������ ��: "); imgui.SameLine()
                    imgui.Text(nick_rep); ToClipboard(nick_rep); imgui.SameLine();
                    imgui.Text("[" .. pid_rep .. "]"); ToClipboard(pid_rep)
                    imgui.Separator()
                    imgui.Text(u8(u8:decode(rep_text)))
                    imgui.Separator()
                elseif (nick_rep == nil or pid_rep == nil or rep_text == nil or text_rep == nil) then
                    imgui.Text(u8"������ �� ����������.")
                end	
                imgui.InputText('##Answer', elements.answer, ffi.sizeof(elements.answer))
                imgui.SameLine()
                if imgui.Button(fa.ROTATE .. ("##RefreshText//RemoveText")) then  
                    imgui.StrCopy(elements.answer, '')
                end; Tooltip("���������/������� ���������� ���������� ���� �����.")
                imgui.SameLine()
                if imgui.Button(fa.TEXT_HEIGHT .. ("##SendColor")) then  
                    imgui.StrCopy(elements.answer, color())
                end; Tooltip("������ ��������� ���� ����� �������.")
                if #ffi.string(elements.answer) > 0 then  
                    imgui.SameLine()
                    if imgui.Button(fa.DOWNLOAD .. ('##SaveReport')) then  
                        imgui.StrCopy(elements.binder_text, ffi.string(elements.answer))
                        imgui.OpenPopup('BinderReport')
                    end 
                end
                if imgui.BeginPopupModal('BinderReport', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                    imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
                    imgui.Text(u8'�������� �����:'); imgui.SameLine()
                    imgui.PushItemWidth(130)
                    imgui.InputText("##elements.binder_name", elements.binder_name, ffi.sizeof(elements.binder_name))
                    imgui.PopItemWidth()
                    imgui.PushItemWidth(100)
                    imgui.Separator()
                    imgui.Text(u8'����� �����:')
                    imgui.PushItemWidth(300)
                    imgui.InputTextMultiline("##elements.binder_text", elements.binder_text, ffi.sizeof(elements.binder_text), imgui.ImVec2(-1, 110))
                    imgui.PopItemWidth()
        
                    imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
                    if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
                        imgui.StrCopy(elements.binder_name, '')
                        imgui.StrCopy(elements.binder_text, '')
                        imgui.CloseCurrentPopup()
                    end
                    imgui.SameLine()
                    if #ffi.string(elements.binder_name) > 0 and #ffi.string(elements.binder_text) > 0 then
                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
                        if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
                            if not EditOldBind then
                                local refresh_text = ffi.string(elements.binder_text):gsub("\n", "~")
                                table.insert(config.bind_name, ffi.string(elements.binder_name))
                                table.insert(config.bind_text, refresh_text)
                                if save() then
                                    sampAddChatMessage(tag .. '����"' ..u8:decode(ffi.string(elements.binder_name)).. '" ������� ������!', -1)
                                    imgui.StrCopy(elements.binder_name, '')
                                    imgui.StrCopy(elements.binder_text, '')
                                    imgui.CloseCurrentPopup()
                                end
                            else
                                local refresh_text = ffi.string(elements.binder_text):gsub("\n", "~")
                                table.insert(config.bind_name, getpos, ffi.string(elements.binder_name))
                                table.insert(config.bind_text, getpos, refresh_text)
                                table.remove(config.bind_name, getpos + 1)
                                table.remove(config.bind_text, getpos + 1)
                                if save() then
                                    sampAddChatMessage(tag .. '����"' ..u8:decode(ffi.string(elements.binder_name)).. '" ������� ��������������!', -1)
                                    imgui.StrCopy(elements.binder_name, '')
                                    imgui.StrCopy(elements.binder_text, '')
                                end
                                EditOldBind = false
                                imgui.CloseCurrentPopup()
                            end
                        end
        
                    end
                    imgui.EndChild()
                    imgui.EndPopup()
                end
                imgui.Separator()
                imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(0.5, 0.5))
                if imgui.Button(fa.EYE .. u8" ������ �� ��", imgui.ImVec2(250,30)) then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then  
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �����(�) ������ �� ����� ������! ' .. u8:decode(u8(config.main.prefix_for_answer)))
                        else 
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �����(�) ������ �� ����� ������! ')	
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0, nil)
                        wait(500)
                        if tonumber(id_punish) ~= nil and id_punish ~= nil then 
                            sampSendChat("/re " .. id_punish)
                        end	
                        elements.repwindow[0] = false
                    end)
                end
                imgui.SameLine()
                if imgui.Button(fa.BAN .. u8" �������", imgui.ImVec2(250,30)) then  
                    lua_thread.create(function() 
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then  
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ����� �������! ' .. u8:decode(u8(config.main.prefix_for_answer)))	
                        else 
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ����� �������! ')	
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.SameLine()
                if imgui.Button(fa.COMMENT .. u8" �������� ID", imgui.ImVec2(250,30)) then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then  
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ID ����������/������ � /report ' .. u8:decode(u8(config.main.prefix_for_answer)))
                        else 
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ID ����������/������ � /report ')	
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end	
                if imgui.Button(fa.CIRCLE_INFO .. u8" �������� ��", imgui.ImVec2(250,30)) then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then  
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ���� ������/������ ' .. u8:decode(u8(config.main.prefix_for_answer)))	
                        else 
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ���� ������/������ ')	
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end	
                imgui.SameLine()
                if imgui.Button(fa.SHARE .. u8' �� �� ������', imgui.ImVec2(250,30)) then
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� �������������� �� ����� https://forumrds.ru '.. u8:decode(u8(config.main.prefix_for_answer)))
                        else
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� �������������� �� ����� https://forumrds.ru ')
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.SameLine()
                if imgui.Button(fa.SHARE .. u8" �� �� ������", imgui.ImVec2(250,30)) then
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(500)
                        if elements.prefix_answer.v then
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� ������ �� ����� https://forumrds.ru '.. u8:decode(u8(config.main.prefix_for_answer)))
                        else
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� ������ �� ����� https://forumrds.ru ')
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end) 
                end
                if imgui.Button(fa.CIRCLE_INFO .. u8' ��� �� �������', imgui.ImVec2(250,30)) then
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� � ���.������ �� ������ https://forumrds.ru '.. u8:decode(u8(config.main.prefix_for_answer)))
                        else
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� � ���.������ �� ������ https://forumrds.ru')
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.SameLine()
                if imgui.Button(fa.TOGGLE_OFF .. u8' �� � ����', imgui.ImVec2(250,30)) then
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(500)
                        if elements.prefix_answer[0] then
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ����� �� � ����. '.. u8:decode(u8(config.main.prefix_for_answer)))
                        else
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ����� �� � ����. ')
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.SameLine()
                if imgui.Button(fa.CLOCK .. u8' ����/��� �����.', imgui.ImVec2(250,30)) then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(500)
                        if elements.prefix_answer[0] then
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �� ���� ��������� �� ������� ������. '.. u8:decode(u8(config.main.prefix_for_answer)))
                        else
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �� ���� ��������� �� ������� ������. ')
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.Separator()
                imgui.SetCursorPosX(imgui.GetWindowWidth() - 600)
                if imgui.Button(fa.CIRCLE_CHECK .. u8" �������� ������ ##SEND", imgui.ImVec2(400,30)) then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then  
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������� ��� ������! '.. u8:decode(u8(config.main.prefix_for_answer)))	
                        else 
                            sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������� ��� ������! ')	
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
                        elements.repwindow[0] = false
                    end)	
                end
                imgui.Separator()
                imgui.SetCursorPosX(imgui.GetWindowWidth() - 675)
                if imgui.Button(fa.CIRCLE_QUESTION .. u8" ������ �� AT", imgui.ImVec2(300,30)) then  
                    elements.select_menu = 1
                end
                imgui.SameLine()
                if imgui.Button(fa.CODE .. u8" ����������� ������", imgui.ImVec2(300,30)) then  
                    elements.select_menu = 2
                end
                imgui.Separator()
                if imgui.Checkbox(u8"��������� � �����", elements.prefix_answer) then 
                    config.main.prefix_answer = elements.prefix_answer[0]
                    save()
                end; Tooltip("������������� ��� ������ ����� �������� ����� ������ ��, ��� �� ���������������")
                imgui.StrCopy(elements.prefix_for_answer, u8(config.main.prefix_for_answer))
                if imgui.InputText(u8'���� ������', elements.prefix_for_answer, ffi.sizeof(elements.prefix_for_answer)) then  
                    config.main.prefix_for_answer = ffi.string(elements.prefix_for_answer)
                    save()
                end
                imgui.Separator()
                if imgui.Button(u8'��������') then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 0)
                        wait(200)
                        if elements.prefix_answer[0] then  
                            local settext = '{FFFFFF}' .. ffi.string(elements.answer) .. ' ' .. color() .. u8(config.main.prefix_for_answer)
                            sampSendDialogResponse(2351, 1, 0, u8:decode(settext))	
                        else
                            local settext = '{FFFFFF}' .. ffi.string(elements.answer)
                            sampSendDialogResponse(2351, 1, 0, u8:decode(settext))	
                        end
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.SameLine()
                if imgui.Button(fa.BAN .. u8" ���������") then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 1, 0)
                        wait(500)
                        sampSendDialogResponse(2350, 1, 1)
                        wait(500)
                        sampSendDialogResponse(2351, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetWindowWidth() - 130)
                if imgui.Button(fa.CLOSED_CAPTIONING .. u8" �������") then  
                    lua_thread.create(function()
                        sampSendDialogResponse(2349, 0, 0)
                        wait(500)
                        sampSendDialogResponse(2348, 0, 0)
                        elements.repwindow[0] = false
                    end)
                end
                imgui.PopStyleVar(1)
            end  
            if elements.select_menu == 1 then  
                imgui.BeginChild("##menuSecond", imgui.ImVec2(250, 380), true)
                if imgui.Button(fa.OBJECT_GROUP .. u8" �� ����-��/���-��") then  -- reporton key
                    elements.select_category = 1  
                end	
                if imgui.Button(fa.LIST .. u8" ������� (/help)") then  -- HelpCMD key
                    elements.select_category = 2 
                end 	
                if imgui.Button(fa.USERS .. u8" �����/�����") then  -- HelpGangFamilyMafia key
                    elements.select_category = 3
                end	
                if imgui.Button(fa.MAP_LOCATION .. u8" ���������") then  -- HelpTP key
                    elements.select_category = 4
                end	
                if imgui.Button(fa.BAG_SHOPPING .. u8" �������") then  -- HelpBuz key
                    elements.select_category = 5 
                end	
                if imgui.Button(fa.MONEY_BILL .. u8" �������/�������") then  -- HelpSellBuy key
                    elements.select_category = 6 
                end	
                if imgui.Button(fa.BOLT .. u8" ���������") then  -- HelpSettings key
                    elements.select_category = 7
                end	
                if imgui.Button(fa.HOUSE .. u8" ����") then  -- HelpHouses key
                    elements.select_category = 8 
                end	
                if imgui.Button(fa.PERSON .. u8" �����") then  -- HelpSkins key
                    elements.select_category = 9 
                end	
                if imgui.Button(fa.BARCODE .. u8" ��������� ������") then  -- HelpDefault key
                    elements.select_category = 10
                end	
                imgui.Separator()
                if imgui.Button(fa.BACKWARD .. u8" �����") then  
                    elements.select_menu = 0 
                end	
                imgui.EndChild()
                imgui.SameLine()
                imgui.BeginChild("##menuSelectable", imgui.ImVec2(460, 380), true)
                if elements.select_category == 0 then  
                    imgui.Text(u8"�������������/����������� ������ \n������ ���� �������� \n������ ��������������")
                end	
                if elements.select_category == 1 then  
                    for key, v in pairs(questions) do
                        if key == "reporton" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    elements.select_category = 0
                                    elements.select_menu = 0 
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 2 then 
                    for key, v in pairs(questions) do
                        if key == "HelpCmd" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 3 then  
                    for key, v in pairs(questions) do
                        if key == "HelpGangFamilyMafia" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 4 then  
                    for key, v in pairs(questions) do
                        if key == "HelpTP" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 6 then  
                    for key, v in pairs(questions) do
                        if key == "HelpSellBuy" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 10 then  
                    for key, v in pairs(questions) do
                        if key == "HelpDefault" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 9 then  
                    for key, v in pairs(questions) do
                        if key == "HelpSkins" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                 end
                             end
                        end
                    end
                end	
                if elements.select_category == 7 then  
                    for key, v in pairs(questions) do
                        if key == "HelpSettings" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 8 then  
                    for key, v in pairs(questions) do
                        if key == "HelpHouses" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                if elements.select_category == 5 then  
                    for key, v in pairs(questions) do
                        if key == "HelpBuz" then
                            for key_2, v_2 in pairs(questions[key]) do
                                if imgui.Button(key_2) then
                                    if not elements.prefix_answer[0] then
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    else
                                        lua_thread.create(function()
                                        local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
                                        sampSendDialogResponse(2349, 1, 0)
                                        sampSendDialogResponse(2350, 1, 0)
                                        wait(200)
                                        sampSendDialogResponse(2351, 1, 0, settext)
                                        wait(200)
                                        sampSendDialogResponse(2351, 0, 0)
                                        end)
                                    end
                                    report_ans = 0
                                end
                            end
                        end
                    end
                end	
                imgui.EndChild()
            end
            if elements.select_menu == 2 then  
                if #config.bind_name > 0 then  
                    for key, name in pairs(config.bind_name) do  
                        if imgui.Button(name .. '##' .. key) then  
                            elements.select_menu = 0 
                            SendBindReport(key)
                        end  
                    end 
                else 
                    imgui.Text(u8"����� �����! :(")
                    if imgui.Button(u8"������� ����") then  
                        imgui.OpenPopup('BinderReport')
                    end  
                end 
                if imgui.BeginPopupModal('BinderReport', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                    imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
                    imgui.Text(u8'�������� �����:'); imgui.SameLine()
                    imgui.PushItemWidth(130)
                    imgui.InputText("##elements.binder_name", elements.binder_name, ffi.sizeof(elements.binder_name))
                    imgui.PopItemWidth()
                    imgui.PushItemWidth(100)
                    imgui.Separator()
                    imgui.Text(u8'����� �����:')
                    imgui.PushItemWidth(300)
                    imgui.InputTextMultiline("##elements.binder_text", elements.binder_text, ffi.sizeof(elements.binder_text), imgui.ImVec2(-1, 110))
                    imgui.PopItemWidth()
        
                    imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
                    if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
                        imgui.StrCopy(elements.binder_name, '')
                        imgui.StrCopy(elements.binder_text, '')
                        imgui.CloseCurrentPopup()
                    end
                    imgui.SameLine()
                    if #ffi.string(elements.binder_name) > 0 and #ffi.string(elements.binder_text) > 0 then
                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
                        if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
                            if not EditOldBind then
                                local refresh_text = ffi.string(elements.binder_text):gsub("\n", "~")
                                table.insert(config.bind_name, ffi.string(elements.binder_name))
                                table.insert(config.bind_text, refresh_text)
                                if save() then
                                    sampAddChatMessage(tag .. '����"' ..u8:decode(ffi.string(elements.binder_name)).. '" ������� ������!', -1)
                                    imgui.StrCopy(elements.binder_name, '')
                                    imgui.StrCopy(elements.binder_text, '')
                                    imgui.CloseCurrentPopup()
                                end
                            else
                                local refresh_text = ffi.string(elements.binder_text):gsub("\n", "~")
                                table.insert(config.bind_name, getpos, ffi.string(elements.binder_name))
                                table.insert(config.bind_text, getpos, refresh_text)
                                table.remove(config.bind_name, getpos + 1)
                                table.remove(config.bind_text, getpos + 1)
                                if save() then
                                    sampAddChatMessage(tag .. '����"' ..u8:decode(ffi.string(elements.binder_name)).. '" ������� ��������������!', -1)
                                    imgui.StrCopy(elements.binder_name, '')
                                    imgui.StrCopy(elements.binder_text, '')
                                end
                                EditOldBind = false
                                imgui.CloseCurrentPopup()
                            end
                        end
        
                    end
                    imgui.EndChild()
                    imgui.EndPopup()
                end
                imgui.Separator()
                if imgui.Button(fa.BACKWARD .. u8" �����") then  
                    elements.select_menu = 0 
                end
            end
        imgui.End()
    end
)

function color() -- �������, ����������� ������������� � ����� ���������� ����� � ������� ������������ os.time()
	mcolor = "{"
	math.randomseed( os.time() )
	for i = 1, 6 do
		local b = math.random(1, 16)
		if b == 1 then
			mcolor = mcolor .. "A"
		end
		if b == 2 then
			mcolor = mcolor .. "B"
		end
		if b == 3 then
			mcolor = mcolor .. "C"
		end
		if b == 4 then
			mcolor = mcolor .. "D"
		end
		if b == 5 then
			mcolor = mcolor .. "E"
		end
		if b == 6 then
			mcolor = mcolor .. "F"
		end
		if b == 7 then
			mcolor = mcolor .. "0"
		end
		if b == 8 then
			mcolor = mcolor .. "1"
		end
		if b == 9 then
			mcolor = mcolor .. "2"
		end
		if b == 10 then
			mcolor = mcolor .. "3"
		end
		if b == 11 then
			mcolor = mcolor .. "4"
		end
		if b == 12 then
			mcolor = mcolor .. "5"
		end
		if b == 13 then
			mcolor = mcolor .. "6"
		end
		if b == 14 then
			mcolor = mcolor .. "7"
		end
		if b == 15 then
			mcolor = mcolor .. "8"
		end
		if b == 16 then
			mcolor = mcolor .. "9"
		end
	end
	--print(mcolor)
	mcolor = mcolor .. '}'
	return mcolor
end 

function royalblue()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding       = ImVec2(4, 6)
	style.WindowRounding      = 0
	style.ChildRounding = 3
	style.FramePadding        = ImVec2(5, 4)
	style.FrameRounding       = 2
	style.ItemSpacing         = ImVec2(3, 3)
	style.TouchExtraPadding   = ImVec2(0, 0)
	style.IndentSpacing       = 21
	style.ScrollbarSize       = 14
	style.ScrollbarRounding   = 16
	style.GrabMinSize         = 10
	style.GrabRounding        = 5
	style.WindowTitleAlign    = ImVec2(0.50, 0.50)
	style.ButtonTextAlign     = ImVec2(0, 0)

	colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.60, 0.60, 0.60, 1.00)
	colors[clr.WindowBg] = ImVec4(0.11, 0.10, 0.11, 1.00)
	colors[clr.ChildBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg] = ImVec4(0.30, 0.30, 0.30, 1.00)
	colors[clr.Border] = ImVec4(0.86, 0.86, 0.86, 1.00)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ImVec4(0.21, 0.20, 0.21, 0.60)
	colors[clr.FrameBgHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.01, 0.26, 0.37, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.00, 0.46, 0.65, 0.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.00, 0.46, 0.65, 0.44)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 0.46, 0.65, 0.74)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.CheckMark] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.SliderGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.Button] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.Header] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ResizeGrip] = ImVec4(1.00, 1.00, 1.00, 0.30)
	colors[clr.ResizeGripHovered] = ImVec4(1.00, 1.00, 1.00, 0.60)
	colors[clr.ResizeGripActive] = ImVec4(1.00, 1.00, 1.00, 0.90)
	colors[clr.PlotLines] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotLinesHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotHistogram] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotHistogramHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.TextSelectedBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ModalWindowDimBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
end

function SendBindReport(value)
    lua_thread.create(function()
        if value ~= 1 then  
            for text_report in config.bind_text[value]:gmatch('[^~]+') do  
                sampSendDialogResponse(2349, 1, 0)
                sampSendDialogResponse(2350, 1, 0)
                wait(200)
                sampSendDialogResponse(2351, 1, 0, u8:decode(tostring(text_report))) -- ���������� ����, �������������� ���������������� ����������� ������ � ��������� � ������!
                wait(200)
                sampCloseCurrentDialogWithButton(1)
            end  
            value = -1
        end
    end)
end

function EXPORTS.BinderEdit()
    if imgui.Button(u8'������� ���� �������������� � ��������.') then  
        imgui.OpenPopup('BinderEditEx')
    end
    if imgui.BeginPopupModal('BinderEditEx', _, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize) then
        imgui.BeginChild('##ListBinders', imgui.ImVec2(200, 480), true)
            if #config.bind_name > 0 then  
                for key, name in pairs(config.bind_name) do 
                    if imgui.Button(name.. '##' ..key) then  
                        EditOldBind = true  
                        getpos = key  
                        local returnwrapped = tostring(config.bind_text[key]):gsub('~', '\n')
                        imgui.StrCopy(elements.binder_text, returnwrapped)
                        imgui.StrCopy(elements.binder_name, tostring(config.bind_name[key]))
                    end
                    imgui.SameLine()
                    if imgui.Button(fa.TRASH.. "##"..key) then  
                        sampAddChatMessage(tag .. '���� "' ..u8:decode(config.bind_name[key]) .. '" ������!', -1)
                        table.remove(config.bind_name, key)
                        table.remove(config.bind_text, key) 
                        inicfg.save(config, directIni)
                    end  
                end 
            end 
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("##EditBinder", imgui.ImVec2(500, 480), true)
            imgui.Text(u8'�������� �����:'); imgui.SameLine()
            imgui.PushItemWidth(130)
            imgui.InputText("##elements.binder_name", elements.binder_name, ffi.sizeof(elements.binder_name))
            imgui.PopItemWidth()
            imgui.PushItemWidth(100)
            imgui.Separator()
            imgui.Text(u8'����� �����:')
            imgui.PushItemWidth(300)
            imgui.InputTextMultiline("##elements.binder_text", elements.binder_text, ffi.sizeof(elements.binder_text), imgui.ImVec2(-1, 110))
            imgui.PopItemWidth()

            imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
            if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
                imgui.StrCopy(elements.binder_name, '')
                imgui.StrCopy(elements.binder_text, '')
            end
            imgui.SameLine()
            if #ffi.string(elements.binder_name) > 0 and #ffi.string(elements.binder_text) > 0 then
                imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
                if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
                    if not EditOldBind then
                        local refresh_text = ffi.string(elements.binder_text):gsub("\n", "~")
                        table.insert(config.bind_name, ffi.string(elements.binder_name))
                        table.insert(config.bind_text, refresh_text)
                        if save() then
                            sampAddChatMessage(tag .. '����"' ..u8:decode(ffi.string(elements.binder_name)).. '" ������� ������!', -1)
                            imgui.StrCopy(elements.binder_name, '')
                            imgui.StrCopy(elements.binder_text, '')
                        end
                    else
                        local refresh_text = ffi.string(elements.binder_text):gsub("\n", "~")
                        table.insert(config.bind_name, getpos, ffi.string(elements.binder_name))
                        table.insert(config.bind_text, getpos, refresh_text)
                        table.remove(config.bind_name, getpos + 1)
                        table.remove(config.bind_text, getpos + 1)
                        if save() then
                            sampAddChatMessage(tag .. '����"' ..u8:decode(ffi.string(elements.binder_name)).. '" ������� ��������������!', -1)
                            imgui.StrCopy(elements.binder_name, '')
                            imgui.StrCopy(elements.binder_text, '')
                        end
                        EditOldBind = false
                    end
                end
            end
        imgui.EndChild()
        if imgui.Button(u8'������� ����', imgui.ImVec2(750, 30)) then  
            imgui.CloseCurrentPopup()
        end
        imgui.End()
    end
end