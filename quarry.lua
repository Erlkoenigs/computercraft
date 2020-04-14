--pull fuel from item chest?
--for the computercraft turtle
--mimics the buildcraft quarry. can be used to level an area
--takes 2 arguments: radius and depth
--radius excludes starting position: radius = 2 mines a 5x5 area
--turtle will always mine the level it is on and then
--_depth_ levels underneath it
--when turtles inventory is full, it will try to drop items into
--a chest above it's starting position

debug = false
local r = 0
local depth = 0
tArgs = {...}
if #tArgs > 0 then
    r = tonumber(tArgs[1])
    depth = tonumber(tArgs[2])
    print("radius: "..r)
    print("depth: "..depth)
    print("ok? any key to continue")
    os.pullEvent("key")
else
    print("Radius?")
    r = tonumber(read())

    print("Depth?")
    depth = tonumber(read())
end

--states
--current position
local pos={}
pos["x"]=0 --right(+)-left(-)
pos["y"]=0 --front(+)-back(-)
pos["z"]=0 --up(+)-down(-)
--starting point is (0/0/0)
--chest is at (0/0/1)

--snapshot of the current postition
local pos_snap = {}
pos_snap["x"]=0
pos_snap["y"]=0
pos_snap["z"]=0
pos_snap["o"]=0 --orientation

--track current position
local orientation = 0 --0 - straight, 1 - right , -1 - left, 2/-2 - back

--functions
function printPosition(ax)
    if debug then
        if ax == "x" then
            print("x: " .. pos.x .. " - " .. pos_snap.x)
        elseif ax == "y" then
            print("y: " .. pos.y .. " - " .. pos_snap.y)
        elseif ax == "z" then
            print("z: " .. pos.z .. " - " .. pos_snap.z)
        elseif ax == nil then
            print("x: " .. pos.x .. " - " .. pos_snap.x)
            print("y: " .. pos.y .. " - " .. pos_snap.y)
            print("z: " .. pos.z .. " - " .. pos_snap.z)
        end
    end
end

function clog(logstr)
    if debug then print(logstr) end
end

--refuel from slot 1
function refuel(level)
    turtle.select(1)
    if level == nil then
        while turtle.getFuelLevel()<(((r+1)^2) + 5) do
            turtle.refuel(1)
        end
    else
        while turtle.getFuelLevel()<level do
            turtle.refuel(1)
        end
    end
end

--track position. called when moving forward, up or down
function newPosition(dir)
    if dir == nil then
        if orientation == 1 then
            pos.x = pos.x+1
        elseif orientation == -1 then
            pos.x = pos.x-1
        elseif orientation == 0 then
            pos.y = pos.y+1
        elseif orientation == 2 or orientation == -2 then
            pos.y = pos.y-1
        else
            error("newPosition: invalid orientation")
        end
    elseif dir == "up" then
        pos.z = pos.z+1
    elseif dir == "down" then
        pos.z = pos.z-1
    else
        error("newPosition: invalid direction")
    end
end

--track orientation when turning. left turn is -1, right turn is +1
function newOrientation(turn)
    orientation = orientation + turn
    if orientation == 3 then --3 right turns are one left turn
        orientation = -1
    elseif orientation == -3 then --3 left turns are one right turn
        orientation = 1
    end
end

--returns the opposite of a given orientation
function getOppositeOrientation(o)
    local newO
    if o<1 then
        newO = o+2
    elseif o>0 then
        newO = o-2
    end
    return newO
end

--turn left and set new orientation
function left()
    turtle.turnLeft()
    newOrientation(-1)
end

--turn right and set new orientation
function right()
    turtle.turnRight()
    newOrientation(1)
end

--move forward and set new position
function forward()
    if turtle.forward() then
        newPosition()
        refuel()
        return true
    end
    return false
end

--move up and set new position
function up()
    if turtle.up() then
        newPosition("up")
        refuel()
        return true
    end
    return false
end

--move down and set new position
function down()
    if turtle.down() then
        newPosition("down")
        refuel()
        return true
    end
    return false
end

--turn turtle in new direction
function turn(newOrientation)
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

--go to snapshot Y position
function goToY()
    clog("toY")
    if pos_snap.y > pos.y then
        turn(0)
    elseif pos_snap.y < pos.y then
        turn(2)
    end
    while pos.y ~= pos_snap.y do
        if forward() then
            printPosition("y")
        end
    end
