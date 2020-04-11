--for the computercraft turtle
--1. goes all the way to the ceiling
--2. goes forward until it finds glowstone
--3. mines all adjacent glowstone
--4. return to starting position

local up = 0
local fw = 0
local orientation = 0
local path = {}
local target = {} --will search for these strings at the end of the block information
target[1] = "lowstone"
target[2] = "dirt"

--refuel from slot 1
function refuel(level)
    if level == nil then
        while turtle.getFuelLevel()<50 do --random value
            turtle.select(1)
            turtle.refuel(1)
        end
    else
        while turtle.getFuelLevel()<level do
            turtle.select(1)
            turtle.refuel(1)
        end
    end
end

--make sure turtle goes forward. If path is blocked, print it once
function forward(steps)
    refuel(steps)
    if steps == nil then steps = 1 end
    local blocked = false
    local blocks = 0
    while blocks < steps do        
        if turtle.forward() then
            blocks=blocks+1
        else
            os.sleep(30)
            if not blocked then
                blocked = true
                print("path is blocked") --only print this once
            end
        end
    end
end

--track orientation when turning. Left turn is -1, right turn is +1
function newOrientation(turn)
    orientation = orientation + turn
    if orientation == 3 then --3 right turns are one left turn
        orientation = -1
    elseif orientation == -3 then --3 left turns are one right turn
        orientation = 1
    end
end

--returns the opposite of a given orientation
function getOppositeOrientation(orientation)
    local opppositeOrientation
    if orientation<=0 then
        opppositeOrientation = orientation+2
    elseif orientation>0 then
        opppositeOrientation = orientation-2
    end
    return opppositeOrientation
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

--dig block in front, up or down, then move in that direction. Update path
function digVein(direction) --ore true when called to mine an ore
    if direction == nil then --if no direction given
        while not turtle.forward() do
            turtle.dig()          
        end
        table.insert(path,orientation)
        refuel()
    elseif direction == "up" then
        while not turtle.up() do
            turtle.digUp()          
        end
        table.insert(path,3)
        refuel()
    elseif direction == "down" then
        while not turtle.down() do
            turtle.digDown()
        end
        table.insert(path,-3)
        refuel()
    end
end

--go a variable amount of steps back on the path you went in
function stepBackOnPath(s)
    --action
    if s == nil then s = 1 end
    for i=1,s do
        local dir=table.remove(path) --get and remove last entry
        --print("reversing "..dir)
        if dir == 3 then
            while not turtle.down() do
                turtle.digDown()
            end
        elseif dir == -3 then
            while not turtle.up() do
                turtle.digUp()
            end
        else
            --print("opposite of "..dir.." is "..oppo)
            turn(getOppositeOrientation(dir))
            while not turtle.forward() do
                turtle.dig()
            end
        end
    end 
end

function check(direction)
    local success,data
    if direction == nil then
        success,data=turtle.inspect()
        if success then
            for i=1,#target do 
                if string.sub(data.name,-#target[i])==target[i] then
                    return true
                end
            end
        end        
    elseif direction=="up" then
        success,data=turtle.inspectUp()
        if success then
            for i=1,#target do 
                if string.sub(data.name,-#target[i])==target[i] then
                    return true
                end
            end
        end
    elseif direction=="down" then
        success,data=turtle.inspectDown()
        if success then
            for i=1,#target do 
                if string.sub(data.name,-#target[i])==target[i] then
                    return true
                end
            end
        end        
    end
    return false
end

function scan()
    if check("up") then
        return "up"
    end
    if check("down") then
        return "down"
    end
    --turn left until block in front is wanted
    local i = 0
    while not check() and i<4 do
        left()
        i=i+1
    end
    if i == 4 then --if full turn, no block was wanted
        return false
    end
    return true
end

--follow and mine a vein
function mineVein()
    while #path>0 do    
        local s = scan()
        if s == "up" then
            digVein("up")
        elseif s == "down" then
            digVein("down")
        elseif s == true then
            digVein()
        else
            stepBackOnPath(1)
        end        
    end
end

--1.
while not turtle.detectUp() do
    turtle.up()
    up = up + 1
end

--2.
while not turtle.detect() do
    turtle.forward()
    fw = fw + 1
end
if check() then --start of a vein
    digVein() --go one block into the vein
    mineVein() --follow it
    turn(2)
else
    print("nope")
end
--4.
for i=0,fw do
    turtle.forward()
end
for i=0,up do
    turtle.down()
end