-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return {
    Graph = require 'tree.Graph',
    Tree = require 'tree.Tree',
    breadthFirst = require 'tree.breadthFirst',
    depthFirst = require 'tree.depthFirst',
    newNeighbours = require 'tree.newNeighbours',
    toNewick = require 'tree.toNewick',
    fromNewick = require 'tree.fromNewick',
    compat = require 'tree.compat',
}
