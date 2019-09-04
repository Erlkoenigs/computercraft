--This program is meant for the computercraft turtle
--It creates 1x2 mining strips with a 3 block spacing
--On the way back it will mine ore veins it finds
--The turtle needs fuel in slot 1, torches in slot 2, a chest that is regularly emptied,
--a chest that contains fuel and a chest that contains torches
--The turtle will start digging the first strip forward from its starting position
--the chest for the mined items has to be placed directly behind the starting position,
--the chest with the fuel has to be placed to the left of the item chest, when looking down the strips,
--the chest with the torches has to be placed to the left of the fuel chest, when looking down the strips.
--the entrance of an already finished strip can be marked by a torch. The turtle will do the same and skip the marked strips

local torchDistance = 12 -- place torches every x blocks
local orientation = 0 --left is negative, right is positive. 0 is strip direction, 1 is to the right of that, -1 is left, 2 and -2 are back
local target = "ore" --will search for this string at the end of the block information
local target2 = "resources" --to find forestry ores, it will also search for this at the end of the block information
local path = {} --the path the turtle has taken while following a vein. 3 is up, -3 is down
local currentPosition = 0 --holds the current position within a strip. Is reset to zero at the beginning of a new strip
local lateralPosition = 0
local currentHeight = 0 --only tracked within strips, not within veins. Will only have values 0 and 1
local torchBlock = false --is there a block to place the finishing torch on

--get command line arguments
tArgs={...}
local stripDirection = "" --New strips will be created to the "stripDirection" of the Startingpoint of the turtle
local stripAmount = 0
local stripLength = 0

--inform user about the program setup and wait for acknowledgement
function informUser()
    local sDir = ""
        if stripDirection == "l" then
            sDir = "left"
        elseif stripDirection == "r" then
            sDir = "right"
        end
    print(stripAmount.." strips with a length of "..stripLength.." will be created to the "..sDir.." of the current position.")
    print("Make sure there's fuel in slot one and torches in slot two")
    print("press any button to continue")
    os.pullEvent("key")
end

--ask for the information needed, if not properly given in command line arguments
function getUserInput()
    stripDirection = ""
    stripLength = 0
    stripAmount = 0
    --direction
    while not (stripDirection == "r" or stripDirection == "l") do
        print("Enter strip direction (l/r):")
        stripDirection = read()
        if not (stripDirection == "r" or stripDirection == "l") then 
            term.clear()
            term.setCursorPos(1,1)
            print("Invalid direction. Please use 'l' or 'r'")
        end
    end    
    --amount
    while stripAmount == 0 do
        print("Enter strip amount:")
        stripAmount = tonumber(read())
        if stripAmount == nil then stripAmount = 0 end --make sure it's a number
        if not (type(stripAmount) == "number" and stripAmount > 0) then 
            term.clear()
            term.setCursorPos(1,1)
            print("Invalid amount. Please input any number greater than zero.")
        end
    end
    --length
    while stripLength == 0 do
        print("Enter strip length:")
        stripLength = tonumber(read())
        if stripLength == nil then stripLength = 0 end --make sure it's a number
        if not (type(stripLength) == "number" and stripLength > 0) then
            term.clear()
            term.setCursorPos(1,1)
            print("Invalid length. Please input any number greater than zero.")
        end
    end
    informUser()
end

function usageHint()
    term.clear()
    term.setCursorPos(1,1)
    print("Invalid command line arguments")
    print("use: strip <direction> <amount> <length>")
    print("with direction as 'l' or 'r' and amount and length as numbers greater than zero")
    print()
end

--if command line arguments are ok, use them
if #tArgs>0 then
    if type(tonumber(tArgs[2])) == "number" and type(tonumber(tArgs[3])) == "number" then
        if (tArgs[1] == "l" or tArgs[1] == "r") and tonumber(tArgs[2])>0 and tonumber(tArgs[3])>0 then
            stripDirection = tArgs[1]
            stripAmount = tonumber(tArgs[2])
            stripLength = tonumber(tArgs[3])
            term.clear()
            term.setCursorPos(1,1)
            informUser()
        else
            usageHint()
            getUserInput()
        end
    else
        usageHint()
        getUserInput()
    end
