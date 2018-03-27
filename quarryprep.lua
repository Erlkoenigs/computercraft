function Refuel()
    turtle.select(1)
    local askedForFuel = false
    while turtle.getFuelLevel < 300 do                
        if not turtle.refuel(1) and askedForFuel == true then
            print("Need fuel in slot 1")
            askedForFuel = true
        end
    end
end

function DigForward(blocks)
    local steps = 0
    while steps<blocks do
        turtle.dig()
        if turtle.forward() then
            steps = steps+1
        end
    end
end

function SetMark()
    if turtle.detectDown() then
        turtle.digUp()
        turtle.up()
        turtle.select(2)
        turtle.placeDown()
    else
        turtle.selcet(3)
        turtle.placeDown()
        turtle.digUp()
        turtle.up()
        turtle.select(2)
        turtle.placeDown()
    end
end

function SetMarkAndTurn()
    SetMark()
    turtle.turnLeft()
    DigForward(1)
    turtle.digDown()
    turtle.down()
end

Refuel()
DigForward(63)
SetMarkAndTurn()
DigForward(62)
SetMarkAndTurn()
DigForward(62)
SetMarkAndTurn()
DigForward(62)
SetMark()
turtle.turnLeft()