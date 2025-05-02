local peripheralList = peripheral.getNames()
for _, peripheralName in pairs(peripheralList) do
    if string.find(peripheralName, "immersiveengineering:tank_master") then
        print("Found tank master: " .. peripheralName)
        tank = peripheral.wrap(peripheralName)
    end
end

local mon = peripheral.find("monitor")

local maxLevel = 512 --512 buckets in immersive engineering tanks

function mon:writeLine(text)
    local x, y = self.getCursorPos()
    self.write(text)
    self.setCursorPos(1, y + 1)
end

function clearLine()
    local x, y = mon.getCursorPos()
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(1, y)
    local width, height = mon.getSize()
    mon.write(string.rep(" ", width))
    mon.setCursorPos(1, y)
end

mon.setTextScale(0.5)
mon.setBackgroundColor(colors.black)
mon.clear()
mon.setCursorPos(1, 1)
while true do
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(1, 1)
    local width, height = mon.getSize()
    local content = table.remove(tank.tanks()) -- tank.tanks() returns nested tables
    local amount = 0
    local name = {}
    if content == nil then
        amount = 0
        name[1] = "empty"
    else
        amount = content.amount
        name[1] = string.sub(content.name, string.find(content.name, ":") + 1, string.len(content.name))
    end
    -- if name longer than width and contains underscore break line at underscore
    if string.len(name[1]) > width then
        local underscore = string.find(name[1], "_")
        if underscore then
            name[2] = string.sub(name[1], underscore + 1, string.len(name[1]))
            name[1] = string.sub(name[1], 1, underscore)
        end
    end
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(1, 1)
    clearLine()
    mon:writeLine(name[1])
    if name[2] then
        clearLine()
        mon:writeLine(name[2])
    end
    local x, y = mon.getCursorPos()
    local barHeight = height - y + 1
    for i=1, barHeight do
        local percent = amount / 1000 / maxLevel
        if i > (1 - percent) * barHeight then
            if percent > 0.9 then
                mon.setBackgroundColor(colors.red)
            else
                mon.setBackgroundColor(colors.green)
            end
        else
            mon.setBackgroundColor(colors.gray)
        end
        mon:writeLine(string.rep(" ", width))
    end
end