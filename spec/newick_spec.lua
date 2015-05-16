-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("tree.fromNewick and tree.toNewick", function()
    it("serializes a tree to Newick format", function()
        local Tree = require 'tree.Tree'
        local parent = {}
        local child1 = {name='A'}; local edge1 = {}
        local child2 = {name='B'}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
        }
        local toNewick = require 'tree.toNewick'
        local newick = toNewick(tree)
        assert.truthy(newick == '(A,B);' or newick == '(B,A);')
    end)

    it("respects names of clades", function()
        local Tree = require 'tree.Tree'
        local parent = {name='r'}
        local child1 = {name='A'}; local edge1 = {}
        local child2 = {name='B'}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
        }
        local toNewick = require 'tree.toNewick'
        local newick = toNewick(tree)
        assert.truthy(newick == '(A,B)r;' or
            newick == '(B,A)r;')
    end)

    it("respects length of edges", function()
        local Tree = require 'tree.Tree'
        local parent = {}
        local child1 = {name='A'}; local edge1 = {length=2}
        local child2 = {name='B'}; local edge2 = {length=3}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
        }
        local toNewick = require 'tree.toNewick'
        local newick = toNewick(tree)
        assert.truthy(newick == '(A:2,B:3);' or
            newick == '(B:3,A:2);')
    end)

    it("throws an error if leafs do not have names", function()
        local Tree = require 'tree.Tree'
        local parent = {}
        local child1 = {}; local edge1 = {}
        local child2 = {}; local edge2 = {}
        local tree = Tree {
            [parent] = {[child1] = edge1, [child2] = edge2},
            [child1] = {},
            [child2] = {},
        }
        local toNewick = require 'tree.toNewick'
        assert.has_error(function()
            local newick = toNewick(tree)
        end)
    end)

    it("parses a tree from Newick format", function()
        local fromNewick = require 'tree.fromNewick'
        local tree = fromNewick '(A,B);'
        assert.equal(3, #tree:nodes())
        assert.equal(2, #tree:leafs())
        local leafs = tree:leafs()
        local a = leafs[1].name
        local b = leafs[2].name
        assert.truthy(a == 'A' or a == 'B')
        assert.truthy(b == 'A' or b == 'B')
    end)

--[[
    A
   / \
  B   C
 / \
D   E
]]

    it("serializes and parses a complex tree", function()
        local Tree = require 'tree.Tree'
        local A = {}
        local B = {}
        local C = {name='C'}
        local D = {name='D'}
        local E = {name='E'}
        local tree = Tree {
            [A] = {[B] = {length=1}, [C] = {length=2}},
            [B] = {[D] = {length=3}, [E] = {length=4}},
        }
        --
        local toNewick = require 'tree.toNewick'
        local newick = toNewick(tree)
        assert.truthy(newick:match('%):1'))
        assert.truthy(newick:match('C:2'))
        assert.truthy(newick:match('D:3'))
        assert.truthy(newick:match('E:4'))
        --
        local fromNewick = require 'tree.fromNewick'
        local tree2 = fromNewick(newick)
        assert.equal(5, #tree2:nodes())
        assert.equal(3, #tree2:leafs())
    end)

    it("serializes and parses a complex tree (same leafs)",
    function()
        local Tree = require 'tree.Tree'
        local A = {name='A'}
        local B = {name='B'}
        local C = {name='C'}
        local D = {name='D'}
        local E = {name='E'}
        local tree = Tree {
            [A] = {[B] = {length=1}, [C] = {length=2}},
            [B] = {[D] = {length=3}, [E] = {length=4}},
        }
        --
        local toNewick = require 'tree.toNewick'
        local newick = toNewick(tree)
        assert.truthy(newick:match('%)B:1'))
        assert.truthy(newick:match('C:2'))
        assert.truthy(newick:match('D:3'))
        assert.truthy(newick:match('E:4'))
        --
        local fromNewick = require 'tree.fromNewick'
        local leafs = {C, D, E}
        local tree2 = fromNewick(newick, leafs)
        assert.equal(5, #tree2:nodes())
        assert.equal(3, #tree2:leafs())
        assert.truthy(tree2:isLeaf(C))
        assert.truthy(tree2:isLeaf(D))
        assert.truthy(tree2:isLeaf(E))
        assert.falsy(tree2:isNode(A))
        assert.falsy(tree2:isNode(B))
        local A2 = tree2:parentOf(C)
        local B2 = tree2:parentOf(D)
        assert.equal(A2, tree2:parentOf(B2))
        assert.equal(B2, tree2:parentOf(E))
        assert.equal(1, tree2:edge(A2, B2).length)
        assert.equal(2, tree2:edge(A2, C).length)
        assert.equal(3, tree2:edge(B2, D).length)
        assert.equal(4, tree2:edge(B2, E).length)
    end)
end)
