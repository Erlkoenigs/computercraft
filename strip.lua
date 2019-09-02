--This program is meant for the computercraft turtle
--It creates 1x2 mining strips with a 3 block spacing
--To start the turtle will need fuel in slot 1, torches in slot 2, a chest that is regularly emptied,
--a chest that contains fuel and a chest that contains torches
--The turtle will start digging the first strip forward from its starting position
--the chest for the mined items has to be placed directly behind the starting position
--the chest with the fuel has to be placed to the left of the item chest, when looking down the strips
--the chest with the torches has to be placed to the left of the fuel chest, when looking down the strips
--the entrance of an already finished strip can be marked by a torch. The turtle will skip it

--turtles inventory slots: 1 to 16

--The first part of this program defines functions. These are then used in the last paragraph

local torchDistance = 12
local orientation = 0 --left is negative, right is positive. 0 is strip direction, 1 is right, -1 is left, 2 and -2 are back
local target = "ore" --will search for this string in the block information
local path = {} --the path the turtle has taken while following a vein. 3 is up, -3 is down
local currentPosition = 0 --holds the current position within a strip. Is reset to zero at the beginning of a new strip
local currentStrip = 0
local currentHeight = 0

--get command line arguments
tArgs={...}
local stripDirection = "" --New strips will be created to the "stripDirection" of the Startingpoint of the turtle
local stripAmount = 0
local stripLength = 0

function confirmInput()
    local answer = ""
    while not (answer == "y" or answer == "n") do
        print(stripAmount.." strips with a length of "..stripLength.." will be created to the "..stripDirection.." of the current position.")
        print("Is that correct? (y/n)")
        answer = io.read()
        if answer == "y" then
            return true
        elseif answer == "n" then
            return false
        else
            print("Incorrect input. Use 'y' or 'n'")
            print()
            return false
        end
    end
end

function usageHint()
    print("Invalid command line arguments")
    print("use: strip <direction> <amount> <length>")
    print("with direction as 'l' or 'r' and amount and length as numbers greater than zero")
end

function getUserInput()
    stripDirection = ""
    stripLength = 0
    stripAmount = 0
    repeat
        --direction
        while not (stripDirection == "r" or stripDirection == "l") do
            print("Enter strip direction (l/r):")
            stripDirection = read()
            if not (stripDirection == "r" or stripDirection == "l") then 
                print("Invalid direction. Please use 'l' or 'r'")
            end
        end    
        --amount
        while stripAmount == 0 do
            print("Enter strip amount:")
            stripAmount = tonumber(read())
            if stripAmount == nil then stripAmount = 0 end --make sure it's a number
            if not (type(stripAmount) == "number" and stripAmount > 0) then 
                print("Invalid amount. Please input any number greater than zero.")
            end
        end
        --length
        while stripLength == 0 do
            print("Enter strip length:")
            stripLength = tonumber(read())
            if stripLength == nil then stripLength = 0 end --make sure it's a number
            if not (type(stripLength) == "number" and stripLength > 0) then 
                print("Invalid length. Please input any number greater than zero.")
            end
        end
    until (confirmInput() == true)
end

--if command line arguments are ok, use them
if #tArgs>0 then
    print("got command line arguments")
    if type(tonumber(tArgs[2])) == "number" and type(tonumber(tArgs[3])) == "number" then
        print("is number!")
        if (tArgs[1] == "l" or tArgs[1] == "r") and tonumber(tArgs[2])>0 and tonumber(tArgs[3])>0 then
            print("valid input")
            stripDirection = tArgs[1]
            stripAmount = tonumber(tArgs[2])
            stripLength = tonumber(tArgs[3])
        else
            print("invalid input")
            usageHint()
            getUserInput()
        end
    else
        print("arguments 2 and 3 not valid")
        usageHint()
        getUserInput()
    end
else
    getUserInput()
end

function forward(steps)
    print("function:forward")
    refuel(steps)
    local blocked = false
    local blocks = 0
    while blocks < steps do        
        if turtle.forward() then
            blocks=blocks+1
        else
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
    if o<=0 then
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
        if stripDirection == "r" then
            right()
        elseif stripDirection == "l" then
            left()
        else
            print("Invalid direction. Use l or r")
        end
    elseif not notInverted then
        if stripDirection == "r" then
            left()
        elseif stripDirection == "l" then
            right()
        else
            print("Invalid direction. Use l or r")
        end
    end
end

