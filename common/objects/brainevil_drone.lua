-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

BrainEvilDrone = {}

function BrainEvilDrone:new(x,y,z)
    local kaizoBot = {}
    setmetatable(kaizoBot, self)
    self.__index = self

    kaizoBot.body = MainLevel.world:newBoxCollider(x,y,z,1,1,1)
    kaizoBot.body:setTag("enemy_nocol")
    kaizoBot.body:setFriction(1)
    kaizoBot.body:setLinearDamping(1)
    kaizoBot.body:setGravityScale(2)
    kaizoBot.textures = {
        stay = MainLevel:add_image(KaizoImage:new("entity_drone.png")),
        walk1 = MainLevel:add_image(KaizoImage:new("entity_drone_walk1.png")),
        walk2 = MainLevel:add_image(KaizoImage:new("entity_drone_walk2.png")),
        walk3 = MainLevel:add_image(KaizoImage:new("entity_drone_walk3.png")),
        attack = MainLevel:add_image(KaizoImage:new("entity_drone_attack.png")),
        attack2 = MainLevel:add_image(KaizoImage:new("entity_drone_attack2.png")),
        attack3 = MainLevel:add_image(KaizoImage:new("entity_drone_attack3.png")),
    }
    kaizoBot.sounds = {
        slice = MainLevel:add_sound(KaizoSound:new("slice.mp3")),
        hurt = MainLevel:add_sound(KaizoSound:new("metal_hit.wav")),
    }
    kaizoBot.intended_vel = {x = 0, y = 0, z = 0}
    kaizoBot.max_intended_vel = {x = 30, y = 50, z = 30}
    kaizoBot.dirangle = 0
    kaizoBot.dirvel = 0
    kaizoBot.frame = 0
    kaizoBot.frametime = 7
    kaizoBot.walk_sound_delay = 14
    kaizoBot.attack = false
    kaizoBot.attack_delay = FPS/7
    kaizoBot.jump_delay = FPS

    kaizoBot.detected_player = nil

    kaizoBot.health = 3
    kaizoBot.prevhealth = 3

    return kaizoBot
end

function BrainEvilDrone:preupdate(dt)

    local x,y,z = self.body:getPosition()
    if y < MainLevel.death_line_y then
        self.marked_for_deletion = true
        return
    end

    if self.health <= 0 then
        self.sounds.hurt:stop()
        self.sounds.hurt:play()
        self.marked_for_deletion = true
        return
    end

    if self.health < self.prevhealth then
        self.sounds.hurt:stop()
        self.sounds.hurt:play()
    end

    self.detected_player = nil

    for index, object in ipairs(MainLevel.objects) do

        if object.marked_for_deletion then
            goto continue
        end

        if not object.body then
            goto continue
        end

        if object.body:getTag() == "player" then
            self.detected_player  = object
            break
        end

        ::continue::
    end

    local p_shape = self.body:getShape()
    local angle, ax, ay, az = self.body:getOrientation()
    local velx, vely, velz = self.body:getLinearVelocity()
    if self.detected_player then
        local px, py, pz = self.detected_player.body:getPosition()
        local vec3me = lovr.math.vec3(x,y,z)
        local distance = vec3me:distance(px,py,pz)

        local attackdistance = 1
        if self.jump_delay == -1 then
            attackdistance = 2
        end

        if distance < 30 and distance > attackdistance then
                
            self.attack = false

            local prevangle = self.dirangle
            
            self.dirangle = math.atan2(pz-z,px-x)

            if self.dirvel ~= prevangle then
                self.intended_vel.x = 0
                self.intended_vel.z = 0
            end

            if math.abs(self.intended_vel.x) < self.max_intended_vel.x * math.abs(math.cos(self.dirangle)) and math.abs(self.intended_vel.z) < self.max_intended_vel.z * math.abs(math.sin(self.dirangle)) then
                if self.dirvel < self.max_intended_vel.x and self.dirvel < self.max_intended_vel.z then
                    self.dirvel = self.dirvel + 2
                end
                
                self.intended_vel.x = self.dirvel * math.cos(self.dirangle)
                self.intended_vel.z = self.dirvel * math.sin(self.dirangle)
            end
        else
            if distance <= attackdistance then
                self.attack = true
                self.dirangle = math.atan2(pz-z,px-x)
            else
                self.attack = false
            end
            self.jump_delay = FPS
            self.intended_vel.x = 0
            self.intended_vel.z = 0
            self.dirvel = 0
        end

    else
        self.jump_delay = FPS
        self.attack = false
        self.intended_vel.x = 0
        self.intended_vel.z = 0
        self.dirvel = 0
    end

    if self.intended_vel.y > -5 then
        self.intended_vel.y = self.intended_vel.y - 1
    else
        self.intended_vel.y = 0
    end

    local ground_hit= MainLevel.world:raycast(x, y, z, x, y - 0.5, z, "solid")
    if ground_hit then

        if self.intended_vel.y < 0 then
            self.intended_vel.y = 0
            self.body:setLinearVelocity(velx, self.intended_vel.y, velz)
            if self.jump_delay == -1 then
                self.jump_delay = FPS
            end
        end
    end

    if self.jump_delay > 0 then
        self.jump_delay = self.jump_delay - 1
    elseif self.jump_delay == 0 then
        self.jump_delay = -1
        if self.detected_player then
            local px, py, pz = self.detected_player.body:getPosition()
            self.intended_vel.y = (py - y)*3
            print(self.intended_vel.y)
            if self.intended_vel.y < 5 then
                self.intended_vel.y = 5
            elseif self.intended_vel.y > 15 then
                self.intended_vel.y = 15
            end
        else
            self.intended_vel.y = 5
        end
        self.body:setLinearVelocity(velx, self.intended_vel.y, velz)
    end

    local wallhitx = nil
    
    if self.intended_vel.x < 0 then
        wallhitx = MainLevel.world:raycast(x, y, z, x - 1, y, z, "solid")
    elseif self.intended_vel.x > 0 then
        wallhitx = MainLevel.world:raycast(x, y, z, x + 1, y, z, "solid")
    end

    if wallhitx then
        self.intended_vel.x = 0
    end

    local wallhitz = nil
    
    if self.intended_vel.z < 0 then
        wallhitz = MainLevel.world:raycast(x, y, z, x, y, z - 1, "solid")
    elseif self.intended_vel.z > 0 then
        wallhitz = MainLevel.world:raycast(x, y, z, x, y, z + 1, "solid")
    end

    if wallhitz then
        self.intended_vel.z = 0
    end

    local applyx, applyy, applyz = self.intended_vel.x, self.intended_vel.y, self.intended_vel.z
    if math.abs(velx) > self.max_intended_vel.x then
        applyx = self.max_intended_vel.x
        if velx > 0 then
            self.body:setLinearVelocity(self.max_intended_vel.x, vely, velz)
        else
            self.body:setLinearVelocity(-self.max_intended_vel.x, vely, velz)
        end
    end
    if math.abs(vely) > self.max_intended_vel.y then
        applyy = self.max_intended_vel.y
        if vely > 0 then
            self.body:setLinearVelocity(velx, self.max_intended_vel.y, velz)
        else
            self.body:setLinearVelocity(velx, -self.max_intended_vel.y, velz)
        end
    end
    if math.abs(velz) > self.max_intended_vel.z then
        applyz = self.max_intended_vel.z
        if velz > 0 then
            self.body:setLinearVelocity(velx, vely, self.max_intended_vel.z)
        else
            self.body:setLinearVelocity(velx, vely, -self.max_intended_vel.z)
        end
    end
    self.body:applyLinearImpulse(applyx * 20, applyy * 20, applyz * 20)
    self.body:setAngularVelocity(0,0,0)
    self.body:setOrientation(0, 0, 0, 0)
    
