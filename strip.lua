--for the computercraft turtle
--creates 1x2 mining strips with a spacing of 3 blocks in between
--on it's way back it will search for and mine ore veins it finds
--it needs fuel in slot 1, torches in slot 2, a stationary chest that is regularly emptied,
--a chest that contains fuel and a chest that contains torches
--the chest for the mined items has to be placed directly behind the starting position,
--the chest with the fuel has to be placed to the left of the item chest,
--the chest with the torches has to be placed to the left of the fuel chest.
--the entrance of a finished strip can be marked by a torch. The turtle will do the same and skip, but still count, marked strips

--turtles range is typically limited by the chunk loaded area.
--it takes three parameters: width, height and depth, which define the area of its mining
--it will dig _depth_ blocks forward, 0.5 _width_ blocks to each side
--and max _height_ blocks up

--example: ("0" is mined, "x" is not mined)
-- 0xxx0xxx0xxx0xxx0
-- 0xxx0xxx0xxx0xxx0 level 3 (odd level)
-- xx0xxx0xxx0xxx0xx
-- xx0xxx0xxx0xxx0xx level 2 (even level)
-- 0xxx0xxx0xxx0xxx0
-- 0xxx0xxx0xxx0xxx0 level 1 (odd level)
--levels = amount of levels => actual height of mined area = levels * 2
--first row of strips is the first level (= level 1 = an odd level)
--the row above the first row is the second level (= level 2 = an even level)

--settings
debug = true
local torchDistance = 12 -- place torches every x blocks
local target = {} --scans for blocks, whose block info names end with one of these strings (!= ore dict name!!!)
target[1] = "ore"
target[2] = "resources" --forestry ores
target[3] = "obsidian"
target[4] = "yellorite" --big reactors
local dummy = {} --materials that can be used to place as a base for the finishing torch
dummy[1] = "dirt"
dummy[2] = "stone" --includes cobblestone, andesite, marble, diorite etc.

--states
local orientation = 0 --left turn is negative, right turn is positive: 0 is strip direction, 1 is to the right of that, -1 is left, 2 and -2 are back
local path = {} --the path the turtle has taken while following an ore vein. 3 is up, -3 is down
local pos = {} --current position in coordinate system (not tracked while following an ore vein)
pos["x"] = 0
pos["y"] = 0
pos["z"] = 0
local pos_snap = {} --snapshot of current position to return to later
pos_snap["x"] = 0
pos_snap["y"] = 0
pos_snap["z"] = 0

--parameters
tArgs={...} --1. width, 2. height, 3. depth
local width = 0
local height = 0
local depth = 0
local even = true --is the amount of strips on the first level (= every odd level) odd or even?
--if not even, there's a strip in the center
local maxX = 0 --absolute of maximum x value on both sides. calculated from width

function clog(logstr)
    if debug then print(logstr) end
end

--get user input. either through command line arguments or by asking
function getParameters()
    --check if value is number and greater than zero
    local function checkValue(value)
        if value == nil then value = 0 end
        if not (type(value) == "number" and value > 0) then 
            term.clear()
            term.setCursorPos(1,1)
            print("Invalid amount. Please input any number greater than zero.")
        end
    end

    if #tArgs == 3 then
        local err = ""
        local errEnd = " argument is not a number"
        if type(tonumber(tArgs[1])) ~= "number" then
            err = "1st"
        end
        if type(tonumber(tArgs[2])) ~= "number" then
            if err ~= "" then
                err = err..", 2nd"
            else
                err = "2nd"
            end
        end
        if type(tonumber(tArgs[3])) ~= "number" then
            if err ~= "" then
                err = err..", 3rd"
            else
                err = "3rd"
            end
        end
        if err ~= "" then
            error(err..errEnd)
        end
        width = tonumber(tArgs[1])
        height = tonumber(tArgs[2])
        depth = tonumber(tArgs[3])

        print("width: "..width)
        print("height: "..height)
        print("depth: "..depth)
        print("Make sure there's fuel in slot one and torches in slot two")
        print("press any button to continue")
        os.pullEvent("key")
    else
        --ask for it
        --width
        while width == 0 do
            print("Enter width of mining area:")
            width = tonumber(read())
            checkValue(width)
        end 
        --height
        while height == 0 do
            print("Enter heigth of mining area:")
            height = tonumber(read())
            checkValue(height)
        end
        --depth
        while depth == 0 do
            print("Enter depth of mining area:")
            depth = tonumber(read())
            checkValue(depth)
        end
    end

    --calculate "even"
    --make width fit (could prob use math.round() for this)
    while (width + 3) % 4 ~= 0 do
        width = width - 1
    end
    --max amount of strips on level
    local stripAmount = (width + 3) / 4
    --is it even or odd
    if stripAmount % 2 == 0 then
        even = true
    else
        even = false
    end

    maxX = (width - 1) / 2
