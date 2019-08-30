local program = ""
tArgs={...}
if #tArgs == 0 then
    print("program to download:")
    program = read()
else
    program = tArgs[1]
end
local url = "https://raw.githubusercontent.com/Erlkoenigs/computercraft/master/"..program..".lua"    
local website = http.get(url)
if website then
    print("received")
    github_file = website.readAll()
    local h = fs.open(program..".lua","w")
    h.write(github_file)
    h.close()
end
website.close()