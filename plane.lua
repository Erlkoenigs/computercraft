--not finished
--This program is meant for the computercraft turtle
--It will create a plane of a configurable radius around the starting position
--by digging everything in the defined area down to a given depth
--A chest has to be placed above the turtle

--radius excludes starting position: radius = 2 planes a 5x5 area

print("Radius:")
local r = tonumber(read())

print("Depth:")
local depth = tonumber(read())

local pos={}
pos["x"]=0 --right(+)-left(-)
pos["y"]=0 --front(+)-back(-)
pos["z"]=0 --up(+)-down(-)
--starting point is (0/0/0)
--chest is at (0/-1/0)

--track current position
local currentHeight = 0
local currentPosition = 0
local orientation = 0 --0 - straight, 1 - right , -1 - left, 2/-2 - back

--refuel from slot 1
function refuel(level)
    turtle.select(1)
    if level == nil then
        while turtle.getFuelLevel()<((r+1)^2)*depth do --random value
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
    else
        error("newOrientation: invalid turn")
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

function emptyInventory()
    --[[for i=1,pos.z do
        down()
    end
    if pos.x>0 then
        turn(-1)
    elseif pos.x<0 then
        turn(1)
    end
    ]]
end

function checkInventory()
    turtle.select(16)
    if turtle.getItemCount() > 0 then
        emptyInventory()
    end
    turtle.select(2)
end

function digForward(blocks)
    for i=0, blocks do
        while not forward() do
            if turtle.dig() then
                checkInventory()
            end            
        end
        if turtle.getFuelLevel()<80 then
            Refuel()
        end
        currentPosition=currentPosition+1
    end
end

--dig an area defined by a given radius down to a given depth
function plane()
    while currentPosition<depth*(r+1)^2 do
        for i=1,(r+1)^2 do
            dig()
            currentPosition = currentPosition+1
            --turn at the end of each straight
            if currentPosition % (2*r+1) == 0 and currentPosition % 2*(2*r+1) ~= 0 then
                left()
            elseif currentPosition % (2*r+1) == 0 and currentPosition % 2*(2*r+1) == 0 then
                right()
            end
            --turn at the beginning of each straight
            if currentPosition-1 % (2*r+1) == 0 and currentPosition-1 % 2*(2*r+1) ~= 0 then
                left()
            elseif currentPosition-1 % (2*r+1) == 0 and currentPosition-1 % 2*(2*r+1) == 0 then
                right()
            end
        end  
    dig("down")
    currentPosition = currentPosition+1
    left()
    left()
    end
end

--action
refuel()
--go to right edge
right()
local i=0
while i<r do
    dig()
end
--go to lower right corner
right()
while i<r do
    dig()
end
left()
left()
currentPosition = 1
