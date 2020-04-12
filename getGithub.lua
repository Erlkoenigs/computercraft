local program = ""
local branch = "master"
tArgs={...}
if #tArgs == 0 then
    print("program to download:")
    program = read()
elseif #tArgs == 1 then
    program = tArgs[1]
elseif #tArgs == 2 then
    branch = tArgs[1]
    program = tArgs[2]
end
local url = "https://raw.githubusercontent.com/Erlkoenigs/computercraft/"..branch.."/"..program..".lua"    
local site = http.get(url)
if site then
    print("received")
    github_file = site.readAll()
    local h = fs.open(program..".lua","w")
    h.write(github_file)
    h.close()
end
site.close()