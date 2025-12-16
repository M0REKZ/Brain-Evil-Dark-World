-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

function lovr.conf(t)
    t.identity = "BrainEvilDarkWorld"
    t.saveprecedence = true
    t.modules.headset = false
    t.window.width = 512
    t.window.height = 256 + 128
    t.window.resizable = true
    t.window.title = "Brain Evil: Dark World"
    t.graphics.vsync = false
    t.window.resizable = true
    t.window.icon = "data/images/icon.png"
end

