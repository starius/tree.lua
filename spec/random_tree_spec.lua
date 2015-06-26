-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("random tree", function()
    it("creates a random tree", function()
        local Tree = require 'treelua.Tree'
        local children_of = {}
        local nodes = {}
        for i = 1, 10000 do
            local node = {name='node'..i}
            children_of[node] = {}
            if #nodes > 0 then
                -- select random parent
                local parent = nodes[math.random(1, #nodes)]
                children_of[parent][node] = {length=math.random(0, 100)}
            end
            table.insert(nodes, node)
        end
        local t = Tree(children_of)
        --
        local lpeg = require 'lpeg'
        lpeg.setmaxstack(100000)
        local toNewick = require 'treelua.toNewick'
        local fromNewick = require 'treelua.fromNewick'
        local t2 = fromNewick(toNewick(t))
        assert.equal(#t:nodes(), #t2:nodes())
    end)
end)
