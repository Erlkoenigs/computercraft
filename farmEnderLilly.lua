--farm one ender lilly once it's ready, put the pearl in a chest to the right and replant the seed
--ender lilly has to be planted in front of the turtle
--a chest for the ender pearls has to be on the right side of the turtle
while true do
    local s,d=turtle.inspect()
    if s then
        if d.state.growth==7 then
        turtle.dig()
            --find lilly seed and pearl in inventory
            for i=1,16 do
                turtle.select(i)
                local data=turtle.getItemDetail()
                if data~=nil then
                    --plant the seed
                    if data.name=="extrautils2:enderlilly" then
                        turtle.place()
                    --put the pearl in the chest
                    elseif data.name=="minecraft:ender_pearl" then
                        turtle.turnRight()
                        while not turtle.drop() do
                            os.sleep(30)
                        end
                        turtle.turnLeft()
                    end
                end
            end
        end
    end
    os.sleep(300)
end