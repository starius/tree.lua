-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("tree.detail.compat", function()
    it("unpacks a table to mutiple result values", function()
        local unpack = require 'treelua.detail.compat'.unpack
        local a, b = unpack({1, 2})
        assert.equal(1, a)
        assert.equal(2, b)
    end)
end)
