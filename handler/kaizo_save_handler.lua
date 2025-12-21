-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

require "handler.kaizo_json_handler"

KaizoSaveHandler = {}

KaizoSaveHandler.config = {}
KaizoSaveHandler.config_name = "config.json"
KaizoSaveHandler.savedata = {}
KaizoSaveHandler.savedata_name = "save.json"

KaizoSaveHandler.config.key_up = nil
KaizoSaveHandler.config.key_down = nil
KaizoSaveHandler.config.key_left = nil
KaizoSaveHandler.config.key_right = nil
KaizoSaveHandler.config.key_jump = nil
KaizoSaveHandler.config.key_weapon_hand = nil
KaizoSaveHandler.config.key_weapon_stick = nil
KaizoSaveHandler.config.fullscreen = true
KaizoSaveHandler.config.volume = nil
KaizoSaveHandler.config.first_person = nil
KaizoSaveHandler.config.key_first_person = nil
KaizoSaveHandler.config.invert_mouse = false

KaizoSaveHandler.savedata.saved_level = nil
KaizoSaveHandler.savedata.saved_checkpoint = nil
KaizoSaveHandler.savedata.player_stick = nil

function KaizoSaveHandler:Init()
    self:InitConfig()
    self:InitSaveData()
end

function KaizoSaveHandler:InitConfig()
    self:LoadConfig()
    self.config.key_up = self.config.key_up or "w"
    self.config.key_down = self.config.key_down or "s"
    self.config.key_left = self.config.key_left or "a"
    self.config.key_right = self.config.key_right or "d"
    self.config.key_jump = self.config.key_jump or "space"
    --self.config.key_weapon_hand = self.config.key_weapon_hand or "1"
    --self.config.key_weapon_stick = self.config.key_weapon_stick or "2"

    self.config.volume = self.config.volume or 0.5
    self.config.first_person = self.config.first_person or false
    --self.config.key_first_person = self.config.key_first_person or "f"
    self.config.invert_mouse = self.config.invert_mouse or false
end

function KaizoSaveHandler:InitSaveData()
    self:LoadSaveData()
    self.savedata.saved_level = self.savedata.saved_level or 1
    self.savedata.saved_checkpoint = self.savedata.saved_checkpoint or 0
    self.savedata.player_stick = self.savedata.player_stick or -1
end

function KaizoSaveHandler:SaveConfig()
    local configjson = KaizoJSONHandler:ToJSON(KaizoSaveHandler.config)
    return lovr.filesystem.write(self.config_name, configjson)
end

function KaizoSaveHandler:SaveSaveData()
    local savejson = KaizoJSONHandler:ToJSON(KaizoSaveHandler.savedata)
    return lovr.filesystem.write(self.savedata_name, savejson)
end

function KaizoSaveHandler:LoadConfig()
    local configjson = lovr.filesystem.read(self.config_name)
    if not configjson then
        return nil
    end
    self.config = KaizoJSONHandler:FromJSON(configjson)
end

function KaizoSaveHandler:LoadSaveData()
    local savejson = lovr.filesystem.read(self.savedata_name)
    if not savejson then
        return nil
    end
    self.savedata = KaizoJSONHandler:FromJSON(savejson)
end

function KaizoSaveHandler:ConfigExists()
    return lovr.filesystem.isFile(self.config_name)
end

function KaizoSaveHandler:SaveExists()
    return lovr.filesystem.isFile(self.savedata_name)
end
