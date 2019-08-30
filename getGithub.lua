print("program to download:")
local program = read()
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