end

--go to snapshot X position
function goToX()
    clog("toX")
    if pos_snap.x > pos.x then
        turn(1)
    elseif pos_snap.x < pos.x then
        turn(-1)
    end
    while pos.x ~= pos_snap.x do
        if forward() then
            printPosition("x")
        end
    end
end

--go to x axis
function goToYZero()
    --go to y = 0
    if pos.y > 0 then
        turn(2)
    elseif pos.y < 0 then
        turn(0)
    end
    while pos.y ~= 0 do 
        if forward() then
            printPosition("y")
        end
    end
end

--go to y axis
function goToXZero()
    --go to x = 0
    if pos.x > 0 then
        turn(-1)
    elseif pos.x < 0 then
        turn(1)
    end
    while pos.x ~= 0 do
        if forward() then
            printPosition("x")
        end
    end
end

--get back to chest
function returnHome()
    pos_snap.x = pos.x
    pos_snap.y = pos.y
    pos_snap.z = pos.z
    pos_snap.o = orientation
    clog(pos_snap.x)
    clog(pos_snap.y)
    clog(pos_snap.z)
    --go to z = 0
    while pos.z < 0 do
        up()
    end
    --go one in positive x direction
    turn(1)
    forward()
    --to x axis
    goToYZero()
    --to y axis
    goToXZero()
end

--dump inventory into chest above
function dumpInventory()
    --Empty inventory. If chest is full, try again till it isn't
    local full = false --to only print errors once
    local slot=2 --keep fuel
    while slot<17 do
        turtle.select(slot)
        if turtle.getItemCount(slot)>0 then
            if turtle.dropUp() then
                slot=slot+1
            else
                if not full then
                    print("chest is full") --only print this once
                    full = true
                end
                os.sleep(30) --wait for 30 seconds
            end
        else
            slot=slot+1
        end
    end
    turtle.select(2)
end

--go back to the chest, dump inventory, get back to current position
function emptyInventory()
    returnHome()
    dumpInventory()
    --return back to where it left off
    if pos_snap.x < r then
        --go to current x position + 1
        pos_snap.x = pos_snap.x + 1
        goToX()
        pos_snap.x = pos_snap.x - 1
        goToY()
        goToX()
    else
        goToX()
        goToY()
    end
    --go to z position
    while pos.z > pos_snap.z do
        down()
    end
    turn(pos_snap.o)
end

--check if last inventory slot is full
function checkInventory()
    if turtle.getItemCount(16) > 0 then
        emptyInventory()
    end
    clog("end of check inventory")
end

function endProgram()
    returnHome()
    dumpInventory()
    error("hit bedrock. program finished") --not nice
end

--native dig()-function with check for full inventory and bedrock
function dig(direction)
    if direction == nil or direction == "forward" then
        if turtle.detect() and not turtle.dig() then
            endProgram()
        else
            checkInventory()
        end
    elseif direction == "up" then
        if turtle.detect() and not turtle.digUp() then
            endProgram()
        else
            checkInventory()
        end
    elseif direction == "down" then
        if turtle.detect() and not turtle.digDown() then
            endProgram()
        else
            checkInventory()
        end
    end
end

function digAndGo(direction)
    if direction == nil or direction == "forward" then
        while not forward() do dig() end
    elseif direction == "up" then
        while not up() do dig(direction) end
    elseif direction == "down" then
        while not down() do dig(direction) end
    end
end

--dig an area defined by a given radius
function plane()
    local dug = 1
    local below = false --mine level below or not
    local above = false -- mine level above or not
    local function digStep()
        if above then dig("up") end
        if below then dig("down") end
        digAndGo()
        dug = dug + 1
    end
    while true do
        digStep()
        if dug == (2*r+1)^2 then break end
        --turn at the top
        if pos.y == r then
            left()
            digStep()
            left()
        --turn at the bottom
        elseif pos.y == -r then
            right()
            digStep()
            right()
        end
    end
end

--action
refuel()
--go to right edge
right()
for i=1, r do
    dig()
end
--go to lower right corner
right()
for i=1, r do
    dig()
end
left()
left()
while pos.z > -depth do
    plane()
    clog("level done")
    dig("down")
    left()
    left()
    --reset coordinate system on next level
    pos.x = r
    pos.y = -r
    orientation = 0
end
plane()
returnHome()
dumpInventory()