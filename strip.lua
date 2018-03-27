
function Refuel()
    for i=1, i<17 do
        turtle.select(i)
        while turtle.getFuelLevel < 19000 do                
                turtle.refuel()  --geht nicht
        end
    end
end

function StripForward()
    for i=0, i<200 do
        while turtle.detect() do
            turtle.dig()
            os.sleep(0.5)
        turtle.forward()
        while turtle.detectUp() do
            turtle.digUp()
            os.sleep(0.5)
    end
end

function StripBack()
    turtle.turnLeft()
    turtle.turnLeft()
    for i=0, i<200