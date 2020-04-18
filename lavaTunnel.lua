--This program is meant for the computercraft turtle
--It moves forward while placing blocks above, left and right of itself
--This creates a 1x2 tunnel, which can be used to cross a lava flow
--Fuel in slot 1, material to place in slot 2

local length = 0

--get length from player
tArgs={...}
if #tArgs == 1 and type(tonumber(tArgs[1])) == "number" then
    length = tonumber(tArgs[1])
else
    print("Input length of the tunnel?")
    length = tonumber(read())
end

--places blocks all around a 1x2 tunnel (starts on the upper block)
function place()
    turtle.placeUp()
    turtle.turnLeft()
    turtle.place()
    turtle.down()
    turtle.place()
    turtle.turnRight()
    turtle.placeDown()
    turtle.turnRight()
    turtle.place()
    turtle.up()
    turtle.place()
    turtle.turnLeft()
end

--refuel
turtle.select(1)
while turtle.getFuelLevel()<length*3 do
    turtle.refuel(1)
end
turtle.select(2)

--way in
turtle.up()
for i=0, length do
    place()
    if not turtle.forward() then
        break
    end
end
turtle.down()

--way out
turtle.turnLeft()
turtle.turnLeft()
for i=0,4 do
    turtle.forward()
end