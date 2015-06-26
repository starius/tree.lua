-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("tree.Tree", function()
    it("creates a tree from children list", function()
        local Tree = require 'treelua.Tree'
        local parent = {}
        local child1 = {}; local edge1 = {}
        local child2 = {}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
            [child1] = {},
            [child2] = {},
        }
    end)

    it("throws if multiple roots", function()
        local Tree = require 'treelua.Tree'
        local parent1 = {}
        local child1 = {}
        local parent2 = {}
        local child2 = {}
        assert.has_error(function()
            local tree = Tree {
                [parent1] = {[child1] = {}},
                [parent2] = {[child2] = {}},
            }
        end)
    end)

    it("throws if ownership is cyclic", function()
        local Tree = require 'treelua.Tree'
        local node1 = {}
        local node2 = {}
        assert.has_error(function()
            local tree = Tree {
                [node1] = {[node2] = {}},
                [node2] = {[node1] = {}},
            }
        end)
    end)

    it("throws if ownership is cyclic even if root exists",
    function()
        local Tree = require 'treelua.Tree'
        local root = {}
        local node1 = {}
        local node2 = {}
        assert.has_error(function()
            local tree = Tree {
                [root] = {[node1] = {}, [node2] = {}},
                [node1] = {[node2] = {}},
                [node2] = {[node1] = {}},
            }
        end)
    end)

    it("gets root", function()
        local Tree = require 'treelua.Tree'
        local parent = {}
        local child1 = {}; local edge1 = {}
        local child2 = {}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
            [child1] = {},
            [child2] = {},
        }
        assert.equal(parent, tree:root())
    end)

--[[
    A
   / \
  B   C
 / \
D   E
]]

    it("gets parent of nodes", function()
        local Tree = require 'treelua.Tree'
        local A = {}
        local B = {}
        local C = {}
        local D = {}
        local E = {}
        local tree = Tree {
            [A] = {[B] = {}, [C] = {}},
            [B] = {[D] = {}, [E] = {}},
            [C] = {},
            [D] = {},
            [E] = {},
        }
        assert.equal(A, tree:parentOf(B))
        assert.equal(A, tree:parentOf(C))
        assert.equal(B, tree:parentOf(D))
        assert.equal(B, tree:parentOf(E))
        --
        assert.equal(A, tree:root())
        assert.falsy(tree:parentOf(A))
        assert.has_error(function()
            tree:parentOf()
        end)
        assert.has_error(function()
            tree:parentOf({})
        end)
    end)

    it("infers leafs in definition", function()
        local Tree = require 'treelua.Tree'
        local parent = {}
        local child1 = {}; local edge1 = {}
        local child2 = {}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
        }
        assert.equal(3, #tree:nodes())
    end)

    it("returns if smth is a node", function()
        local Tree = require 'treelua.Tree'
        local parent = {1}
        local child1 = {2}; local edge1 = {22}
        local child2 = {3}; local edge2 = {23}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
        }
        assert.truthy(tree:isNode(parent))
        assert.truthy(tree:isNode(child1))
        assert.truthy(tree:isNode(child2))
        assert.falsy(tree:isNode())
        assert.falsy(tree:isNode(nil))
        assert.falsy(tree:isNode(1))
        assert.falsy(tree:isNode({1}))
        assert.falsy(tree:isNode({}))
    end)

