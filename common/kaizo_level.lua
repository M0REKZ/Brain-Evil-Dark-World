-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

KaizoLevel = {}

function KaizoLevel:new()
    local kaizoLevel = {}
    setmetatable(kaizoLevel, self)
    self.__index = self

    kaizoLevel.objects = {}
    kaizoLevel.world = lovr.physics.newWorld({
        tags = {
            "player",
            "solid",
            "enemy",
            "enemy_nocol", --enemies that dont collide each other
            "decoration",
            "pickup",
        }
    })
    --kaizoLevel.world:disableCollisionBetween("player","enemy")
    kaizoLevel.world:disableCollisionBetween("enemy_nocol","enemy")
    kaizoLevel.world:disableCollisionBetween("decoration","enemy")
    kaizoLevel.world:disableCollisionBetween("decoration","player")
    kaizoLevel.world:disableCollisionBetween("decoration","pickup")
    kaizoLevel.world:disableCollisionBetween("enemy","pickup")
    kaizoLevel.world:disableCollisionBetween("pickup","pickup")
    kaizoLevel.world:disableCollisionBetween("player","pickup")
    kaizoLevel.world:disableCollisionBetween("enemy_nocol","player")
    kaizoLevel.world:disableCollisionBetween("enemy_nocol","pickup")
    kaizoLevel.world:disableCollisionBetween("enemy_nocol","decoration")
    kaizoLevel.world:disableCollisionBetween("enemy_nocol","enemy_nocol")
    kaizoLevel.images = {}
    kaizoLevel.sounds = {}
    kaizoLevel.camera_following_object = nil
    kaizoLevel.is_menu_level = false
    kaizoLevel.death_line_y = -100
    kaizoLevel.music = nil
    kaizoLevel.targets = nil

    return kaizoLevel
end

function KaizoLevel:update(dt)

    self:activate_and_deactivate_objects_not_in_camera()

    BrainEvilLevelLoader:HandleLevelUpdateForDarkWorld(dt)
    for _, object in ipairs(self.objects) do
        if object.sleeping then
            goto continue
        end
        object:preupdate(dt)
        ::continue::
    end
    self.world:update(dt)
    for _, object in ipairs(self.objects) do
        if object.sleeping then
            goto continue
        end
        object:postupdate(dt)
        ::continue::
    end
    self:check_deleted_objects()
end

function KaizoLevel:interpolate(alpha)
    self.world:interpolate(alpha)
end

function KaizoLevel:draw(pass)
    for _, object in ipairs(self.objects) do
        if object.sleeping then
            goto continue
        end

        if not object.invisible then
            object:draw(pass)
        end
        ::continue::
    end
end

function KaizoLevel:activate_and_deactivate_objects_not_in_camera()
    local vec3me = lovr.math.vec3(KaizoCamera.x,KaizoCamera.y,KaizoCamera.z)
    local cx,cy,cz = 0,0,0
    local distance

    for index, object in ipairs(self.objects) do
        if object.always_awake then
            goto continue
        end
        cx,cy,cz =  object.body:getPosition()
        distance = vec3me:distance(cx,cy,cz)
        if distance > 250 then
            self.objects[index].sleeping = true
            self.objects[index].body:setAwake(false)
        elseif object.sleeping then
            self.objects[index].sleeping = false
            self.objects[index].body:setAwake(true)
        end
        ::continue::
    end
end

function KaizoLevel:add_image(image)
    for i = 1, #self.images, 1 do
        if self.images[i].imagePath == image.imagePath then
            return self.images[i]
        end
    end

    self.images[#self.images + 1] = image
    return self.images[#self.images]
end

function KaizoLevel:add_sound(sound)
    for i = 1, #self.sounds, 1 do
        if self.sounds[i].soundPath == sound.soundPath then
            return self.sounds[i]
        end
    end

    self.sounds[#self.sounds + 1] = sound
    return self.sounds[#self.sounds]
end

function KaizoLevel:add_object(object)
    self.objects[#self.objects + 1] = object
end

function KaizoLevel:check_deleted_objects()
    for num = #self.objects, 1, -1 do
        if self.objects[num].marked_for_deletion then
            if self.objects[num].body then
                self.objects[num].body:destroy()
            end
            table.remove(self.objects,num)
        end
    end

    if self.targets then
        for num = #self.targets, 1, -1 do
            if self.targets[num].marked_for_deletion then
                table.remove(self.targets,num)
            end
        end
    end

    if self.camera_following_object and self.camera_following_object.marked_for_deletion then
        if self.camera_following_object.body and not self.camera_following_object.body:isDestroyed() then
            self.camera_following_object.body:destroy()
        end
        self.camera_following_object = nil
    end
end

function KaizoLevel:set_music(music)
    if self.music then
        self.music:stop()
    end
    self.music = nil
    self.music = music
    self.music:play()
end
