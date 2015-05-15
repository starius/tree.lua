-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- init is start node. It is the first yielded value
-- newNeighbours(node1) returns iterator, returning
--   pairs (node2, edge), so that node2 is not repeated
--   (including node1) across calls to newNeighbours
-- func is applied to every (node, level, parent, edge),
--   including init node (for which parent = edge = nil
return function(init, newNeighbours, func)
    local unpack = require 'tree.detail.compat'.unpack
    local stack = {{init, 0, nil, nil}}  -- parent, edge
    while #stack > 0 do
        local item = table.remove(stack)
        local node1, level, parent, edge = unpack(item)
        func(node1, level, parent, edge)
        level = level + 1
        for node2, edge in newNeighbours(node1) do
            table.insert(stack, {node2, level, node1, edge})
        end
    end
end
