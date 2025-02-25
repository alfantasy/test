require 'lib.moonloader'
require 'module.commands'

local dlstatus = require('moonloader').download_status
local fflags = require('moonloader').font_flag
local imgui = require 'mimgui' -- ������������� ���������� Moon ImGUI
local encoding = require 'encoding' -- ������ � �����������
local sampev = require 'lib.samp.events' -- ���������� ������� SA:MP � ������������/���������/�������� �.�. �������
local mim_addons = require 'mimgui_addons' -- ���������� ������� ��� ���������� mimgui
local fa = require 'fAwesome6_solid' -- ������ � ������� �� ������ FontAwesome 6
local inicfg = require 'inicfg' -- ������ � ��������
local memory = require 'memory' -- ������ � ������� ��������
local ffi = require 'ffi' -- ���������� ������ � ����������� ����
local http = require('socket.http') -- ������ � ��������� HTTP
local ltn12 = require('ltn12') -- ������ � �������� ��������
local atlibs = require 'libsfor' -- ������������� ���������� InfoSecurity ��� AT (libsfor)
local toast_ok, toast = pcall(import, 'lib/mimtoasts.lua') -- ���������� �����������.
local question_ok, QuestionAnswer = pcall(import, 'QuestionAnswer.lua') -- ������������� ���������� �������� ������
local automute_ok, AutoMuteLib = pcall(import, 'module/automute.lua') -- ���������� ��������
local other_ok, plother = pcall(import, 'module/other.lua') -- ���������� �������������� �������
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ���������� ��������� U8 ��� �������, �� � ����� ���������� (��� ����������)

-- ## ���� ��������� ���������� ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- ��������� ����������, ������� ������������ ��� AT
-- ## ���� ��������� ���������� ## --

-- ## ��������������� ������ AT. ����������, ������ � ����������. ## --
local urls = {
	['main'] = "https://raw.githubusercontent.com/alfantasy/atad/main/AdminTool.lua",
	['libsfor'] = 'https://raw.githubusercontent.com/alfantasy/atad/main/libsfor.lua',
	['report'] = 'https://raw.githubusercontent.com/alfantasy/atad/main/QuestionAnswer.lua',
	['upat'] = 'https://raw.githubusercontent.com/alfantasy/atad/main/upat.ini',
	['clogger'] = 'https://raw.githubusercontent.com/alfantasy/atad/main/clogger.lua',
	['automute'] = 'https://raw.githubusercontent.com/alfantasy/atad/main/module/automute.lua',
	['commands'] = 'https://raw.githubusercontent.com/alfantasy/atad/main/module/commands.lua',
}
local paths = {
	['main'] = getWorkingDirectory() .. '/AdminTool.lua',
	['libsfor'] = getWorkingDirectory() .. '/lib/libsfor.lua',
	['report'] = getWorkingDirectory() .. '/QuestionAnswer.lua',
	['upat'] = getWorkingDirectory() .. '/upat.ini',
	['clogger'] = getWorkingDirectory() .. '/clogger.lua',
	['automute'] = getWorkingDirectory() .. '/module/automute.lua',
	['commands'] = getWorkingDirectory() .. '/module/commands.lua',
}

function downloadFile(url, path)
	local response = {}
	local _, status_code, _ = http.request{
	  url = url,
	  method = "GET",
	  sink = ltn12.sink.file(io.open(path, "wb")),
	  headers = {
		["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0;Win64) AppleWebkit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
  
	  },
	}
	if status_code == 200 then
		return true
	else
		return false
	end
end

local version_control = 7
local version_text = '2.1'
-- ## ��������������� ������ AT. ����������, ������ � ����������. ## --

-- ## ������� ������� � ���������� VARIABLE ## --
local new = imgui.new

local directIni = 'AdminTool/settings.ini'
local eventsIni = 'AdminTool/events.ini'

local config = inicfg.load({
    settings = {
        custom_recon = false,
		autologin = false,
		password_to_login = '',
		auto_online = false,
		adminforms = false, 
		autoforms = false,
		render_date = false,
    },
}, directIni)
inicfg.save(config, directIni)

local cfgevents = inicfg.load({
    bind_name = {},
    bind_text = {},
    bind_vdt = {},
    bind_coords = {},
}, eventsIni)
inicfg.save(cfgevents, eventsIni)

function EventsSave()
	inicfg.save(cfgevents, eventsIni)
	toast.Show(u8'���������� ����� INI �� ATEvents ������ �������.', toast.TYPE.OK, 5)
	return true
end

function save()
    inicfg.save(config, directIni)
    toast.Show(u8"���������� �������� ������ �������.", toast.TYPE.OK, 5)
end

local elements = {
    imgui = {
        main_window = new.bool(false),
        recon_window = new.bool(false),
        menu_selectable = new.int(0),
        btn_size = imgui.ImVec2(70,0),
		selectable = 0,
        stream = new.char[65536](),
        input_word = new.char[500](),
    },
    boolean = {
		adminforms = new.bool(config.settings.adminforms),
		autoforms = new.bool(config.settings.autoforms),
        recon = new.bool(config.settings.custom_recon),
		autologin = new.bool(config.settings.autologin),
		auto_online = new.bool(config.settings.auto_online),
		render_date = new.bool(config.settings.render_date),
    },
	buffers = {
		password = new.char[50](config.settings.password_to_login),
		name = new.char[126](),
        rules = new.char[65536](),
        win_pl = new.char[32](),
        name = new.char[256](),
        text = new.char[65536](),
        vdt = new.char[32](),
        coord = new.char[32](),
	},
}

local show_password = false -- ��������/������ ������ � ����������
local control_spawn = false -- �������� ������. ������������ ��� ������� �������

local access_file = 'AdminTool/accessadm.ini'
local main_access = inicfg.load({
	settings = {
		ban = false,
		mute = false, 
		jail = false,
		makeadmin = false,
		agivemoney = false,
	},
}, access_file)
inicfg.save(main_access, access_file)
-- ## ������� ������� � ���������� VARIABLE ## --

-- ## mimgui ## --
function Tooltip(text)
    if imgui.IsItemClicked() then
        imgui.BeginTooltip()
        imgui.Text(u8(text))
        imgui.EndTooltip()
    end 
end

imgui.OnInitialize(function()   
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	imgui.GetIO().Fonts:Clear()
	imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '/lib/mimgui/trebucbd.ttf', 24.0, _, glyph_ranges)
	fa.Init(24)
end)

local sw, sh = getScreenResolution()
-- ## mimgui ## --

-- ## ���� ���������� ��������� � CustomReconMenu ## --
local info_to_player = {}
local recon_info = { "��������: ", "�����: ", "�� ������: ", "��������: ", "����: ", "�������: ", "�������: ", "������� ��������: ", "����� � ���: ", "P.Loss: ", "������� VIP: ", "��������� �����: ", "�����-�����: ", "��������: ", '�����-���: '}
local right_recon = new.bool(true)
local accept_load_recon = false 
local recon_id = -1
local control_to_player = false

