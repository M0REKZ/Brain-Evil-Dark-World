-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

require "common.kaizo_ffi_binds"

function lovr.conf(t)
    t.identity = "BrainEvilDarkWorld"
    t.saveprecedence = true
    t.modules.headset = false
    local x, y, w, h = GetMonitorArea()
    t.window.width = w --512
    t.window.height = h --256 + 128
    t.window.fullscreen = true
    t.window.resizable = true
    t.window.title = "Brain Evil: Dark World"
    t.graphics.vsync = false
    t.window.resizable = true
    t.window.icon = "data/images/icon.png"
end

