-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(func)
    local seen = {}
    return function(node1)
        return coroutine.wrap(function()
            seen[node1] = true
            for node2, edge in func(node1) do
                if not seen[node2] then
                    seen[node2] = true
                    coroutine.yield(node2, edge)
                end
            end
        end)
    end
end
