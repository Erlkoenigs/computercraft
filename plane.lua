--not finished
--This program is meant for the computercraft turtle
--It will create a plane of a configurable radius around the starting position
--by digging everything on the level of its starting position and above

--radius excludes starting position: radius = 2 planes a 5x5 area

--Order of digging in one plane when radius = 2:
--t - turtle
--c - chest
--19 18 11 10 6
--20 17 12 9  5
--21 16 t  1  2
--22 15 c  8  3
--23 14 13 7  4

print("Radius:")
local r = tonumber(read())

--track current position
local currentPosition = 0
local dug = false

function refuel()
    turtle.select(1)
    while turtle.getFuelLevel()<300 do --random value
        turtle.refuel(1)
    end
    turtle.select(2)
end

function emptyInventory()

end

function checkInventory()
    turtle.select(16)
    if turtle.getItemCount() > 0 then
        emptyInventory()
    end
    turtle.select(2)
end

function digForward(blocks)
    for i=0, blocks do
        while not turtle.forward() do
            if turtle.dig() then
                dug = true
                checkInventory()
            end            
        end
        if turtle.getFuelLevel()<80 then
            Refuel()
        end
        currentPosition=currentPosition+1
    end
end

--dig a plane with given radius, when it broke a block on this level, return true
function plane()
    dug = false
    --go to the edge and dig straights    
    for i=0,r*2+1 do --(plus starting position block)
        if i==2*r^2+2*r+1 then --if in middle row, go over chest
            digForward(r)
            while not turtle.up() do
                turtle.digUp()
            end
            digForward(2)
            while not turtle.down() do
                turtle.digDown()
            end
            digForward(r-2)
            --turn
            if i%2==0 or i==0 then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
            digForward(1)
            if i%2==0 or i==0 then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
        else
            digForward(r*2+1)
            --turn
            if i%2==0 or i==0 then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
            digForward(1)
            if i%2==0 or i==0 then
                turtle.turnLeft()
            else
                turtle.turnRight()
            end
        end
    end
    return dug
end

--action
--to lower left corner
refuel()
turtle.turnRight()
digForward(r) --to the edge
turtle.turnRight()
turtle.digForward(r) --to the lower right corner
turtle.turnLeft() --turn around
turtle.turnLeft()
currentPosition = 1
while plane() == true and i<height do
    while not turtle.up() do
        turtle.digUp()
    end
    i=i+1
end