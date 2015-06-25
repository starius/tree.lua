#!/usr/bin/env lua

-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local T = require 'tree'

local newick = io.read('*all')
local tree = T.fromNewick(newick)
local graph = tree:toGraph()
local dot = T.toDot(graph)
print(dot)
