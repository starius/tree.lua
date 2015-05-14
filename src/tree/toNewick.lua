-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(tree)
    local function toNewick(node)
        local text = ''
        if not tree:isLeaf(node) then
            local texts = {}
            for child in tree:iterChildrenOf(node) do
                table.insert(texts, toNewick(child))
            end
            text = '(' .. table.concat(texts, ',') .. ')'
        end
        if tree:isLeaf(node) then
            assert(node.name, "Unnamed leaf is not allowed")
        end
        local name = node.name or ''
        local length = ''
        local parent = tree:parentOf(node)
        if parent then
            local edge = tree:edge(parent, node)
            if edge.length then
                length = ':' .. assert(edge.length)
            end
        end
        return text .. name .. length
    end
    return toNewick(tree:root()) .. ';'
end
