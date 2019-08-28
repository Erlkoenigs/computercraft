--this program is meant for the computercraft turtle
--it will place Buildcraft Land Marks in a square of a given size

--user input
print("width of the quarry to the left of the starting position:")
local width = tonumber(read())
print("depth of the quarry:")
local depth = tonumber(read())

function Refuel()
    turtle.select(1)
    if not turtle.refuel(1) then
        print("Need fuel in slot 1")
    end
    while turtle.getFuelLevel()<300 do
        turtle.refuel(1)
    end
    print("refueled")
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

--turns when above the mark it has set, then digs/goes foward and down one block
function SetMarkAndTurn()
    if turtle.detectDown() then
        turtle.digUp()
        turtle.up()
        turtle.select(2)
        turtle.placeDown()
    else
        turtle.select(3)
        turtle.placeDown()
        turtle.digUp()
        turtle.up()
        turtle.select(2)
        turtle.placeDown()
    end
    --turn
    turtle.turnLeft()
    DigForward(1)
    turtle.digDown()
    turtle.down()
end

--action
Refuel()
DigForward(depth)
SetMarkAndTurn() --already goes 1 block into next direction
DigForward(width-1)
SetMarkAndTurn() --already goes 1 block into next direction
DigForward(depth-1)
SetMarkAndTurn() --already goes 1 block into next direction
DigForward(width-1)
SetMark() -- back at starting position