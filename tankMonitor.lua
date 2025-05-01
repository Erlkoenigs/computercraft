local tank = peripheral.wrap("immersiveengineering:tank_master_0")
local mon = peripheral.find("monitor")

local maxLevel = 512 --512 buckets in immersive engineering tanks

function clear()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

function mon:writeLine(text)
    local x, y = self.getCursorPos()
    self.write(text)
    self.setCursorPos(1, y + 1)
end

while true do
    local width, height = mon.getSize()
    local content = table.remove(tank.tanks()) -- tank.tanks() returns nested tables
    local name = {}
    name[1] = string.sub(content.name, string.find(content.name, ":") + 1, string.len(content.name))
    -- if name longer than width break line at underscore
    if string.len(name[1]) > width then
        local underscore = string.find(name[1], "_")
        if underscore then
            name[2] = string.sub(name[1], underscore + 1, string.len(name[1]))
            name[1] = string.sub(name[1], 1, underscore)
        end
    end
    mon:writeLine(name[1])
    if name[2] then
        mon:writeLine(name[2])
    end
    os.sleep(1)
    local x, y = mon.getCursorPos()
    local barHeight = height - y
    for i=1, barHeight do
        local percent = content.amount / 1000 / maxLevel
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