--[[
    A
   / \
  B   C
 / \
D   E
]]

    it("gets if a node is leaf", function()
        local Tree = require 'treelua.Tree'
        local A = {}
        local B = {}
        local C = {}
        local D = {}
        local E = {}
        local tree = Tree {
            [A] = {[B] = {}, [C] = {}},
            [B] = {[D] = {}, [E] = {}},
        }
        assert.falsy(tree:isLeaf(A))
        assert.falsy(tree:isLeaf(B))
        assert.truthy(tree:isLeaf(C))
        assert.truthy(tree:isLeaf(D))
        assert.truthy(tree:isLeaf(E))
        assert.has_error(function()
            tree:isLeaf()
        end)
        assert.has_error(function()
            tree:isLeaf({})
        end)
    end)

    local function cmpAsStrings(a, b)
        return tostring(a) < tostring(b)
    end

    it("gets leafs", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}
        local C = {3}
        local D = {4}
        local E = {5}
        local tree = Tree {
            [A] = {[B] = {}, [C] = {}},
            [B] = {[D] = {}, [E] = {}},
        }
        -- expected
        local exp = {C, D, E}
        table.sort(exp, cmpAsStrings)
        -- iterator
        local arrayFromIt = require 'treelua.detail.arrayFromIt'
        local leafs = arrayFromIt(tree:iterLeafs())
        table.sort(leafs, cmpAsStrings)
        assert.same(exp, leafs)
        -- list
        local leafs = tree:leafs()
        table.sort(leafs, cmpAsStrings)
        assert.same(exp, leafs)
    end)

    local function mapFromIt(it)
        local map = {}
        for k, v in it do
            map[k] = v
        end
        return map
    end

    it("gets #children of nodes", function()
        local Tree = require 'treelua.Tree'
        local parent = {1}
        local child1 = {2}; local edge1 = {22}
        local child2 = {3}; local edge2 = {23}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
            [child1] = {},
            [child2] = {},
        }
        assert.same({[child1]=edge1, [child2]=edge2},
            mapFromIt(tree:iterChildrenOf(parent)))
        assert.same({}, mapFromIt(tree:iterChildrenOf(child1)))
        assert.same({}, mapFromIt(tree:iterChildrenOf(child2)))
        assert.has_error(function()
            tree:iterChildrenOf()
        end)
        assert.has_error(function()
            tree:iterChildrenOf({})
        end)
    end)

    it("gets children of nodes (larger example)", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}; local edgeB = {22}
        local C = {3}; local edgeC = {23}
        local D = {4}; local edgeD = {24}
        local E = {5}; local edgeE = {25}
        local tree = Tree {
            [A] = {[B] = edgeB, [C] = edgeC},
            [B] = {[D] = edgeD, [E] = edgeE},
        }
        assert.same({[B]=edgeB, [C]=edgeC},
            mapFromIt(tree:iterChildrenOf(A)))
        assert.same({[D]=edgeD, [E]=edgeE},
            mapFromIt(tree:iterChildrenOf(B)))
        assert.same({}, mapFromIt(tree:iterChildrenOf(C)))
        assert.same({}, mapFromIt(tree:iterChildrenOf(D)))
        assert.same({}, mapFromIt(tree:iterChildrenOf(E)))
    end)

    it("gets edges of nodes", function()
        local Tree = require 'treelua.Tree'
        local parent = {}
        local child1 = {}; local edge1 = {}
        local child2 = {}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
            [child1] = {},
            [child2] = {},
        }
        assert.equal(edge1, tree:edge(parent, child1))
        assert.equal(edge1, tree:edge(child1, parent))
        assert.equal(edge2, tree:edge(parent, child2))
        assert.equal(edge2, tree:edge(child2, parent))
    end)

    it("throws in edge() is called with non-nodes", function()
        local Tree = require 'treelua.Tree'
        local parent = {}
        local child1 = {}; local edge1 = {}
        local child2 = {}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
        }
        assert.equal(edge1, tree:edge(parent, child1))
        assert.equal(edge1, tree:edge(child1, parent))
        assert.equal(edge2, tree:edge(parent, child2))
        assert.equal(edge2, tree:edge(child2, parent))
        assert.falsy(tree:edge(child1, child2))
        assert.falsy(tree:edge(child2, child1))
        assert.has_error(function()
            tree:edge(nil, nil)
        end)
        assert.has_error(function()
            tree:edge(child1, nil)
        end)
        assert.has_error(function()
            tree:edge(nil, child1)
        end)
        assert.has_error(function()
            tree:edge(child1, {})
        end)
        assert.has_error(function()
            tree:edge({}, child1)
        end)
        assert.has_error(function()
            tree:edge(nil, {})
        end)
        assert.has_error(function()
            tree:edge({}, nil)
        end)
        assert.has_error(function()
            tree:edge({}, {})
        end)
    end)

    it("gets nodes of tree", function()
        local Tree = require 'treelua.Tree'
        local parent = {1}
        local child1 = {2}; local edge1 = {}
        local child2 = {3}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
            [child1] = {},
            [child2] = {},
        }
        -- expected
        local exp = {parent, child1, child2}
        table.sort(exp, cmpAsStrings)
        -- Method tree:nodes()
        local nodes = tree:nodes()
        table.sort(nodes, cmpAsStrings)
        assert.same(exp, nodes)
        -- Method tree:iterNodes(), iterator
        local arrayFromIt = require 'treelua.detail.arrayFromIt'
        local nodes = arrayFromIt(tree:iterNodes())
        table.sort(nodes, cmpAsStrings)
        assert.same(exp, nodes)
    end)

