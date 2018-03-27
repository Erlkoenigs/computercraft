local stripDirection = "right" --New strips will be created to the "stripDirection" of the Startingpoint of the turtle
local stripLength = 200
local numberOfStrips = 5

function Refuel()
    turtle.select(1)
    if not turtle.refuel(1) then
        print("Need fuel in slot 1")
    end
    while turtle.getFuelLevel()<300 do
        turtle.refuel(1)
    end
end

--First run through the strip. Needs a second run to clear out possible gravel or sand that has fallen down behind the turtle(StripBack)
function StripForward(blocks)
    local steps = 0
    while steps<blocks do
        turtle.dig()        
        if turtle.forward() then
            steps = steps+1
        end
        turtle.digUp()
    end
end

--Similar to StripForward but with timers to wait for blocks to fall down
function StripBack(blocks)
    local steps = 0
    while steps<blocks do
        turtle.dig()
        os.sleep(0.5)
        if turtle.forward() then
            steps = steps+1
        end
    end
end

function Strip(length)
    StripForward(length)
    turtle.turnLeft()
    turtle.turnLeft()
    StripBack(length)
    turtle.turnLeft()
    turtle.turnLeft()
end

function Reposition(direction)
    if direction == "right" then
        turtle.turnRight()
    elseif direction == "left" then
        turtle.turnLeft()
    else
        print("Invalid direction. Use left or right")
    end
    while steps<3 do
        turtle.dig()
        if turtle.forward() then
            steps = steps+1
        end
    end
    if direction == "right" then
        turtle.turnLeft()
    elseif direction == "left" then
        turtle.turnRight()
    else
        print("Invalid direction. Use left or right")
    end
end

while strips<numberOfStrips do
    Strip(stripLength)
    Reposition(stripDirection)
    strips = strips+1
end