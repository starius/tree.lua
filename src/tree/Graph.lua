-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local mt = {}
mt.__index = mt

-- nodes is a list of unique elements
-- edges is a list of tables {node1, node2, options}
-- options is a table with edge's properties. It can be empty
local function constructor(nodes, edges)
    assert(#nodes >= 1)
    local graph = {}
    graph._nodes = nodes
    graph._neighbours = {}
    for _, node in ipairs(nodes) do
        graph._neighbours[node] = {}
    end
    for _, edge in ipairs(edges) do
        local node1 = assert(edge[1])
        local node2 = assert(edge[2])
        local options = assert(edge[3])
        assert(node1 ~= node2)
        assert(not graph._neighbours[node1][node2])
        graph._neighbours[node1][node2] = options
        graph._neighbours[node2][node1] = options
    end
    setmetatable(graph, mt)
    return graph
end

function mt.edge(self, node1, node2)
    return self._neighbours[node1][node2]
end

function mt.iterNodes(self)
    return coroutine.wrap(function()
        for _, node in ipairs(self._nodes) do
            coroutine.yield(node)
        end
    end)
end

function mt.iterPairs(self)
    return coroutine.wrap(function()
        local seen_edges = {}
        for node1, neighbours in pairs(self._neighbours) do
            for node2, edge in pairs(neighbours) do
                if not seen_edges[edge] then
                    seen_edges[edge] = true
                    coroutine.yield(node1, node2, edge)
                end
            end
        end
    end)
end

function mt.nodes(self)
    local arrayFromIt = require 'tree.detail.arrayFromIt'
    return arrayFromIt(self:iterNodes())
end

local function getNeighbours(self)
    local newNeighbours = require 'tree.detail.newNeighbours'
    return newNeighbours(function(node1)
        return coroutine.wrap(function()
            local neighbours = self._neighbours[node1]
            for node2, edge in pairs(neighbours) do
                coroutine.yield(node2, edge)
            end
        end)
    end)
end

function mt.iterBreadth(self, init)
    -- https://en.wikipedia.org/wiki/Breadth-first_search
    return coroutine.wrap(function()
        local breadthFirst = require 'tree.detail.breadthFirst'
        breadthFirst(init, getNeighbours(self),
            coroutine.yield)
    end)
end

function mt.iterDepth(self, init)
    -- https://en.wikipedia.org/wiki/Depth-first_search
    return coroutine.wrap(function()
        local depthFirst = require 'tree.detail.depthFirst'
        depthFirst(init, getNeighbours(self),
            coroutine.yield)
    end)
end

function mt.isConnected(self)
    local seen = {}
    for node in self:iterBreadth(self:nodes()[1]) do
        seen[node] = true
    end
    for node in self:iterNodes() do
        if not seen[node] then
            return false
        end
    end
    return true
end

function mt.isTree(self)
    if not self:isConnected() then
        return false
    end
    -- match levels of nodes in-depth and in-breadth
    local levels = {}
    local root = self:nodes()[1]
    for node, level in self:iterDepth(root) do
        levels[node] = level
    end
    for node, level in self:iterBreadth(root) do
        if levels[node] ~= level then
            return false
        end
    end
    return true
end

function mt.toTree(self, root)
    assert(root, "No root provided")
    assert(self:isTree(), "This graph is not tree")
    local children_of = {}
    local it = self:iterDepth(root)
    for node, level, parent, edge in it do
        if parent then
            if not children_of[parent] then
                children_of[parent] = {}
            end
            children_of[parent][node] = edge
        end
    end
    local Tree = require 'tree.Tree'
    return Tree(children_of)
end

return constructor
