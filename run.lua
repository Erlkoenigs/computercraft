--for a computercraft computer
--supervise a program
--get a message when that program errors

local webhookUrl
local tArgs = {...}
local call = {}
if tArgs > 0 then
    print("webhook url?")
    webhookUrl = read()
    for index,value in ipairs(tArgs) do
        table.insert(call, value)
    end
    print("run: "..unpack(call))
    s = os.run(unpack(call))
    if s == false and webhookUrl then
        msg = tArgs[1].." crashed"
        label = os.getComputerLabel()
        img = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Red_X.svg/200px-Red_X.svg.png"
        http.post(webhookUrl, "{  \"content\": \""..msg.."\", \"username\": \""..label.."\", \"avatar_url\": \""..img.."\"}", { ["Content-Type"] = "application/json", ["User-Agent"] = "ComputerCraft"})
    end
end