-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("tree.Graph", function()
    it("creates a graph from nodes and edges", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local c = {}
        local nodes = {a, b, c}
        local edges = {
            {a, b, {}},
            {b, c, {foo='bar'}},
        }
        local graph = Graph(nodes, edges)
    end)

    it("can't create en empty graph", function()
        local Graph = require 'tree.Graph'
        assert.has_error(function()
            local graph = Graph({}, {})
        end)
    end)

    it("can create a graph with no edges", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local graph = Graph({a}, {})
    end)

    it("can't make a loop", function()
        local Graph = require 'tree.Graph'
        assert.has_error(function()
            local a = {}
            local graph = Graph({a}, {
                {a, a, {}},
            })
        end)
    end)

    it("can't use edges of unknown nodes", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        assert.has_error(function()
            local graph = Graph({a}, {
                {a, b, {}},
            })
        end)
    end)

    it("can't use double edges", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        assert.has_error(function()
            local graph = Graph({a, b}, {
                {a, b, {}},
                {a, b, {}},
            })
        end)
    end)

    it("extracts edge", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local graph = Graph({a, b}, {
            {a, b, {foo='bar'}},
        })
        assert.equal('bar', graph:edge(a, b).foo)
        assert.equal('bar', graph:edge(b, a).foo)
    end)

    it("iterates all edges", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local c = {}
        local d = {}
        local graph = Graph({a, b, c, d}, {
            {a, b, {foo='bar1'}},
            {c, d, {foo='bar2'}},
        })
        local seen_foos = {}
        for n1, n2, edge in graph:iterPairs() do
            if edge.foo == 'bar1' then
                assert.truthy(n1 == a or n1 == b)
                assert.truthy(n2 == a or n2 == b)
            elseif edge.foo == 'bar2' then
                assert.truthy(n1 == c or n1 == d)
                assert.truthy(n2 == c or n2 == d)
            else
                error('bad foo')
            end
            table.insert(seen_foos, edge.foo)
        end
        assert.equal(2, #seen_foos)
    end)

    it("gets nodes", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local graph = Graph({a}, {})
        assert.equal(1, #graph:nodes())
        assert.equal(a, graph:nodes()[1])
    end)

    it("iterates nodes", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local graph = Graph({a}, {})
        local it = graph:iterNodes()
        assert.equal(a, it())
        assert.falsy(it())
    end)

    it("iterates breadth-first", function()
        -- a - b - c - e
        --     |
        --     d - f
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local c = {}
        local d = {}
        local e = {}
        local f = {}
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            {b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
        })
        local it = graph:iterBreadth(a)
        local p = require 'tree.detail.arrayFromIt'(it)
        assert.truthy(p[1] == a)
        assert.truthy(p[2] == b)
        assert.truthy((p[3] == c and p[4] == d) or
            (p[3] == d and p[4] == c))
        assert.truthy((p[5] == e and p[6] == f) or
            (p[5] == f and p[6] == e))
    end)

    it("iterates depth-first", function()
        -- a - b - c - e
        --     |
        --     d - f
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local c = {}
        local d = {}
        local e = {}
        local f = {}
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            {b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
        })
        local it = graph:iterDepth(a)
        local p = require 'tree.detail.arrayFromIt'(it)
        assert.truthy(p[1] == a)
        assert.truthy(p[2] == b)
        assert.truthy((p[3] == c and p[4] == e
            and p[5] == d and p[6] == f) or
        (p[3] == d and p[4] == f
            and p[5] == c and p[6] == e))
    end)

    it("yields level, parent, edge from iterator", function()
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local edge = {}
        local graph = Graph({a, b}, {
            {a, b, edge},
        })
        local it = graph:iterDepth(a)
        assert.same({a, 0, nil, nil}, {it()})
        assert.same({b, 1, a, edge}, {it()})
    end)

    it("gets if it is connected", function()
        -- a - b - c - e
        --     |
        --     d - f
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local c = {}
        local d = {}
        local e = {}
        local f = {}
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            {b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
        })
        assert.truthy(graph:isConnected())
        ---
        -- a - b   c - e
        --     |
        --     d - f
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            --{b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
        })
        assert.falsy(graph:isConnected())
    end)

    it("gets if it is a tree", function()
        -- a - b - c - e
        --     |
        --     d - f
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local c = {}
        local d = {}
        local e = {}
        local f = {}
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            {b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
        })
        assert.truthy(graph:isTree())
        ---
        -- a - b   c - e
        --     |
        --     d - f
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            --{b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
        })
        assert.falsy(graph:isTree())
        ---
        -- a - b - c - e
        --     |     /
        --     d - f
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            {b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
            {f, e, {}},
        })
        assert.falsy(graph:isTree())
    end)

    it("converts to tree", function()
        -- a - b - c - e
        --     |
        --     d - f
        local Graph = require 'tree.Graph'
        local a = {}
        local b = {}
        local c = {}
        local d = {}
        local e = {}
        local f = {}
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            {b, c, {}},
            {c, e, {foo='bar'}},
            {b, d, {}},
            {d, f, {}},
        })
        local tree = graph:toTree(a)
        assert.equal('bar', tree:edge(c, e).foo)
        ---
        -- a - b   c - e
        --     |
        --     d - f
        local graph = Graph({a, b, c, d, e, f}, {
            {a, b, {}},
            --{b, c, {}},
            {c, e, {}},
            {b, d, {}},
            {d, f, {}},
        })
        assert.has_error(function()
            local tree = graph:toTree(a)
        end)
    end)
end)
