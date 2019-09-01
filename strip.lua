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

--get user input
print("Enter strip direction: (left/right)")
local stripDirection = read() --New strips will be created to the "stripDirection" of the Startingpoint of the turtle
print("Enter strip length:")
local stripLength = tonumber(read())
print("Enter number of strips to dig:")
local numberOfStrips = tonumber(read())
--keep track of the current position to return back to it after emptying the inventory into the chest
local currentPosition = 0 --holds the current position within a strip. Is reset to zero at the beginning of a new strip
local currentStrip = 0 --holds the count of the current strip

function Forward(steps)
    print("Forward")
    local blocks = 0
    while blocks < steps do        
        if turtle.forward() then
            blocks = blocks+1  
            if turtle.getFuelLevel()<80 then
                Refuel()
            end
        else
            print("path is blocked")  
        end
    end
end
--needs work
function Refuel()
    turtle.select(1)
    while turtle.getFuelLevel()<stripLength*2.5 do
        turtle.refuel(1)
    end
end

--return to chest and empty inventory into chest. If chest full, wait. When finished, return to previous position
--also picks up fuel and torches from the chests next to the item chest
function EmptyInventory()
    Refuel()
    --get back to the chest
    turtle.turnLeft()
    turtle.turnLeft()
    Forward(currentPosition) --back down the strip
    if stripDirection == "right" then
        turtle.turnRight()
    elseif stripDirection == "left" then
        turtle.turnLeft()
    else
        print("Invalid direction. Use left or right")
    end
    Forward(currentStrip*4) --back to the chest
    if stripDirection == "right" then
        turtle.turnLeft()
    elseif stripDirection == "left" then
        turtle.turnRight()
    else
        print("Invalid direction. Use left or right")
    end
    --Empty inventory. If chest is full, wait
    local slot=3 --keep torch and fuel
    while slot<17 do
        turtle.select(slot)
        if turtle.drop() then
            slot=slot+1
        else             
            print("chest is full") --floods the console. Not nice
            os.sleep(10) --wait for 10 seconds
        end
    end
    turtle.select(3)
    --pick up fuel and torches
    --fuel
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    turtle.select(1)
    while turtle.getItemCount()<64 do
        if not turtle.suck(64-turtle.getItemCount()) then
            print("no fuel in chest")
        end
    end
    --torches
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    turtle.select(2)
    while turtle.getItemCount()<64 do
        if not turtle.suck(64-turtle.getItemCount()) then
            print("no torches in chest")
        end
    end
    --back to starting position
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.turnRight()
    turtle.select(3)
    --return to current strip
    if stripDirection == "right" then
        turtle.turnLeft()
    elseif stripDirection == "left" then
        turtle.turnRight()
    else
        print("Invalid direction. Use left or right")
    end
    Forward(currentStrip*4) --back to the strip
    if stripDirection == "right" then
        turtle.turnLeft()
    elseif stripDirection == "left" then
        turtle.turnRight()
    else
        print("Invalid direction. Use left or right")
    end
    Forward(currentPosition) --back to the position in the strip
end

--Digs a 1x2 strip of a given length in the forward direction. Picks up mined items
function StripForward(blocks)
    local torch = 0
    currentPosition = 0
    while currentPosition<blocks do
        turtle.dig()   
        if turtle.getItemCount(16) ~=0 then
            EmptyInventory()
        end
        if turtle.forward() then
            torch=torch+1
            currentPosition = currentPosition+1
            if turtle.getFuelLevel()<80 then
                Refuel()
            end
        end        
        while turtle.detectUp() do --break upper block of the strip and wait for potential gravity-affected blocks that fall down (like gravel and sand)
        turtle.digUp()
        os.sleep(0.75)
        end
        --place a torch every 10 blocks
        if blocks > 5 and torch % 10 == 0 then
            turtle.select(2)
            turtle.placeUp()
            turtle.select(3)
        end
        --when item in last slot, inventory is "full"
        if turtle.getItemCount(16) ~=0 then
            EmptyInventory()
        end
    end
end

--dig a strip and return to starting position of the strip. Uses StripForward, but returns to the starting position afterwards
function Strip(length)
    StripForward(length)
    turtle.turnLeft()
    turtle.turnLeft()
    Forward(length) --walk back out of the strip
    turtle.turnLeft() --turn around
    turtle.turnLeft()
    --place torch to mark the strip as finished
    turtle.select(2) 
    turtle.place()
    --make sure the torch has been placed. It can't be placed if there's no block there and it will break again on gravel
    while not turtle.detect() do
        turtle.forward() --to where the torch should be
        turtle.digDown() --get rid of the gravel
        turtle.select(16)
        if turtle.getItemCount()>0 then EmptyInventory() end --in case the gravel went to 16
        turtle.select(3)
        --need a block to place the torch on
        --find cobblestone in the inventory
        local i=0
        local cobb = false
        while i<16 and cobb == false do
            turtle.select(i)
            d=turtle.getItemDetail()
            if string.sub(d.name,-11)=="cobblestone" then cobb=true end
        end
        if not cobb then --if no cobblestone found in inventory
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
        while turtle.detectUp() do turtle.digUp() end --get rid of possible gravel
        turtle.placeDown()
        while not turtle.back() do end --go back one
        turtle.select(2)
        turtle.place()
    end
end

--Shift over to the next strip in the given direction. 
function Reposition(direction)
    if direction == "right" then
        turtle.turnRight()
    elseif direction == "left" then
        turtle.turnLeft()
    else
        print("Invalid direction. Use left or right")
    end
    StripForward(4) --three steps to the right or left
    if direction == "right" then
        turtle.turnLeft()
    elseif direction == "left" then
        turtle.turnRight()
    else
        print("Invalid direction. Use left or right")
    end
end

--action
currentStrip = 0
currentPosition = 0
while currentStrip<numberOfStrips do
    print("refueling...")
    Refuel()
    turtle.select(2)
    if not turtle.compare() then 
    Strip(stripLength)
    end    
    Reposition(stripDirection)
    currentStrip = currentStrip+1
end
--return home
if direction == "right" then
    turtle.turnLeft()
elseif direction == "left" then
    turtle.turnRight()
end
Forward(numberOfStrips*4)
turtle.turnRight()