


BrainEvilKillerBot = {}

function BrainEvilKillerBot:new(x,y,z)
    local kaizoBot = {}
    setmetatable(kaizoBot, self)
    self.__index = self

    kaizoBot.body = MainLevel.world:newCapsuleCollider(x,y,z,0.5,1)
    kaizoBot.body:setTag("enemy")
    kaizoBot.body:setFriction(1)
    kaizoBot.body:setLinearDamping(1)
    kaizoBot.body:setGravityScale(2)
    kaizoBot.intended_vel = {x = 0, y = 0, z = 0}
    kaizoBot.max_intended_vel = {x = 50, y = 50, z = 50}
    kaizoBot.dirangle = 0
    kaizoBot.dirvel = 0
    kaizoBot.frame = 0
    kaizoBot.frametime = 7
    kaizoBot.walk_sound_delay = 14
    kaizoBot.attack = false
    kaizoBot.attack_delay = FPS/4
    kaizoBot.dont_slide = false
    kaizoBot.slope_smart = false

    kaizoBot.detected_player = nil

    kaizoBot.prevhealth = 5

    kaizoBot.class = nil

    kaizoBot.body:setMass(1700.0001220703)
    kaizoBot.body:setOrientation(math.pi/2, 1, 0, 0)

    return kaizoBot
end

function BrainEvilKillerBot:set_class(class)
    self.class = class
    if class == 0 then -- normal killer bot
        self.health = 5
        self.attack_delay = FPS/4
        self.textures = {
            stay = MainLevel:add_image(KaizoImage:new("entity_killerbot.png")),
            walk1 = MainLevel:add_image(KaizoImage:new("entity_killerbot_walk1.png")),
            walk2 = MainLevel:add_image(KaizoImage:new("entity_killerbot_walk2.png")),
            attack1 = MainLevel:add_image(KaizoImage:new("entity_killerbot_attack1.png")),
            attack2 = MainLevel:add_image(KaizoImage:new("entity_killerbot_attack2.png")),
        }
        self.sounds = {
            slice = MainLevel:add_sound(KaizoSound:new("slice.mp3")),
            hurt = MainLevel:add_sound(KaizoSound:new("metal_hit.wav")),
        }
    elseif class == 1 then -- saw bot
        self.max_intended_vel = {x = 45, y = 50, z = 45} --slower
        self.health = 10
        self.attack_delay = 1
        self.textures = {
            stay = MainLevel:add_image(KaizoImage:new("entity_sawbot.png")),
            walk1 = MainLevel:add_image(KaizoImage:new("entity_sawbot_walk1.png")),
            walk2 = MainLevel:add_image(KaizoImage:new("entity_sawbot_walk2.png")),
            attack1 = MainLevel:add_image(KaizoImage:new("entity_sawbot_attack1.png")),
            attack2 = MainLevel:add_image(KaizoImage:new("entity_sawbot_attack2.png")),
        }
        self.sounds = {
            slice = MainLevel:add_sound(KaizoSound:new("saw.mp3")),
            hurt = MainLevel:add_sound(KaizoSound:new("metal_hit.wav")),
        }
        self.dont_slide = true
        self.slope_smart = true
    end
end

