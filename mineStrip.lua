--not finished
--finds and mines specific ores in strips by going down the strips looking for ores and following the connected ore veins
--won't look for diagonal ores in a vein
--place in front of first strip
--will continue till the end of every strip and until the last strip

local test = true
print("Enter direction of next strips (left/right)")
local stripDirection = read()
local amountOfStrips = 0 --tracks hoow many strips it cleared to find its way back to the starting position
local steps = 0 --tracks how many steps to the side the turtle took after the last strip to be able to find its way back to the starting position
local target = "minecraft:coal_ore"
local currentPosition = 0 --in the strip
local deviation = 0 --deviation from currentPosition in strip direction. forward is positive, backward is negative
local deviationSide = 0 --deviation from strip to the sides. left is negative, right is positive
local deviationVert = 0 --vertical deviation. up is positive, down is negative
local orientation = 0 --left is negative, right is positive. 0 is strip direction, 1 is right, -1 is left, 2 and -2 are back
local path = {} --the path the turtle has taken while following a vein. 3 is up, -3 is down
--local orePosition = {} --track the steps on the path that had ores

--refuel from slot 1
function refuel()
    turtle.select(1)
    while turtle.getFuelLevel()<250 do --random value
        turtle.refuel(1)
    end
end

--track orientation when turning. left turn is -1, right turn is +1
function newOrientation(turn) --1 is right turn, -1 is left turn
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
    if o<0 then
        newO = o+2
    elseif o>2 then
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

--turn depending on stripDirection, true for turn in stripDirection false for opposite direction
function turnStripDirection(notInverted)
    if notInverted then
        if stripDirection == "right" then
            right()
        elseif stripDirection == "left" then
            left()
        else
            print("Invalid direction. Use left or right")
        end
    elseif not notInverted then
        if stripDirection == "right" then
            left()
        elseif stripDirection == "left" then
            right()
        else
            print("Invalid direction. Use left or right")
        end
    end
end

--Shift over to the next strip in the given direction. 
function reposition(direction)
    if amountOfStrips == 0 then --when just starting
        amountOfStrips = 1
    else
        --turn
        turnStripDirection(true)
        --go to next strip
        local i=0
        while i<4 do --4 blocks
            if turtle.forward() then 
                i=i+1
                steps=i
            else --if last strip is reached, turtle cant move further
                return false
            end
        end
        amountOfStrips=amountOfStrips+1
        turnStripDirection(false)
    end
end

--set new deviation from currentPosition when following a vein. called when moving one step forward, up or down. based on orientation
function newDeviation(direction)
    if direction == nil then
        if orientation == 0 then
            deviation = deviation + 1
        elseif orientation == 1 or orientation == -1 then
            deviationSide = deviationSide + orientation
        elseif orientation == 2 or orientation == -2 then
            deviation = deviation - 1
        end
    elseif direction == "up" then
        deviationVert=deviationVert+1
    elseif direction == "down" then
        deviationVert=deviationVert-1
    end
end

--dig block in front, up or down, then move in that direction
function dig(direction) --ore true when called to mine an ore
    if direction == nil then --if no direction given
        while not turtle.forward() do
            turtle.dig()          
        end
        newDeviation()
        table.insert(path,orientation)
        refuel()
    elseif direction == "up" then
        while not turtle.up() do
            turtle.digUp()          
        end
        newDeviation("up")
        table.insert(path,3)
        refuel()
    elseif direction == "down" then
        while not turtle.down() do
            turtle.digDown()
        end
        newDeviation("down")
        table.insert(path,-3)
        refuel()
    end
end

--go a variable amount of steps back on the path you went in
function stepBackOnPath(s)
    for i=0,s do
        dir=table.remove(path)
        if dir == 3 then
            dig("down")
            table.remove(path)
        elseif dir == -3 then
            dig("up")
        else
            turn(getOppositeOrientation(table.remove(path)))
            dig()
        end
    end 
end

--follow a given path
function followPath(path)
    for i=1,#path do
        if path[i] == 3 then
            dig("up")
        elseif path[i] == -3 then
            dig("down")
        else
            turn(path[i])
            dig()
        end
    end
