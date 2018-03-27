function Refuel()
    turtle.select(1)
    if not turtle.refuel(1) then
        print("Need fuel in slot 1")
    end
    while turtle.getFuelLevel()<300 do
        turtle.refuel(1)
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