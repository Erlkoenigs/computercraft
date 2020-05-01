--digs a tunnel

local debug = true
local l = 0
local lenght
local width = 1
local toDig = {}
toDig.r = 0
toDig.l = 0
local height = 1
local pos = vector.new(0,0,0)
local orientation = 0
local pos_snap = vector.new(0,0,0)
local o_snap = 0
local torch = vector.new(0,0,0)
local target = vector.new(0,0,0)

local tArgs = {...}
if #tArgs == 0 then
    print("tunnel <target x> <target y> <target z>")
    return
elseif #tArgs == 3 then
    target = vector.new(tArgs[1], tArgs[2], tArgs[3])
else
    print("tunnel <target x> <target y> <target z>")
    return
end

--refuel from slot 1
local function refuel(amount)
    if amount == nil then amount = depth*5 end --random value
    while turtle.getFuelLevel() < amount do
        turtle.select(1)
        turtle.refuel(1)
    end
end --refuel

--update pos based on direction of movement and current orientation
local function newPosition(dir)
    if dir == nil or dir == "forward" then
        if orientation == 1 then
            pos.x = pos.x+1
        elseif orientation == -1 then
            pos.x = pos.x-1
        elseif orientation == 0 then
            pos.y = pos.y+1
        elseif orientation == 2 or orientation == -2 then
            pos.y = pos.y-1
        end
    elseif dir == "back" then
        if orientation == 1 then
            pos.x = pos.x-1
        elseif orientation == -1 then
            pos.x = pos.x+1
        elseif orientation == 0 then
            pos.y = pos.y-1
        elseif orientation == 2 or orientation == -2 then
            pos.y = pos.y+1
        end
    elseif dir == "up" then
        pos.z = pos.z+1
    elseif dir == "down" then
        pos.z = pos.z-1
    else
        error("newPosition: invalid direction")
    end
end

--update orientation when turning. left turn is -1, right turn is +1
local function newOrientation(turn)
    orientation = orientation + turn
    if orientation == 3 then --3 right turns are one left turn
        orientation = -1
    elseif orientation == -3 then --3 left turns are one right turn
        orientation = 1
    end
end

--turn left and set new orientation
local function left()
    turtle.turnLeft()
    newOrientation(-1)
end

--turn right and set new orientation
local function right()
    turtle.turnRight()
    newOrientation(1)
end

--turn turtle in new direction
local function turn(newOrientation)
    diff=newOrientation-orientation
    if diff == -1 or diff == 3 then
        left()    
    elseif diff == 1 or diff == -3 then
        right()
    elseif diff == 2 or diff == -2 then
        right()
        right()
    end
end

--move forward and set new position. return success
local function forward()
    refuel()
    if turtle.forward() then
        newPosition()
        return true
    end
    return false
end

--move back and set new position. return success
local function back()
    refuel()
    if turtle.back() then
        newPosition()
        return true
    end
    return false
end

--move up and set new position. return success
local function up()
    refuel()
    if turtle.up() then
        newPosition("up")
        return true
    end
    return false
end

--move down and set new position. return success
local function down()
    refuel()
    if turtle.down() then
        newPosition("down")
        return true
    end
    return false
end

--go one step in a given direction. return success
local function step(dir)
    local res
    if dir == nil or dir == "forward" then
        res = forward()
    elseif dir == "up" then
        res = up()
    elseif dir == "down" then
        res = down()
    elseif dir == "back" then
        res = back()
    end
    return res
end

local function returnHome()
    pos_snap = pos.x
    pos_snap = pos.y
    pos_snap = pos.z
    o_snap = orientation
    --1 step back
    turn(2)
    forward()
    --to z = 1 to stay above torches
    if pos.z > 1 then
        while pos.z ~= 1 do down() end
    elseif pos.z < 1 then
        while pos.z ~= 1 do up() end
    end
    --to x = 0
    if pos.x > 0 then
        turn(-1)
    elseif pos.x < 0 then
        turn(1)
    end
    while pos.x ~= 0 do forward() end
    turn(2)
    --to y = 0
    while pos.y ~= 0 do forward() end
    --to z = 0
    while pos.z ~= 0 do down() end
end

local function backToWork()
    --to z = 1
    while pos.z ~= 1 do up() end
    --to y-1
    turn(0)
    while pos.y < pos_snap.y-1 do forward() end
    --to x
    if pos_snap.x > 0 then 
        turn(1)
    elseif pos_snap.x < 0 then
        turn(-1)
    end
    while pos.x ~= pos_snap.x do forward() end
    --to z
    while pos.z ~= pos_snap.z do up() end
    --to y
    turn(0)
    while pos.y < pos_snap.y do forward() end
    turn(o_snap)
end

--empty inventory. If chest is full, try again till it isn't
local function dumpInventory()
    local full = false --to only print errors once
    local slot=2 --keep fuel
    while slot < 17 do
        if turtle.getItemCount(slot)>0 then
            turtle.select(slot)
            if turtle.dropUp() then
                slot=slot+1
            else
                print("chest is full")
                os.pullEvent("key")
            end
        else
            slot=slot+1
        end
    end
    turtle.select(2)
end

local function checkInventory()
    if turtle.getItemCount(16) > 0 then
        returnHome()
        dumpInventory()
        backToWork()
    end
end

local function dig(dir)
    if dir == nil or dir == "fw" then
        turtle.dig()
    elseif dir == "up" then
        turtle.digUp()
    elseif dir == "down" then
        turtle.digDown()
    end
    checkInventory()
end

local function digAndGo(dir)
    while not step(dir) do dig(dir) end
end

function tunnel(axis)
    repeat
        digAndGo()
        dig("up")
        turn(1)
        for i=1,3 do
        digAndGo()
        dig("up")
        end
        turn(-1)
        digAndGo("up")
        for i=1,3 do
            digAndGo()
            dig("up")
        end
        right()
        digAndGo("down")
    until pos[axis] == target[axis]
end

tunnel("y")
if target.x > pos.x then
    turn(1)
elseif target.x < pos.x then
    turn(-1)
end
tunnel("x")