--dig block in front, up or down, then move in that direction. Update path
function dig(direction) --ore true when called to mine an ore
    if direction == nil then --if no direction given
        while not turtle.forward() do
            turtle.dig()          
        end
        table.insert(path,orientation)
        print("added "..path[#path].." to path")
        refuel()
    elseif direction == "up" then
        while not turtle.up() do
            turtle.digUp()          
        end
        table.insert(path,3)
        print("added "..path[#path].." to path")
        refuel()
    elseif direction == "down" then
        while not turtle.down() do
            turtle.digDown()
        end
        table.insert(path,-3)
        print("added "..path[#path].." to path")
        refuel()
    end
end

--go a variable amount of steps back on the path you went in
function stepBackOnPath(s)
    --debugging
    print("stepping back. path:")
    for i,v in ipairs(path) do
        print(v)
    end
    --action
    if s == nil then s = 1 end
    for i=1,s do
        local dir=table.remove(path) --get and remove last entry
        print("reversing "..dir)
        if dir == 3 then
            while not turtle.down() do
                turtle.digDown()
            end
        elseif dir == -3 then
            while not turtle.up() do
                turtle.digUp()
            end
        else
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
            dig("up")
        elseif newPath[i] == -3 then
            dig("down")
        else
            turn(newPath[i])
            dig()
        end
    end
end

function emptyInventory()
    
end

--check if last item slot contains items. if true,
--return to chest and empty inventory into chest. If chest full, wait. When finished, return to previous position
--also picks up fuel and torches from the chests next to the item chest
function checkInventory()
    turtle.select(16)
    if turtle.getItemCount() > 0 then
        refuel(stripLength+stripAmount*4+5)
        --get back to the chest
        turn(2)
        if currentHeight == 1 then --if on upper level, go down
            while not turtle.down() do end
        end
        forward(currentPosition) --back down the strip
        turnStripDirection(true)
        forward(currentStrip*4) --back to the chest
        turnStripDirection(false)
        --Empty inventory. If chest is full, try again till it isn't
        local full = false
        local slot=3 --keep torch and fuel
        while slot<17 do
            turtle.select(slot)
            if turtle.drop() then
                slot=slot+1
            else
                if not full then
                    print("chest is full") --only print this once
                    full = true
                end
                os.sleep(30) --wait for 30 seconds
            end
        end
        turtle.select(3)
        --pick up fuel and torches
        --fuel
        right()
        turtle.forward()
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
        turtle.forward()
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
        --return to current strip from torch chest
        turnStripDirection(false)
        forward(currentStrip*4-2) --back to the strip
        turnStripDirection(false)
        forward(currentPosition) --back to the position in the strip
    end
    turtle.select(3)
end

--check block in front, up or down. true if block is wanted
function check(direction)
    print("function:check")
    local s,data
    if direction == nil then
        s,data=turtle.inspect()
        if s then
            if not string.find(data.name,target)==nil then
                print("detected")
                return true
            end
        end        
    elseif direction=="up" then
        s,data=turtle.inspectUp()
        if s then
            if not string.find(data.name,target)==nil then
                print("detected up")
                return true
            end
        end
    elseif direction=="down" then
        s,data=turtle.inspectDown()
        if s then
            if not string.find(data.name,target)==nil then
                print("detected down")
                return true
            end
        end        
    end
    if s then
        print("no match: "..data.name)
    else
        print("nothing detected: ")
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
            dig("up")
        elseif s == "down" then
            dig("down")
        elseif s == true then
            dig()
        else
            stepBackOnPath(1)
        end        
    end
    checkInventory()
end

--Digs a 1x2 strip of a given length in the forward direction. Picks up mined items
function stripForward(blocks)
    currentPosition = 0
    while currentPosition<blocks do
        if turtle.dig() then checkInventory() end
        if turtle.forward() then
            currentPosition = currentPosition+1
            refuel()
            if turtle.detectUp() then
                while turtle.detectUp() do --break upper block of the strip and wait for potential gravity-affected blocks that fall down (like gravel and sand)
                    turtle.digUp()
                    os.sleep(0.75)
                end
                checkInventory()
            end
        end
    end
end

--dig a strip and return to starting position of the strip. Uses StripForward, but returns to the starting position afterwards
function strip(length)
    stripForward(length)    
    left()
    left()
    --Forward(length) --walk back out of the strip
    while currentPosition>0 do
        if check("down") then --start of a vein
            dig("down") --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        turn(1) --right
        if check() then --start of a vein
            dig() --go one block into the vein
            mineVein() --follow it
            turn(2)
        end            
        turn(-1) --left
        if check() then --start of a vein
            dig() --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        while not turtle.up() do end
        currentHeight=currentHeight+1
        turn(-1) --left
        if check() then --start of a vein
            dig() --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        if check("up") then --start of a vein
            dig("up") --go one block into the vein
            mineVein() --follow it
            turn(2)
        end
        turn(1) --right
        if check() then --start of a vein
            dig() --go one block into the vein
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
        while not turtle.forward() do end
        currentPosition=currentPosition-1
        refuel()
    end
    left() --turn around
    left()
    --place torch to mark the strip as finished
    turtle.select(2) 
    turtle.place()
    right() --shake the torch off if it was placed on the turtle
    turtle.forward()
    turtle.back()
    left()
    --make sure the torch has been placed. It can't be placed if there's no block there and it will break again on gravel
    while not turtle.detect() do
        turtle.forward() --to where the torch should be
        turtle.digDown() --get rid of the gravel
        checkInventory()
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
        turtle.placeDown()
        while not turtle.back() do end --go back one
        turtle.select(2)
        turtle.place()
        right()
        turtle.forward()
        turtle.back()
        left()
    end
end

--Shift over to the next strip in the given direction. 
function reposition()
    turnStripDirection(true)
    stripForward(4) --three steps to the right or left
    turnStripDirection(false)
end

--action
while currentStrip<stripAmount do
    refuel()
    turtle.select(2)
    if not turtle.compare() then 
        strip(stripLength)
    end    
    reposition()
    currentStrip = currentStrip+1
end
--return home
turnStripDirection(false)
forward(stripAmount*4)
right()