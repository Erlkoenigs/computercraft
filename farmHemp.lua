
print("Length:")
local length = tonumber(read())

print("Width:")
local width = tonumber(read())

function farmForward(distance)
    for j=1,distance do
        if turtle.dig() then
            turtle.forward()
            turtle.digDown()
            for k=1,16 do
                turtle.select(k)
                local data=turtle.getItemDetail()
                if data~=nil then
                    --plant the seed
                    if data.name=="immersiveengineering:seed" then
                        turtle.placeDown()
                    end
                end
            end
        else
            turtle.forward()
        end
    end
end

while true do
    for i=0,width do
        farmForward(length)
        if i%2==0 then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
        farmForward(1)
        if i%2==0 then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
    end
end