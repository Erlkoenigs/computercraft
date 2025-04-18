--farm entro clusters from ExtendedAE:
--place turtle in front of the crystal...
--with the entroized fluix behind it...
--forming a line of entroized fluix, growing crystal and the turtle.
--turtle will check for mature crystal and farm it...
--once it stops growing or stops appearing, turtle will replace fluix block...
--and use entro seed on it.
-- first slot fuel
--second slot dluix block
--third slot entro seed
--chest/inventory on top
--wait time is short, expects a growth accelerator

function replaceFluixBlock()
    --check inventory
    while turtle.getItemCount(2) == 0 or turtle.getItemCount(3) == 0 do
        print("No seed or fluix block found in inventory. Waiting 30 seconds.")
        os.sleep(30)
    end
    --select slot 4 and dig possible immature crystal
    turtle.select(4)
    turtle.dig()
    --go forward and dig fluix block
    turtle.forward()
    turtle.dig()
    --select new fluix block and place
    turtle.select(2)
    turtle.place()
    --select seed and place
    turtle.select(3)
    turtle.place()
    --go back if possible
    while turtle.back() == false do
        os.sleep(10)
        print("Can't go back, waiting 10 seconds")
    end
end

--main loop
local lastName = ""
while true do
    while turtle.getFuelLevel() < 10 do
        turtle.select(1)
        turtle.refuel(1)
    end
    local success, data = turtle.inspect()
    --if there is a block in front
    if success then
        --if crystal fully grown
        if data.name == "extendedae:entro_cluster" then
            turtle.dig()
            --if theres a block above the turtle, assume it's an inventory
            if turtle.inspectUp() == true then
                --drop slot 4 into chest
                turtle.select(4)
                while turtle.getItemCount() > 0 and turtle.dropUp() == false do
                    print("chest full. waiting 10 seconds")
                    os.sleep(10)
                end
                --drop slot 5 into chest
                turtle.select(5)
                while turtle.getItemCount() > 0 and turtle.dropUp() == false do
                    print("chest full. waiting 10 seconds")
                    os.sleep(10)
                end
                --drop slot 6 into chest
                turtle.select(6)
                while turtle.getItemCount() > 0 and turtle.dropUp() == false do
                    print("chest full. waiting 10 seconds")
                    os.sleep(10)
                end
            end
        elseif data.name == lastName then
            --crystal hasn't grown since last check
            replaceFluixBlock()
        else
            lastName = data.name
        end
    else
        --no crystal is found, place new
        replaceFluixBlock()
    end
    --wait 20 seconds before checking again 
    os.sleep(20)
end