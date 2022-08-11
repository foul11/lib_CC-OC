local sides = sides
local uni = uni

local uni_cc = {
	robot = {},
	computer = {}, -- TODO: write
	component = {}, -- TODO: write
	shell = { ["parse"] = function() end }, -- TODO: write
}


local equipList = {
	['bottom'] = nil,
	['top'] = nil,
	['front'] = nil,
	['back'] = nil,
	['right'] = nil,
	['left'] = nil,
} -- TODO: fill on start and proxy all equip for information

local turtle_type = {
	['unknown'] = 0,
	['mining'] = 1, -- pickaxe
	['felling'] = 2, -- axe
	['digging'] = 3, -- shovel
	['farming'] = 4, -- hoe
}

local function findStringInTable(t, str)
	for k, v in pairs(t) do
		if string.find(v, str) then
			return k
		end
	end
	
	return nil
end

local function toSide(side)
	return sides[side]
end

--[[
	return:
		string - type turtle
		[table(side)] - side equip
]]
local function getTurtleType()
	local finded
	
	finded = findStringInTable(equipList, 'pickaxe')
	if finded then return 'minning', sides[finded] end
	
	finded = findStringInTable(equipList, 'axe')
	if finded then return 'felling', sides[finded] end
	
	finded = findStringInTable(equipList, 'shovel')
	if finded then return 'digging', sides[finded] end
	
	finded = findStringInTable(equipList, 'hoe')
	if finded then return 'farming', sides[finded] end
	
	return nil
end


function uni_cc.robot.durability() -- COMPATIBILITY
	return 9999
end

local _move = {
	[sides.forward] = turtle.forward,
	[sides.back] = turtle.back,
	[sides.up] = turtle.up,
	[sides.down] = turtle.down,
}
function uni_cc.robot.move(direction)
	_move[toSide(direction)]()
end

function uni_cc.robot.turn(clockwise)
	if clockwise then
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
end

function uni_cc.robot.name()
	return (os.getComputerLabel and os.getComputerLabel()) or
		(os.computerLabel and os.computerLabel()) or
		"none"
end

local _swing = {
	[sides.forward] = { ["attack"] = turtle.attack, ["dig"] = turtle.dig },
	[sides.up] = { ["attack"] = turtle.attackUp, ["dig"] = turtle.digUp },
	[sides.down] = { ["attack"] = turtle.attackDown, ["dig"] = turtle.digDown },
}
function uni_cc.robot.swing(side)
	local t, eqSide = getTurtleType()
	
	if t ~= nil then
		return _swing[toSide(side)]["attack"](eqSide.CC)
	end
	
	return _swing[toSide(side)]["dig"](eqSide.CC)
end

function uni_cc.robot.use(side, sneaky --[[ OPTION IGNORE PARM ]], duraction  --[[ OPTION IGNORE PARM ]]) end -- TODO: write [Core Use needed]

local _place = {
	[sides.forward] = turtle.place,
	[sides.up] = turtle.placeUp,
	[sides.down] = turtle.placeDown,
}
function uni_cc.robot.place(side, sneaky --[[ IGNORE PARM ]])
	return _place[toSide(side)]()
end


local lightColor = 0xFF0000

function uni_cc.robot.getLightColor()
	return lightColor
end

function uni_cc.robot.setLightColor(value)
	lightColor = value
end


function uni_cc.robot.inventorySize() return 16 end -- COMPATIBILITY

function uni_cc.robot.select(slot)
	if slot ~= nil then
		return turtle.select(slot)
	end
	
	return turtle.getSelectedSlot()
end

function uni_cc.robot.count(slot)
	return turtle.getItemCount(slot)
end

function uni_cc.robot.space(slot)
	return turtle.getItemSpace(slot)
end

function uni_cc.robot.compareTo(slot)
	return turtle.compareTo(slot)
end

function uni_cc.robot.transferTo(slot, amount)
	return turtle.transferTo(slot, amount)
end

-- COMPATIBILITY
function uni_cc.robot.tankCount() return 0 end
function uni_cc.robot.selectTank(tank) return end
function uni_cc.robot.tankLevel(tank) return 0 end
function uni_cc.robot.tankSpace(tank) return 0 end
function uni_cc.robot.compareFluidTo(tank) return false end
function uni_cc.robot.transferFluidTo(tank, count) return false end
-- END

local _detect = {
	[sides.forward] = turtle.detect,
	[sides.up] = turtle.detectUp,
	[sides.down] = turtle.detectDown,
}
function detect(side)
	return _detect[toSide(side)]()
end

-- COMPATIBILITY
function compareFluid(side) return false end
function drain(side, count) return false end
function fill(side, count) return false end
-- END

local _compare = {
	[sides.forward] = turtle.detect,
	[sides.up] = turtle.detectUp,
	[sides.down] = turtle.detectDown,
}
function compare(side, fuzzy --[[ IGNORE PARM ]])
	return _compare[toSide(side)]()
end

local _drop = {
	[sides.forward] = turtle.drop,
	[sides.up] = turtle.dropUp,
	[sides.down] = turtle.dropDown,
}
function drop(side, count)
	return _drop[toSide(side)](count)
end

local _suck = {
	[sides.forward] = turtle.suck,
	[sides.up] = turtle.suckUp,
	[sides.down] = turtle.suckDown,
}
function suck(side, count)
	return _suck[toSide(side)](count)
end


return uni_cc