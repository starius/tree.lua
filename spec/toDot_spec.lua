-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("tree.toDot", function()
    it("converts a graph to DOT format", function()
        local tree = require 'treelua'
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

    it("converts a graph with named nodes to DOT format",
    function()
        local tree = require 'treelua'
        local a = {name='test'}
        local b = {}
        local c = {}
        local nodes = {a, b, c}
        local edges = {
            {a, b, {}},
            {b, c, {}},
            {a, c, {}},
        }
        local graph = tree.Graph(nodes, edges)
        local dot = tree.toDot(graph)
        assert.truthy(dot:match('test'))
    end)

    it("prints all edges of non-connected graph", function()
        local tree = require 'treelua'
        local a = {}
        local b = {}
        local c = {}
        local d = {}
        local nodes = {a, b, c, d}
        local edges = {
            {a, b, {length=42}},
            {c, d, {length=66}},
        }
        local graph = tree.Graph(nodes, edges)
        local dot = tree.toDot(graph)
        assert.truthy(dot:match('42'))
        assert.truthy(dot:match('66'))
    end)
end)
