--This program is meant for the computercraft turtle
--It creates 1x2 mining strips with a 3 block spacing
--To start the turtle will need fuel in slot 1, a torch in slot 2, a chest that is regularly emptied and chest that contains fuel
--The turtle will start digging the first strip forward from its starting position
--the chest for the mined items has to be placed directly behind the starting position
--the chest with the fuel has to be placed to the left of the item chest, when looking down the strips
--the entrance of an already finished strip can be marked by a torch. The turtle will skip it

--turtles inventory slots: 1 to 16

--The first part of this program defines functions. These are then used in the last paragraph

--get user input
print("Enter strip direction: (left/right)")
local stripDirection = read("*") --New strips will be created to the "stripDirection" of the Startingpoint of the turtle
print("Enter strip length:")
local stripLength = read()
print("Enter number of strips to dig:")
local numberOfStrips = read()
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
--also picks up fuel from the chest next to the item chest
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
    --pick up fuel
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    turtle.select(1)
    while turtle.getItemCount()<64 do
        if not turtle.suck(64-turtle.getItemCount()) then
            print("no fuel in chest")
        end
    end
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
    turtle.select(3)
    --return to current position in strip
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
    currentPosition = 0
    while currentPosition<blocks do
        turtle.dig()   
        if turtle.getItemCount(16) ~=0 then
            EmptyInventory()
        end     
        if turtle.forward() then
            currentPosition = currentPosition+1
            if turtle.getFuelLevel()<80 then
                Refuel()
            end
        end        
        while turtle.detectUp() do --break upper block of the strip and wait for potential gravity-affected blocks that fall down (like gravel and sand)
        turtle.digUp()
        os.sleep(0.5)
        end
        if turtle.getItemCount(16) ~=0 then
            EmptyInventory()
        end
--        while turtle.suck() do
--            local slot = 1
--           while slot<17 do --16 slots
--                turtle.select(slot)
--                slot=slot+1                
--            end
--            if turtle.getItemCount(16) then --drops inventory into chest, when theres an item in the 16th slot. This is inefficient but reliable
--                EmptyInventory()
--                print("inventory full")
--            end
--        end
    end
end

--obsolete function
--Similar to StripForward but with timers to wait for blocks to fall down
function StripBack(blocks)
    local steps = 0
    while steps<blocks do
        while turtle.detect() do
            turtle.dig()
            os.sleep(0.5)
        end
        if turtle.forward() then
            steps = steps+1
        end
    end
end

--dig a strip and return to starting position of the strip. Uses StripForward, but returns to the starting position afterwards
function Strip(length)
    StripForward(length)
    turtle.turnLeft()
    turtle.turnLeft()
    Forward(length)
    turtle.turnLeft()
    turtle.turnLeft()
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
turtle.turnLeft()
Forward(numberOfStrips*4)
turtle.turnRight()