local ids_recon = {}
local text_recon = {'STATS', 'MUTE', 'KICK', 'BAN', 'JAIL', 'CLOSE'}
for i = 190, 236 do 
	table.insert(ids_recon, i, #ids_recon+1)
end
local refresh_button_textdraw = 0
local info_textdraw_recon = 0

local select_recon = 0 
local recon_punish = 0
-- ## ���� ���������� ��������� � CustomReconMenu ## --

local reasons = { 
	"/mute","/jail","/iban","/ban","/kick","/skick","/sban", "/muteakk", "/offban", "/banakk"
}

local lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text

function main()

    if toast_ok then 
        toast.Show(u8"AdminTool ���������������.\n��� ������ � �����������, �������: /tool", toast.TYPE.INFO, 5)
    else 
        sampAddChatMessage(tag .. 'AdminTool ������� ���������������. ���������: /tool', -1)
        print(tag .. "����� � ��������� �����������")
    end

	local response_update_check = downloadFile(urls['upat'], paths['upat'])
	if response_update_check then 
		local response = http.request(urls['main']) 
		local currentVersionFile = io.open(paths['main'], 'r')
		local currentVersion = currentVersionFile:read("*a")
		currentVersionFile:close()
		updateIni = inicfg.load(nil, paths['upat'])
		if tonumber(updateIni.info.version) > version_control and response ~= currentVersion then  
			if toast_ok then  
				toast.Show(u8'�������� ����������.\nAT �������� ���������� �������������.', toast.TYPE.INFO, 5)
			else 
				print(tag .. '����� � ��������� �����������.')
				sampAddChatMessage(tag .. '�������� ����������. AT �������� ��������������!', -1)
			end 
			
			local response_main = downloadFile(urls['main'], paths['main'])
			if response_main then  
				sampAddChatMessage(tag .. '�������� ������ �� ������.', -1)
			end  
			local response_lib = downloadFile(urls['libsfor'], paths['libsfor'])
			if response_lib then  
				sampAddChatMessage(tag .. '���������� � �� ������� �������.', -1)
			end  
			local response_questans = downloadFile(urls['report'], paths['report'])
			if response_questans then  
				sampAddChatMessage(tag .. '������ ��� �������� ������.', -1)
			end  
			local response_clogger = downloadFile(urls['clogger'], paths['clogger'])
			if response_clogger then  
				sampAddChatMessage(tag .. '���-������ ������', -1)
			end
			local response_automute = downloadFile(urls['automute'], paths['automute'])
			if response_automute then
				sampAddChatMessage(tag .. '������� ������', -1)
			end
			local response_commands = downloadFile(urls['commands'], paths['commands'])
			if response_commands then
				sampAddChatMessage(tag .. '���������� ������ �������', -1)
			end
			sampAddChatMessage(tag .. '������� ������������ ��������!', -1)
			reloadScripts()
		else 
			if toast_ok then  
				toast.Show(u8'� ��� ����������� ���������� ������ ��.\n������ AT: ' .. version_text, toast.TYPE.INFO, 5)
			else 
				print(tag .. '����� � ��������� �����������.')
				sampAddChatMessage(tag .. '� ��� ����������� ���������� ������ ��. ������ ��: ' .. version_text, -1)
			end
		end  
		--os.remove(paths['upat'])
	end

    load_recon = lua_thread.create_suspended(loadRecon)
	send_online = lua_thread.create_suspended(drawOnline)
	draw_date = lua_thread.create_suspended(drawDate)
	send_online:run()
	draw_date:run()

	sampRegisterChatCommand('pac', function()
		sampAddChatMessage(tag .. '������������ ��������. ���� � ������, ���� ��� AutoLogin', -1)
		sampSendChat('/access')
	end)

	for key in pairs(cmd_massive) do  
		sampRegisterChatCommand(key, function(arg)
			if #arg > 0 then  
				if cmd_massive[key].cmd == '/iban' or cmd_massive[key].cmd == '/ban' then  
					if main_access.settings.ban then  
						sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
						sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
						sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					else 
						sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					end
				end
				if cmd_massive[key].cmd == '/siban' then
					if main_access.settings.ban then
						sampSendChat(cmd_massive[key].cmd .. '' .. arg .. ' ' .. cmd_massive[key].time .. ' ' .. cmd_massive[key].reason)
					else
						sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					end
				end
				if cmd_massive[key].cmd == '/mute' then
					if main_access.settings.mute then
						if arg:find('(%d+) (%d+)') then
							id_punish, multiply_punish = arg:match('(%d+) (%d+)')
							sampSendChat(cmd_massive[key].cmd .. " " .. id_punish .. " " .. tostring(tonumber(cmd_massive[key].time)*tonumber(multiply_punish)) .. " " .. cmd_massive[key].reason .. " x" .. multiply_punish)
						else
							sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
						end
					else
						sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					end
				end
				if cmd_massive[key].cmd == '/rmute' then
					if main_access.settings.mute then
						if arg:find('(%d+) (%d+)') then
							id_punish, multiply_punish = arg:match('(%d+) (%d+)')
							sampSendChat(cmd_massive[key].cmd .. " " .. id_punish .. " " .. tostring(tonumber(cmd_massive[key].time)*tonumber(multiply_punish)) .. " " .. cmd_massive[key].reason .. " x" .. multiply_punish)
						else
							sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
						end
					else
						sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					end
				end
				if cmd_massive[key].cmd == '/jail' then  
					if main_access.settings.jail then
						if arg:find('(%d+) (%d+)') then
							id_punish, multiply_punish = arg:match('(%d+) (%d+)')
							sampSendChat(cmd_massive[key].cmd .. " " .. id_punish .. " " .. tostring(tonumber(cmd_massive[key].time)*tonumber(multiply_punish)) .. " " .. cmd_massive[key].reason .. " x" .. multiply_punish)
						else
							sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
						end
					else
						sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					end
				end
				if cmd_massive[key].cmd == '/kick' then 
					sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].reason)
				end 
				if cmd_massive[key].cmd == '/jailakk' or cmd_massive[key].cmd == '/offban' or cmd_massive[key].cmd == '/muteakk' or cmd_massive[key].cmd == '/rmuteakk' then  
					sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
				end
			end
		end)
	end
    -- ## ����������� ��������������� ������ ## --
    sampRegisterChatCommand("u", cmd_u)
	sampRegisterChatCommand("uu", cmd_uu)
	sampRegisterChatCommand("uj", cmd_uj)
	sampRegisterChatCommand("as", cmd_as)
	sampRegisterChatCommand("stw", cmd_stw)
	sampRegisterChatCommand("ru", cmd_ru)
	sampRegisterChatCommand('rcl', function()
        toast.Show(u8"������� ���� ��������.", toast.TYPE.WARN)
        memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
        memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
        memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
    end)
	sampRegisterChatCommand('spp', function()
        local user_to_stream = playersToStreamZone()
        for _, v in pairs(user_to_stream) do 
            sampSendChat('/aspawn ' .. v)
        end
    end)
	sampRegisterChatCommand("aheal", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0)
			wait(200)
			sampSendDialogResponse(500, 1, 4)
			wait(200)
			sampSendDialogResponse(500, 0, nil)
		end)
	end)
	sampRegisterChatCommand("akill", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0)
			wait(200)
			sampSendDialogResponse(500, 1, 7)
			wait(200)
			sampSendDialogResponse(48, 1, _, "kill")
			wait(200)
			sampSendDialogResponse(48, 0, nil)
		end)
	end)
	sampRegisterChatCommand('sl', function(id)
		sampSendChat('/slap ' .. id)
	end)
	sampRegisterChatCommand('gh', function(id)
		sampSendChat('/gethere ' .. id)
	end)
	sampRegisterChatCommand('ib', function(id)
		sampSendChat('/iunban ' .. id)
	end)
	sampRegisterChatCommand('ubi', function(id)
		sampSendChat('/unbanip ' .. id)
	end)
	sampRegisterChatCommand('auj', function(nick)
		sampSendChat('/jailakk ' .. nick .. ' 5 ������/��������')
	end)
	sampRegisterChatCommand('au', function(nick)
		sampSendChat('/muteakk ' .. nick .. ' 5 ������/������')
	end)
	sampRegisterChatCommand('aru', function(nick)
		sampSendChat('/rmuteakk ' .. nick .. ' 5 ������/������')
	end)
    -- ## ����������� ��������������� ������ ## --    

	sampRegisterChatCommand('checksh', function()
		sampAddChatMessage(tag .. "������� ����������: X - " .. sw .. " | Y - " .. sh, -1)
		sampAddChatMessage(tag .. "������ ������� ������������� ��� debug ���������� ���� ����.����������", -1)
	end)

    sampRegisterChatCommand("tool", function()
        elements.imgui.main_window[0] = not elements.imgui.main_window[0]
        elements.imgui.menu_selectable[0] = 0
    end)

	sampRegisterChatCommand("al", function(id)
		sampSendChat("/ans " .. id .. " ��������� ��������������! �� ������ ������ /alogin")
		sampSendChat("/ans " .. id .. " ����������, ������� /alogin � ������� ���� �����.")
	end)

    while true do
        wait(0)

		if control_spawn and elements.boolean.autologin[0] then  
			sampAddChatMessage(tag .. "AutoLogin �������� � ������� 15 ������ ����� ������.", -1)
			sampAddChatMessage(tag .. "��������...", -1)
			wait(15000)
			sampSendChat('/alogin ' .. u8:decode(config.settings.password_to_login))
			control_spawn = false
			sampSendChat('/access')
		end

        -- if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
		-- 	imgui.ShowCursor = not imgui.ShowCursor
		-- 	wait(600)
        -- end

        if not sampIsPlayerConnected(recon_id) then  
            elements.imgui.recon_window[0] = false  
            recon_id = -1 
        end
        
    end
end

-- ## ���� ������� � ��������������� �������� ## --
function cmd_u(arg)
	sampSendChat("/unmute " .. arg)
end  

function cmd_uu(arg)
    sampSendChat("/unmute " .. arg)
    sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����")
end

function cmd_uj(arg)
    sampSendChat("/unjail " .. arg)
    sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����")
end

function cmd_stw(arg)
	sampSendChat("/setweap " .. arg .. " 38 5000 ")
end  

function cmd_as(arg)
	sampSendChat("/aspawn " .. arg)
end

function cmd_ru(arg)
	sampSendChat("/unrmute " .. arg)
	sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����.")
end
-- ## ���� ������� � ��������������� �������� ## --


-- ## �������������� ������ /online ## --
function drawOnline()
    if elements.boolean.auto_online[0] then 
        while true do 
			sampAddChatMessage(tag .. "������ ���������� AutoOnline. �������� ������.", -1)
			wait(62000)
			sampSendChat("/online")
			wait(100)
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1)
			sampSendDialogResponse(1098, 0, -1)
			wait(650)
            wait(1)
        end	
    end
