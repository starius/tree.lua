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
    local unpack = require 'treelua.detail.compat'.unpack
    local queue = {{init, nil, nil}}  -- parent, edge
    local level = 0
    while #queue > 0 do
        local queue2 = {}
        for _, item in ipairs(queue) do
            local node1, parent, edge = unpack(item)
            func(node1, level, parent, edge)
            for node2, edge in newNeighbours(node1) do
                table.insert(queue2, {node2, node1, edge})
            end
        end
        level = level + 1
        queue = queue2
    end
end
