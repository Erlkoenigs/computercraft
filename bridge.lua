--for the computercraft turtle
--creates a straight bridge
--fuel in slot one
--dummy material in slot 2

local pos = 0

--give length as command line argument
tArgs={...}
if #tArgs > 0 and type(tonumber(tArgs[1])) == "number" then
    length = tArgs[1]
else
    print("Input length of the bridge:")
    local length = read()
end

--refuel
turtle.select(1)
while turtle.getFuelLevel()<length do
    turtle.refuel(1)
end
turtle.select(2)

--build bridge
while pos < length do
    if not turtle.forward() then
        print("path blocked")
        break
    else
        pos = pos + 1
    end
    local f = false
    if not turtle.placeDown() and f = false then
        print("no material")
        f = true
        os.sleep(5)
    end
end
print("ended")