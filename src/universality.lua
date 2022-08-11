--[[
	Universal control library for openComputers and computerCraft
]]--

local uni = {
	robot = {},
	mods = {},
	sides = {},
	network = {}, -- corutiune
	-- os = {},
	
}

--[[
	Sides api
]]

local sides = {
	['bottom'] = 	{ ['OC'] = 0, ['OC2'] = 0, ['CC'] = "bottom" },
	['top'] = 		{ ['OC'] = 1, ['OC2'] = 1, ['CC'] = "top" },
	['back'] = 		{ ['OC'] = 2, ['OC2'] = 2, ['CC'] = "back" },
	['front'] = 	{ ['OC'] = 3, ['OC2'] = 3, ['CC'] = "front" },
	['right'] = 	{ ['OC'] = 4, ['OC2'] = 4, ['CC'] = "right" },
	['left'] = 		{ ['OC'] = 5, ['OC2'] = 5, ['CC'] = "left" },
	
	['north'] = 	{ ['OC'] = 2, ['OC2'] = 2, ['CC'] = "north" },
	['south'] = 	{ ['OC'] = 3, ['OC2'] = 3, ['CC'] = "south" },
	['west'] = 		{ ['OC'] = 4, ['OC2'] = 4, ['CC'] = "west" },
	['east'] = 		{ ['OC'] = 5, ['OC2'] = 5, ['CC'] = "east" },
}

uni.sides = {
	['bottom'] = 	sides.bottom,
	['top'] = 		sides.top,
	['back'] = 		sides.back,
	['front'] = 	sides.front,
	['right'] = 	sides.right,
	['left'] = 		sides.left,
	
	['north'] = sides.north,
	['south'] = sides.south,
	['west'] = 	sides.west,
	['east'] = 	sides.east,
	
	['down'] = 		sides.bottom,
	['up'] = 		sides.top,
	['backward'] = 	sides.back,
	['forward'] = 	sides.front,
	['rightward'] = sides.right,
	['leftward'] =	sides.left,
	
	['negy'] = 	sides.bottom,
	['posy'] = 	sides.top,
	['negz'] = 	sides.north,
	['posz'] = 	sides.south,
	['negx'] = 	sides.west,
	['posx'] = 	sides.east,
	
	['0'] = sides.bottom,
	['1'] = sides.top,
	['2'] = sides.back,
	['3'] = sides.front,
	['4'] = sides.right,
	['5'] = sides.left,
	
	[0] = sides.bottom,
	[1] = sides.top,
	[2] = sides.back,
	[3] = sides.front,
	[4] = sides.right,
	[5] = sides.left,
}

--[[
	Mods api
]]

-- ___Other___ --



--[[
	return:
		string - Вернет [string] мода, внутри которого запущенна библиотека
]]
function uni.mods.test()
	if _HOST ~= nil then
		return "ComputerCraft (" .. (string.match(_HOST, "%s([%d.]+)%s") or "none") .. ")"
	elseif _CC_VERSION then
		return "ComputerCraft (" .. _CC_VERSION .. ")"
	elseif _OSVERSION then
		if string.find(string.lower(_OSVERSION), "openos") then
			return "OpenComputers (" .. (string.match(string.lower(_OSVERSION), "openos ([%d.]+)") or "none") .. ")"
		end
		
		return "Unknown"
	end
	
	return "Unknown"
end

--[[
	return:
		boolean - Если мы внутри OpenComputers
]]
function uni.mods.isOC()
	return (not uni.mods.isCC()) and (_OSVERSION ~= nil) and string.find(string.lower(_OSVERSION or ""), "openos")
end

--[[
	return:
		boolean - Если мы внутри ComputerCraft
]]
function uni.mods.isCC()
	return (string.find(string.lower(_HOST or ""), "computercraft") or _CC_VERSION) ~= nil
end

--[[
	return:
		boolean - Если мы внутри OpenComputers 2
]]
-- function uni.mods.isOC2()
	
-- end

--[[
	return:
		boolean - Если мы внутри непонятно чего
]]
function uni.mods.isUnknown()
	return (not uni.mods.isCC()) and (not uni.mods.isOC())
end



-- [[ INIT ]]
local function tableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
	
    return t1
end

local function install_api(t)
	if t == nil then return end
	
	for k,v in pairs(t) do
		tableMerge(_G, t)
	end
end


local old_sides = _G.sides
local old_uni = _G.uni

_G.sides = uni.sides
_G.uni = uni

--#############
--[[ this requires ]]
--#############

if uni.mods.isCC() then
	install_api(require("universality_cc"))
elseif uni.mods.isOC() then
	install_api(require("universality_oc"))
end

_G.sides = old_sides
_G.uni = old_uni




--[[
	Robot api
]]

-- ___Other___ --



--[[
	return:
		boolean - [true] если команда выполена на роботе
]]
function uni.robot.isRobot()
	-- component.isAvailable("robot") -- OpenComputers
