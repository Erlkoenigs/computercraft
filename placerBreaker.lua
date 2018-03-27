function Refuel()
    turtle.select(1)
    if not turtle.refuel(1) then
        print("Need fuel in slot 1")
    end
    while turtle.getFuelLevel()<300 do
        turtle.refuel(1)
    end
end

--Slots 3 to 16 are product slots. Inventory is needed in the front of the turtle
function DumpItems()
    print("Dumping items")
    for i=3,16 do
        turtle.select(i)
        turtle.drop()
    end
turtle.select(3)
end

while true do
    if turtle.getFuelLevel()<10 then
        print("Need a refuel")
        Refuel()
    end
    if turtle.getItemSpace(16)<20 then
        print("Need to dump items")
        DumpItems()
    end
    
    turtle.select(2)
    if not turtle.placeUp() then
        print("sucking items")
        turtle.suck()
        turtle.placeUp()
    end
    turtle.select(3)
    turtle.digUp()
end