end --getParameters

--refuel from slot 1
function refuel(amount)
    if amount == nil then amount = depth*5 end --random value
    while turtle.getFuelLevel() < amount do
        turtle.select(1)
        turtle.refuel(1)
    end
end --refuel

--ud = "up" or "down"
function updateCoord(ud)
    if ud == nil then
        if orientation == 0 then
            pos.y = pos.y + 1
        elseif orientation == 2 or orientation == -2 then
            pos.y = pos.y - 1
        elseif orientation == 1 then
            pos.x = pos.x + 1
        elseif orientation == - 1 then
            pos.x = pos.x - 1
        end
    elseif ud == "up" then
        pos.z = pos.z + 1
    elseif ud == "down" then
        pos.z = pos.z - 1
    else
        error("updateCoord: bad argument")
    end
    --clog(pos.x)
    --clog(pos.y)
    --clog(pos.z)
    clog("("..pos.x.."/"..pos.y.."/"..pos.z..")")
end --updateCoord

--make sure turtle goes forward. If path is blocked, print it once
function forward(steps)
    if steps == nil then steps = 1 end
    --clog("forward: "..steps)
    steps = math.abs(steps)
    refuel(steps)
    local blocked = false
    local b = 0
    while b < steps do     
        if turtle.forward() then
            --clog("1 step")
            b=b+1
            updateCoord()
        else
            os.sleep(30)
            if not blocked then
                blocked = true
                print("path is blocked (forward)") --only prints this once
                return false
            end
        end
    end
    return true
end --forward

function up()
    refuel(1)
    if turtle.up() then
        updateCoord("up")
        return true
    else
        return false
    end
end

function down()
    refuel(1)
    if turtle.down() then
        updateCoord("down")
        return true
    else
        return false
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
    --clog("orientation :" .. orientation)
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

--if notInverted == true or nil, turns toward (0/0/0) on x axis, 
--if notInverted == false, turns toward pos_snap on x axis (= away from (0/0/0))
-- => results in a a turn toward 1 or -1, depending on where pos_snap.x is from pos.x
function turnTowardHome(notInverted)
    if notInverted == nil then notInverted = true end
    if notInverted then
        if pos.x > 0 then
            turn(-1)
            return true
        elseif pos.x < 0 then
            turn(1)
            return true
        else
            return false
        end
    elseif not notInverted then
        if pos.x > pos_snap then
            turn(-1)
            return true
        elseif pos.x < pos_snap.x then
            turn(1)
            return true
        else
            return false
        end
    end
end

--return to chest
function returnHome()
    refuel(pos.x + pos.z + pos.y + 4)
    if pos.z % 2 ~= 0 then --if on upper level within a strip, go down
        while not down() do end
    end
    clog("return home: y: " .. pos.y)
    if pos.y > 0 then
        turn(2)
        forward(pos.y) --back down the strip
    end
    clog("return home: x: " .. pos.x)
    if pos.x ~= 0 then
        turnTowardHome(true)
        forward(pos.x) --back to the chest
    end
    clog("return home: z: " .. pos.z)
    while pos.z > 0 do
        down()
    end
end

--check if last item slot contains items. if true,
--return to chest and empty inventory into chest. If chest full, wait. When finished, return to previous position
--also picks up fuel and torches from the chests next to the item chest
--only call when on "main road" (=within strip or lateral path)
function checkInventory()
    if turtle.getItemCount(16) > 0 then
        local orientation_snap = orientation --snapshot of the current orientation
        pos_snap.x = pos.x
        pos_snap.y = pos.y
        pos_snap.z = pos.z
        returnHome()
        turn(2) --turn toward chest
        --Empty inventory. If chest is full, try again till it isn't
        local full = false --to only print errors once
        local slot = 3 --keep torch and fuel
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
        --to pos_snap.x
        clog("checkInventory:back to x")
        turnTowardHome(false)
        while pos.x ~= pos_snap.x do
            forward()
        end
        turn(0)
        --to pos_snap.z
        clog("checkInventory:back to z")
        while pos.z ~= pos_snap.z do
            up()
        end
        --back down the strip
        clog("checkInventory:back down y")
        while pos.y ~= pos.y do
            forward()
        end
        turn(orientation_snap)
    end
    turtle.select(3)