else
    getUserInput()
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

--refuel from slot 1
function refuel(level)
    turtle.select(1)
    if level == nil then
        while turtle.getFuelLevel()<stripLength*3 do --random value
            turtle.refuel(1)
        end
    else
        while turtle.getFuelLevel()<level do
            turtle.refuel(1)
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

--turn depending on stripDirection, true for turn in stripDirection false for turn in opposite direction
function turnStripDirection(notInverted)
    if notInverted then
        if stripDirection == "r" then
            right()
        elseif stripDirection == "l" then
            left()
        else
            error("Invalid direction. Use l or r")
        end
    elseif not notInverted then
        if stripDirection == "r" then
            left()
        elseif stripDirection == "l" then
            right()
        else
            error("Invalid direction. Use l or r")
        end
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

--follow a given path. Not used
function followPath(newPath)
    for i=1,#newPath do
        if newPath[i] == 3 then
            digVein("up")
        elseif newPath[i] == -3 then
            digVein("down")
        else
            turn(newPath[i])
            digVein()
        end
    end
end

--check if last item slot contains items. if true,
--return to chest and empty inventory into chest. If chest full, wait. When finished, return to previous position
--also picks up fuel and torches from the chests next to the item chest
function checkInventory()
    turtle.select(16)
    if turtle.getItemCount() > 0 then
        refuel(stripLength+stripAmount*4+5)
        print("checkInventory:down the strip")
        print("currentPosition: "..currentPosition)
        --get back to the chest
        turn(2)
        if currentHeight == 1 then --if on upper level, go down
            while not turtle.down() do end
        end
        forward(currentPosition) --back down the strip
        turnStripDirection(true)
        print("checkInventory:back to chest")
        print("lateralPosition: "..lateralPosition)
        forward(lateralPosition) --back to the chest
        turnStripDirection(false)
        --Empty inventory. If chest is full, try again till it isn't
        local full = false
        local slot=3 --keep torch and fuel
        while slot<17 do
            turtle.select(slot)
            if turtle.getItemCount(slot)>0 then
                if turtle.drop() then
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
        turtle.select(3)
        --pick up fuel and torches
        --fuel
        right()
        forward()
        left()
        refuel()
        turtle.select(1)
        full = false
        while turtle.getItemCount()<64 do
            if not turtle.suck(64-turtle.getItemCount()) then
                if not full then
                    print("no fuel in chest")
                    full = true
                end
            end
        end
        --torches
        right()
        forward()
        left()
        turtle.select(2)
        full = false
        while turtle.getItemCount()<64 do
            if not turtle.suck(64-turtle.getItemCount()) then
                if not full then
                    print("no torches in chest")
                    full = true
                end
            end
        end
        --back to starting position
        left()
        forward(2)
        left()
        --return to current strip
        print("checkInventory:back to strip")
        turnStripDirection(true)
        forward(lateralPosition) --back to the strip
        turnStripDirection(false)
        print("checkInventory:back to current position")
        forward(currentPosition) --back to the position in the strip
        if currentHeight == 1 then --if on upper level, go down
            while not turtle.up() do end
        end
    end
    turtle.select(3)
end

