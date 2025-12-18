-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

require "common.objects.kaizo_checkpoint"
require "common.objects.brainevil_killerbot"

BrainEvilLevelLoader = {}

function BrainEvilLevelLoader:LoadMenuLevel()
    if MainLevel and MainLevel.music then
        MainLevel.music:stop()
    end
    MainLevel = nil

    MainLevel = KaizoLevel:new()
    MainLevel.is_menu_level = true
    local cube = BrainEvilKillerBot:new(1,0,1)
    MainLevel.camera_following_object = cube
    cube.body:setGravityScale(0)
    cube.body:setKinematic(true)
    cube.invisible = true
    MainLevel:add_object(cube)
    local map = KaizoMap:new('menumap.obj', 0,-10,0,"bedw","menu")
    MainLevel:add_object(map)
    MainLevel:set_music(KaizoSound:new("music_destroyer.mp3", true))
end

function BrainEvilLevelLoader:LoadFirstLevel()
    --[[if MainLevel and MainLevel.music then
        MainLevel.music:stop()
    end
    MainLevel = nil

    local floorimg = KaizoImage:new("floor_dirt_bw.png")
    local robotimg = KaizoImage:new("floor_robot_dark.png")

    MainLevel = KaizoLevel:new()
    --MainLevel.is_menu_level = true
    local xo = KaizoPlayer:new(0,1,-2)
    MainLevel.camera_following_object = xo
    MainLevel:add_object(xo)
    local cube = KaizoCube:new(1,1,1,1,1,1)
    cube.img = floorimg
    MainLevel:add_object(cube)
    MainLevel:add_object(BrainEvilKillerBot:new(2,2,2))
    MainLevel:add_object(BrainEvilKillerBot:new(30,2,-10))
    MainLevel:add_object(BrainEvilDrone:new(35,2,-15))
    local map = KaizoMap:new('testmap.obj', 0,-10,0)
    
    map.img = MainLevel:add_image(robotimg)
    MainLevel:add_object(map)]]
    KaizoSaveHandler.savedata.saved_level = 1
    KaizoSaveHandler.savedata.saved_checkpoint = 0
    KaizoSaveHandler.savedata.player_stick = -1
    KaizoMovieHandler:PlayMovie("tutorial")
    self:LoadSpecificLevel(1)
end

function BrainEvilLevelLoader:LoadSavedLevel()
    if MainLevel and MainLevel.music then
        MainLevel.music:stop()
    end
    MainLevel = nil
    self:LoadSpecificLevel(KaizoSaveHandler.savedata.saved_level)
end

function BrainEvilLevelLoader:LoadSpecificLevel(id)
    if id == 0 then
        self:LoadMenuLevel()
        return
    end

    if MainLevel and MainLevel.music then
        MainLevel.music:stop()
    end
    MainLevel = nil

    MainLevel = KaizoLevel:new()

    local map = KaizoMap:new("Map.glb", 0,0,0,"bedw",""..id)

    MainLevel:add_object(map)
    
    local objname = nil
    local x,y,z
    local a = nil
    for i = 1, map.model.model:getNodeCount(), 1 do
        objname = map.model.model:getNodeName(i)
        if not objname then
            goto continue
        end
        
        a = string.find(objname, ".", nil, true)

        if a then
            objname = string.sub(objname,1,a-1)
        end

        --print(objname)

        if objname and _G[objname] and _G[objname].new then
            x,y,z = map.model.model:getNodePosition(i)
            local obj = _G[objname]:new(x,y,z)
            if objname == "KaizoPlayer" then
                MainLevel.camera_following_object = obj
            end

            self:HandleLevelObjectForDarkWorld(id, obj, objname)
            MainLevel:add_object(obj)
        end

        self:HandleLevelNodeForDarkWorld(id, i, objname, map)
        ::continue::
    end

    if lovr.filesystem.isFile("levels/bedw/"..id.."/Decoration.glb") then
        local deco = KaizoMap:new("Decoration.glb", 0,0,0,"bedw",""..id)
        deco.body:setTag("decoration")
        MainLevel:add_object(deco)
    end

    if id == 1 then
        MainLevel:set_music(KaizoSound:new("music_wind.mp3", true))
        MainLevel.death_line_y = -40
    elseif id == 2 then
        MainLevel:set_music(KaizoSound:new("music_consumed.mp3", true))
        MainLevel.death_line_y = -40
    end
end

