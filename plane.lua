--This program is meant for the computercraft turtle
--It will create a plane of a configurable radius around the starting position
--by digging everything in the defined area down to a given depth
--A chest has to be placed above the turtle

--radius excludes starting position: radius = 2 planes a 5x5 area

print("Radius:")
local r = tonumber(read())

print("Depth:")
local depth = tonumber(read())

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

--track current position
local orientation = 0 --0 - straight, 1 - right , -1 - left, 2/-2 - back

--functions
--refuel from slot 1
function refuel(level)
    turtle.select(1)
    if level == nil then
        while turtle.getFuelLevel()<(((r+1)^2)*depth) do --random value
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
        return true
    end
    return false
end

--move up and set new position
function up()
    if turtle.up() then
        newPosition("up")
        return true
    end
    return false
end

--move down and set new position
function down()
    if turtle.down() then
        newPosition("down")
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
    if pos_snap.y > 0 then
        turn(0)
    elseif pos_snap.y < 0 then
        turn(2)
    end
    while pos.y ~= pos_snap.y do
        forward()
    end
end

--go to snapshot X position
function goToX()
    if pos_snap.x > 0 then
        turn(1)
    elseif pos_snap.x < 0 then
        turn(-1)
    end
    while pos.x ~= pos_snap.y do
        forward()
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
        forward()
    end
end

--go to y axis
function goToXZero()
    --go to x = 0
    if pos.x > 0 then
        turn(-1)
    elseif pos.x > 0 then
        turn(1)
    end
    while pos.x ~= 0 do
        forward()
    end
end

--get back to chest
function returnHome()
    pos_snap.x = pos.x
    pos_snap.y = pos.y
    pos_snap.z = pos.z
    --go to z = 0
    while pos.z > 0 do
        up()
    end
    if pos.x > 0 then
        --go to right border
        turn(1)
        while pos.x < r do
            forward()
        end
        goToYZero()
        goToXZero()
    elseif pos.x == 0 then
        goToYZero()
    elseif pos.x < 0 then
        goToXZero()
        goToYZero()
    end
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
end

--go back to the chest, dum+p inventory, get back to current position
function emptyInventory()
    returnHome()
    dumpInventory()
    --return back to where it left off
    if pos_snap.x > 0 then
        --go to right border
        turn(1)
        while pos.x < r do
            forward()
        end
        goToY()
        goToX()
    elseif pos_snap.x == 0 then
        goToY()
    elseif pos_snap.x < 0 then
        goToX()
        goToY()
    end
    --go to z position
    while pos.z < pos_snap.z do
        down()
    end
end

--check if last inventory slot is full
function checkInventory()
    turtle.select(16)
    if turtle.getItemCount() > 0 then
        emptyInventory()
    end
    turtle.select(2)
end

function dig(direction)
    if direction == nil or direction == "forward" then
        while not forward() do
            if turtle.dig() then
                checkInventory()
            end
        end
    elseif direction == "up" then
        while not up() do
            if turtle.digUp() then
                checkInventory()
            end
        end
    elseif direction == "down" then
        while not down() do
            if turtle.digDown() then
                checkInventory()
            end
        end
    end
end

--dig an area defined by a given radius down to a given depth
function plane()
    local dug = 1
    while true do
        dig()
        dug = dug + 1
        if dug == (2*r+1)^2 then
            break
        end
        --turn at the top
        if pos.z % 2 == 0 then
            if pos.y == r then
                left()
                dig()
                dug = dug +1
                left()
            --turn at the bottom
            elseif pos.y == 0-r then
                right()
                dig()
                dug = dug +1
                right()
            end
        elseif pos.z % 2 ~= 0 then
            if pos.y == r then
                right()
                dig()
                dug = dug +1
                right()
            --turn at the bottom
            elseif pos.y == 0-r then
                left()
                dig()
                dug = dug +1
                left()
            end
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
while pos.z > 0-depth do
    plane()
    dig("down")
    left()
    left()
end
plane()
returnHome()
dumpInventory()