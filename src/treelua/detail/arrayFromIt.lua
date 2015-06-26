-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(it)
    local clone = {}
    for item in it do
        table.insert(clone, item)
    end
    return clone
end
