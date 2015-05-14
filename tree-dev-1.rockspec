-- tree.lua, Lua representation of trees with edge lengths
-- Copyright (C) 2015 Boris Nagaev
-- See the LICENSE file for terms of use.

package = "tree"
version = "dev-1"
source = {
    url = "git://github.com/starius/tree.lua.git"
}
description = {
    summary = "Lua representation of trees with edge lengths",
    homepage = "https://github.com/starius/tree.lua",
    license = "MIT",
}
dependencies = {
    "lua >= 5.1",
    "lpeg",
}
build = {
    type = "builtin",
    modules = {
        ['tree'] = 'src/tree/init.lua',
        ['tree.Graph'] = 'src/tree/Graph.lua',
        ['tree.Tree'] = 'src/tree/Tree.lua',
        ['tree.breadthFirst'] = 'src/tree/breadthFirst.lua',
        ['tree.depthFirst'] = 'src/tree/depthFirst.lua',
        ['tree.newNeighbours'] = 'src/tree/newNeighbours.lua',
        ['tree.toNewick'] = 'src/tree/toNewick.lua',
        ['tree.fromNewick'] = 'src/tree/fromNewick.lua',
        ['tree.compat'] = 'src/tree/compat.lua',
    },
}
