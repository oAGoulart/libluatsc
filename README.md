# libluatsc

Lua 5.4 library to read 64-bit time-stamp counter and `TSC_AUX` value.

> The TSC register can be used by performance-analysis applications, along with the performance
> monitoring registers, to help determine the relative frequency of an event or its duration.
> TSC is incremented at a rate corresponding to the baseline frequency of the processor
> (which may differ from actual processor frequency in low power modes of operation).

Supports SSE 2 and if available will, by default:
1. be executed only after all previous stores are globally visible; and
2. be executed prior to execution of any subsequent instruction (including any memory accesses).

## Usage

To build, use `build.sh` script. If on Windows, use MinGW/MSYS2 with `CFLAGS` and `LFLAGS` set to include and library paths, respectively.

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
