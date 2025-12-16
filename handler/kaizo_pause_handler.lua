-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

require "common.kaizo_helper"

KaizoPauseHandler = {}

KaizoPauseHandler.active = false
KaizoPauseHandler.waiting_for_release_key = false

KaizoPauseHandler.menu_selected_option = 1
KaizoPauseHandler.menu_waiting_for_release_key = false
KaizoPauseHandler.menu_options = {}

KaizoPauseHandler.was_menu_level = false
KaizoPauseHandler.prevmenu_section = -1
KaizoPauseHandler.menu_section = 0

KaizoPauseHandler.cursor_img = KaizoImage:new("cursor.png")
KaizoPauseHandler.logo_img = KaizoImage:new("bedw_logo.png")


KaizoPauseHandler.keyboard = {}
KaizoPauseHandler.keyboard.binding_key = false
KaizoPauseHandler.keyboard.binding_key_number = 1
KaizoPauseHandler.keyboard.key_names = {
    "jump",
    "up",
    "down",
    "left",
    "right",
}

local proportion = 1
local width, height = 512,256+128
local center = {x = width/2, y = height/2}

function KaizoPauseHandler:init(section)
    KaizoPauseHandler.menu_options = nil
    KaizoPauseHandler.menu_selected_option = 1
    if section == 1 then --options
        KaizoPauseHandler.menu_options = {
            "Keyboard",
            "", --volume
            "Fullscreen",
            "Save Changes",
        }
    elseif section == 2 then
        KaizoPauseHandler.menu_options = {
            "", --key to bind
            "Go Back To Options"
        }
    else
        if MainLevel and MainLevel.is_menu_level then
            KaizoPauseHandler.menu_options = {
                "Continue",
                "New Game",
                "Options",
                "Exit",
            }
        else
            KaizoPauseHandler.menu_options = {
                "Resume",
                "Retry",
                "Options",
                "Main Menu",
            }
        end
    end
end

-- return true is pause the world
function KaizoPauseHandler:update()
    width, height = lovr.system.getWindowDimensions()
    center = {x = width/2, y = height/2}
    proportion = (width/512)
    if MainLevel.is_menu_level then
        KaizoPauseHandler.active = true --always active in menu
        return false
    elseif KaizoPauseHandler.active then
        return true
    end
    KaizoPauseHandler.menu_selected_option = 1 --reset option when closed
    return false
end

function KaizoPauseHandler:draw(pass)
    if not self.active then
        return
    end

    Set2DPass(pass, true)

    --pass:setColor(1, 1, 1)
    --pass:text('Click me!', button.x, button.y, 0, 10)
    
    if self.prevmenu_section ~= self.menu_section or (MainLevel and self.was_menu_level ~= MainLevel.is_menu_level) then
        self:init(self.menu_section)
        self.prevmenu_section = self.menu_section
        self.was_menu_level = MainLevel.is_menu_level
    end

    if MainLevel.is_menu_level then
        pass:setMaterial(self.logo_img.texture)
        pass:plane(center.x, (height / 8) * 2, 0, 128 * 3.03 * proportion, -128 * proportion)
        pass:setMaterial()
    end

    if self.menu_section == 0 then
        if MainLevel.is_menu_level then
            self:do_main_menu(pass)
        else
            self:do_pause_menu(pass)
        end
    elseif self.menu_section == 1 then
        self:do_options(pass)
    elseif self.menu_section == 2 then
        self:do_key_bind(pass)
    end

    Set2DPass(pass,false)
    
end

function KaizoPauseHandler:do_pause_menu(pass)

    SetTextShader(pass)
    for index, name in ipairs(self.menu_options) do
        pass:text(name, center.x, (height / 8) * (3 + index), 0, 50 * proportion)
    end

    SetGameShader(pass)

    pass:setMaterial(self.cursor_img.texture)
    pass:plane(center.x - 120 * proportion, (height / 8) * (2.75 + self.menu_selected_option), 0, 32 * proportion, 32 * proportion)
    pass:setMaterial()

    local selected = self:menu_input()
    if selected then
        self:handle_menu_option(selected)
    end

