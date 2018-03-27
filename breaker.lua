function Refuel()
    turtle.select(1)
    if not turtle.refuel(1) then
        print("Need fuel in slot 1")
    end
    while turtle.getFuelLevel()<300 do
        turtle.refuel(1)
    end
end

function DumpItems()
    print("Dumping items")
    turtle.turnLeft()
    for i=3,16 do
        turtle.select(i)
        turtle.drop()
    end
turtle.select(3)
turtle.turnRight()
end

while turtle.getItemCount(2)==1 do
    if turtle.getFuelLevel()<10 then
        print("Need a refuel")
        Refuel()
    end
    if turtle.getItemSpace(16)<20 then
        print("Need to dump items")
        DumpItems()
    end
    turtle.dig()
end
