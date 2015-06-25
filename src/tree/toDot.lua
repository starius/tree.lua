-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(graph)
    local node2name = {}
    for i, node in ipairs(graph:nodes()) do
        node2name[node] = 'n' .. i
    end
    --
    local buffer = {}
    local function print(text)
        table.insert(buffer, text)
    end
    print('graph G {')
    -- print named nodes
    for node in graph:iterNodes() do
        if node.name then
            local node_str = '%s [label=%q];'
            print(node_str:format(node2name[node], node.name))
        end
    end
    print('node[shape=none, width=0, height=0, label=""];')
    -- print unnamed nodes
    for node in graph:iterNodes() do
        if not node.name then
            print(node2name[node] .. ';')
        end
    end
    -- print edges
    for n1, n2, edge in graph:iterPairs() do
        local n1_s = node2name[n1]
        local n2_s = node2name[n2]
        local edge_s = edge.length or ''
        local edge_str = '%s -- %s [label=%q];'
        print(edge_str:format(n1_s, n2_s, edge_s))
    end
    -- close graph
    print('}')
    --
    return table.concat(buffer, '\n')
end
