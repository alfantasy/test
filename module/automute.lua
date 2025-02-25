require("lib.moonloader")

local imgui = require 'mimgui' -- ������������� ���������� Moon ImGUI
local encoding = require 'encoding' -- ������ � �����������
local sampev = require 'lib.samp.events' -- ���������� ������� SA:MP � ������������/���������/�������� �.�. �������
local mim_addons = require 'mimgui_addons' -- ���������� ������� ��� ���������� mimgui
local fa = require 'fAwesome6_solid' -- ������ � ������� �� ������ FontAwesome 6
local inicfg = require 'inicfg' -- ������ � ��������
local ffi = require 'ffi' -- ���������� ������ � ����������� ����
local atlibs = require 'libsfor' -- ���������� ���������� ���������� ��� ������ � ��������������� ���������
local widgets = require('widgets') -- for WIDGET_(...)

encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ���������� ��������� U8 ��� �������, �� � ����� ���������� (��� ����������)

-- ## ���� ��������� ���������� ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- ��������� ����������, ������� ������������ ��� AT
-- ## ���� ��������� ���������� ## --

-- ## ������ � mimgui ## --
imgui.OnInitialize(function()   
    imgui.GetIO().IniFilename = nil
    fa.Init()
end)

local new = imgui.new
-- ## ������ � mimgui ## --

EXPORTS = {}

-- ## ������ ������ � inicfg ## --

local directoryAutoMute = getWorkingDirectory() .. '/config/AdminTool/AutoMute'
local directIni = 'AdminTool/amsett.ini'
local config = inicfg.load({
    settings = {
        automute_mat = false,
        automute_osk = false,
        automute_rod = false, 
        automute_upom = false, 
        automute_oadm = false,
        agree_mute = false,
    },
}, directIni)
inicfg.save(config, directIni)

function save() 
    inicfg.save(config, directIni)
end
-- ## ������ ������ � inicfg ## --

-- ## ������ � ����������� ## --
local elements = {
    settings = {
        automute_mat = new.bool(config.settings.automute_mat),
        automute_osk = new.bool(config.settings.automute_osk),
        automute_rod = new.bool(config.settings.automute_rod),
        automute_upom = new.bool(config.settings.automute_upom),
        automute_oadm = new.bool(config.settings.automute_oadm),
        agree_mute = new.bool(config.settings.agree_mute),
    },
    imgui = {
        selectable = 0,
        stream = new.char[65536](),
        input_word = new.char[500](),
    },
}
-- ## ������ � ����������� ## --

-- ## ���������� ���������� �� ������ �������� ## --
local onscene_mat = { 
    "�����", "����", "���", "�����" 
} 
local onscene_osk = { 
    "����", "���", "������", "�����" 
}
local onscene_upom = {
    "�������", "russian roleplay", "evolve", "������"
}
local onscene_rod = { 
    "���� ����", "mq", "���� � ������", "���� ���� �����", "���� ��� �����", "mqq", "mmq", 'mmqq', "matb v kanave",
}
local onscene_oskadm = {
    "����� �����", "����� ����", "����� ���", "����� ������", "����� �����", "����� ���� ���� �����", "����� ���� ��� �����", "����� mqq", "����� mmq", "����� mmqq", "����� matb v kanave",
}
local control_onscene_mat = false -- ��������������� ����� �������� "����������� �������"
local control_onscene_osk = false -- ��������������� ����� �������� "�����������/��������"
local control_onscene_upom = false -- ��������������� ����� �������� "���������� ����.��������"
local control_onscene_rod = false -- ��������������� ����� �������� "����������� ������"
local control_onscene_oskadm = false -- ��������������� ����� �������� "����������� �������"
-- ## ���������� ���������� �� ������ �������� ## --