end	
-- ## �������������� ������ /online ## --

-- ## ���� ������� ��� ������� SA:MP ## --
function sampev.onServerMessage(color, text)
	local check_string = string.match(text, "[^%s]+")

	lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")
	--lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%](.+)%[(%d+)%]: {FFFFFF}(.+)")

	if text:find("%[A%] ������������� (.+)%[(%d+)%] %(%d+ level%) ������������� � ����� ������") then  
		nick, _ = text:match("%[A%] ������������� (.+)%[(%d+)%] %(%d+ level%) ������������� � ����� ������")
		if atlibs.getMyNick() == nick then  
			sampAddChatMessage(tag .. '������ ����', -1)
			sampSendChat('/access')
		end  
	end

	if text:find("�� ������� ��������������!") then  
		if elements.boolean.autologin[0] then 
        	control_spawn = true
		end
    	return true
    end
    if text:find("�� ��� ������������ ��� �������������") then  
		if elements.boolean.autologin[0] then 
			control_spawn = false   
		end
    	return true
    end
	if text:find("���������� ��������������!") then  
		if elements.boolean.autologin[0] then  
			control_spawn = true  
		end  
		return true  
	end 

	function start_forms()
		sampRegisterChatCommand('fac', function()
			lua_thread.create(function()
				sampSendChat('/a AT - ����� �������!')
				wait(500)
				sampSendChat(''..adm_form)
				adm_form = ''
			end)
		end)
		sampRegisterChatCommand('fn', function()
			sampSendChat('/a AT - ����� ���������!')
			adm_form = ''
		end)
	end

	if elements.boolean.adminforms[0] and lc_text ~= nil then
		for k, v in ipairs(reasons) do  
			if lc_text:match(v) ~= nil then  
				if lc_text:find("/(.+) (%d+) (%d+) (.+)") or lc_text:find('/(.+) (.+) (%d+) (.+)') then  
					if lc_text:find(lc_nick) then  
						adm_form = lc_text 
					else 
						adm_form = lc_text .. ' // ' .. lc_nick  
					end 
				else 
					adm_form = ''
				end
				if #adm_form > 1 then 
					toast.Show(u8'������ �����! \n /fac - ������� | /fn - ���������', toast.TYPE.INFO, 5)
					sampAddChatMessage(tag .. '�����: ' .. adm_form, -1)
					if elements.boolean.autoforms[0] and not isGamePaused() and not isPauseMenuActive() then  
						lua_thread.create(function()
							sampSendChat('/a AT - ����� �������!')
							wait(500)
							sampSendChat(''..adm_form)
							adm_form = ''
						end) 
					elseif not isGamePaused() and not isPauseMenuActive() then  
						start_forms()
					end 
				end
			end 
		end 
	end 
	-- ## ������ � �������. ������� ��������� � ����������� ������������.

	local check_nick, check_id, basic_color, check_text = string.match(text, "(.+)%((.+)%): {(.+)}(.+)") -- ������ �������� ������� ���� � �������� � �� �������
end
-- ## ���� ������� ��� ������� SA:MP ## --