function BrainEvilKillerBot:preupdate(dt)

    if not self.class then
        self:set_class(0)
    end

    local x,y,z = self.body:getPosition()
    if y < MainLevel.death_line_y then
        self.marked_for_deletion = true
        self.sounds.slice:stop()
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
        if distance < 30 and distance > 1 then
                
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
            if distance <= 1 then
                if not self.attack and self.class == 1 then
                    self:attack_player()
                    self.sounds.slice:stop()
                    self.sounds.slice:play()
                end
                self.attack = true
                self.dirangle = math.atan2(pz-z,px-x)
            else
                self.attack = false
            end
            self.intended_vel.x = 0
            self.intended_vel.z = 0
            self.dirvel = 0
        end

    else
        self.attack = false
        self.intended_vel.x = 0
        self.intended_vel.z = 0
        self.dirvel = 0
    end

    if not self.attack then
        if self.class == 1 then
            self.attack_delay = 0
        else
            self.attack_delay = FPS/4
        end
    end

    if self.intended_vel.y > -5 then
        self.intended_vel.y = self.intended_vel.y - 1
    else
        self.intended_vel.y = 0
    end

    local ground_hit= MainLevel.world:raycast(x, y, z, x, y - 1, z, "solid")
    if ground_hit then

        if self.intended_vel.y < 0 then
            self.intended_vel.y = 0
            self.body:setLinearVelocity(velx, self.intended_vel.y, velz)
        end
    end

    local wallhitx = nil
    local floorhitx = nil
    
    if self.intended_vel.x < 0 then
        wallhitx = MainLevel.world:raycast(x, y, z, x - 1, y, z, "solid")
        if self.slope_smart then
            floorhitx = MainLevel.world:raycast(x, y, z, x - 1, y - 1, z, "solid")
        end
    elseif self.intended_vel.x > 0 then
        wallhitx = MainLevel.world:raycast(x, y, z, x + 1, y, z, "solid")
        if self.slope_smart then
            floorhitx = MainLevel.world:raycast(x, y, z, x + 1, y - 1, z, "solid")
        end
    end

    if wallhitx or (self.slope_smart and not floorhitx) then
        self.intended_vel.x = 0
    end

    local wallhitz = nil
    local floorhitz = nil
    
    if self.intended_vel.z < 0 then
        wallhitz = MainLevel.world:raycast(x, y, z, x, y, z - 1, "solid")
        if self.slope_smart then
            floorhitz = MainLevel.world:raycast(x, y, z, x, y - 1, z - 1, "solid")
        end
    elseif self.intended_vel.z > 0 then
        wallhitz = MainLevel.world:raycast(x, y, z, x, y, z + 1, "solid")
        if self.slope_smart then
            floorhitz = MainLevel.world:raycast(x, y, z, x, y - 1, z + 1, "solid")
        end
    end

    if wallhitz or (self.slope_smart and not floorhitz) then
        self.intended_vel.z = 0
    end

    local applyx, applyy, applyz = self.intended_vel.x, self.intended_vel.y, self.intended_vel.z
    if self.dont_slide and applyx == 0 and applyz == 0 then
        self.body:setLinearVelocity(0, vely, 0)
    end
    if math.abs(velx) > self.max_intended_vel.x then
        applyx = self.max_intended_vel.x
        if velx > 0 then
            if self.dont_slide then
                self.body:setLinearVelocity(self.max_intended_vel.x, vely, self.max_intended_vel.z * math.sin(self.dirangle))
            else
                self.body:setLinearVelocity(self.max_intended_vel.x, vely, velz)
            end
        else
            if self.dont_slide then
                self.body:setLinearVelocity(-self.max_intended_vel.x, vely, self.max_intended_vel.z * math.sin(self.dirangle))
            else
                self.body:setLinearVelocity(-self.max_intended_vel.x, vely, velz)
            end
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
            if self.dont_slide then
                self.body:setLinearVelocity(self.max_intended_vel.x * math.cos(self.dirangle), vely, self.max_intended_vel.z)
            else
                self.body:setLinearVelocity(velx, vely, self.max_intended_vel.z)
            end
        else
            if self.dont_slide then
                self.body:setLinearVelocity(self.max_intended_vel.x * math.cos(self.dirangle), vely, -self.max_intended_vel.z)
            else
                self.body:setLinearVelocity(velx, vely, -self.max_intended_vel.z)
            end
        end
    end
    self.body:applyLinearImpulse(applyx * 20, applyy * 20, applyz * 20)
    self.body:setAngularVelocity(0,0,0)
    self.body:setOrientation(math.pi/2, 1, 0, 0)
    
end

function BrainEvilKillerBot:postupdate(dt)
    if not self.class then
        return
    end

    local velx, vely, velz = self.body:getLinearVelocity()

    if self.attack and self.attack_delay > 0 then
        self.attack_delay = self.attack_delay - 1
    elseif not self.attack then
        if self.class == 0 then
            self.attack_delay = FPS/4
        elseif self.class == 1 then
            self.attack_delay = 0
        end
    end

    if self.attack and self.attack_delay == 0 then
        if self.frametime >= 0 then
            self.frametime = self.frametime - 1
        end

        if self.frametime < 0 then
            if self.class == 1 then
                self.frametime = 5
            else
                self.frametime = 14
            end
            self.frame = self.frame + 1
            self:attack_player()
        end

        if self.frame < 3 or self.frame >= 5 then
            self.frame = 3
            self.sounds.slice:stop()
            self.sounds.slice:play()
        end

    elseif self.intended_vel.x ~= 0 or self.intended_vel.z ~= 0 then
        if self.frametime >= 0 then
            self.frametime = self.frametime - 1
        end

        if self.frametime < 0 then
            self.frametime = 14
            self.frame = self.frame + 1
        end

        if self.frame >= 3 then
            self.frame = 1
        end
    else
        self.frame = 0
    end

    self.prevhealth = self.health
end

function BrainEvilKillerBot:attack_player()

    if not self.detected_player then
        return
    end

    if self.detected_player and self.detected_player.marked_for_deletion then
        return
    end

    if self.class == 0 then

        local attackx = math.cos(self.dirangle)
        local attackz = math.sin(self.dirangle)

        local x,y,z = self.body:getPosition()

        local playerbody = MainLevel.world:raycast(x,y,z,x + attackx, y, z + attackz, "player")

        if playerbody then
            self.detected_player.health = self.detected_player.health - 5
        end
    elseif self.class == 1 then
        local x,y,z = self.body:getPosition()

        local vec3me = lovr.math.vec3(x,y,z)
        local cx,cy,cz = self.detected_player.body:getPosition()
        local distance = vec3me:distance(cx,cy,cz)

        if distance <= 1 then
            self.detected_player.health = self.detected_player.health - 7
        end
    end
end

function BrainEvilKillerBot:draw(pass)
    if not self.class then
        return
    end

    local x,y,z = self.body:getPosition()

    if self.frame == 0 then
        self.textures.stay:draw_billboard(pass,x,y,z,1.45)
    elseif self.frame == 1 then
        self.textures.walk1:draw_billboard(pass,x,y,z,1.45)
    elseif self.frame == 2 then
        self.textures.walk2:draw_billboard(pass,x,y,z,1.45)
    elseif self.frame == 3 then
        self.textures.attack1:draw_billboard(pass,x,y,z,1.45)
    elseif self.frame == 4 then
        self.textures.attack2:draw_billboard(pass,x,y,z,1.45)
    end
    --local angle, ax, ay, az = self.body:getOrientation()
    --pass:box(x,y,z, 1, 1.45, 1, angle, ax, ay, az)
end