end

function KaizoPauseHandler:do_main_menu(pass)

    SetTextShader(pass)
    for index, name in ipairs(self.menu_options) do
        pass:text(name, center.x, (height / 8) * (3 + index), 0, 50 * proportion)
    end

    SetGameShader(pass)

    pass:setMaterial(self.cursor_img.texture)
    pass:plane(center.x - 120 * proportion, (height / 8) * (2.75 + self.menu_selected_option), 0, 32 * proportion, 32 * proportion)
    pass:setMaterial()

    local selected = self:menu_input()
    if selected then
        self:handle_menu_option(selected)
    end

end

function KaizoPauseHandler:do_options(pass)

    SetTextShader(pass)
    for index, name in ipairs(self.menu_options) do
        if KaizoSaveHandler.config.fullscreen and name == "Fullscreen" then
            self.menu_options[index] = "Windowed"
        elseif not KaizoSaveHandler.config.fullscreen and name == "Windowed" then
            self.menu_options[index] = "Fullscreen"
        end

        if index == 2 then -- volume
            self.menu_options[index] = "Volume: "..KaizoSaveHandler.config.volume*100
        end

        pass:text(name, center.x, (height / 8) * (3 + index), 0, 50 * proportion)
    end

    SetGameShader(pass)

    pass:setMaterial(self.cursor_img.texture)
    pass:plane(center.x - 140 * proportion, (height / 8) * (2.75 + self.menu_selected_option), 0, 32 * proportion, 32 * proportion)
    pass:setMaterial()

    if not self.menu_waiting_for_release_key then
            if KaizoInputHandler.menu_left then
                self.menu_waiting_for_release_key = true
                KaizoSaveHandler.config.volume = KaizoSaveHandler.config.volume - 0.01
                if KaizoSaveHandler.config.volume < 0 then
                    KaizoSaveHandler.config.volume = 0
                end
                lovr.audio.setVolume(KaizoSaveHandler.config.volume)
            elseif KaizoInputHandler.menu_right then
                self.menu_waiting_for_release_key = true
                KaizoSaveHandler.config.volume = KaizoSaveHandler.config.volume + 0.01
                if KaizoSaveHandler.config.volume > 1 then
                    KaizoSaveHandler.config.volume = 1
                end
                lovr.audio.setVolume(KaizoSaveHandler.config.volume)
            end
        end

    local selected = self:menu_input()

    if selected then
        self:handle_menu_option(selected)
    end
end

function KaizoPauseHandler:do_key_bind(pass)

    if not self.keyboard.binding_key then
        self.menu_options[1] = "< "..KaizoSaveHandler.config["key_"..self.keyboard.key_names[self.keyboard.binding_key_number]] .." is for "..self.keyboard.key_names[self.keyboard.binding_key_number].." >"
    else
        self.menu_options[1] = "Binding key for "..self.keyboard.key_names[self.keyboard.binding_key_number]
    end

    SetTextShader(pass)
    for index, name in ipairs(self.menu_options) do
        pass:text(name, center.x, (height / 8) * (3 + index), 0, 50 * proportion)
    end

    SetGameShader(pass)

    pass:setMaterial(self.cursor_img.texture)
    pass:plane(center.x - 230 * proportion, (height / 8) * (2.75 + self.menu_selected_option), 0, 32 * proportion, 32 * proportion)
    pass:setMaterial()

    if not self.keyboard.binding_key then

        if not self.menu_waiting_for_release_key then
            if KaizoInputHandler.menu_left then
                self.menu_waiting_for_release_key = true
                self.keyboard.binding_key_number = self.keyboard.binding_key_number - 1
                if self.keyboard.binding_key_number <= 0 then
                    self.keyboard.binding_key_number = #self.keyboard.key_names
                end
            elseif KaizoInputHandler.menu_right then
                self.menu_waiting_for_release_key = true
                self.keyboard.binding_key_number = self.keyboard.binding_key_number + 1
                if self.keyboard.binding_key_number > #self.keyboard.key_names then
                    self.keyboard.binding_key_number = 1
                end
            end
        end

        local selected = self:menu_input()

        if selected then
            self:handle_menu_option(selected)
        end
    else
        self:handle_key_binding("key_"..self.keyboard.key_names[self.keyboard.binding_key_number])
    end