end --checkInventory

--Digs a 1x2 strip of a given length in the forward direction. Picks up mined items. checks inventory
--used to mine the path to the strips (x-direction) and the strips themselves (y-direction)
function digForward(blocks)
    local i=0
    while i<blocks do
        if turtle.dig() then checkInventory() end
        if forward() then
            if turtle.detectUp() then
                while turtle.detectUp() do --break upper block of the strip and wait for potential gravity-affected blocks that fall down (like gravel and sand)
                    turtle.digUp()
                    os.sleep(0.75) --this slows down! alternative?
                end
                checkInventory()
            end
            i=i+1
        end
    end
end

--dig a strip and return to starting position of the strip.
--Uses StripForward, then returns to the starting position while scanning for ores
function strip(length)
    clog("strip")
    local torchBlock = false --is a block present to place the finishing torch on?
    local torchBlockAlt = false --alternative torch block (sides)

    --functions
    --searches inventory for dummy-material. if it finds some, places it down
    local function placeTorchBlock()
        local o_snap = orientation --snapshot of orientation
        --search for dummy
        for i=3, 16 do
            if turtle.getItemCount(i) > 0 then
                data = turtle.getItemDetail(i)
                for i,v in ipairs(dummy) do
                    if string.sub(data.name,-#v) == v then --if end of name == dummy-string
                        turtle.select(i)
                        turtle.placeDown() --place dummy
                        turtle.select(2)
                        return true
                    end
                end
            end
        end
        --check if there's blocks on the sides. works too, but isn't as nice
        turn(1)
        if turtle.detect() then torchBlockAlt = true end
        turn(-1)
        if turtle.detect() then torchBlockAlt = true end
        turn(o_snap)
        return false
    end --placeTorchBlock

    --just take .name from turtle.inspect. returns "" when no block there
    local function inspect(dir)
        local s,d
        local n
        if dir == nil then
            s,d = turtle.inspect()
        elseif dir == "up" then
            s,d = turtle.inspectUp()
        elseif dir == "down" then
            s,d =turtle.inspectDown()
        end
        if s then
            n = d.name
        else
            n = ""
        end
    end --inspect

    --check block in front, up or down. true if block is wanted
    local function check(direction)
        clog("check")
        local name = inspect(direction)
        if name ~= "" then
            for index,targetName in ipairs(target) do
                clog(name.." - "..targetName)
                if string.sub(name,-#targetName) == targetName then --if end of name == ore-string
                    clog("is wanted")
                    return true
                end
            end
        end
        return false
    end --check

    --dig block in front, up or down, then move in that direction. Update path
    local function digVein(direction) --ore true when called to mine an ore
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
    end --digVein

    --follow and mine a vein
    --only called after the vein has already been entered by "digVein()" initially
    local function mineVein()
        while #path > 0 do
            --scan up, down and all sides. return "up" or "down" when ore found in those directions return true or false when ore found on a side
            --will leave the turtle in the direction of the found ore
            local function scan()
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
            end --scan

            local s = scan()
            if s == "up" then
                digVein("up")
            elseif s == "down" then
                digVein("down")
            elseif s == true then
                digVein()
            else
                --take one step back on path
                local dir = table.remove(path) --get and remove last entry
                --clog("reversing "..dir)
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
        checkInventory()
    end --mineVein

    --action
    digForward(length)
    clog("strip: reached end of strip")
    --Forward(length) --walk back out of the strip
    while pos.y > 0 do
        if check("down") then --start of a vein
            digVein("down") --go one block into the vein
            mineVein() --follow it
        end
        turn(1) --right
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
        end            
        turn(-1) --left
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
        end
        while not up() do end
        turn(-1) --left
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
        end
        if check("up") then --start of a vein
            digVein("up") --go one block into the vein
            mineVein() --follow it
        end
        turn(1) --right
        if check() then --start of a vein
            digVein() --go one block into the vein
            mineVein() --follow it
        end
        turn(2)         
        while not down() do end
        if pos.y % torchDistance == 0 then
            turtle.select(2)
            turtle.placeUp()
        end
        --check if there's a block underneath the first block of the strip (= base to place the torch on = torch block)
        if pos.y == 1 then
            local s,d=turtle.inspectDown()
            if s then
                if d == "minecraft:gravel" or d == "minecraft:sand" then --can't place torch on these
                    turtle.digDown() --get rid of the gravel or sand
                    checkInventory()
                    torchBlock = placeTorchBlock()
                else
                    torchBlock = true
                end
            else
                torchBlock = placeTorchBlock()
            end
        end
        --go forward. If the path is blocked and it is gravel, dig it. If it's not gravel, something is wrong
        while not forward() do
            if inspect() == "minecraft:gravel" then
                turtle.dig()
            else
                os.sleep(30) --wait for help, then try again
            end
        end
        refuel()
    end
    turn(0)
    --place torch to mark the strip as finished
    if torchBlock then
        turtle.select(2)
        turtle.place()
    elseif torchBlockAlt then
        --not tracked by coordinates
        while not turtle.up() do end
        while not turtle.forward() do end
        turtle.select(2)
        while not turtle.placeDown() do end
        while not turtle.back() do end
        while not turtle.down() do end
    end
    clog("end of strip")
end --strip

--positions the turtle in front of the next strip
--this function defines the sequence in which strips are made
function reposition()
    clog("reposition")
    clog("pos.x: "..pos.x)
    clog("maxX: "..maxX)
    
    --elevate to the next level of strips
    local function elevate()
        --two left
        left()
        digForward(2)
        right()
        --two up
        local i = 0
        while i < 2 do
            if not up() then
                turtle.digUp()
                checkInventory()
            else
                i = i + 1
            end
        end
        --in case of gravel
        while turtle.detectUp() do
            turtle.digUp()
            checkInventory()
        end
    end

    --go to the next strip on the left
    local function shiftLeft()
        left()
        digForward(4)
        right()
    end

    --go to the next strip on the right
    local function shiftRight()
        right()
        digForward(4)
        left()
    end

    --first create strips from the starting position to the left,
    --then create strips from the starting position to the right
    --this is a little more complicated than simply starting on the far left,
    --but it yields resources earlier
    turn(0) --just in case
    if pos.z == 0 then --first level is special. starts in center, then goes left, then right
        if pos.x == 0 then --starting postition
            clog("center")
            if even then --start two blocks to the left of center
                left()
                digForward(2)
                right()
            else --start here, except if you've been here before
                turtle.select(2)
                --if beginning of strip is marked, skip it
                if turtle.compare() then
                    shiftLeft()
                end
            end
        elseif pos.x == -maxX then --last strip on he left on first level => go to first strip on the right side of starting position
            clog("z0 -maxX")
            right()
            if even then
                local st = maxX + 2
                clog("even, "..st)
                digForward(st)
            else
                local st = maxX + 4
                clog("even, "..st)
                digForward(st)
            end
            left()
        elseif pos.x == maxX then
            clog("z0 maxX")
            elevate()
        elseif pos.x < 0 then
            clog("z0 pos.x < 0")
            shiftLeft()
        elseif pos.x > 0 then
            clog("z0 pos.x > 0")
            shiftRight()
        end
    --pos.z ~= 0
    elseif pos.x == maxX or pos.x == -maxX + 2 then --last strip on the right or left
        clog("maxX or -maxX+2")
        elevate()
    elseif pos.x > maxX or pos.x < -maxX then --just in case
        error("reposition: went too far")
    elseif pos.z % 4 == 0 then
        clog("pos.z%4==0")
        shiftRight()
    elseif pos.z % 4 ~= 0 then
        clog("pos.z%4~=0")
        shiftLeft()
    else
        error("reposition: something's wrong")
    end
end --reposition

--action
getParameters()
repeat
    reposition()
    turtle.select(2)
    --if beginning of strip is marked, skip it
    if not turtle.compare() then
        strip(depth)
    end
until (pos.z >= height - 2 and (pos.x == maxX or pos.x == -maxX + 2))
--return home
returnHome()
turn(2)
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
turn(0)
print("finished")