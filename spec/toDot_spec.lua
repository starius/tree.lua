-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("tree.toDot", function()
    it("converts a graph to DOT format", function()
        local tree = require 'tree'
        local a = {}
        local b = {}
        local c = {}
        local nodes = {a, b, c}
        local edges = {
            {a, b, {}},
            {b, c, {foo='bar'}},
            {a, c, {length=1.2}},
        }
        local graph = tree.Graph(nodes, edges)
        local dot = tree.toDot(graph)
        assert.truthy(dot:match('1.2'))
        assert.falsy(dot:match('bar'))
    end)
end)