--check block in front, up or down. true if block is wanted
function check(direction)
    local success,data
    if direction == nil then
        success,data=turtle.inspect()
        if success then
            if string.sub(data.name,-#target)==target or string.sub(data.name,-#target2)==target2 then
                return true
            end
        end        
    elseif direction=="up" then
        success,data=turtle.inspectUp()
        if success then
            if string.sub(data.name,-#target)==target or string.sub(data.name,-#target2)==target2 then
                return true
            end
        end
    elseif direction=="down" then
        success,data=turtle.inspectDown()
        if success then
            if string.sub(data.name,-#target)==target or string.sub(data.name,-#target2)==target2 then
                return true
            end
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
    checkInventory()
end

--Digs a 1x2 strip of a given length in the forward direction. Picks up mined items
function stripForward(blocks)
    local i=0
    while i<blocks do
        if turtle.dig() then checkInventory() end
        if turtle.forward() then
            if orientation == 0 then --count currentPosition up when going down the strip
                currentPosition = currentPosition+1
            elseif orientation == -1 or orientation == 1 then -- count lateralPosition up when repositioning
                lateralPosition = lateralPosition + 1
            end
            refuel()
            if turtle.detectUp() then
                while turtle.detectUp() do --break upper block of the strip and wait for potential gravity-affected blocks that fall down (like gravel and sand)
                    turtle.digUp()
                    os.sleep(0.75)
                end
                checkInventory()
            end
            i=i+1
        end
    end
end

--dig a strip and return to starting position of the strip. Uses StripForward, but returns to the starting position afterwards
function strip(length)
    print("strip")
    stripForward(length)    
    left()
    left()
    --Forward(length) --walk back out of the strip
    while currentPosition>0 do
        if check("down") then --start of a vein
            digVein("down") --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        turn(1) --right
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
            turn(2)
        end            
        turn(-1) --left
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        while not turtle.up() do end
        currentHeight=currentHeight+1
        turn(-1) --left
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        if check("up") then --start of a vein
            digVein("up") --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        turn(1) --right
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        turn(2)            
        while not turtle.down() do end
        currentHeight=currentHeight-1
        if currentPosition % torchDistance == 0 then
            turtle.select(2)
            turtle.placeUp()
        end
        --check if there's a block underneath the first block of the strip
        if currentPosition == 1 then
            local s,d=turtle.inspectDown()
            if s then
                if d == "minecraft:gravel" then
                    torchBlock = false
                    turtle.digDown() --get rid of the gravel
                    checkInventory()
                else
                    torchBlock = true
                end
            else
                torchBlock = false
            end
        end
        --go forward. If the path is blocked and it is gravel, dig it. If it's not gravel, something is wrong
        while not turtle.forward() do
            local s,d = turtle.inspect()
            if s then
                if d.name == "minecraft:gravel" then
                    turtle.dig()
                else
                    os.sleep(30)
                end
            end
        end
        currentPosition=currentPosition-1
        refuel()
    end
    left() --turn around
    left()
    --place torch to mark the strip as finished
    if torchBlock then
        turtle.select(2)
        turtle.place()
    else
        --need a block to place the torch on
        --find cobblestone in the inventory
        local i=1
        local cobb = false
        while i<16 and cobb == false do
            turtle.select(i)
            if turtle.getItemCount()>0 then
                d=turtle.getItemDetail()
                if string.sub(d.name,-11)=="cobblestone" then cobb=true end
            end
            i=i+1
        end
        --if no cobblestone found in inventory
        if not cobb then
            --get a block from above
            turtle.select(16) --16 should be free
            local i=0
            while turtle.getItemCount()<1 do --dig up until there's a block in the 16th slot
                turtle.digUp()
                if turtle.up() then
                    i=i+1
                end
            end
            local j=0
            while j<i do --go back down
                if turtle.down() then j=j+1 end
            end
        end
        forward()
        turtle.placeDown()
        while not turtle.back() do end
        turtle.select(2)
        turtle.place()
    end
end

--Shift over to the next strip in the given direction. 
function reposition()
    print("reposition")
    turnStripDirection(true)
        stripForward(4)
    turnStripDirection(false)
end

--action
while lateralPosition<=(stripAmount-1)*4 do
    refuel()
    turtle.select(2)
    if not turtle.compare() then 
        strip(stripLength)
    end
    if lateralPosition==(stripAmount-1)*4 then 
        break
    else
        reposition()
    end
end
--return home
turnStripDirection(false)
forward(lateralPosition)
turnStripDirection(false)
--empty inventory into chest
local full = false
local slot=3 --keep torch and fuel
while slot<17 do
    turtle.select(slot)
    if turtle.getItemCount(slot)>0 then
        if turtle.drop() then
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
turtle.select(3)
turnStripDirection(true)
turnStripDirection(true)
print("finished")