--[[
     A
    / \
   /   \
  B     C
 / \   / \
D   E F   G
]]

    it("travere depth-first, starting from root", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}; local edgeB = {22}
        local C = {3}; local edgeC = {23}
        local D = {4}; local edgeD = {24}
        local E = {5}; local edgeE = {25}
        local F = {6}; local edgeF = {26}
        local G = {7}; local edgeG = {27}
        local tree = Tree {
            [A] = {[B] = edgeB, [C] = edgeC},
            [B] = {[D] = edgeD, [E] = edgeE},
            [C] = {[F] = edgeF, [G] = edgeG},
        }
        local index_of = {}
        local index = 0
        local info = {}
        for node, level, parent, edge in tree:iterDepth(A) do
            info[node] = {level, parent, edge}
            index_of[node] = index
            index = index + 1
        end
        assert.same({
            [A] = {0},
            [B] = {1, A, edgeB},
            [C] = {1, A, edgeC},
            [D] = {2, B, edgeD},
            [E] = {2, B, edgeE},
            [F] = {2, C, edgeF},
            [G] = {2, C, edgeG},
        }, info)
        assert.equal(0, index_of[A])
        assert.equal(1, math.abs(index_of[D] - index_of[E]))
        assert.equal(1, math.abs(index_of[F] - index_of[G]))
        assert.equal(index_of[B] + 1,
            math.min(index_of[D], index_of[E]))
        assert.equal(index_of[C] + 1,
            math.min(index_of[F], index_of[G]))
        assert.equal(3, math.abs(index_of[B] - index_of[C]))
    end)