end

function KaizoPauseHandler:menu_input()
    if not self.menu_waiting_for_release_key then
        if KaizoInputHandler.menu_up then
            self.menu_waiting_for_release_key = true
            self.menu_selected_option = self.menu_selected_option - 1
            if self.menu_selected_option <= 0 then
                self.menu_selected_option = #self.menu_options
            end
        elseif KaizoInputHandler.menu_down then
            self.menu_waiting_for_release_key = true
            self.menu_selected_option = self.menu_selected_option + 1
            if self.menu_selected_option > #self.menu_options then
                self.menu_selected_option = 1
            end
        elseif KaizoInputHandler.menu_selected then
            self.menu_waiting_for_release_key = true
            return self.menu_options[self.menu_selected_option]
        end
    elseif not KaizoInputHandler.menu_down and not KaizoInputHandler.menu_left and not KaizoInputHandler.menu_right and not KaizoInputHandler.menu_up and not KaizoInputHandler.menu_selected then
        self.menu_waiting_for_release_key = false
    end

    return nil
end

function KaizoPauseHandler:handle_key_binding(key_id)
    if not self.menu_waiting_for_release_key then
        if KaizoInputHandler.last_key_pressed and KaizoInputHandler.last_key_pressed ~= "up" and KaizoInputHandler ~= "down" and KaizoInputHandler ~= "left" and KaizoInputHandler ~= "right" and KaizoInputHandler ~= "return" then
            self.keyboard.binding_key = false
            KaizoSaveHandler.config[key_id] = KaizoInputHandler.last_key_pressed
        end
    elseif not KaizoInputHandler.menu_down and not KaizoInputHandler.menu_left and not KaizoInputHandler.menu_right and not KaizoInputHandler.menu_up and not KaizoInputHandler.menu_selected then
        self.menu_waiting_for_release_key = false
        KaizoInputHandler.last_key_pressed = nil --clear last key pressed
    end
end

function KaizoPauseHandler:handle_menu_option(name)
    if name == "Exit" then
        lovr.event.quit()
        return
    end

    --menu
    if name == "New Game" then
        self.active = false
        BrainEvilLevelLoader:LoadFirstLevel()
        return
    elseif name == "Continue" then
        self.active = false
        if KaizoSaveHandler:SaveExists() then
            BrainEvilLevelLoader:LoadSavedLevel()
        else
            BrainEvilLevelLoader:LoadFirstLevel()
        end
        return
    elseif name == "Options" then
        self.menu_section = 1
        return
    end

    --pause
    if name == "Resume" then
        self.active = false
        return
    elseif name == "Retry" then
        BrainEvilLevelLoader:LoadSavedLevel()
        self.active = false
        return
    elseif name == "Main Menu" then
        BrainEvilLevelLoader:LoadMenuLevel()
        KaizoSaveHandler:SaveSaveData()
        return
    end

    --options
    if name == "Keyboard" then
        self.menu_section = 2
        return
    elseif name == "Fullscreen" then
        SetFullscreen()
        return
    elseif name == "Windowed" then
        SetWindowed()
        return
    elseif name == "Save Changes" then
        self.menu_section = 0
        KaizoSaveHandler:SaveConfig()
        return
    end

    --keyboard
    if name == "Go Back To Options" then
        self.menu_section = 1
        return
    else
        self.keyboard.binding_key = true
        return
    end
end
