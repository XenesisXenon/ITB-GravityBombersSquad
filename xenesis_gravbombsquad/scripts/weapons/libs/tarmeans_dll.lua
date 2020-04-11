
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."weapons/"

local old = package.loaded["test"]

package.loaded["test"] = nil
test = nil
assert(package.loadlib(path .."dll/utils.dll", "luaopen_utils"), "cannot find tarmean's C-Utils dll")()

ret = test

package.loaded["test"] = old
test = old

return ret