end



-- ___Movment___ --



--[[
	Перемещает робота вперед на заданое кол-во блоков
	
	return:
		boolean / nil - если все успешно [true], если хоть раз удалось сдвинутся [false], если не разу не получилось сдвинутся [nil]
		int - оставшиеся кол-во блоков, если первый аргумент [false / nil]
		string - ошибка, если была
]]
function uni.robot.forward(count)
	
end

--[[
	Перемещает робота назад на заданое кол-во блоков
	
	return:
		boolean / nil - если все успешно [true], если хоть раз удалось сдвинутся [false], если не разу не получилось сдвинутся [nil]
		int - оставшиеся кол-во блоков, если первый аргумент [false / nil]
		string - ошибка, если была
]]
function uni.robot.back(count)
	
end

--[[
	Перемещает робота вверх на заданое кол-во блоков
	
	return:
		boolean / nil - если все успешно [true], если хоть раз удалось сдвинутся [false], если не разу не получилось сдвинутся [nil]
		int - оставшиеся кол-во блоков, если первый аргумент [false / nil]
		string - ошибка, если была
]]
function uni.robot.up(count)
	
end

--[[
	Перемещает робота вниз на заданое кол-во блоков
	
	return:
		boolean / nil - если все успешно [true], если хоть раз удалось сдвинутся [false], если не разу не получилось сдвинутся [nil]
		int - оставшиеся кол-во блоков, если первый аргумент [false / nil]
		string - ошибка, если была
]]
function uni.robot.down(count)
	
end

--[[
	Поворачивает робота налево
	
	return:
		boolean / nil - если все успешно [true], если хоть раз удалось повернутся [false], если не разу не получилось повернутся [nil]
		int - оставшиеся кол-во поворотов, если первый аргумент [false / nil]
		string - ошибка, если была
]]
function uni.robot.turnLeft(count)
	
end

--[[
	Поворачивает робота направо
	
	return:
		boolean / nil - если все успешно [true], если хоть раз удалось повернутся [false], если не разу не получилось повернутся [nil]
		int - оставшиеся кол-во поворотов, если первый аргумент [false / nil]
		string - ошибка, если была
]]
function uni.robot.turnRight(count)
	
end

--[[
	Поворачивает робота на 180 градусов (аналог [uni.robot.turnLeft | uni.robot.turnRight](2))
	
	return:
		boolean / nil - если все успешно [true], если хоть раз удалось повернутся [false], если не разу не получилось повернутся [nil]
		int - оставшиеся кол-во поворотов, если первый аргумент [false / nil]
		string - ошибка, если была
]]
function uni.robot.turn180()
	
end



-- ___Inventory___ --


--[[
	Находит предмет внутри инвентаря
	MinCount по умолчанию 1
	
	return:
		Int / nil - номер [Slot] если найден иначе nil
]]
function uni.robot.invFind(name, minCount)
	
end

--[[
	Находит предмет внутри инвентаря, и возращает таблицу
	MinCount по умолчанию 1
	Пустая таблица если ничего не найдено
	
	return:
		table:
			[int(слот) - int(кол-во)]
]]
function uni.robot.invFindTable(name, minCount)
	
end

--[[
	return:
		Int - кол-во слотов
]]
function uni.robot.invSlots()
	
end

--[[
	Если указан name, то считает кол-во предметов которые можно подобрать, до конца инвентаря, иначе показывает кол-во свободных слотов
	
	return:
		Int - кол-во свободных [слотов / под предмет]
]]
function uni.robot.invSlotsFree(name)
	
end

--[[
	Бросает предмет из инвентаря
	Если указан name находит и переключается на выбраный слот, если их несколько делает это для всех слотов
	Если указан count выбросить [count предметов], иначе 1
	
	return:
		boolean - если удалось выбросить нужное кол-во предметов, в случаи не удачи они останутся в инвенторе
		string - ошибка, если была
]]
function uni.robot.drop(name, count)
	
end

--[[
	Подбирает предмет в инвентарь
	Если указан name, пытается поднять предмет соответсвующего имени
	Если указан count собрать [count предметов], иначе все
	
	return:
		boolean - если удалось собрать нужное кол-во предметов
		Int - оставшиеся кол-во не поднятых предметов, если первый аргумент false
		string - ошибка, если была
]]
function uni.robot.pickup(name, count)
	
end

--[[
	-- Подбирает предмет в инвентарь
	-- Если указан name, пытается поднять предмет соответсвующего имени
	-- Если указан count собрать [count предметов], иначе все
	
	-- return:
		-- boolean - если удалось собрать нужное кол-во предметов
		-- Int - оставшиеся кол-во не поднятых предметов, если первый аргумент false
]]
-- function uni.robot.swing / attack|dig (name)

-- end

-- function uni.robot.place / place(name)
	
-- end






return uni