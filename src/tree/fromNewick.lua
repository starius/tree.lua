-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

--[[
https://en.wikipedia.org/wiki/Newick_format#Grammar

The grammar nodes
=================

Tree: The full input Newick Format for a single tree
Subtree: an internal node (and its descendants) or a leaf node
Leaf: a node with no descendants
Internal: a node and its one or more descendants
BranchSet: a set of one or more Branches
Branch: a tree edge and its descendant subtree.
Name: the name of a node
Length: the length of a tree edge.

The grammar rules
=================

Note, "|" separates alternatives.

    Tree --> Subtree ";" | Branch ";"
    Subtree --> Leaf | Internal
    Leaf --> Name
    Internal --> "(" BranchSet ")" Name
    BranchSet --> Branch | BranchSet "," Branch
    Branch --> Subtree Length
    Name --> empty | string
    Length --> empty | ":" number

Whitespace (spaces, tabs, carriage returns, and linefeeds)
within number is prohibited. Whitespace within string is
often prohibited. Whitespace elsewhere is ignored.
Sometimes the Name string must be of a specified fixed
length; otherwise the punctuation characters from the
grammar (semicolon, parentheses, comma, and colon) are
prohibited.
]]

return function(text, leafs)
    local lpeg = require 'lpeg'
    local V, R, S, L = lpeg.V, lpeg.R, lpeg.S, lpeg.locale()

    local rules = {
        "Tree",
        Tree = (V("Subtree") + V("Branch")) * ";",
        Subtree = V("Leaf") + V("Internal"),
        Leaf = V("Name"),
        Internal = "(" * V("BranchSet") * ")" * V("Name")^-1,
        BranchSet = V("Branch") * ("," * V("BranchSet")) ^ -1,
        Branch = V("Subtree") * V("Length")^-1,
        Name = (1 - S(";,():"))^1,
        Length = (":" * L.digit^1 * ("." * L.digit^1)^-1),
    }

    rules.Name = lpeg.Cg(rules.Name, "name")
    rules.Length = lpeg.Cg(rules.Length, "length")
    rules.Branch = lpeg.Ct(rules.Branch)
    rules.Tree = lpeg.Ct(rules.Tree)

    rules = lpeg.P(rules)

    text = text:gsub('%s', '')
    local raw = assert(rules:match(text), "Can't parse Newick")

--[[
    Example:

    rules:match('(A:0.1,B:0.2,(C,D:0.4):0.5);')

    {
      {
        name = "A",
        length = ":0.1",
      },
      {
        name = "B",
        length = ":0.2",
      },
      {
        {
          name = "C",
        },
        {
          name = "D",
          length = ":0.4",
        },
        length = ":0.5",
      },
    }
]]

    local name2leaf = {}
    if leafs then
        for _, leaf in ipairs(leafs) do
            name2leaf[leaf.name] = leaf
        end
    end

    local children_of = {}

    local function fromNewick(raw_node)
        local name = raw_node.name
        local node = name2leaf[name] or {name = name}
        children_of[node] = {}
        for _, raw_child in ipairs(raw_node) do
            local child = fromNewick(raw_child)
            local length = raw_child.length
            -- remove ":"
            length = length and tonumber(length:sub(2))
            local edge = {length = length}
            children_of[node][child] = edge
        end
        return node
    end

    fromNewick(raw)
    local Tree = require 'tree.Tree'
    return Tree(children_of)
end
