--farm one ender lilly once it's ready, put the pearl in a chest to the right and replant the seed
while true do
    local s,d=turtle.inspect()
    if s then
        if d.state.growth==7 then
        turtle.dig()
            for i=1,16 do
                turtle.select(i)
                local data=turtle.getItemDetail()
                if data~=nil then
                    if data.name=="extrautils2:enderlilly" then
                        turtle.place()
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