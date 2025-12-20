-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

require "handler.kaizo_save_handler"

KaizoInputHandler = {}

KaizoInputHandler.up = false
KaizoInputHandler.down = false
KaizoInputHandler.left = false
KaizoInputHandler.right = false
KaizoInputHandler.jump = false
KaizoInputHandler.action = false
KaizoInputHandler.attack = false
KaizoInputHandler.weapon_hand = false
KaizoInputHandler.weapon_stick = false

KaizoInputHandler.pause = false
KaizoInputHandler.menu_up = false
KaizoInputHandler.menu_down = false
KaizoInputHandler.menu_left = false
KaizoInputHandler.menu_right = false
KaizoInputHandler.menu_selected = false

KaizoInputHandler.last_key_pressed = nil

local pressing_first_person = false

function KaizoInputHandler:handle_input()
    
    if lovr.system.isKeyDown("escape") then
        self.pause = true
    else
        self.pause = false
    end

    if lovr.system.isKeyDown(KaizoSaveHandler.config.key_up) then
        self.up = true
    else
        self.up = false
    end

    if lovr.system.isKeyDown(KaizoSaveHandler.config.key_down) then
        self.down = true
    else
        self.down = false
    end

    if lovr.system.isKeyDown(KaizoSaveHandler.config.key_left) then
        self.left = true
    else
        self.left = false
    end

    if lovr.system.isKeyDown(KaizoSaveHandler.config.key_right) then
        self.right = true
    else
        self.right = false
    end

    if lovr.system.isKeyDown(KaizoSaveHandler.config.key_jump) then
        self.jump = true
    else
        self.jump = false
    end

    if lovr.system.isMouseDown(2) then
        self.action = true
    else
        self.action = false
    end

    if lovr.system.isMouseDown(1) then
        self.attack = true
    else
        self.attack = false
    end

    --menu

    if lovr.system.isKeyDown("up") then
        self.menu_up = true
    else
        self.menu_up = false
    end

    if lovr.system.isKeyDown("down") then
        self.menu_down = true
    else
        self.menu_down = false
    end

    if lovr.system.isKeyDown("left") then
        self.menu_left = true
    else
        self.menu_left = false
    end

    if lovr.system.isKeyDown("right") then
        self.menu_right = true
    else
        self.menu_right = false
    end

    if lovr.system.isKeyDown("return") then
        self.menu_selected = true
    else
        self.menu_selected = false
    end

end
