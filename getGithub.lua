local url = "https://raw.githubusercontent.com/Erlkoenigs/computercraft/master/strip.lua"
local website = http.get(url)
if website then
    print("received")
    github_file = website.readAll()
    local h = fs.open("stripProgram.lua","w")
    h.write(github_file)
    h.close()
    print("run:")
    shell.run("stripProgram.lua")
end
website.close()