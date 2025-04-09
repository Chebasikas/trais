script_name('Autoupdate script') -- название скрипта
script_author('FORMYS') -- автор скрипта
script_description('Autoupdate') -- описание скрипта

require "lib.moonloader" -- подключение библиотеки
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local script_vers = 6
local script_vers_text = "5.05"

local update_url = "https://raw.githubusercontent.com/Chebasikas/trais/refs/heads/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://github.com/Chebasikas/trais/raw/refs/heads/main/ffaf.lua" -- тут свою ссылку
local script_path = thisScript().path
local font_flag = require('moonloader').font_flag
local my_font = renderCreateFont('Verdana', 12, font_flag.BOLD + font_flag.SHADOW)
local BlackNick = {"Cheba","Cheba","Chebas"}
local WhiteNick = {"Vasya"} -- Новый список WhiteNick

-- Координаты и флаги для BlackNick
local black_x, black_y = 10, 400  -- Начальные координаты (по умолчанию)
local setting_black_coordinates = false
local show_black_list = false
local title_black_text = "Black Players"

-- Координаты и флаги для WhiteNick
local white_x, white_y = 200, 400  -- Начальные координаты (по умолчанию)
local setting_white_coordinates = false
local show_white_list = false
local title_white_text = "White Players"

local key_pressed = false -- Флаг для отслеживания нажатия клавиши
local script_path = thisScript().path
local moonloader_path = script_path:match("(.*[\\/])") -- Извлекаем путь к папке Moonloader
local config_file = moonloader_path .. "KPZ_Silas_Config.txt"  -- Путь к файлу конфигурации в папке Moonloader


-- Функция для загрузки координат из файла
local function load_config()
    local file = io.open(config_file, "r")
    if file then
        local line = file:read("*l")
        if line then
            local parts = string.split(line, ",")
            if #parts == 4 then
                local loaded_black_x = tonumber(parts[1])
                local loaded_black_y = tonumber(parts[2])
                local loaded_white_x = tonumber(parts[3])
                local loaded_white_y = tonumber(parts[4])
                if loaded_black_x and loaded_black_y then
                    black_x = loaded_black_x
                    black_y = loaded_black_y
                end
                 if loaded_white_x and loaded_white_y then
                    white_x = loaded_white_x
                    white_y = loaded_white_y
                end
            end
        end
        file:close()
    end
end

-- Функция для сохранения координат в файл
local function save_config()
    local file = io.open(config_file, "w")
    if file then
        file:write(string.format("%d,%d,%d,%d", black_x, black_y, white_x, white_y)) -- Сохраняем обе пары координат
        file:close()
    end
end


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("setblacknick", setBlackNickCommand)
    sampRegisterChatCommand("black", toggleBlackList)
    sampRegisterChatCommand("setwhitenick", setWhiteNickCommand)
    sampRegisterChatCommand("white", toggleWhiteList)
	load_config() -- Загружаем координаты при запуске скрипта

    -- Проверяем существование файла при запуске скрипта и создаем его при необходимости
    local file = io.open(config_file, "r")
    if not file then
       local default_black_x, default_black_y = 10, 400
       local default_white_x, default_white_y = 200, 400
       local file_create = io.open(config_file, "w")
        if file_create then
            file_create:write(string.format("%d,%d,%d,%d", default_black_x, default_black_y, default_white_x, default_white_y))
            file_create:close()
        end
    else
        file:close()
    end
    sampRegisterChatCommand("update", cmd_update)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
    
	while true do
        wait(0)

        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end


        -- Обработка ввода для BlackNick
        if setting_black_coordinates then
            -- Проверяем, была ли нажата какая-либо клавиша
           for i = 1, 255 do -- Перебираем все возможные коды клавиш
               if wasKeyPressed(i) then
                   key_pressed = true
                   break -- Выходим из цикла, если клавиша была нажата
               end
           end
       end
       if setting_black_coordinates and key_pressed then
           black_x, black_y = getCursorPos()
           setting_black_coordinates = false
           key_pressed = false
           sampAddChatMessage("Координаты BlackNick изменены", -1)
           save_config()
           showCursor(false, true) -- Скрываем курсор
       end

       -- Обработка ввода для WhiteNick
       if setting_white_coordinates then
            -- Проверяем, была ли нажата какая-либо клавиша
           for i = 1, 255 do -- Перебираем все возможные коды клавиш
               if wasKeyPressed(i) then
                   key_pressed = true
                   break -- Выходим из цикла, если клавиша была нажата
               end
           end
       end
        if setting_white_coordinates and key_pressed then
           white_x, white_y = getCursorPos()
           setting_white_coordinates = false
           key_pressed = false
           sampAddChatMessage("Координаты WhiteNick изменены", -1)
           save_config()
           showCursor(false, true) -- Скрываем курсор
       end


       -- Отображение списков
       if show_black_list then
           renderFontDrawText(my_font, title_black_text, black_x, black_y, 0xFFFFFFFF)
           for i, nick in ipairs(BlackNick) do
               renderFontDrawText(my_font, nick, black_x, black_y + (i * 15) + 15, 0xFFFFFFFF)
           end
       end

       if show_white_list then
           renderFontDrawText(my_font, title_white_text, white_x, white_y, 0xFFFFFFFF)
           for i, nick in ipairs(WhiteNick) do
               renderFontDrawText(my_font, nick, white_x, white_y + (i * 15) + 15, 0xFFFFFFFF)
           end
       end

       key_pressed = false -- Сбрасываем флаг нажатия клавиши в конце цикла
	end
end

function cmd_update(arg)
    sampShowDialog(1000, "Автообновление v2.0", "{FFFFFF}Это урок по обновлению\n{FFF000}Новая версия", "Закрыть", "", 0)
end


function setBlackNickCommand()
    setting_black_coordinates = true -- Включаем режим установки координат
    showCursor(true, true) -- Показываем курсор
    setting_white_coordinates = false -- Отключаем настройку координат для WhiteNick
    sampAddChatMessage("Установите координаты списка BlackNick, нажав любую клавишу.", -1)
end

function toggleBlackList()
    show_black_list = not show_black_list
    sampAddChatMessage("Список BlackNick " .. (show_black_list and "отображается" or "скрыт"), -1)
end

function setWhiteNickCommand()
    setting_white_coordinates = true
    showCursor(true, true)
    setting_black_coordinates = false -- Отключаем настройку координат для BlackNick
    sampAddChatMessage("Установите координаты списка WhiteNick, нажав любую клавишу.", -1)
end

function toggleWhiteList()
    show_white_list = not show_white_list
    sampAddChatMessage("Список WhiteNick " .. (show_white_list and "отображается" or "скрыт"), -1)
end


-- Добавляем функцию split (если она у вас еще не добавлена)
function string:split(delimiter)
    local result = {}
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
        table.insert( result, string.sub( self, from , delim_from-1 ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end