-- ## ������� ��� ���������� ������ ## --
function textSplit(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(recon_id) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end
-- ## ������� ��� ���������� ������ ## --

-- ## �������� ������� ������ ## -- 
function loadRecon()
    wait(3000)
    accept_load_recon = true
end
function sampev.onTextDrawSetString(id, text) 
    if id == info_textdraw_recon and elements.boolean.recon[0] then  
        info_to_player = textSplit(text, "~n~")
    end
end

function sampev.onSendCommand(command)
    id = string.match(command, "/re (%d+)")
	if elements.boolean.recon[0] then
		if id ~= nil then  
			control_to_player = true  
			if control_to_player then  
				load_recon:run()
				accept_load_recon = false
				elements.imgui.recon_window[0] = true 
			end 
			recon_id = id
		end
		if command == '/reoff' then  
			control_to_player = false  
			elements.imgui.recon_window[0] = false  
			recon_id = -1
			select_recon = 0
		end
	end
end


-- ## �����, ���������� �� �������. � ���������, ����� ��������� �������� ������ �������� �� ������.
function sampev.onShowDialog(id, style, title, button1, button2, text)
	if title:find(atlibs.getMyNick()) and id == 8991 then  
			lua_thread.create(function()
			text = atlibs.textSplit(text, '\n')
			newtext = nil 
			for i, v in ipairs(text) do  
				if v:find('��� ���� �����') and v:find('�������') then  
					main_access.settings.ban = true
					inicfg.save(main_access, access_file)
				elseif v:find('������ ����') and v:find('�������') then  
					main_access.settings.mute = true
					inicfg.save(main_access, access_file)
				elseif v:find('������ ������') and v:find('�������') then  
					main_access.settings.jail = true
					inicfg.save(main_access, access_file)
				end
				if v:find('��� ���� �����') and v:find('�����������') then  
					main_access.settings.ban = false
					inicfg.save(main_access, access_file)
				elseif v:find('������ ����') and v:find('�����������') then  
					main_access.settings.mute = false
					inicfg.save(main_access, access_file)
				elseif v:find('������ ������') and v:find('�����������') then  
					main_access.settings.jail = false
					inicfg.save(main_access, access_file)
				end
			end
			sampAddChatMessage(tag .. '/access �������������. ��� ��������� ����� /access, ��������� ��������� ������� � ����������.', -1)
			wait(1)
			sampSendDialogResponse(8991, 0, -1)
		end)
	end
end

function sampev.onShowTextDraw(id, data)
    if elements.boolean.recon[0] then 
		if data.text:find('~g~::Health:~n~') then  
			return false
		end
		if data.text:find('REFRESH') then  
			refresh_button_textdraw = id  
			return false  
		end
		if data.text:find('(%d+) : (%d+)') then  
			info_textdraw_recon = id  
			return false
		end
		for _, v in pairs(text_recon) do  
			if data.text:find(v) then  
				if id ~= 244 then 
					return false  
				end
			end 
		end
		if data.text:find("(%d+)") then  
			if id == 2052 then  
				return false  
			end  
		end
		if ids_recon[id] then  
			return false 
		end
		if data.text:find('CLOSE') or id == 244 then  
			return true  
		end
    end
end
-- ## �������� ������� ������ ## -- 

-- ## ������ Date and Time ## --
function drawDate()
	font = renderCreateFont('Arial', 20, fflags.BOLD)
	if elements.boolean.render_date[0] then  
		while true do  
			renderFontDrawText(font,'{FFFFFF}' .. (os.date("%d.%m.%y | %H:%M:%S", os.time())),10,sh-30,0xCCFFFFFF)

			wait(1)
		end
	end
end
-- ## ������ Date and Time ## --


local ReconWindow = imgui.OnFrame(
    function() return elements.imgui.recon_window[0] end, 
    function(player)
        
        royalblue()

        imgui.SetNextWindowPos(imgui.ImVec2(sw / 3, sh / 1), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(100, 300), imgui.Cond.FirstUseEver)

        imgui.LockPlayer = false  

        imgui.Begin("reconmenu", elements.imgui.recon_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize)
            if control_to_player then  
                if imgui.Button(u8"����������") then  
                    sampSendChat('/aspawn ' .. recon_id)
                end
				imgui.SameLine()
                if imgui.Button(u8"��������") then  
                    -- sampSendClickTextdraw(156)
					sampSendClickTextdraw(refresh_button_textdraw)
                end
				imgui.SameLine()
                if imgui.Button(u8"��������") then  
                    sampSendChat("/slap " .. recon_id)
                end
				imgui.SameLine()
                if imgui.Button(u8"����������\n�����������") then  
                    sampSendChat("/freeze " .. recon_id)
                end
				imgui.SameLine()
                if imgui.Button(u8"�����") then
                    sampSendChat("/reoff ")
                    control_to_player = false
                    elements.imgui.recon_window[0] = false
                end
				imgui.SetCursorPosX(100)
				if imgui.Button(u8"��������") then  
					select_recon = 1 
					recon_punish = 1
				end
				imgui.SameLine()
				if imgui.Button(u8"��������") then  
					select_recon = 1
					recon_punish = 2
				end
				imgui.SameLine()
				if imgui.Button(u8"�������") then  
					select_recon = 1
					recon_punish = 3
				end
            end
        imgui.End()

        if right_recon[0] then  
            imgui.SetNextWindowPos(imgui.ImVec2(sw - 200, sh - 310), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(350, 550), imgui.Cond.FirstUseEver)

            imgui.Begin(u8"���������� �� ������", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar)
				if accept_load_recon then
					if not sampIsPlayerConnected(recon_id) then 
						recon_nick = '-'
					else
						recon_nick = sampGetPlayerNickname(recon_id)
					end					
					imgui.BeginMenuBar()
						if imgui.Button(fa.USER_CHECK) then  
							select_recon = 0 
						end  
						if imgui.Button(fa.BAN) then  
							select_recon = 1 
						end
					imgui.EndMenuBar()
					if select_recon == 0 then
						imgui.Text(u8"�����: ")
						imgui.Text(recon_nick)
						imgui.SameLine()
						imgui.Text('[' .. recon_id .. ']')
						imgui.Separator()
						for key, v in pairs(info_to_player) do  
							if key == 1 then  
								imgui.Text(u8:encode(recon_info[1]) .. " " .. info_to_player[1])
								mim_addons.BufferingBar(tonumber(info_to_player[1])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 2 and tonumber(info_to_player[2]) ~= 0 then
								imgui.Text(u8:encode(recon_info[2]) .. " " .. info_to_player[2])
								mim_addons.BufferingBar(tonumber(info_to_player[2])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 3 and tonumber(info_to_player[3]) ~= -1 then
								imgui.Text(u8:encode(recon_info[3]) .. " " .. info_to_player[3])
								mim_addons.BufferingBar(tonumber(info_to_player[3])/1000, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 4 then
								imgui.Text(u8:encode(recon_info[4]) .. " " .. info_to_player[4])
								local speed, const = string.match(info_to_player[4], "(%d+) / (%d+)")
								if tonumber(speed) > tonumber(const) then
									speed = const
								end
								mim_addons.BufferingBar((tonumber(speed)*100/tonumber(const))/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key ~= 1 and key ~= 2 and key ~= 3 and key ~= 4 then
								if key == 11 then  
									local lvl = string.match(info_to_player[11], "(%d+)")
									local str_lvl = ''
									if tonumber(lvl) == 0 then
										str_lvl = u8'�� �������.'
									elseif tonumber(lvl) == 1 then
										str_lvl = u8'�������'
									elseif tonumber(lvl) == 2 then
										str_lvl = u8'�������'
									elseif tonumber(lvl) == 3 then
										str_lvl = u8'Diamond'
									elseif tonumber(lvl) == 4 then
										str_lvl = u8'Platinum'
									elseif tonumber(lvl) == 5 then
										str_lvl = u8'Personal'
									end
									imgui.Text(u8:encode(recon_info[key]) .. " " .. str_lvl)
								elseif key == 15 then  
									local chkdrv = string.match(info_to_player[15], '(.+)')
									if chkdrv == 'DISABLED' then  
										imgui.Text(u8:encode(recon_info[key]) .. " " .. u8'���������')
									elseif chkdrv == 'ENABLED' then
										imgui.Text(u8:encode(recon_info[key]) .. " " .. u8'��������')
									end
								else 
									imgui.Text(u8:encode(recon_info[key]) .. " " .. info_to_player[key])
								end
							end
						end
					elseif select_recon == 1 then  
						if recon_punish == 0 then  
							imgui.Text(u8'�������� ������ ��������')
						end  
						if recon_punish == 1 then  
							imgui.Text(u8'������������������ ���������')
							for key in pairs(cmd_massive) do  
								if cmd_massive[key].cmd == "/jail" then  
									if imgui.Button(u8(cmd_massive[key].reason)) then  
										if main_access.settings.jail then
											sampSendChat(cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
										else 
											sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
										end
									end 
								end 
							end
						end 
						if recon_punish == 2 then  
							imgui.Text(u8'������������������ ���������')
							for key in pairs(cmd_massive) do  
								if cmd_massive[key].cmd == "/ban" or cmd_massive[key].cmd == '/iban' then  
									if imgui.Button(u8(cmd_massive[key].reason)) then  
										if main_access.settings.ban then
											sampSendChat("/ans " .. recon_id .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
											sampSendChat("/ans " .. recon_id .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
											sampSendChat(cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
										else 
											sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
										end
										recon_id = -1
									end 
								end 
							end
						end 
						if recon_punish == 3 then  
							imgui.Text(u8'������������������ ���������')
							for key in pairs(cmd_massive) do  
								if cmd_massive[key].cmd == "/kick" then  
									if imgui.Button(u8(cmd_massive[key].reason)) then  
										sampSendChat(cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].reason)
										recon_id = -1
									end 
								end 
							end
						end 
					end
				else 
					imgui.Text(u8'��������...')
				end
            imgui.End()
        end
    end
)

local helloText = [[
��������� AT ��� ������ �������������. 
����� ��� ������, ������������ ����� ���� ���������� � �� ������.
AT ��� ������ alfantasyz. ������ ������������: https://vk.com/infsy
]]

local textToMenuSelectableAutoMute = [[
������ ������� ��������� ��������� ������� ��� ���� �����. 
�� ������ �������� ������ �����, 
����������� ������ ����������� ������ � �������� ���� ����.
]]

local MainWindowAT = imgui.OnFrame( 
	function() return elements.imgui.main_window[0] end, 
	function (player) 

		royalblue()

		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(950, 450), imgui.Cond.FirstUseEver)

		imgui.Begin(fa.SERVER .. ' [AT for Android]', elements.imgui.main_window)
			imgui.BeginChild('##MenuSelectable', imgui.ImVec2(200, 400), true)
				if imgui.Button(fa.HOUSE .. u8" ���. ��������") then  
					elements.imgui.menu_selectable[0] = 0
				end
				if imgui.Button(fa.USER_GEAR .. u8' ���. �������') then
					elements.imgui.menu_selectable[0] = 1
				end
				if imgui.Button(fa.BOOK .. u8' �������') then  
					elements.imgui.menu_selectable[0] = 2
				end  
				if imgui.Button(fa.LIST_OL .. u8' ���/���������') then
					elements.imgui.menu_selectable[0] = 3 
				end
				if imgui.Button(fa.TABLE_LIST .. u8' �����') then  
					elements.imgui.menu_selectable[0] = 4 
				end
				if imgui.Button(fa.LIST .. u8' ������ /ans') then  
					elements.imgui.menu_selectable[0] = 5
				end
				if imgui.Button(fa.USERS .. u8' �����������') then  
					elements.imgui.menu_selectable[0] = 6
				end 
				if imgui.Button(fa.GEARS .. u8' ���������') then
					elements.imgui.menu_selectable[0] = 7
				end
			imgui.EndChild() 
			imgui.SameLine()
			imgui.BeginChild('##MainSelectable', imgui.ImVec2(720, 400), true)
				if elements.imgui.menu_selectable[0] == 0 then
					imgui.TextWrapped(u8(helloText))
				end
				if elements.imgui.menu_selectable[0] == 1 then  
					if not show_password then  
						if #ffi.string(elements.buffers.password) > 0 then  
							if tonumber(ffi.string(elements.buffers.password)) then 
								imgui.StrCopy(elements.buffers.password, tostring(ffi.string(elements.buffers.password)))
							end 
						end
						if imgui.InputText('##PasswordAdmin', elements.buffers.password, ffi.sizeof(elements.buffers.password), imgui.InputTextFlags.Password) then
							config.settings.password_to_login = ffi.string(elements.buffers.password)
							inicfg.save(config, directIni)
						end
					else 
						if imgui.InputText('##PasswordAdmin', elements.buffers.password, ffi.sizeof(elements.buffers.password)) then
							config.settings.password_to_login = ffi.string(elements.buffers.password)
							inicfg.save(config, directIni)
						end
					end
					imgui.SameLine()
					if not show_password then  
						imgui.Text(fa.EYE_SLASH)
						if imgui.IsItemClicked() then  
							show_password = true  
						end  
					else 
						imgui.Text(fa.EYE)
						if imgui.IsItemClicked() then  
							show_password = false 
						end 
					end 
					imgui.SameLine()
					if imgui.Button(fa.ROTATE) then  
						imgui.StrCopy(elements.buffers.password, '')
						config.settings.password_to_login = ''
						inicfg.save(config, directIni)
					end
					imgui.Text(u8'����-Alogin') 
					imgui.SameLine()
					if mim_addons.ToggleButton('##AutoALogin', elements.boolean.autologin) then  
						config.settings.autologin = elements.boolean.autologin[0]
						save()
					end  
					imgui.SameLine()
					imgui.SetCursorPosX(280)
					imgui.Text(u8"��������� �����-����")
					imgui.SameLine()
					if mim_addons.ToggleButton("##CustomReconMenu", elements.boolean.recon) then  
						config.settings.custom_recon = elements.boolean.recon[0]
						save() 
					end
					AutoMuteLib.ActiveAutoMute()
					imgui.SameLine()
					imgui.SetCursorPosX(280)
					imgui.Text(u8"����-������")
					imgui.SameLine()
					if mim_addons.ToggleButton('##AutoOnline', elements.boolean.auto_online) then  
						config.settings.auto_online = elements.boolean.auto_online[0]
						save()  
						send_online:run()
					end
					imgui.Text(u8'���. �����')
					imgui.SameLine()
					if mim_addons.ToggleButton('##AdminsForms', elements.boolean.adminforms) then  
						config.settings.adminforms = elements.boolean.adminforms[0]
						save() 
					end 
					imgui.SameLine()
					if imgui.Checkbox('##AutoForms', elements.boolean.autoforms) then  
						config.settings.autoforms = elements.boolean.autoforms[0]
						save() 
					end; Tooltip('��������� ����� �������������. ������������� �������������!')
					imgui.SameLine()
					imgui.SetCursorPosX(280)
					imgui.Text(u8'����� ���� � �������')
					imgui.SameLine()
					if mim_addons.ToggleButton('##RenderDate', elements.boolean.render_date) then  
						config.settings.render_date = elements.boolean.render_date[0]
						save()  
					end
					plother.ActivateWH()
				end
				if elements.imgui.menu_selectable[0] == 2 then
					imgui.Text(u8(textToMenuSelectableAutoMute))
					AutoMuteLib.ReadWriteAM()
				end 
				if elements.imgui.menu_selectable[0] == 3 then
					if imgui.TreeNodeStr(u8"��������� � �������") then 
						if imgui.TreeNodeStr("Ban") then  
							for key in pairs(cmd_massive) do  
								if cmd_massive[key].cmd == '/iban' or cmd_massive[key].cmd == '/ban' or cmd_massive[key].cmd == '/siban' or cmd_massive[key].cmd == '/sban'then  
									imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
									if cmd_massive[key].tip then  
										imgui.TextWrapped(u8('		' ..cmd_massive[key].tip))
									end
								end 
							end 
							imgui.TreePop()
						end
						if imgui.TreeNodeStr("Jail") then  
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/jail" then
									imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						if imgui.TreeNodeStr("Mute") then  
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/mute" then
									imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						if imgui.TreeNodeStr('Mute with Report') then  
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/rmute" then
									imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						if imgui.TreeNodeStr("Kick") then  
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/kick" then
									imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						imgui.TreePop()
					end
		
					if imgui.TreeNodeStr(u8"��������� � ��������") then  
						if imgui.TreeNodeStr("Ban") then  
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/banakk" or cmd_massive[key].cmd == '/offban' or cmd_massive[key].cmd == '/banip' then
									imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						if imgui.TreeNodeStr("Jail") then  
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/jailakk" or cmd_massive[key].cmd == '/jailoff' then
									imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						if imgui.TreeNodeStr("Mute") then  
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/muteakk" then
									imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						if imgui.TreeNodeStr('Mute with Report') then
							for key in pairs(cmd_massive) do
								if cmd_massive[key].cmd == "/rmuteakk" then
									imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
								end
							end
							imgui.TreePop()
						end
						imgui.TreePop()
					end
		
					if imgui.TreeNodeStr(u8"�������������� ������� AT") then  
						for key in pairs(cmd_helper_others) do 
							imgui.TextWrapped(u8'/'..key..u8' ' .. u8(cmd_helper_others[key].reason))
							if cmd_helper_others[key].tip then  
								imgui.TextWrapped(u8(cmd_helper_others[key].tip))
							end
						end
						imgui.TreePop()
					end
				end
				if elements.imgui.menu_selectable[0] == 4 then
					showFlood_ImGUI()
				end 
				if elements.imgui.menu_selectable[0] == 5 then
					QuestionAnswer.BinderEdit()
				end
				if elements.imgui.menu_selectable[0] == 6 then
					if imgui.BeginTabBar('##EventBar') then  
						if imgui.BeginTabItem(fa.WAREHOUSE .. u8" ��������� ����") then  
							posX, posY, posZ = getCharCoordinates(PLAYER_PED)
							imgui.TextWrapped(u8"����� �� ������ ������� ����������� � ��������� ��.")
							imgui.TextWrapped(u8"���������� ���� �������� � ����������� �� ���������� ����.")
							imgui.TextWrapped(u8"����� �����, ���������� ������� ���� ����� ������������ � �������� �����������.")
							imgui.TextWrapped(u8"AT Events �������� ��������� ���������� ������������ � ������ RealTime.")
							imgui.TextWrapped(u8"AT Events ������������ �������� ������ ����������� � ���� ��� ������������� ������������� �������������.")
							imgui.Text('')
							imgui.Text(u8'���� �����: \nX: ' .. posX .. ' | Y: ' .. posY .. ' | Z: ' .. posZ)
							imgui.EndTabItem()
						end
						if imgui.BeginTabItem(fa.MAP_LOCATION .. u8' �������� ��') then  
							imgui.Text(u8'������ ������ ��������� ������� ���� �����������.')
							imgui.TextWrapped(u8"�������� ����������� ����� ������ ���� ��������������� ��� ���������� ����� ��������. ")
							imgui.Text(u8"������� ��������� �� �������� ������.");
							Tooltip("����� � ��������/�������� ������� ���������� �������:\n1. �������� �� �������� ������, �.�. ����� ����� mess � �����. ������: \n 6 ������� � �� ����� ������� ���! \n 6 ��������� ������������ /heal, /r � /s\n2. ������ ������� �������� �������� ��� ����������� ������. ")
							imgui.Separator()
							imgui.PushItemWidth(130)
							imgui.InputText(u8"��� MP", elements.buffers.name, ffi.sizeof(elements.buffers.name))  
							imgui.PopItemWidth()
							imgui.SameLine()
							imgui.PushItemWidth(60)
							imgui.InputText(u8"/dt", elements.buffers.vdt, ffi.sizeof(elements.buffers.vdt)); Tooltip("���� ���� ������ �� �������, �� ����������� ��� �������� ��������.")
							imgui.PopItemWidth()
							imgui.Separator()
							atlibs.CenterText("������� �����������")
							imgui.PushItemWidth(400)
							imgui.InputTextMultiline("##RulesForEvent", elements.buffers.rules, ffi.sizeof(elements.buffers.rules), imgui.ImVec2(-1, 250))
							imgui.PopItemWidth()
							if imgui.Button(u8"����� ������") then  
								text = atlibs.string_split(ffi.string(elements.buffers.rules):gsub("\n", "~"), "~")
								for _, i in pairs(text) do  
									sampSendChat("/mess " .. u8:decode(i))
								end
							end; Tooltip("������� ����� ������ �� ��� ������������ ����������.")
							imgui.SameLine()
							imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
							if imgui.Button(u8"�����.�������") then  
								sampSendChat("/mess 6 �� ����������� ������: /passive, /anim, /r - /s, DM, �������� ������ ������� �������")
								sampSendChat("/mess 6 ��� ��������� ������, �� ������ �������� � Jail.")
							end; Tooltip("������� ����� ������ �� ��� ������������ ����������.")
							imgui.SameLine()
							imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
							if imgui.Button(u8"������ ��") then  
								lua_thread.create(function()
									sampSendChat("/mp")
									sampSendDialogResponse(5343, 1, 15)
									wait(1)
									sampSendDialogResponse(16069, 1, 1)
									if #ffi.string(elements.buffers.vdt) > 0 then  
										sampSendDialogResponse(16070, 1, 0, u8:decode(tostring(ffi.string(elements.buffers.vdt))))
									else
										math.randomseed(os.clock())
										local dt = math.random(500, 999)
										imgui.StrCopy(elements.buffers.vdt, tostring(dt))
										sampSendDialogResponse(16070, 1, 0, tostring(dt))
									end
									sampSendDialogResponse(16069, 1, 2)
									sampSendDialogResponse(16071, 1, 0, "0")
									sampSendDialogResponse(16069, 0, 0)
									sampSendDialogResponse(5343, 1, 0)
									wait(200)
									sampSendDialogResponse(5344, 1, 0, u8:decode(tostring(ffi.string(elements.buffers.name))))
									sampSendChat("/mess 6 ��������� ������! �������� �����������: " .. u8:decode(tostring(ffi.string(elements.buffers.name))) .. ". ��������: /tpmp")
									sampSendChat("/mess 6 ��������� ������! �������� �����������: " .. u8:decode(tostring(ffi.string(elements.buffers.name))) .. ". ��������: /tpmp")
									wait(1)
									sampSendDialogResponse(5344, 0, 0)
									wait(1)
									sampSendDialogResponse(5343, 0, 0)
								end)
							end
							imgui.SameLine()
							if imgui.Button(fa.UPLOAD) then  
								positionX, positionY, positionZ = getCharCoordinates(playerPed)
								positionX = string.sub(tostring(positionX), 1, string.find(tostring(positionX), ".")+6)
								positionY = string.sub(tostring(positionY), 1, string.find(tostring(positionY), ".")+6)
								positionZ = string.sub(tostring(positionZ), 1, string.find(tostring(positionZ), ".")+6)
								imgui.StrCopy(elements.buffers.coord, tostring(positionX) .. "," .. tostring(positionY) .. "," .. tostring(positionZ))
								local refresh_text = ffi.string(elements.buffers.rules):gsub("\n", "~")
								table.insert(cfgevents.bind_name, ffi.string(elements.buffers.name))
								table.insert(cfgevents.bind_text, refresh_text)
								table.insert(cfgevents.bind_vdt, tostring(ffi.string(elements.buffers.vdt)))
								table.insert(cfgevents.bind_coords, ffi.string(elements.buffers.coord))
								if EventsSave() then  
									sampAddChatMessage(tag .. '�� "' ..u8:decode(ffi.string(elements.buffers.name)).. '" ������� ��������� � ������!', -1)
									imgui.StrCopy(elements.buffers.name, '')
									imgui.StrCopy(elements.buffers.text, '')
									imgui.StrCopy(elements.buffers.vdt, '0')
									imgui.StrCopy(elements.buffers.coord, '0')
								end  
							end; Tooltip("������� ��������� ��������� ������ ����������� � �������. \n������������ ��������������, ������ �� ��� ������, ��� �� �� ������ ������ ������.")

							imgui.EndTabItem()
						end 
						if imgui.BeginTabItem(fa.TERMINAL .. u8' ��������� � ������') then  
							imgui.TextWrapped(u8"� ������ ������� ����� ������������ ����������� �� ������������, ���� ������� ���� � ������������ �� � ����������.")
							imgui.TextWrapped(u8"�������� �� ��������. �������� ������! � ���� ���������� ��� ��������� ��������� :D");
							Tooltip("� ���. ������ ���������� �� �������� ������ �����������. \n����� � ��������/�������� ������� ���������� �������:\n1. �������� �� �������� ������, �.�. ����� ����� mess � �����. ������: \n 6 ������� � �� ����� ������� ���! \n 6 ��������� ������������ /heal, /r � /s\n2. ������ ������� �������� �������� ��� ����������� ������. \n\n ���������� ����� ����� �� �������� ��������, ���� �������� '��� �������' \n ����������� ��� ������������� �������� ��������, ��� ������ ������ ������� \n ����������� ��������� �������������, ������� �� ��� ������ ���������� ��� ����.")
							imgui.Separator()

							if imgui.Button(u8'������� �����������') then  
								imgui.StrCopy(elements.buffers.name, '')
								imgui.StrCopy(elements.buffers.vdt, '0')
								imgui.StrCopy(elements.buffers.coord, '0')
								getpos = nil 
								EditOldBind = false  
								imgui.OpenPopup('EventsBinder')
							end

							if #cfgevents.bind_name > 0 then  
								for key, bind in pairs(cfgevents.bind_name) do  
									if imgui.Button(bind .. '##' .. key) then  
										sampAddChatMessage(tag .. '�������� ������ ������ �� "' .. u8:decode(bind) .. '"', -1)
										lua_thread.create(function()
											if #cfgevents.bind_coords > 5 then  
												coords = atlibs.string_split(cfgevents.bind_coords[key], ',')
												setCharCoordinates(PLAYER_PED,coords[1],coords[2],coords[3])
											end  
											stream_text = atlibs.string_split(cfgevents.bind_text[key], '~')
											wait(500)
											sampSendChat('/mp')
											sampSendDialogResponse(5343, 1, 15)
											wait(1)
											sampSendDialogResponse(16069, 1, 1)
											sampSendDialogResponse(16070, 1, 0, cfgevents.bind_vdt[key])
											sampSendDialogResponse(16069, 1, 2)
											sampSendDialogResponse(16071, 1, 0, "0")
											sampSendDialogResponse(16069, 0, 0)
											sampSendDialogResponse(5343, 1, 0)
											wait(200)
											sampSendDialogResponse(5344, 1, 0, u8:decode(tostring(cfgevents.bind_name[key])))
											sampSendChat("/mess 6 ��������� ������! �������� �����������: " .. u8:decode(tostring(cfgevents.bind_name[key])) .. ". ��������: /tpmp")
											sampSendChat("/mess 6 ��������� ������! �������� �����������: " .. u8:decode(tostring(cfgevents.bind_name[key])) .. ". ��������: /tpmp")
											wait(1)
											sampSendDialogResponse(5344, 0, 0)
											wait(1)
											sampSendDialogResponse(5343, 0, 0)
										end)
									end  
									imgui.SameLine()
									if imgui.Button(fa.COMMENT_SLASH .. '##' .. key) then  
										EditOldBind = true  
										getpos = key 
										local returnwrapped = tostring(cfgevents.bind_text[key]):gsub('~', '\n')
										imgui.StrCopy(elements.buffers.text, returnwrapped)
										imgui.StrCopy(elements.buffers.name, tostring(cfgevents.bind_name[key]))
										imgui.StrCopy(elements.buffers.coord, tostring(cfgevents.bind_coords[key]))
										imgui.StrCopy(elements.buffers.vdt, tostring(cfgevents.bind_vdt[key]))
										imgui.OpenPopup('EventsBinder')
									end  
									imgui.SameLine()
									if imgui.Button(fa.TRASH .. '##' .. key) then  
										sampAddChatMessage(tag .. '�� "' ..u8:decode(cfgevents.bind_name[key])..'" �������!', -1)
										table.remove(cfgevents.bind_name, key)
										table.remove(cfgevents.bind_text, key)
										EventsSave()
									end
								end  
							else 
								imgui.TextWrapped(u8'�� ���� ����������� �� ����������������. �����, ��������?')
							end

							if imgui.BeginPopupModal('EventsBinder', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then  
								imgui.BeginChild('##CreateEdit', imgui.ImVec2(800, 500), true)
									imgui.Text(u8"�������� ��: "); imgui.SameLine()
									imgui.PushItemWidth(130)
									imgui.InputText('##name_events', elements.buffers.name, ffi.sizeof(elements.buffers.name))
									imgui.PopItemWidth()
									imgui.Text(u8"����������� ���: "); Tooltip("������ �������� ������������ ���� (�������� �� 0) ���������� ��� �������� ������ ����������� \n����� ����������: ���������� �� 500 �� 999 ���������� ����������.\n���������� � ������ ����� ����������� ����������� ��������, ����� ������ �� ��������.")
									imgui.SameLine()
									imgui.PushItemWidth(60)
									imgui.InputText('##dt_event', elements.buffers.vdt, ffi.sizeof(elements.buffers.vdt))
									imgui.PopItemWidth()
									imgui.SameLine()
									if imgui.Button(u8"������") then  
										math.randomseed(os.clock())
										local dt = math.random(500, 999)
										imgui.StrCopy(elements.buffers.vdt, tostring(dt))
									end; Tooltip("������ ��� ��������� ��������� ����� ������������ ���� (/dt)")
									imgui.Text(u8"���������� ������ ��: ")
									imgui.SameLine()
									imgui.PushItemWidth(250)
									imgui.InputText("##CoordsEvent", elements.buffers.coord, ffi.sizeof(elements.buffers.coord))
									imgui.PopItemWidth()
									imgui.SameLine()
									if imgui.Button(u8"��� �������") then  
										positionX, positionY, positionZ = getCharCoordinates(playerPed)
										positionX = string.sub(tostring(positionX), 1, string.find(tostring(positionX), ".")+6)
										positionY = string.sub(tostring(positionY), 1, string.find(tostring(positionY), ".")+6)
										positionZ = string.sub(tostring(positionZ), 1, string.find(tostring(positionZ), ".")+6)
										imgui.StrCopy(elements.buffers.coord, tostring(positionX) .. "," .. tostring(positionY) .. "," .. tostring(positionZ))
									end; Tooltip("�������� ����������, �� ������� �� ������ ����������. \n���������� ��������� �������������� �� 2-4 ������ ����� �������.")
									imgui.Separator()
									imgui.Text(u8"�������/�������� ��:")
									imgui.PushItemWidth(300)
									imgui.InputTextMultiline("##EventText", elements.buffers.text, ffi.sizeof(elements.buffers.text), imgui.ImVec2(-1, 280))
									imgui.PopItemWidth()
									imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
									if imgui.Button(u8'�������##bind') then  
										imgui.StrCopy(elements.buffers.name, '')
										imgui.StrCopy(elements.buffers.text, '')
										imgui.StrCopy(elements.buffers.vdt, '0')
										imgui.StrCopy(elements.buffers.coord, '0')
										imgui.CloseCurrentPopup()
									end  
									imgui.SameLine()
									if #ffi.string(elements.buffers.name) > 0 and #ffi.string(elements.buffers.text) > 0 then  
										imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 1.01)
										if imgui.Button(u8'���������##bind') then  
											if not EditOldBind then  
												local refresh_text = ffi.string(elements.buffers.text):gsub("\n", "~")
												table.insert(cfgevents.bind_name, ffi.string(elements.buffers.name))
												table.insert(cfgevents.bind_text, refresh_text)
												table.insert(cfgevents.bind_vdt, tostring(ffi.string(elements.buffers.vdt)))
												table.insert(cfgevents.bind_coords, ffi.string(elements.buffers.coord))
												if EventsSave() then  
													sampAddChatMessage(tag .. '�� "' ..u8:decode(ffi.string(elements.buffers.name)).. '" ������� �������!', -1)
													imgui.StrCopy(elements.buffers.name, '')
													imgui.StrCopy(elements.buffers.text, '')
													imgui.StrCopy(elements.buffers.vdt, '0')
													imgui.StrCopy(elements.buffers.coord, '0')
												end  
												imgui.CloseCurrentPopup()
											else 
												local refresh_text = ffi.string(elements.buffers.text):gsub("\n", "~")
												table.insert(cfgevents.bind_name, getpos, ffi.string(elements.buffers.name))
												table.insert(cfgevents.bind_text, getpos, refresh_text)
												table.insert(cfgevents.bind_vdt, getpos, tostring(ffi.string(elements.buffers.vdt)))
												table.insert(cfgevents.bind_coords, getpos, ffi.string(elements.buffers.coord))
												table.remove(cfgevents.bind_name, getpos + 1)
												table.remove(cfgevents.bind_text, getpos + 1)
												table.remove(cfgevents.bind_vdt, getpos + 1)
												table.remove(cfgevents.bind_coords, getpos + 1)
												if EventsSave() then
													sampAddChatMessage(tag .. '�� "' ..u8:decode(ffi.string(elements.buffers.name)).. '" ������� ���������������!', -1)
													imgui.StrCopy(elements.buffers.name, '')
													imgui.StrCopy(elements.buffers.text, '')
													imgui.StrCopy(elements.buffers.vdt, '0')
													imgui.StrCopy(elements.buffers.coord, '0')
												end
												EditOldBind = false 
												imgui.CloseCurrentPopup()
											end
										end                        
									end
								imgui.EndChild()
								imgui.EndPopup()
							end

							imgui.EndTabItem()
						end
						imgui.EndTabBar()
					end 
				end
				if elements.imgui.menu_selectable[0] == 7 then
					imgui.Text(u8'� ����������....')
				end
			imgui.EndChild()
		imgui.End()
	end
)

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

-- ## ���� �������-�������� ��� ���������� �� � �������� ������ ## --

function showFlood_ImGUI()
    local colours_mess = [[
0 - {FFFFFF}�����, {FFFFFF}1 - {000000}������, {FFFFFF}2 - {008000}�������, {FFFFFF}3 - {80FF00}������-�������
4 - {FF0000}�������, {FFFFFF}5 - {0000FF}�����, {FFFFFF}6 - {FDFF00}������, {FFFFFF}7 - {FF9000}���������
8 - {B313E7}����������, {FFFFFF}9 - {49E789}���������, {FFFFFF}10 - {139BEC}�������
11 - {2C9197}�����-�������, {FFFFFF}12 - {DDB201}�������, {FFFFFF}13 - {B8B6B6}�����, {FFFFFF}14 - {FFEE8A}������-������
15 - {FF9DB6}�������, {FFFFFF}16 - {BE8A01}����������, {FFFFFF}17 - {E6284E}�����-�������
]]
    imgui.Text(u8"����� ����� ������������ ����� � ��� /mess ��� �������.")
    imgui.Separator()
    if imgui.CollapsingHeader(u8'����������� ������ /mess') then  
        atlibs.TextColoredRGB('0 - {FFFFFF}�����, {FFFFFF}1 - {000000}������, {FFFFFF}2 - {008000}�������, {FFFFFF}3 - {80FF00}������-�������')
		atlibs.TextColoredRGB('4 - {FF0000}�������, {FFFFFF}5 - {0000FF}�����, {FFFFFF}6 - {FDFF00}������, {FFFFFF}7 - {FF9000}���������')
		atlibs.TextColoredRGB('4 - {B313E7}����������, {FFFFFF}9 - {49E789}���������, {FFFFFF}10 - {139BEC}�������')
		atlibs.TextColoredRGB('11 - {2C9197}�����-�������, {FFFFFF}12 - {DDB201}�������, {FFFFFF}13 - {B8B6B6}�����, {FFFFFF}14 - {FFEE8A}������-������')
		atlibs.TextColoredRGB('15 - {FF9DB6}�������, {FFFFFF}16 - {BE8A01}����������, {FFFFFF}17 - {E6284E}�����-�������')
    end
    if imgui.Button(u8"�������� �����") then  
        imgui.OpenPopup('mainFloods')
    end
    if imgui.Button(u8"���� �� GangWar") then  
        imgui.OpenPopup('FloodsGangWar')
    end 
    if imgui.Button(u8"����������� /join") then  
        imgui.OpenPopup('FloodsJoinMP')
    end
    if imgui.BeginPopup('mainFloods') then  
        if imgui.Button(u8'���� ��� �������') then
			sampSendChat("/mess 4 ===================== | ������� | ====================")
			sampSendChat("/mess 0 �������� ������ ��� ����������?")
			sampSendChat("/mess 4 ������� /report, ������ ���� ID ����������/������!")
			sampSendChat("/mess 0 ���� �������������� ������� ��� � ���������� � ����. <3")
			sampSendChat("/mess 4 ===================== | ������� | ====================")
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� VIP') then
			sampSendChat("/mess 2 ===================== | VIP | ====================")
			sampSendChat("/mess 3 ������ ����� �������� �� ����� �����?")
			sampSendChat("/mess 2 ����� ��������� �������? ������� ��� � ������� 10� �����.")
			sampSendChat("/mess 3 ����� ������� /sellvip � �� �������� VIP!")
			sampSendChat("/mess 2 ===================== | VIP | ====================")
		end
		if imgui.Button(u8'���� ��� ������ �������/����') then
			
			sampSendChat("/mess 5 ===================== | ���� | ====================")
			sampSendChat("/mess 10 ��� ��� ������ ����� ����������. ���? -> ..")
			sampSendChat("/mess 0 ��� ����� ����������, �������� /tp, ����� ������ -> ����...")
			sampSendChat("/mess 0 ...����� ����� ������ � ����, ������� ���� �..")
			sampSendChat("/mess 10 ..� �������� �� ������ ���� ��� ������ �������. �� ���� ���.")
			sampSendChat("/mess 5 ===================== | ���� | ====================")
		end
		if imgui.Button(u8'���� ��� /dt 0-990 (����� ����������)') then
			
			sampSendChat("/mess 6 =================== | ����������� ��� | ==================")
			sampSendChat("/mess 0 ����������� �������? ��������� ��, ������ ��������..")
			sampSendChat("/mess 0 ���� ������� ���������? ��� ����� ���������! <3")
			sampSendChat("/mess 0 ������ ����� /dt 0-990. ����� - ��� ����������� ���.")
			sampSendChat("/mess 0 �� �������� �������� ������� ���� ���. ������� ����. :3")
			sampSendChat("/mess 6 =================== | ����������� ���  | ==================")
			
		end
		if imgui.Button(u8'���� ��� /storm') then
			
			sampSendChat("/mess 2 ===================== | ����� | ====================")
			sampSendChat("/mess 3 ������ ������ ���������� ����� ? � ��� ���� �����������!")
			sampSendChat("/mess 2 ����� ������� /storm , ����� ���� ��������� � NPC ... ")
			sampSendChat("/mess 3 ...������� ������������� � ������.")
			sampSendChat("/mess 2 ����� �������� ������ ���������� ������� ����� �������.")
			sampSendChat("/mess 2 ===================== | ����� | ====================")
			
		end
		if imgui.Button(u8'���� ��� /arena') then
			
			sampSendChat("/mess 7 ===================== | ����� | ====================")
			sampSendChat("/mess 0 ������ �������� ���� ������ � ��������?")
			sampSendChat("/mess 7 ������ ����� /arena, ������ ���� ���� ���.")
			sampSendChat("/mess 0 ����������� ����, ������ ��. ������, ��� ����� �������� ����. <3")
			sampSendChat("/mess 7 ===================== | ����� | ====================")
			
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� VK group') then
			
			sampSendChat("/mess 15 ===================== | ��������� | ====================")
			sampSendChat("/mess 0 ������ ����� ������������� � ��������?")
			sampSendChat("/mess 15 � ����� ������ ��������� �����, ��� �������� ������?")
			sampSendChat("/mess 0 ������ � ���� ������ ���������: https://vk.com/dmdriftgta")
			sampSendChat("/mess 15 ===================== | ��������� | ====================")
			
		end
		if imgui.Button(u8'���� ��� ���������') then
			
			sampSendChat("/mess 12 ===================== | ��������� | ====================")
			sampSendChat("/mess 0 � ���� ��������� �����? �� ������ ������ �����?")
			sampSendChat("/mess 12 ����� ������� /tp -> ������ -> ����������")
			sampSendChat("/mess 0 ������� ������ ���������, ���� ������ �� RDS �����. � ������� :3")
			sampSendChat("/mess 12 ===================== | ��������� | ====================")
			
		end
		if imgui.Button(u8'���� ��� ���� RDS') then
			
			sampSendChat("/mess 8 ===================== | ����� | ====================")
			sampSendChat("/mess 15 ������ ���������� �� ���� ������� ������ RDS? :> ")
			sampSendChat("/mess 15 �� ��� ������ ������� � ��������! ����: myrds.ru :3 ")
			sampSendChat("/mess 15 � ����� ����������: @empirerosso")
			sampSendChat("/mess 8 ===================== | ����� | ====================")
			
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� /gw') then
			
			sampSendChat("/mess 10 ===================== | Capture | ====================")
			sampSendChat("/mess 5 ���� �������� ������ �� ����� � GTA:SA? ��� ��� ���� ����! :>")
			sampSendChat("/mess 5 ������ ��� � ������� /gw, ��� �� ���������� � ��������")
			sampSendChat("/mess 5 ����� ������ ������� �� ����������, ����� ������� /capture XD")
			sampSendChat("/mess 10 ===================== | Capture | ====================")
			
		end
		if imgui.Button(u8"���� ��� ������ ������ �� RDS") then
			
			sampSendChat("/mess 2 ================== | ��������� ������ RDS | =================")
			sampSendChat("/mess 11 ����� ������ ������� ���� ������, � �������� ������?")
			sampSendChat("/mess 2 ����������� ������� ���-������, �� � ���� ����� �� ����������?")
			sampSendChat("/mess 11 �� ������ �������� ��������� ������: https://vk.com/freerds")
			sampSendChat("/mess 2 ================== | ��������� ������ RDS | =================")
			
		end
		if imgui.Button(u8"���� ��� /gangwar") then 
			
			sampSendChat("/mess 16 ===================== | �������� | ====================")
			sampSendChat("/mess 13 ������ ��������� � ������� �������? ��������� ����?")
			sampSendChat("/mess 16 �� ������ ���� ��� ���������! ������ �������� ������ �����")
			sampSendChat("/mess 13 ������� /gangwar, ��������� ���������� � ���������� �� ��.")
			sampSendChat("/mess 16 ===================== | �������� | ====================")
			
		end 
		imgui.SameLine()
		if imgui.Button(u8"���� ��� ������") then
			
			sampSendChat("/mess 14 ===================== | ������ | ====================")
			sampSendChat("/mess 13 �� ������� ����� �� ������? �� ������� �� �������?")
			sampSendChat("/mess 13 ���� ����� ������ � ���������, ��������� ������ ��� �������")
			sampSendChat("/mess 13 ������ ���� ������, �������� /tp -> ������")
			sampSendChat("/mess 14 ===================== | ������ | ====================")
			
		end
		if imgui.Button(u8"���� � ����") then  
			
			sampSendChat("/mess 13 ===================== | ��� RDS | ====================")
			sampSendChat("/mess 0 ��������� ��� � ��� RDS. ������ �����, �� Drift Server")
			sampSendChat("/mess 13 ����� � ��� ���� ����������, ��� GangWar, DM � ���������� RPG")
			sampSendChat("/mess 0 ����������� ������ � ��� ��������� ������� � /help")
			sampSendChat("/mess 13 ===================== | ��� RDS | ====================")
			
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� /trade') then
			
			sampSendChat("/mess 9 ===================== | ����� | ====================")
			sampSendChat("/mess 3 ������ ������ ����������, � ����� ������ �� ������� � ���� �����/����/�����/�����?")
			sampSendChat("/mess 9 ������� /trade, ��������� � ������� �����, �������� � �������� � ������ �������.")
			sampSendChat("/mess 3 �����, ������ �� ����� ���� NPC �����, � ���� ����� ����� ���-�� �����.")
			sampSendChat("/mess 9 ===================== | ����� | ====================")
			
		end
		if imgui.Button(u8'���� ��� �����') then 
			
			sampSendChat("/mess 4 ===================== | ����� | ====================")
			sampSendChat('/mess 0 ���� ������ �� �������/�������? ���� �������? ������ ������ � ��������?')
			sampSendChat('/mess 4 � ��� ���� ����� - https://forumrds.ru. ��� ���� �������� ���� :D')
			sampSendChat('/mess 0 ����� �����, ��� ���� ������� � �������. ����������, ������ <3')
			sampSendChat("/mess 4 ===================== | �����  | ====================")
			
		end	
		if imgui.Button(u8'���� ��� ����� ���') then 
			
			sampSendChat("/mess 15 ===================== | ����� | ====================")
			sampSendChat('/mess 17 ������� ������! �� ������ ������� ������ �������?')
			sampSendChat('/mess 15 ���� �� �����-�� ������ ����� �������, �� ��� ��� ����!')
			sampSendChat('/mess 17 ��� �� ������ ������� ������! ������� ������: https://forumrds.ru')
			sampSendChat("/mess 15 ===================== | ����� | ====================")
			
		end
		if imgui.Button(u8'����� ����� �� 15 ������') then
			
			sampSendChat("/mess 14 ��������� ������. ������ ����� ������� ����� ���������� ����������")
			sampSendChat("/mess 14 ������� ������������ �����, � ����������� ��������, ���� ������� :3")
			sampSendChat("/delcarall ")
			sampSendChat("/spawncars 15 ")
			toast.Show(u8"������� �/� �������", toast.TYPE.INFO, 5)
			
		end
	    if imgui.Button(u8'������') then
			
		    sampSendChat("/mess 8 =================| ������ NPC |=================")
		    sampSendChat("/mess 0 �� ������ ����� NPC ������� ���� ������? :D")
		    sampSendChat("/mess 0 � ��� ��� �� �� ����� , - ALT(/mm) - ��������� - ...")
		    sampSendChat("/mess 0 ...������� �������, ������� �����, � �� ������ ������...")
		    sampSendChat("/mess 0 ...NPC ����. �������� ���� �� RDS <3")
		    sampSendChat("/mess 8 =================| ������ NPC |=================")
			
		end	
	    imgui.EndPopup()
    end
    if imgui.BeginPopup('FloodsGangWar') then  
        if imgui.Button(u8"Aztecas vs Ballas") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 3 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs East Side Ballas ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 3 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Aztecas vs Groove") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 2 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Groove Street ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 2 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Aztecas vs Vagos") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 4 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Los Santos Vagos ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 4 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Aztecas vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 5 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 5 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Ballas vs Groove") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 6 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Groove Street  ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 6 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Ballas vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 7 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 7 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Groove vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 8 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street  vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 8 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Groove vs Vagos") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 9 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street vs Los Santos Vagos ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 9 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Vagos vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 10 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Los Santos Vagos vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 10 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Ballas vs Vagos") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 11 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Los Santos Vagos ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 11 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
        imgui.EndPopup()
    end
    if imgui.BeginPopup('FloodsJoinMP') then  
        if imgui.Button(u8'����������� "�����" ') then 
			
			sampSendChat("/mess 8 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������! ��������: /derby")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������! ��������: /derby")
			sampSendChat("/mess 8 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "������" ') then 
			
			sampSendChat("/mess 10 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /parkour")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /parkour")
			sampSendChat("/mess 10 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "PUBG" ') then 
			
			sampSendChat("/mess 9 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PUBG�! ��������: /pubg")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PUBG�! ��������: /pubg")
			sampSendChat("/mess 9 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "DAMAGE DM" ') then 
			
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �DAMAGE DEATHMATCH�! ��������: /damagedm")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �DAMAGE DEATHMATCH�! ��������: /damagedm")
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "KILL DM" ') then 
			
			sampSendChat("/mess 17 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �KILL DEATHMATCH�! ��������: /killdm")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �KILL DEATHMATCH�! ��������: /killdm")
			sampSendChat("/mess 17 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "����� �����" ') then 
			
			sampSendChat("/mess 7 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ �����! ��������: /drace")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ �����! ��������: /drace")
			sampSendChat("/mess 7 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "PaintBall" ') then 
			
			sampSendChat("/mess 12 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PaintBall�! ��������: /paintball")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PaintBall�! ��������: /paintball")
			sampSendChat("/mess 12 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "����� ������ �����" ') then 
			
			sampSendChat("/mess 13 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ ������ �����! ��������: /zombie")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ ������ �����! ��������: /zombie")
			sampSendChat("/mess 13 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "���������� ������" ') then 
			
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������� ������! ��������: /ny")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������� ������! ��������: /ny")
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "Capture Blocks" ') then 
			
			sampSendChat("/mess 16 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �Capture Blocks�! ��������: /join -> 12")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �Capture Blocks�! ��������: /join -> 12")
			sampSendChat("/mess 16 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "������" ') then 
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /join -> 10 �������")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /join -> 10 �������")
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'����������� "���������" ') then 
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������! ��������: /catchup")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������! ��������: /catchup")
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
		end
        imgui.EndPopup()
    end
end