-- ## �������, ����������� ��������� ������������ ����� � ������ ����������� ���������� ## -- 
function checkMessage(msg, arg) -- ��� ���������� �������������� ����� ������� mainstream (�� 1 �� 4); ��� 1 - ���, 2 - ���, 3 - ����.����.��������, 4 - ��� ���
    if msg ~= nil then -- ��������, ���������� �� ��������� � ������� ��� ������������ ������
        if arg == 1 then -- MainStream Automute-Report For "����������� �������"  
            for i, ph in ipairs(onscene_mat) do -- ������� ������� ������ � ������������ �������� �������, ���������� � ����
                nmsg = atlibs.string_split(msg, " ") -- �������� ��������� �� ������ �� ������
                for j, word in ipairs(nmsg) do -- ���� �������� �� ������ ������ �������
                    if ph == atlibs.string_rlower(word) then  -- ���� ����������� ����� ���� ������ �������, ��
                        return true, ph -- ������� True � ����������� �����
                    end  
                end  
            end  
        elseif arg == 2 then -- MainStream Automute-Report For "�����������/��������" 
            for i, ph in ipairs(onscene_osk) do -- ������� ������� ������ � ������������ �������� �������, ���������� � ����
                nmsg = atlibs.string_split(msg, " ") -- �������� ��������� �� ������ �� ������
                for j, word in ipairs(nmsg) do -- ���� �������� �� ������ ������ �������
                    if ph == atlibs.string_rlower(word) then  -- ���� ����������� ����� ���� ������ �������, ��
                        return true, ph -- ������� True � ����������� �����
                    end  
                end  
            end
        elseif arg == 3 then -- MainStream Automute-Report For "���������� ��������� ��������"  
            for i, ph in ipairs(onscene_upom) do -- ������ � ������������ �������� ������� �� �����
                if string.find(msg, ph, 1, true) then -- ����� ������� �� ������. ������ ����������� ������ �����? ������ ������ �� �����������, ������ ��� � ������ ���� 
                    return true, ph -- ���������� True � ����������� �����
                end 
            end
        elseif arg == 4 then -- MainStream Automute-Report For "����������� ������" 
            for i, ph in ipairs(onscene_rod) do -- ������ � ������������ �������� ������� �� �����
                if string.find(msg, ph, 1, true) then -- ����� ������� �� ������. ������ ����������� ������ �����? ������ ������ �� �����������, ������ ��� � ������ ���� 
                    return true, ph -- ���������� True � ����������� �����
                end 
            end 
        elseif arg == 5 then -- MainStream Automute-Report For "�����������/�������� ���"
            for i, ph in ipairs(onscene_oskadm) do -- ������ � ������������ �������� ������� �� �����
                nmsg = atlibs.string_split(msg, " ") -- �������� ��������� �� ������ �� ������
                for j, word in ipairs(nmsg) do -- ���� �������� �� ������ ������ �������
                    if ph == atlibs.string_rlower(word) then  -- ���� ����������� ����� ���� ������ �������, ��
                        return true, ph -- ������� True � ����������� �����
                    end
                end
            end
        end  
    end
end 

