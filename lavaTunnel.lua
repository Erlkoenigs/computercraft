--This program is meant for the computercraft turtle
--It moves forward while placing blocks above, left and right of itself
--It creates a 1x2 tunnel, which can be used to get rid of a lava flow
print("Input length of the tunnel:")
local length = read()

--places a blocks all around a 1x2 area
function place()
    turtle.up()
    turtle.placeUp()
    turtle.turnLeft()
    turtle.place()
    turtle.turnRight()
    turtle.turnRight()
    turtle.place()
    turtle.turnLeft()
    turtle.down()
    turtle.turnLeft()
    turtle.place()
    turtle.turnRight()
    turtle.turnRight()
    turtle.place()
    turtle.turnLeft()
    turtle.placeDown()
end

turtle.select(1)
while turtle.getFuelLevel()<length*5 do
    turtle.refuel(1)
end
turtle.select(2)

for i=0, length do
    place()
    turtle.forward()
end
--return to starting position
turtle.turnLeft()
turtle.turnLeft()
for i=0,length do
    turtle.forward()
end
turtle.turnLeft()
turtle.turnLeft()