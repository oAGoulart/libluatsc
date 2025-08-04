# libluatsc

[![GitHub Release](https://img.shields.io/github/v/release/oagoulart/libluatsc?color=green)](https://github.com/oAGoulart/libluatsc/releases)
[![GitHub License](https://img.shields.io/github/license/oagoulart/libluatsc)](https://github.com/oAGoulart/libluatsc/tree/master?tab=MS-RL-1-ov-file)
[![Static Badge](https://img.shields.io/badge/Lua-5.4-green?logo=lua)](https://www.lua.org/download.html)

Lua 5.4 library to read 64-bit time-stamp counter and `TSC_AUX` value.

> The TSC register can be used by performance-analysis applications, along with the performance
> monitoring registers, to help determine the relative frequency of an event or its duration.
> TSC is incremented at a rate corresponding to the baseline frequency of the processor
> (which may differ from actual processor frequency in low power modes of operation).

Supports SSE 2 and if available will, by default:
1. be executed only after all previous stores are globally visible; and
2. be executed prior to execution of any subsequent instruction (including any memory accesses).

## Usage

Binaries for AMD64 are available on Releases page. For x86, build with `build.sh` script. If on Windows, use MinGW/MSYS2 with `CFLAGS` and `LFLAGS` set to include and library paths, respectively.

```sh
env CFLAGS=-IC:/Users/a_gou/scoop/apps/lua/5.4.7-2/include \
    LFLAGS=-LC:/Users/a_gou/scoop/apps/lua/5.4.7-2/bin ./build.sh
```

**NOTE:** If you want to use MSVC, you are on your own, sorry.

Then, require and call `now()` to get the counter and `TSC_AUX`. On most systems, `TSC_AUX` is initialized by privileged software with a signature value (e.g., a logical processor ID).

```lua
local tsc = require("libluatsc")

local stamp, aux = tsc.now()
print("stamp: ", stamp, " aux: ", aux)

--[[
  The time stamp counter in newer processors may
  support an enhancement, referred to as invariant TSC ]]--
print("is invariant? ", tsc.isinvariant())
```

...might output:

```text
stamp:  50806050955569   aux:   6
is invariant?   true
```

**NOTE:** If the Lua code above fails with `module 'libluatsc' not found` on Windows, add `package.cpath=".\\?.dll"` one line before `require` or change your `LUA_CPATH` environment variable to include `.\\?.dll`.

### Calculating delta time

To find the difference in seconds between two time stamps, you'll need to divide the result of T<sub>end</sub> minus T<sub>begin</sub> by the the processor clock speed.

```lua
local tsc = require("libluatsc")
-- from: https://github.com/oAGoulart/libluacrc32
local crc32 = require("libluacrc32")

local s = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.;/][-=!@#$%&*(){}?:><|"
for i = 0, 20 do
  s = s .. s
end

local begin, baux = tsc.now()
local res = crc32.calculate(s, "ISCSI")
local endin, eaux = tsc.now()

--[[
  On Linux, use: `grep -m1 "cpu MHz" /proc/cpuinfo`
  This will output something like: "cpu MHz         : 2096.004"
  Since MHz are 1e+6, we use: 2096004000 ]]--
print("delta time:", (endin - begin) / 2096004000, "seconds")
```

...might output:

```text
delta time:     0.030666233461387       seconds
```