function sampev.onServerMessage(color, text)

    local check_nick, check_id, basic_color, check_text = string.match(text, "(.+)%((.+)%): {(.+)}(.+)") -- ������ �������� ������� ���� � �������� � �� �������

    -- ## �������, ��� mainframe - ������� ## --
    if not isGamePaused() and not isPauseMenuActive() then  
        if text:find("������ (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") then  
            local number_report, nick_rep, id_rep, text_rep = text:match("������ (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") 
            sampAddChatMessage(tag .. "������ ������ " .. number_report .. " �� " .. nick_rep .. "[" .. id_rep .. "]: " .. text_rep, -1)
            if elements.settings.automute_mat[0] or elements.settings.automute_osk[0] or elements.settings.automute_rod[0] or elements.settings.automute_rod[0] then  
                local mat_text, _ = checkMessage(text_rep, 1)
                local osk_text, _ = checkMessage(text_rep, 2)
                local upom_text, _ = checkMessage(text_rep, 3)
                local rod_text, _ = checkMessage(text_rep, 4)
                local oskadm_text, _ = checkMessage(text_rep, 5)
                if mat_text and elements.settings.automute_mat[0] then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    if elements.settings.agree_mute[0] then  
                        lua_thread.create(function()
                            local startTime = os.time()
                            local timeLimut = 5
                            sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                            while os.time() - startTime < timeLimut do 
                                wait(0)
                                if isWidgetReleased(WIDGET_ATTACK) then  
                                    sampSendChat("/rmute " .. id_rep .. " 300 ����������� �������")
                                end 
                            end 
                        end) 
                    else 
                        sampSendChat("/rmute " .. id_rep .. " 300 ����������� �������")
                    end
                end
                if osk_text and elements.settings.automute_osk[0] then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    if elements.settings.agree_mute[0] then
                        lua_thread.create(function()
                            local startTime = os.time()
                            local timeLimut = 5
                            sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                            while os.time() - startTime < timeLimut do 
                                wait(0)
                                if isWidgetReleased(WIDGET_ATTACK) then  
                                    sampSendChat("/rmute " .. id_rep .. " 400 ���/����.")
                                end 
                            end 
                        end)
                    else 
                        sampSendChat("/rmute " .. id_rep .. " 400 ���/����.")
                    end
                end
                if upom_text and elements.settings.automute_upom[0] then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    if elements.settings.agree_mute[0] then
                        lua_thread.create(function()
                            local startTime = os.time()
                            local timeLimut = 5
                            sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                            while os.time() - startTime < timeLimut do 
                                wait(0)
                                if isWidgetReleased(WIDGET_ATTACK) then  
                                    sampSendChat("/rmute " .. id_rep .. " 1000 ����.����.��������")
                                end 
                            end 
                        end)
                    else 
                        sampSendChat("/rmute " .. id_rep .. " 1000 ����.����.��������")
                    end
                end
                if rod_text and elements.settings.automute_rod[0] then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    if elements.settings.agree_mute[0] then
                        lua_thread.create(function()
                            local startTime = os.time()
                            local timeLimut = 5
                            sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                            while os.time() - startTime < timeLimut do 
                                wait(0)
                                if isWidgetReleased(WIDGET_ATTACK) then  
                                    sampSendChat("/rmute " .. id_rep .. " 5000 ���/����. ������")
                                end 
                            end 
                        end)
                    else 
                        sampSendChat("/rmute " .. id_rep .. " 5000 ���/����. ������")
                    end
                end
                if oskadm_text and elements.settings.automute_oadm[0] then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                    if elements.settings.agree_mute[0] then
                        lua_thread.create(function()
                            local startTime = os.time()
                            local timeLimut = 5
                            sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                            while os.time() - startTime < timeLimut do 
                                wait(0)
                                if isWidgetReleased(WIDGET_ATTACK) then  
                                    sampSendChat("/rmute " .. id_rep .. " 2500 ���/����. �������������")
                                end 
                            end 
                        end)
                    else 
                        sampSendChat("/rmute " .. id_rep .. " 2500 ���/����. �������������")
                    end
                end
            end  
            return true
        end
    end
    -- ## �������, ��� mainframe - ������� ## --

    -- ## �������, ��� mainframe - ��� ## --
    if not isGamePaused() and not isPauseMenuActive() then  
        if check_text ~= nil and check_id ~= nil and (elements.settings.automute_mat[0] or elements.settings.automute_osk[0] or elements.settings.automute_upom[0] or elements.settings.automute_rod[0]) then  
            local mat_text, _ = checkMessage(check_text, 1)
            local osk_text, _ = checkMessage(check_text, 2)
            local upom_text, _ = checkMessage(check_text, 3)
            local rod_text, _ = checkMessage(check_text, 4)
            local oskadm_text, _ = checkMessage(check_text, 5)
            if mat_text and elements.settings.automute_mat[0] then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " | ��� " .. check_nick .. "[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                if elements.settings.agree_mute[0] then
                    lua_thread.create(function()
                        local startTime = os.time()
                        local timeLimut = 5
                        sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                        while os.time() - startTime < timeLimut do 
                            wait(0)
                            if isWidgetReleased(WIDGET_ATTACK) then  
                                sampSendChat("/mute " .. check_id .. " 300 ����������� �������")
                            end 
                        end 
                    end)
                else 
                    sampSendChat("/mute " .. check_id .. " 300 ����������� �������")
                end
            end
            if osk_text and elements.settings.automute_osk[0] then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " | ��� " .. check_nick .. "[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                if elements.settings.agree_mute[0] then
                    lua_thread.create(function()
                        local startTime = os.time()
                        local timeLimut = 5
                        sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                        while os.time() - startTime < timeLimut do 
                            wait(0)
                            if isWidgetReleased(WIDGET_ATTACK) then  
                                sampSendChat("/mute " .. check_id .. " 400 ���/����.")
                            end 
                        end 
                    end)
                else 
                    sampSendChat("/mute " .. check_id .. " 400 ���/����.")
                end
            end
            if upom_text and elements.settings.automute_upom[0] then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " | ��� " .. check_nick .. "[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                if elements.settings.agree_mute[0] then
                    lua_thread.create(function()
                        local startTime = os.time()
                        local timeLimut = 5
                        sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                        while os.time() - startTime < timeLimut do 
                            wait(0)
                            if isWidgetReleased(WIDGET_ATTACK) then 
                                sampSendChat("/mute " .. check_id .. " 1000 ����.����.��������")
                            end
                        end
                    end)
                else
                    sampSendChat("/mute " .. check_id .. " 1000 ����.����.��������")
                end
            end
            if rod_text and elements.settings.automute_rod[0] then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " | ��� " .. check_nick .. "[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                if elements.settings.agree_mute[0] then
                    lua_thread.create(function()
                        local startTime = os.time()
                        local timeLimut = 5
                        sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                        while os.time() - startTime < timeLimut do 
                            wait(0)
                            if isWidgetReleased(WIDGET_ATTACK) then 
                                sampSendChat("/mute " .. check_id .. " 5000 ���/����. ������")
                            end
                        end
                    end)
                else 
                    sampSendChat("/mute " .. check_id .. " 5000 ���/����. ������")
                end
            end
            if oskadm_text and elements.settings.automute_oadm[0] then
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " | ��� " .. check_nick .. "[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ', -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ", -1)
                if elements.settings.agree_mute[0] then
                    lua_thread.create(function()
                        local startTime = os.time()
                        local timeLimut = 5
                        sampAddChatMessage(tag .. '��� ������������� ����, ������� �� ������ �����', -1)
                        while os.time() - startTime < timeLimut do 
                            wait(0)
                            if isWidgetReleased(WIDGET_ATTACK) then 
                                sampSendChat("/mute " .. check_id .. " 2500 ���/����. �������������")
                            end
                        end
                    end)
                else 
                    sampSendChat("/mute " .. check_id .. " 2500 ���/����. �������������")
                end
            end
            return true
        end
    end 

    -- ## �������, ��� mainframe - ��� ## --
