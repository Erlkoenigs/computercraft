--not finished
--This program is meant for the computercraft turtle
--It will create a plane of a configurable radius around the starting position
--by digging everything on the level of its starting position and above

--radius excludes starting position: radius = 2 planes a 5x5 area

--Order of digging in one plane with radius = 2:
--t - turtle
--c - chest
--19 18 11 10 6
--20 17 12 9  5
--21 16 t  1  2
--22 15 c  8  3
--23 14 13 7  4

print("Radius:")
local r = tonumber(read())

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
local dug = true

function refuel()
    turtle.select(1)
    while turtle.getFuelLevel()<300 do --random value
        turtle.refuel(1)
    end
    turtle.select(2)
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

function emptyInventory()
    --back to starting position
    --two problems: 
    --1. the chest might be in the way 
    --2. if the turtle is still in the first half of the first level, only the path it took to get from the starting position to the lower right corner is free
    --=> path to take:
    --move down one level (to get around potentially uncleard blocks)
    --if not on ground level now (not pos.z==0), then move to pos.y=0, then move to pos.x=0, then move to pos.z=0
    --if on ground level now (pos.z==0) and the chest is on the path (pos.x=0 and currentPosition<(2*r^2+2*r+1)(=starting position)), then go around it
    --if r%2==0, then go around right, else go around left
    if pos.z>0 then
        down()
    end
    if pos.z==0 and pos.x==0 and currentPosition<2*r^2+2*r+1 then --chest is in the way
        --go around chest
    else

    end
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
                dug = true
                checkInventory()
            end            
        end
        if turtle.getFuelLevel()<80 then
            Refuel()
        end
        currentPosition=currentPosition+1
    end
end

--dig a plane with given radius
function plane()
    dug = false
    currentPosition = 1
    --dig straights up and down, starting from the lower right corner (point (r/-r/0))
    for i=0,r*2+1 do --(plus starting position block)
        if i==2*r^2+2*r+1-r and currentHeight==0 then --if in middle row on the lowest level, go over chest
            digForward(r)
            while not turtle.up() do
                turtle.digUp()
            end
            currentHeight=currentHeight+1
            digForward(2)
            while not turtle.down() do
                turtle.digDown()
            end
            currentHeight=currentHeight-1
            digForward(r-2)
            --turn
            if i%2==0 or i==0 then
                left()
            else
                right()
            end
            digForward(1)
            if i%2==0 or i==0 then
                left()
            else
                right()
            end
        else
            digForward(r*2+1)
            --turn
            if i%2==0 or i==0 then
                left()
            else
                right()
            end
            digForward(1)
            if i%2==0 or i==0 then
                left()
            else
                right()
            end
        end
    end
end

--action
refuel()
--to lower right corner
right()
digForward(r) --to the right edge
right()
turtle.digForward(r) --to the lower right corner
left() --turn around
left()
while dug == true and pos.z < height do
    refuel()

    if not up() then --go up one level
        turtle.digUp()
    end
end