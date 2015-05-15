-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local mt = {}
mt.__index = mt

-- children_of is a map from node to map {child: edge}
local function constructor(children_of)
    local tree = {}
    tree._children_of = {}
    tree._parent_of = {}
    local node_set = {}
    for node, children in pairs(children_of) do
        tree._children_of[node] = {}
        node_set[node] = true
        for child, edge in pairs(children) do
            assert(not tree._parent_of[child],
                "Each node must have only one parent")
            tree._children_of[node][child] = edge
            tree._parent_of[child] = node
            node_set[child] = true
        end
    end
    tree._nodes = {}
    for node in pairs(node_set) do
        if not tree._children_of[node] then
            tree._children_of[node] = {}
        end
        table.insert(tree._nodes, node)
        if not tree._parent_of[node] then
            assert(not tree._root, "Only one root is allowed")
            tree._root = node
        end
    end
    assert(tree._root, "No root detected")
    setmetatable(tree, mt)
    return tree
end

function mt.root(self)
    return self._root
end

function mt.parentOf(self, node)
    assert(self:isNode(node))
    return self._parent_of[node]
end

function mt.iterChildrenOf(self, node)
    assert(self:isNode(node))
    return coroutine.wrap(function()
        for child, edge in pairs(self._children_of[node]) do
            coroutine.yield(child, edge)
        end
    end)
end

function mt.edge(self, node1, node2)
    assert(self:isNode(node1))
    assert(self:isNode(node2))
    local ch = self._children_of
    if ch[node1] and ch[node1][node2] then
        return ch[node1][node2]
    end
    if ch[node2] and ch[node2][node1] then
        return ch[node2][node1]
    end
end

function mt.isNode(self, node)
    return node and self._children_of[node]
end

function mt.iterNodes(self)
    return coroutine.wrap(function()
        for _, node in ipairs(self._nodes) do
            coroutine.yield(node)
        end
    end)
end

function mt.nodes(self)
    local arrayFromIt = require 'tree.detail.arrayFromIt'
    return arrayFromIt(self:iterNodes())
end

function mt.isLeaf(self, node)
    assert(self:isNode(node))
    local n_children = 0
    for child in pairs(self._children_of[node]) do
        n_children = n_children + 1
    end
    return n_children  == 0
end

function mt.iterLeafs(self)
    return coroutine.wrap(function()
        for node in self:iterNodes() do
            if self:isLeaf(node) then
                coroutine.yield(node)
            end
        end
    end)
end

function mt.leafs(self)
    local arrayFromIt = require 'tree.detail.arrayFromIt'
    return arrayFromIt(self:iterLeafs())
end

local function getNeighbours(self)
    local newNeighbours = require 'tree.detail.newNeighbours'
    return newNeighbours(function(node1)
        return coroutine.wrap(function()
            local parent = self._parent_of[node1]
            if parent then
                local edge = self._children_of[parent][node1]
                coroutine.yield(parent, edge)
            end
            local children = self._children_of[node1]
            for node2, edge in pairs(children) do
                coroutine.yield(node2, edge)
            end
        end)
    end)
end

function mt.iterBreadth(self, init)
    assert(self:isNode(init))
    -- https://en.wikipedia.org/wiki/Breadth-first_search
    return coroutine.wrap(function()
        local breadthFirst = require 'tree.detail.breadthFirst'
        breadthFirst(init, getNeighbours(self),
            coroutine.yield)
    end)
end

function mt.iterDepth(self, init)
    assert(self:isNode(init))
    -- https://en.wikipedia.org/wiki/Depth-first_search
    return coroutine.wrap(function()
        local depthFirst = require 'tree.detail.depthFirst'
        depthFirst(init, getNeighbours(self),
            coroutine.yield)
    end)
end

function mt.toGraph(self)
    local nodes = self:nodes()
    local edges = {}
    local root = self:root()
    for node, _, parent, edge in self:iterDepth(root) do
        if parent and edge then
            table.insert(edges, {node, parent, edge})
        end
    end
    local Graph = require 'tree.Graph'
    return Graph(nodes, edges)
end

return constructor