end

function main()
    while not isSampAvailable() do wait(0) end
    
 	-- ## �������������� �������� ## --
	    -- ## ���� �������� �� ���������� ������ ������ � ������� ����� ## --

    if not doesDirectoryExist(directoryAutoMute) then  
        createDirectory(directoryAutoMute)
    end  

    local file_read_mat, file_line_mat = io.open(directoryAutoMute .. "/mat.txt", "r"), -1
    if file_read_mat ~= nil then  
        file_read_mat:seek("set", 0)
        for line in file_read_mat:lines() do  
            onscene_mat[file_line_mat] = line  
            file_line_mat = file_line_mat + 1 
        end  
        file_read_mat:close()  
    else
        file_read_mat, file_line_mat = io.open(directoryAutoMute.."/mat.txt", 'w'), 1
        for _, v in ipairs(onscene_mat) do  
            file_read_mat:write(v .. "\n")
        end 
        file_read_mat:close()
    end

    local file_read_osk, file_line_osk = io.open(directoryAutoMute.."/osk.txt", 'r'), 1
    if file_read_osk ~= nil then  
        file_read_osk:seek("set", 0)
        for line in file_read_osk:lines() do  
            onscene_osk[file_line_osk] = line  
            file_line_osk = file_line_osk + 1 
        end  
        file_read_osk:close()  
    else 
        file_read_osk, file_line_osk = io.open(directoryAutoMute.."/osk.txt", 'w'), 1
        for _, v in ipairs(onscene_osk) do  
            file_read_osk:write(v .. "\n")
        end 
        file_read_osk:close()
    end

    local file_read_rod, file_line_rod = io.open(directoryAutoMute.."/rod.txt", 'r'), 1
    if file_read_rod ~= nil then  
        file_read_rod:seek("set", 0)
        for line in file_read_rod:lines() do  
            onscene_rod[file_line_rod] = line  
            file_line_rod = file_line_rod + 1 
        end  
        file_read_rod:close()  
    else
        file_read_rod, file_line_rod = io.open(directoryAutoMute.."/rod.txt", 'w'), 1
        for _, v in ipairs(onscene_rod) do  
            file_read_rod:write(v .. "\n")
        end 
        file_read_rod:close()
    end

    local file_read_upom, file_line_upom = io.open(directoryAutoMute.."/upom.txt", 'r'), 1
    if file_read_upom ~= nil then  
        file_read_upom:seek("set", 0)
        for line in file_read_upom:lines() do  
            onscene_upom[file_line_upom] = line  
            file_line_upom = file_line_upom + 1 
        end  
        file_read_upom:close()  
    else 
        file_read_upom, file_line_upom = io.open(directoryAutoMute.."/upom.txt", 'w'), 1
        for _, v in ipairs(onscene_upom) do  
            file_read_upom:write(v .. "\n")
        end 
        file_read_upom:close()
    end

    local file_read_oadm, file_line_oadm = io.open(directoryAutoMute.."/oadm.txt", 'r'), 1
    if file_read_oadm ~= nil then  
        file_read_oadm:seek("set", 0)
        for line in file_read_oadm:lines() do  
            onscene_oskadm[file_line_oadm] = line  
            file_line_oadm = file_line_oadm + 1 
        end  
        file_read_oadm:close()  
    else
        file_read_oadm, file_line_oadm = io.open(directoryAutoMute.."/oadm.txt", 'w'), 1
        for _, v in ipairs(onscene_oskadm) do  
            file_read_oadm:write(v .. "\n")
        end 
        file_read_oadm:close()
    end

        -- ## ���� �������� �� ���������� ������ ������ � ������� ����� ## --

    -- ## ���� �������������� ������� ��� ������ � ��������� (���� ����� ����/�������� ����) ## --
    
    sampRegisterChatCommand("s_rod", save_rod)
    sampRegisterChatCommand("d_rod", delete_rod)

    sampRegisterChatCommand("s_upom", save_upom)
    sampRegisterChatCommand("d_upom", delete_upom)

    sampRegisterChatCommand("s_osk", save_osk)
    sampRegisterChatCommand("d_osk", delete_osk)

    sampRegisterChatCommand("s_mat", save_mat)
    sampRegisterChatCommand("d_mat", delete_mat)

    sampRegisterChatCommand("s_oadm", save_oadm)
    sampRegisterChatCommand("d_oadm", delete_oadm)

    -- ## ���� �������������� ������� ��� ������ � ��������� (���� ����� ����/�������� ����) ## --

    while true do
        wait(0)
        
    end
