--for a computercraft computer
--start a program and get a discord message when that program errors

local webhookUrl
local tArgs = {...}
local call = {}
if #tArgs > 0 then
    print("webhook url?")
    webhookUrl = read()
    for index,value in ipairs(tArgs) do
        table.insert(call, tostring(value))
    end
    s = shell.run(unpack(call))
    if s == false and webhookUrl then
        local label = os.getComputerLabel()
        local img = "https://turtleappstore.com/static/images/turtle_pickaxe.png"
        local msg = tArgs[1].." crashed/terminated"
        http.post(webhookUrl, "{  \"content\": \""..msg.."\", \"username\": \""..label.."\", \"avatar_url\": \""..img.."\"}", { ["Content-Type"] = "application/json", ["User-Agent"] = "ComputerCraft"})
    end
end