function BrainEvilLevelLoader:HandleLevelObjectForDarkWorld(id, obj, objname)
    if id == 1 then
        if not MainLevel.level_1_door_enemies then
            MainLevel.level_1_door_enemies = {}
        end

        if not MainLevel.targets then
            MainLevel.targets = {}
        end
        if objname == "BrainEvilDrone" then
            MainLevel.level_1_door_enemies[#MainLevel.level_1_door_enemies+1] = obj
        end

        if objname == "BrainEvilVictim" then
            MainLevel.targets[#MainLevel.targets+1] = obj
            obj.boy = 2 --force girl in this level
        end
    end
end

function BrainEvilLevelLoader:HandleLevelNodeForDarkWorld(id, nodeid, objname, map)
    --level specific
    if id == 1 then
        if objname == "EndDoor" then
            local x,y,z = map.model.model:getNodePosition(nodeid)
            local door = KaizoCube:new(x,y,z, 0.1,30,30)
            door.body:setGravityScale(0)
            door.body:setKinematic(true)
            door.img = KaizoImage:new("wall_red_square.png")
            door.level_1_name = "enddoor"
            MainLevel:add_object(door)
        end

        if objname == "Checkpoint1" then
            local x,y,z = map.model.model:getNodePosition(nodeid)
            local checkpoint = KaizoCheckpoint:new(x,y,z)
            checkpoint.checkpoint_number = 1
            MainLevel:add_object(checkpoint)
        end
    elseif id == 2 then

        if not MainLevel.level_2_door_1_enemies then
            MainLevel.level_2_door_1_enemies = {}
        end

        if objname == "Door1KillerBot" then
            local x,y,z = map.model.model:getNodePosition(nodeid)
            local bot = BrainEvilKillerBot:new(x,y,z)
            MainLevel.level_2_door_1_enemies[#MainLevel.level_2_door_1_enemies+1] = bot
            MainLevel:add_object(bot)
        end

        if objname == "Checkpoint1" then
            local x,y,z = map.model.model:getNodePosition(nodeid)
            local checkpoint = KaizoCheckpoint:new(x,y,z)
            checkpoint.checkpoint_number = 1
            MainLevel:add_object(checkpoint)
        end

        if objname == "Checkpoint2" then
            local x,y,z = map.model.model:getNodePosition(nodeid)
            local checkpoint = KaizoCheckpoint:new(x,y,z)
            checkpoint.checkpoint_number = 2
            MainLevel:add_object(checkpoint)
        end

        if objname == "Exit" then
            local x,y,z = map.model.model:getNodePosition(nodeid)
            MainLevel.exit_pos = {x = x, y = y, z = z}
            MainLevel.exit_distance = 7
        end

        if objname == "Door1" then
            local x,y,z = map.model.model:getNodePosition(nodeid)
            local door = KaizoCube:new(x,y,z, 30,30,0.1)
            door.body:setGravityScale(0)
            door.body:setKinematic(true)
            door.img = KaizoImage:new("wall_red_square.png")
            door.level_2_name = "door1"
            MainLevel:add_object(door)
        end
    end

    --global
    if objname == "BrainEvilSawBot" then
        local x,y,z = map.model.model:getNodePosition(nodeid)
        local bot = BrainEvilKillerBot:new(x,y,z)
        bot:set_class(1)
        MainLevel:add_object(bot)
    elseif objname == "BrainEvilShootBot" then
        local x,y,z = map.model.model:getNodePosition(nodeid)
        local bot = BrainEvilKillerBot:new(x,y,z)
        bot:set_class(2)
        MainLevel:add_object(bot)
    end
end

function BrainEvilLevelLoader:HandleLevelUpdateForDarkWorld(dt)
    if KaizoSaveHandler.savedata.saved_level == 1 then
        if MainLevel.level_1_door_enemies then
            for num = #MainLevel.level_1_door_enemies, 1, -1 do
                if MainLevel.level_1_door_enemies[num].marked_for_deletion then
                    table.remove(MainLevel.level_1_door_enemies,num)
                end
            end

            if #MainLevel.level_1_door_enemies == 0 and not MainLevel.level_1_door_open then
                for index, obj in ipairs(MainLevel.objects) do
                    if obj.level_1_name == "enddoor" then
                        obj.marked_for_deletion = true
                        MainLevel.level_1_door_open = true
                        break
                    end
                end
            end
        end
    elseif KaizoSaveHandler.savedata.saved_level == 2 then
        if MainLevel.level_2_door_1_enemies then
            for num = #MainLevel.level_2_door_1_enemies, 1, -1 do
                if MainLevel.level_2_door_1_enemies[num].marked_for_deletion then
                    table.remove(MainLevel.level_2_door_1_enemies,num)
                end
            end

            if #MainLevel.level_2_door_1_enemies == 0 and not MainLevel.level_2_door_1_open then
                for index, obj in ipairs(MainLevel.objects) do
                    if obj.level_2_name == "door1" then
                        obj.marked_for_deletion = true
                        MainLevel.level_2_door_1_open = true
                        break
                    end
                end
            end
        end
    end
end

function BrainEvilLevelLoader:HandleLevelNoMoreTargets()
    if KaizoSaveHandler.savedata.saved_level == 1 then
        KaizoSaveHandler.savedata.saved_level = 2
        KaizoSaveHandler.savedata.saved_checkpoint = 0
        self:LoadSpecificLevel(2)
        return
    end
end

function BrainEvilLevelLoader:HandleExitTouch()
    if KaizoSaveHandler.savedata.saved_level == 2 then
        KaizoSaveHandler.savedata.saved_level = 3
        KaizoSaveHandler.savedata.saved_checkpoint = 0
        self:LoadSpecificLevel(3)
    end
end
