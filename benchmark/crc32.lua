package.cpath="./?.so"
-- from: https://github.com/oAGoulart/libluacrc32
local crc32 = require("libluacrc32")

local inp = assert(io.open(arg[1], "rb"))
local data = inp:read("*all")
--local dlen = string.len(data)
inp:close()

local res = crc32.calculate(data, "ISCSI")
