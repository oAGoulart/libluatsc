local begin = os.clock()
dofile("crc32.lua")
local endin = os.clock()
print((endin - begin) * 1000000)