end

-- ## ���� �������, ���������� �� ��������� � ����� �������� �������. ����������� � �������� ## --
function save_rod(param)
    if param == nil then  
        return false  
    end 
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    for _, val in ipairs(onscene_rod) do  
        if atlibs.string_rlower(param) == val then  
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ���� ����������� ������.", -1)
            return false  
        end    
    end  
    local file_write, file_line = io.open(directoryAutoMute.."/rod.txt", 'w'), 1
    onscene_rod[#onscene_rod + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_rod) do  
        file_write:write(val .. "\n")
    end  
    file_write:close() 
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ ���� ����������� ������", -1)
end

function delete_rod(param)
    if param == nil then  
        return false  
    end  
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.")
        return false 
    end
    local file_write, file_line = io.open(directoryAutoMute.. "/rod.txt", "w"), 1
    for i, val in ipairs(onscene_rod) do
        if val == atlibs.string_rlower(param) then
            onscene_rod[i] = nil
            control_onscene_rod = true
        else
            file_write:write(val .. "\n")
        end
    end
    file_write:close()
    if control_onscene_rod then
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ ���� ����������� ������", -1)
        control_onscene_rod = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ ���� ����������� ������", -1)
    end
end

function save_upom(param)
    if param == nil then  
        return false 
    end 
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.")
        return false 
    end
    for _, val in ipairs(onscene_upom) do 
        if atlibs.string_rlower(param) == val then  
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ���� ���������� ��������� ��������.", -1)
            return false 
        end 
    end 
    local file_read, file_line = io.open(directoryAutoMute.. "/upom.txt", "w"), 1
    onscene_upom[#onscene_upom + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_upom) do 
        file_read:write(val .. "\n")
    end 
    file_read:close() 
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ ���� ���������� ��������� ��������.", -1)
end

function delete_upom(param)
    if param == nil then
        return false
    end
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    local file_read, file_read = io.open(directoryAutoMute.. "/upom.txt", "w"), 1
    for i, val in ipairs(onscene_upom) do
        if val == atlibs.string_rlower(param) then
            onscene_upom[i] = nil
            control_onscene_upom = true
        else
            file_read:write(val .. "\n")
        end
    end
    file_read:close()
    if control_onscene_upom then
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ ���� ���������� ��������� ��������.", -1)
        control_onscene_upom = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ ���� ���������� ��������� ��������.", -1)
    end
end

function save_osk(param)
    if param == nil then
        return false
    end
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    for _, val in ipairs(onscene_osk) do
        if atlibs.string_rlower(param) == val then
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ �����������/��������.", -1)
            return false
        end
    end
    local file_write, file_line = io.open(directoryAutoMute.. "/osk.txt", "w"), 1
    onscene_osk[#onscene_osk + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_osk) do
        file_write:write(val .. "\n")
    end
    file_write:close()
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ �����������/��������.", -1)
end

function delete_osk(param)
    if param == nil then
        return false
    end
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    local file_write, file_line = io.open(directoryAutoMute.. "/osk.txt", "w"), 1
    for i, val in ipairs(onscene_osk) do
        if val == atlibs.string_rlower(param) then
            onscene_osk[i] = nil
            control_onscene_osk = true
        else
            file_write:write(val .. "\n")
        end
    end
    file_write:close()
    if control_onscene_osk then
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ �����������/��������.", -1)
        control_onscene_osk = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ �����������/��������.", -1)
    end
end

function save_mat(param)
    if param == nil then
        return false
    end
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    for _, val in ipairs(onscene_mat) do
        if atlibs.string_rlower(param) == val then
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ����������� �����.", -1)
            return false
        end
    end
    local file_write, file_line = io.open(directoryAutoMute.. "/mat.txt", "w"), 1
    onscene_mat[#onscene_mat + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_mat) do
        file_write:write(val .. "\n")
    end
    file_write:close()
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ ����������� �������.", -1)
end

function delete_mat(param)
    if param == nil then
        return false
    end
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    local file_write, file_line = io.open(directoryAutoMute.. "/mat.txt", "w"), 1
    for i, val in ipairs(onscene_mat) do
        if val == atlibs.string_rlower(param) then
            onscene_mat[i] = nil
            control_onscene_mat = true
        else
            file_write:write(val .. "\n")
        end
    end
    file_write:close()
    if control_onscene_mat then
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ ����������� �����.", -1)
        control_onscene_mat = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ ������������.", -1)
    end
end

function save_oadm(param)
    if param == nil then
        return false
    end
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    for _, val in ipairs(onscene_oskadm) do
        if atlibs.string_rlower(param) == val then
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ����������� ���.", -1)
            return false
        end
    end
    local file_write, file_line = io.open(directoryAutoMute.. "/oadm.txt", "w"), 1
    onscene_oskadm[#onscene_oskadm + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_oskadm) do
        file_write:write(val .. "\n")
    end
    file_write:close()
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ ����������� ���.", -1)
end

function delete_oadm(param)
    if param == nil then
        return false
    end
    if param == "" then  
        sampAddChatMessage(tag .. "�� ����� ������ �����.", -1)
        return false 
    end
    local file_write, file_line = io.open(directoryAutoMute.. "/oadm.txt", "w"), 1
    for i, val in ipairs(onscene_oskadm) do
        if val == atlibs.string_rlower(param) then
            onscene_oskadm[i] = nil
            control_onscene_oskadm = true
        else
            file_write:write(val .. "\n")
        end
    end
    file_write:close()
    if control_onscene_oskadm then
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ ����������� ���.", -1)
        control_onscene_oskadm = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ ����������� ���.", -1)
    end
end
-- ## ���� �������, ���������� �� ��������� � ����� �������� �������. ����������� � �������� ## --

-- ## ���� �������, ���������� �� ������ ������ �������� ��� ����� ����������� ���� ## --
function check_files_automute(param) 
    if param == "mat" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '/config/AdminTool/AutoMute/mat.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()
            return t
    elseif param == "osk" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '/config/AdminTool/AutoMute/osk.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()     
            return t   
    elseif param == "oskrod" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '/config/AdminTool/AutoMute/rod.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()        
            return t
    elseif param == "upomproject" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '/config/AdminTool/AutoMute/upom.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()        
            return t     
    elseif param == "oadm" then
        local file_check = assert(io.open(getWorkingDirectory() .. '/config/AdminTool/AutoMute/oadm.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()
            return t   
    end
end
-- ## ���� �������, ���������� �� ������ ������ �������� ��� ����� ����������� ���� ## --

-- ## ���� �������-�������� ��� ���������� �� � �������� ������ ## --
function EXPORTS.ActiveAutoMute()
    if imgui.Button(fa.NEWSPAPER .. u8" �������") then  
        imgui.OpenPopup('##SettingsAutoMute')
    end  
    if imgui.BeginPopup('##SettingsAutoMute') then  
        if mim_addons.ToggleButton(u8'������� �� ���', elements.settings.automute_mat) then  
            config.settings.automute_mat = elements.settings.automute_mat[0] 
            save()  
        end
        if mim_addons.ToggleButton(u8'������� �� ���', elements.settings.automute_osk) then  
            config.settings.automute_osk = elements.settings.automute_osk[0]
            save() 
        end  
        if mim_addons.ToggleButton(u8'������� �� ����.����.��������', elements.settings.automute_upom) then  
            config.settings.automute_upom = elements.settings.automute_upom[0]
            save()  
        end  
        if mim_addons.ToggleButton(u8'������� �� ��� ������', elements.settings.automute_rod) then  
            config.settings.automute_rod = elements.settings.automute_rod[0]
            save()  
        end
        if mim_addons.ToggleButton(u8'������� �� ��� ���', elements.settings.automute_oadm) then
            config.settings.automute_oadm = elements.settings.automute_oadm[0]
            save()
        end
        if mim_addons.ToggleButton(u8'������������� ����', elements.settings.agree_mute) then
            config.settings.agree_mute = elements.settings.agree_mute[0]
            save()
        end
        imgui.EndPopup()
    end
end

function EXPORTS.ReadWriteAM()
    imgui.BeginChild('##MenuRWAMF', imgui.ImVec2(200, 310), true)
        if imgui.Button(u8"���") then  
            elements.imgui.selectable = 1
        end  
        if imgui.Button(u8"���/����") then  
            elements.imgui.selectable = 2
        end  
        if imgui.Button(u8"����.��������") then  
            elements.imgui.selectable = 3
        end 
        if imgui.Button(u8"��� ������") then  
            elements.imgui.selectable = 4
        end
        if imgui.Button(u8"��� ���") then
            elements.imgui.selectable = 5
        end
    imgui.EndChild()
    imgui.SameLine()
    imgui.BeginChild('##WindowRWAMF', imgui.ImVec2(500, 310), true)
        if elements.imgui.selectable == 0 then  
            imgui.TextWrapped(u8"������������ ����� ���������. ������ ���� ��������� ����� ����� ������������� � ����� ��� ����������.")
            imgui.TextWrapped(u8"�� ������ ������ �� ���� ���� �� �������� � ������.")
        end  
        if elements.imgui.selectable == 1 then  
            imgui.TextWrapped(u8"��� ����������/�������� ����, ����������� ���� ����� ����")
            imgui.InputText("##InputWord", elements.imgui.input_word, ffi.sizeof(elements.imgui.input_word))
            imgui.SameLine()
            if imgui.Button(fa.ROTATE) then  
                imgui.StrCopy(elements.imgui.input_word, '')
            end  
            if #ffi.string(elements.imgui.input_word) > 0 then
                if imgui.Button(u8"��������") then  
                    save_mat(u8:decode(ffi.string(elements.imgui.input_word)))
                end  
                if imgui.Button(u8"�������") then  
                    delete_mat(u8:decode(ffi.string(elements.imgui.input_word)))
                end
            end
            imgui.Separator()
            imgui.StrCopy(elements.imgui.stream, check_files_automute("mat"))
            for line in ffi.string(elements.imgui.stream):gmatch("[^\r\n]+") do  
                imgui.Text(u8(line))
            end
        end 
        if elements.imgui.selectable == 2 then  
            imgui.TextWrapped(u8"��� ����������/�������� ����, ����������� ���� ����� ����")
            imgui.InputText("##InputWord", elements.imgui.input_word, ffi.sizeof(elements.imgui.input_word))
            imgui.SameLine()
            if imgui.Button(fa.ROTATE) then  
                imgui.StrCopy(elements.imgui.input_word, '')
            end  
            if imgui.Button(u8"��������") then  
                save_osk(u8:decode(ffi.string(elements.imgui.input_word)))
            end  
            if imgui.Button(u8"�������") then  
                delete_osk(u8:decode(ffi.string(elements.imgui.input_word)))
            end
            imgui.Separator()
            imgui.StrCopy(elements.imgui.stream, check_files_automute("osk"))
            for line in ffi.string(elements.imgui.stream):gmatch("[^\r\n]+") do  
                imgui.Text(u8(line))
            end
        end 
        if elements.imgui.selectable == 3 then  
            imgui.TextWrapped(u8"��� ����������/�������� ����, ����������� ���� ����� ����")
            imgui.InputText("##InputWord", elements.imgui.input_word, ffi.sizeof(elements.imgui.input_word))
            imgui.SameLine()
            if imgui.Button(fa.ROTATE) then  
                imgui.StrCopy(elements.imgui.input_word, '')
            end  
            if imgui.Button(u8"��������") then  
                save_upom(u8:decode(ffi.string(elements.imgui.input_word)))
            end  
            if imgui.Button(u8"�������") then  
                delete_upom(u8:decode(ffi.string(elements.imgui.input_word)))
            end
            imgui.Separator()
            imgui.StrCopy(elements.imgui.stream, check_files_automute("upomproject"))
            for line in ffi.string(elements.imgui.stream):gmatch("[^\r\n]+") do  
                imgui.Text(u8(line))
            end
        end  
        if elements.imgui.selectable == 4 then  
            imgui.TextWrapped(u8"��� ����������/�������� ����, ����������� ���� ����� ����")
            imgui.InputText("##InputWord", elements.imgui.input_word, ffi.sizeof(elements.imgui.input_word))
            imgui.SameLine()
            if imgui.Button(fa.ROTATE) then  
                imgui.StrCopy(elements.imgui.input_word, '')
            end  
            if imgui.Button(u8"��������") then  
                save_rod(u8:decode(ffi.string(elements.imgui.input_word)))
            end  
            if imgui.Button(u8"�������") then  
                delete_rod(u8:decode(ffi.string(elements.imgui.input_word)))
            end
            imgui.Separator()
            imgui.StrCopy(elements.imgui.stream, check_files_automute("oskrod"))
            for line in ffi.string(elements.imgui.stream):gmatch("[^\r\n]+") do  
                imgui.Text(u8(line))
            end
        end
        if elements.imgui.selectable == 5 then
            imgui.TextWrapped(u8"��� ����������/�������� ����, ����������� ���� ����� ����")
            imgui.InputText("##InputWord", elements.imgui.input_word, ffi.sizeof(elements.imgui.input_word))
            imgui.SameLine()
            if imgui.Button(fa.ROTATE) then
                imgui.StrCopy(elements.imgui.input_word, '')
            end
            if imgui.Button(u8"��������") then
                save_oadm(u8:decode(ffi.string(elements.imgui.input_word)))
            end
            if imgui.Button(u8"�������") then
                delete_oadm(u8:decode(ffi.string(elements.imgui.input_word)))
            end
            imgui.Separator()
            imgui.StrCopy(elements.imgui.stream, check_files_automute("oadm"))
            for line in ffi.string(elements.imgui.stream):gmatch("[^\r\n]+") do
                imgui.Text(u8(line))
            end
        end
    imgui.EndChild()
end
-- ## ���� �������-�������� ��� ���������� �� � �������� ������ ## --