--[[
     A
    / \
   /   \
  B     C
 / \   / \
D   E F   G
]]

    it("travere depth-first, starting from leaf", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}; local edgeB = {22}
        local C = {3}; local edgeC = {23}
        local D = {4}; local edgeD = {24}
        local E = {5}; local edgeE = {25}
        local F = {6}; local edgeF = {26}
        local G = {7}; local edgeG = {27}
        local tree = Tree {
            [A] = {[B] = edgeB, [C] = edgeC},
            [B] = {[D] = edgeD, [E] = edgeE},
            [C] = {[F] = edgeF, [G] = edgeG},
        }
        local index = 0
        local info = {}
        for node, level, parent, edge in tree:iterDepth(D) do
            info[node] = {level, parent, edge}
            index = index + 1
        end
        assert.same({
            [D] = {0},
            [B] = {1, D, edgeD},
            [E] = {2, B, edgeE},
            [A] = {2, B, edgeB},
            [C] = {3, A, edgeC},
            [F] = {4, C, edgeF},
            [G] = {4, C, edgeG},
        }, info)
    end)

    it("travere depth-first, starting from middle", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}; local edgeB = {22}
        local C = {3}; local edgeC = {23}
        local D = {4}; local edgeD = {24}
        local E = {5}; local edgeE = {25}
        local F = {6}; local edgeF = {26}
        local G = {7}; local edgeG = {27}
        local tree = Tree {
            [A] = {[B] = edgeB, [C] = edgeC},
            [B] = {[D] = edgeD, [E] = edgeE},
            [C] = {[F] = edgeF, [G] = edgeG},
        }
        local index = 0
        local info = {}
        for node, level, parent, edge in tree:iterDepth(B) do
            info[node] = {level, parent, edge}
            index = index + 1
        end
        assert.same({
            [B] = {0},
            [D] = {1, B, edgeD},
            [E] = {1, B, edgeE},
            [A] = {1, B, edgeB},
            [C] = {2, A, edgeC},
            [F] = {3, C, edgeF},
            [G] = {3, C, edgeG},
        }, info)
    end)

    it("travere breadth-first, starting from root", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}; local edgeB = {22}
        local C = {3}; local edgeC = {23}
        local D = {4}; local edgeD = {24}
        local E = {5}; local edgeE = {25}
        local F = {6}; local edgeF = {26}
        local G = {7}; local edgeG = {27}
        local tree = Tree {
            [A] = {[B] = edgeB, [C] = edgeC},
            [B] = {[D] = edgeD, [E] = edgeE},
            [C] = {[F] = edgeF, [G] = edgeG},
        }
        local index_of = {}
        local index = 0
        local info = {}
        for node, level, parent, edge in tree:iterBreadth(A) do
            info[node] = {level, parent, edge}
            index_of[node] = index
            index = index + 1
        end
        assert.same({
            [A] = {0},
            [B] = {1, A, edgeB},
            [C] = {1, A, edgeC},
            [D] = {2, B, edgeD},
            [E] = {2, B, edgeE},
            [F] = {2, C, edgeF},
            [G] = {2, C, edgeG},
        }, info)
        assert.equal(0, index_of[A])
        assert.equal(1, math.abs(index_of[B] - index_of[C]))
        assert.equal(1, math.min(index_of[D], index_of[E],
            index_of[F], index_of[G]) -
            math.max(index_of[B], index_of[C]))
    end)

    it("travere breadth-first, starting from leaf", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}; local edgeB = {22}
        local C = {3}; local edgeC = {23}
        local D = {4}; local edgeD = {24}
        local E = {5}; local edgeE = {25}
        local F = {6}; local edgeF = {26}
        local G = {7}; local edgeG = {27}
        local tree = Tree {
            [A] = {[B] = edgeB, [C] = edgeC},
            [B] = {[D] = edgeD, [E] = edgeE},
            [C] = {[F] = edgeF, [G] = edgeG},
        }
        local index = 0
        local info = {}
        local prev_level
        for node, level, parent, edge in tree:iterBreadth(D) do
            info[node] = {level, parent, edge}
            index = index + 1
            if prev_level then
                assert.truthy(prev_level <= level)
            end
            prev_level = level
        end
        assert.same({
            [D] = {0},
            [B] = {1, D, edgeD},
            [E] = {2, B, edgeE},
            [A] = {2, B, edgeB},
            [C] = {3, A, edgeC},
            [F] = {4, C, edgeF},
            [G] = {4, C, edgeG},
        }, info)
    end)

    it("travere breadth-first, starting from middle", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}; local edgeB = {22}
        local C = {3}; local edgeC = {23}
        local D = {4}; local edgeD = {24}
        local E = {5}; local edgeE = {25}
        local F = {6}; local edgeF = {26}
        local G = {7}; local edgeG = {27}
        local tree = Tree {
            [A] = {[B] = edgeB, [C] = edgeC},
            [B] = {[D] = edgeD, [E] = edgeE},
            [C] = {[F] = edgeF, [G] = edgeG},
        }
        local index = 0
        local info = {}
        local prev_level
        for node, level, parent, edge in tree:iterBreadth(B) do
            info[node] = {level, parent, edge}
            index = index + 1
            if prev_level then
                assert.truthy(prev_level <= level)
            end
            prev_level = level
        end
        assert.same({
            [B] = {0},
            [D] = {1, B, edgeD},
            [E] = {1, B, edgeE},
            [A] = {1, B, edgeB},
            [C] = {2, A, edgeC},
            [F] = {3, C, edgeF},
            [G] = {3, C, edgeG},
        }, info)
    end)

    it("throws if trying to traverse from non-node", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}
        local tree = Tree {
            [A] = {[B] = {}},
        }
        assert.has_error(function()
            tree:iterBreadth({1})
        end)
    end)

    it("convert to a graph", function()
        local Tree = require 'treelua.Tree'
        local A = {1}
        local B = {2}
        local C = {2}
        local D = {2}
        local tree = Tree {
            [A] = {[B] = {}},
            [B] = {[C] = {}, [D] = {}},
        }
        local graph = tree:toGraph()
        assert.truthy(graph:edge(A, B))
        assert.truthy(graph:edge(B, C))
        assert.truthy(graph:edge(B, D))
        assert.falsy(graph:edge(A, C))
        assert.falsy(graph:edge(A, D))
        assert.falsy(graph:edge(C, D))
    end)
end)