end

--go back to chest and empty inventory, then come back
function emptyInventory()
    refuel()
    local tempPath = path
    stepBackOnPath(#path)
    --turn toward the beginning of the strip
    turn(2)
    --walk back the strip to the beginning
    local i=0
    while i<currentPosition do
        if turtle.forward() then i=i+1 end
    end
    --turn toward starting position
    turnStripDirection(true)
    --walk back to starting position
    local i = 0
    while i<(amountOfStrips-1)*4 do
        if turtle.forward() then
            i=i+1
        end
    end
    --turn toward chest
    turnStripDirection(false)
    --empty Inventory in chest
    print("emptying inventory")
    local slot=2 --keep fuel and torches
    while slot<17 do
        turtle.select(slot)
        if turtle.drop() then
            slot=slot+1
        end
    end
    --move to fuel chest
    right()
    turtle.forward()
    left()
    turtle.select(1)
    print("picking up fuel")
    while turtle.getItemCount()<64 do
        if not turtle.suck(64-turtle.getItemCount()) then
            print("no fuel in chest")
        end
    end
    --move to torch chest
    right()
    turtle.forward()
    left()
    turtle.select(2)
    print("picking up torches")
    while turtle.getItemCount()<64 do
        if not turtle.suck(64-turtle.getItemCount()) then
        end
    end
    turtle.select(3)
    --move back to starting position
    left()
    turtle.forward()
    turtle.forward()
    left() --now in starting position and orientation
    if not orientation == 0 then --just to be sure
        print("wrong orientation")
        read()
    end 
    turnStripDirection(true)
    --back to the current strip
    local i=0
    while i<(amountOfStrips-1)*4 do
        if turtle.forward() then
            i=i+1
        end
    end
    turnStripDirection(false)
    --back down the strip
    local i=0
    while i<currentPosition do
        if turtle.forward() then
            i=i+1
        end
    end
    followPath(tempPath)
end

--check if last item slot contains items. if true, emptyInventory()
function checkInventory()
    turtle.select(16)
    if turtle.getItemCount() > 0 then
        emptyInventory()
    end
    turtle.select(2)
end

--check block in front, up or down. true if block is wanted
function check(d)
    if d == nil then
        s,d=turtle.inspect()
        if d.name==target then
            return true
        end
    elseif d=="up" then
        s,d=turtle.inspectUp()
        if d.name==target then
            return true
        end
    elseif d=="down" then
        s,d=turtle.inspectDown()
        if d.name==target then
            return true
        end
    end
    return false
end

--scan up, down and all sides. return "up" or "down" when ore found in those directions return true or false when ore found on a side
--will leave the turtle in the direction of the found ore
function scan()
    if check("up") then
        return "up"
    end
    if check("down") then
        return "down"
    end
    local i = 0
    while not check() and i<4 do --if no target block around, turn back to previous orientation
        left()
        i=i+1
    end
    if i == 4 then
        return false
    end
    return true
end

--follow and mine a vein
function mineVein()
    while #path>0 do    
        local s = scan()
        if s == "up" then
            dig("up")
        elseif s == "down" then
            dig("down")
        elseif s == true then
            dig()
        else
            stepBackOnPath(1)
        end
    end
end

if not test then
    while reposition() do
        if turtle.detect() then --when reposition() was able to go 4 blocks to the left, but there's no more strips
            break
        end
        while turtle.forward() do --go forward through strip till the end
            currentPosition=currentPosition+1
            --check surrounding blocks
            turtle.turnLeft() --left one first
            if check() then --start of a vein
                dig() --go one block into the vein
                left()
                mineVein() --follow it
            end

            turn(0)
        end
        turtle.turnLeft() --turn around
        turtle.turnLeft()
        for i=0,currentPosition do --back to the start of the strip
            turtle.forward()
        end
        turtle.turnLeft()
        turtle.turnLeft()
    end
    turtle.turnRight()
    turtle.turnRight()
    while i<(amountOfStrips-1)*4+steps do
        if turtle.forward() then
            i=i+1
        end
    end
    turtle.turnRight() --turn to starting orientation
end

refuel()
dig()
mineVein()