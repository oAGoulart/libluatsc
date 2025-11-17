package.cpath="./?.so"
local tsc = require("libluatsc")

local begin, baux = tsc.now()
dofile("crc32.lua")
local endin, eaux = tsc.now()
assert(baux == eaux)

local cs = io.open(".cpuspd", "r")
if cs == nil then
  os.execute("grep -m1 \"cpu MHz\" /proc/cpuinfo >> .cpuspd")
  cs = io.open(".cpuspd", "r")
end
local result = cs:read("*a")
cs:close()
local cpuspd = tonumber(result:match("%d+.%d+"))

local deltat = (endin - begin) / cpuspd
print(deltat) -- (MHz = 1e+6 = microsecond)