end

function BrainEvilDrone:postupdate(dt)
    local velx, vely, velz = self.body:getLinearVelocity()

    if self.attack and self.attack_delay > 0 then
        self.attack_delay = self.attack_delay - 1
    elseif not self.attack then
        if self.jump_delay == -1 then
            self.attack_delay = -1
        else
            self.attack_delay = FPS/7
        end
    end

    if self.attack_delay <= 0 then
        self:attack_player()
    end

    if self.jump_delay == -1 then
        self.frame = 7
    elseif self.attack then
        if self.frametime >= 0 then
            self.frametime = self.frametime - 1
        end

        if self.frametime < 0 then
            self.frametime = 10
            self.frame = self.frame + 1
        end

        if self.frame < 5 or self.frame >= 7 then
            self.frame = 5
        end

    elseif self.intended_vel.x ~= 0 or self.intended_vel.z ~= 0 then
        if self.frametime >= 0 then
            self.frametime = self.frametime - 1
        end

        if self.frametime < 0 then
            self.frametime = 5
            self.frame = self.frame + 1
        end

        if self.frame >= 5 then
            self.frame = 1
        end
    else
        self.frame = 0
    end

    if self.attack_delay <= 0 then
        self.attack_delay = FPS/4
    end

    self.prevhealth = self.health
end

function BrainEvilDrone:attack_player()

    if not self.detected_player then
        return
    end

    if self.detected_player and self.detected_player.marked_for_deletion then
        return
    end

    local x,y,z = self.body:getPosition()

    local vec3me = lovr.math.vec3(x,y,z)
    local cx,cy,cz = self.detected_player.body:getPosition()
    local distance = vec3me:distance(cx,cy,cz)

    if distance <= 2 then
        self.sounds.slice:stop()
        self.sounds.slice:play()
        self.detected_player.health = self.detected_player.health - 5
    end
end

function BrainEvilDrone:draw(pass)
    local x,y,z = self.body:getPosition()

    if self.frame == 0 then
        self.textures.stay:draw_billboard(pass,x,y,z,2)
    elseif self.frame == 1 then
        self.textures.walk1:draw_billboard(pass,x,y,z,2)
    elseif self.frame == 2 or self.frame == 4 then
        self.textures.walk2:draw_billboard(pass,x,y,z,2)
    elseif self.frame == 3 then
        self.textures.walk3:draw_billboard(pass,x,y,z,2)
    elseif self.frame == 5 then
        self.textures.attack2:draw_billboard(pass,x,y,z,2)
    elseif self.frame == 6 then
        self.textures.attack3:draw_billboard(pass,x,y,z,2)
    elseif self.frame == 7 then
        self.textures.attack:draw_billboard(pass,x,y,z,2)
    end
    --local angle, ax, ay, az = self.body:getOrientation()
    --pass:box(x,y,z, 1, 1.45, 1, angle, ax, ay, az)
end

