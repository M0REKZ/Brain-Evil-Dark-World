-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

KaizoPlayer = {}

function KaizoPlayer:new(x,y,z)
    local kaizoPlayer = {}
    setmetatable(kaizoPlayer, self)
    self.__index = self
    kaizoPlayer.body = MainLevel.world:newCapsuleCollider(x,y,z,0.45,1.45/2)
    kaizoPlayer.body:setTag("player")
    kaizoPlayer.body:setFriction(0)
    kaizoPlayer.body:setLinearDamping(1)
    kaizoPlayer.body:setGravityScale(2)
    kaizoPlayer.textures = {
        stay = MainLevel:add_image(KaizoImage:new("entity_chydia.png")),
        walk1 = MainLevel:add_image(KaizoImage:new("entity_chydia2.png")),
        walk2 = MainLevel:add_image(KaizoImage:new("entity_chydia3.png")),
        run = MainLevel:add_image(KaizoImage:new("entity_chydia_run.png")),
        run2 = MainLevel:add_image(KaizoImage:new("entity_chydia_run2.png")),
        jump = MainLevel:add_image(KaizoImage:new("entity_chydia_jump.png")),
        fall = MainLevel:add_image(KaizoImage:new("entity_chydia_fall.png")),
        hurt = MainLevel:add_image(KaizoImage:new("entity_chydia_damage.png")),
        attack = MainLevel:add_image(KaizoImage:new("entity_chydia_attack1.png")),

        stay_stick = MainLevel:add_image(KaizoImage:new("chydia_stick.png")),
        walk_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_walk1.png")),
        run_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_run1.png")),
        run2_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_run2.png")),
        jump_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_jump.png")),
        fall_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_fall.png")),
        hurt_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_hurt.png")),
        attack_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_attack.png")),
        charge_stick = MainLevel:add_image(KaizoImage:new("chydia_stick_attack_charge.png")),

        arm = MainLevel:add_image(KaizoImage:new("chydia_arm.png")),
        stick = MainLevel:add_image(KaizoImage:new("chydia_arm_stick.png")),
    }
    kaizoPlayer.sounds = {
        jump = MainLevel:add_sound(KaizoSound:new("chydia_jump.mp3")),
        walk = MainLevel:add_sound(KaizoSound:new("chydia_step.mp3")),
        death = MainLevel:add_sound(KaizoSound:new("chydia_hurt.mp3")),
        attack = MainLevel:add_sound(KaizoSound:new("hit_miss.mp3")),
    }
    kaizoPlayer.intended_vel = {x = 0, y = 0, z = 0}
    kaizoPlayer.max_intended_vel = {x = 10, y = 50, z = 10}
    kaizoPlayer.jumped = false
    kaizoPlayer.dirangle = 0
    kaizoPlayer.dirvel = 0
    kaizoPlayer.frame = 0
    kaizoPlayer.frametime = 7
    kaizoPlayer.grounded = false
    kaizoPlayer.walk_sound_delay = 14
    kaizoPlayer.prevhealth = 100
    kaizoPlayer.health = 100
    kaizoPlayer.hurt_frame_time = 0

    kaizoPlayer.frameflip = false

    kaizoPlayer.attack_delay = 0

    kaizoPlayer.waiting_to_release_attack = false
    kaizoPlayer.prevdirkey = -1

    kaizoPlayer.body:setMass(1450)
    kaizoPlayer.body:setOrientation(math.pi/2, 1, 0, 0)

    kaizoPlayer.current_weapon = "hand"
    kaizoPlayer.attack_charge = 0

    return kaizoPlayer
end

function KaizoPlayer:preupdate(dt)

    if not self.handled_checkpoint then
        if KaizoSaveHandler.savedata.saved_checkpoint ~= 0 then
            for index, object in ipairs(MainLevel.objects) do
                if object.is_checkpoint and object.checkpoint_number == KaizoSaveHandler.savedata.saved_checkpoint then
                    local cx, cy, cz = object.body:getPosition()
                    self.body:setPosition(cx, cy, cz)
                    break
                end
            end
        end
        self.handled_checkpoint = true
    end

    self.max_intended_vel.x, self.max_intended_vel.z = 10, 10


    local p_shape = self.body:getShape()
    local x,y,z = self.body:getPosition()
    local angle, ax, ay, az = self.body:getOrientation()
    local velx, vely, velz = self.body:getLinearVelocity()

    local prevangle = self.dirangle
    local prevdirkey = self.prevdirkey

    if y < MainLevel.death_line_y then
        self.marked_for_deletion = true
        self.sounds.death:stop()
        self.sounds.death:play()
        return
    end

    if KaizoInputHandler.weapon_hand then
        self.current_weapon = "hand"
    elseif KaizoSaveHandler.savedata.player_stick >= 0 and KaizoInputHandler.weapon_stick then
        self.current_weapon = "stick"
    end

    if KaizoInputHandler.up or KaizoInputHandler.left or KaizoInputHandler.right or KaizoInputHandler.down then

        if KaizoInputHandler.up and KaizoInputHandler.left then
            self.dirangle = KaizoCamera.anglex - (math.pi + math.pi/4)
            self.prevdirkey = 0
        elseif KaizoInputHandler.up and KaizoInputHandler.right then
            self.dirangle = KaizoCamera.anglex + (math.pi + math.pi/4)
            self.prevdirkey = 1
        elseif KaizoInputHandler.down and KaizoInputHandler.left then
            self.dirangle = KaizoCamera.anglex + math.pi/4
            self.prevdirkey = 2
        elseif KaizoInputHandler.down and KaizoInputHandler.right then
            self.dirangle = KaizoCamera.anglex - math.pi/4
            self.prevdirkey = 3
        elseif KaizoInputHandler.down then
            self.dirangle = KaizoCamera.anglex
            self.prevdirkey = 4
        elseif KaizoInputHandler.up then
            self.dirangle = KaizoCamera.anglex + math.pi
            self.prevdirkey = 5
        elseif KaizoInputHandler.left then
            self.dirangle = KaizoCamera.anglex + math.pi/2
            self.prevdirkey = 6
        elseif KaizoInputHandler.right then
            self.dirangle = KaizoCamera.anglex - math.pi/2
            self.prevdirkey = 7
        end

        if KaizoInputHandler.left then
            self.frameflip = true
        elseif KaizoInputHandler.right then
            self.frameflip = false
        end

        if self.prevdirkey ~= prevdirkey then
            self.dirvel = 0
        end

        if self.dirvel ~= prevangle then
            self.intended_vel.x = 0
            self.intended_vel.z = 0
        end

        if math.abs(self.intended_vel.x) < self.max_intended_vel.x * math.abs(math.cos(self.dirangle)) and math.abs(self.intended_vel.z) < self.max_intended_vel.z * math.abs(math.sin(self.dirangle)) then
            if self.dirvel < self.max_intended_vel.x * 3.7 and self.dirvel < self.max_intended_vel.z * 3.7 then
                self.dirvel = self.dirvel + 10
            end
            
            self.intended_vel.x = self.dirvel * math.cos(self.dirangle)
            self.intended_vel.z = self.dirvel * math.sin(self.dirangle)
        end

    else
        self.intended_vel.x = 0
        self.intended_vel.z = 0
        self.dirvel = 0
    end

    if self.attack_delay > 0 then
        self.attack_delay = self.attack_delay - 1
    elseif KaizoInputHandler.attack and not self.waiting_to_release_attack then
        if self.current_weapon == "stick" then
            if self.attack_charge == 0 then
                self.attack_charge = FPS/3
            end
        else
            self:attack_enemy()
        end
        self.waiting_to_release_attack = true
    elseif not KaizoInputHandler.attack then
        self.waiting_to_release_attack = false
    end

    if self.attack_charge > 0 then
        self.attack_charge = self.attack_charge - 1
        if self.attack_charge == 0 then
            self:attack_enemy()
        end
    end

    if self.intended_vel.y > -5 then
        self.intended_vel.y = self.intended_vel.y - 1
    else
        self.intended_vel.y = 0
    end

    self:check_pickups()

    local ground_hit= MainLevel.world:raycast(x, y, z, x, y - 1, z, "solid")
    if ground_hit then
        self.grounded = true
        self.jumped = false

        if self.intended_vel.y < 0 then
            self.intended_vel.y = 0
            self.body:setLinearVelocity(velx, self.intended_vel.y, velz)
        end

        if KaizoInputHandler.jump then
            self.intended_vel.y = 15
            vely = 15
            self.body:setLinearVelocity(velx, self.intended_vel.y, velz)
            self.jumped = true
            self.sounds.jump:stop()
            self.sounds.jump:play()
        end

        if self.intended_vel.x ~= 0 or self.intended_vel.z ~= 0 then
            if self.walk_sound_delay > 0 then
                self.walk_sound_delay = self.walk_sound_delay - 1
            else
                if math.abs(velx) <= 8 and math.abs(velz) <= 8 then
                    self.walk_sound_delay = 14
                else
                    self.walk_sound_delay = 10
                end
                self.sounds.walk:stop()
                self.sounds.walk:play()
            end
        end
    else
        self.grounded = false
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
        self.body:setLinearVelocity(self.max_intended_vel.x * math.cos(prevangle), vely, self.max_intended_vel.z * math.sin(prevangle))
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
        self.body:setLinearVelocity(self.max_intended_vel.x * math.cos(prevangle), vely, self.max_intended_vel.z * math.sin(prevangle))
    end

    velx, vely, velz = self.body:getLinearVelocity() --update values

    if self.grounded and applyx == 0 and applyz == 0 then
        if velx > 0 then
            if velz > 0 then
                self.body:setLinearVelocity(velx - 0.1, vely, velz - 0.1)
            else
                self.body:setLinearVelocity(velx - 0.1, vely, velz + 0.1)
            end
        else
            if velz > 0 then
                self.body:setLinearVelocity(velx + 0.1, vely, velz - 0.1)
            else
                self.body:setLinearVelocity(velx + 0.1, vely, velz + 0.1)
            end
        end
    end

    self.body:applyLinearImpulse(applyx * 20, applyy * 20, applyz * 20)
    self.body:setAngularVelocity(0,0,0)
    self.body:setOrientation(math.pi/2, 1, 0, 0)
    
end

function KaizoPlayer:check_pickups()
    local x,y,z = self.body:getPosition()
    local found_pickups = {}
    local vec3me
    local distance
    local cx, cy, cz
    for index, object in ipairs(MainLevel.objects) do
        if object.marked_for_deletion then
            goto continue
        end
        if not object.body then
            goto continue
        end

        if object.body:getTag() ~= "pickup" then
            goto continue
        end
        
        vec3me = lovr.math.vec3(x,y,z)
        cx,cy,cz = object.body:getPosition()
        distance = vec3me:distance(cx,cy,cz)

        if distance <= 1 then
            found_pickups[#found_pickups+1] = object
        end

        ::continue::
    end

    for index, pickup in ipairs(found_pickups) do
        pickup:handle_pickup(self)
    end
end

function KaizoPlayer:attack_enemy()
    self.sounds.attack:play()

    local x,y,z = self.body:getPosition()
    if KaizoSaveHandler.config.first_person then
        local attackx, attackz

        if self.current_weapon == "hand" then
            attackx = -math.cos(KaizoCamera.anglex)
            attackz = -math.sin(KaizoCamera.anglex)
        elseif self.current_weapon == "stick" then
            attackx = -math.cos(KaizoCamera.anglex) * 3
            attackz = -math.sin(KaizoCamera.anglex) * 3
        end

        local x,y,z = self.body:getPosition()

        local body = MainLevel.world:raycast(x,y,z,x + attackx, y, z + attackz, "enemy enemy_nocol")

        if body then
            local enemy = nil
            for index, object in ipairs(MainLevel.objects) do
                if object.marked_for_deletion then
                    goto continue
                end
                if object.body ~= body then
                    goto continue
                end

                enemy = object

                ::continue::
            end
            if enemy then
                if self.current_weapon == "hand" then
                    enemy.health = enemy.health - 1
                elseif self.current_weapon == "stick" then
                    enemy.health = enemy.health - 5
                end
            end
        end
    else
        local found_enemies = {}
        local vec3me
        local distance
        local cx, cy, cz

        local closest_distance = 999999
        local closest_enemy = nil

        local required_distance

        if self.current_weapon == "hand" then
            required_distance = 1
        elseif self.current_weapon == "stick" then
            required_distance = 3
        end

        for index, object in ipairs(MainLevel.objects) do
            if object.marked_for_deletion then
                goto continue
            end
            if not object.body then
                goto continue
            end

            if string.sub(object.body:getTag(), 1, #"enemy") ~= "enemy" then
                goto continue
            end
            
            vec3me = lovr.math.vec3(x,y,z)
            cx,cy,cz = object.body:getPosition()
            distance = vec3me:distance(cx,cy,cz)

            if distance <= required_distance then
                found_enemies[#found_enemies+1] = object
                if distance <= closest_distance then
                    closest_distance = distance
                    closest_enemy = object
                end
            end

            ::continue::
        end

        if closest_enemy then
            if self.current_weapon == "hand" then
                closest_enemy.health = closest_enemy.health - 1
            elseif self.current_weapon == "stick" then
                closest_enemy.health = closest_enemy.health - 5
            end
        end
    end

    self.attack_delay = FPS/5
end

function KaizoPlayer:postupdate(dt)

    if self.health <= 0 then
        self.marked_for_deletion = true
        self.sounds.death:play()
    end

    if self.prevhealth > self.health then
        self.sounds.death:play()
        self.hurt_frame_time = FPS/4
    end

    local velx, vely, velz = self.body:getLinearVelocity()

    if self.attack_delay > 0 then
        self.frame = 9
    elseif self.hurt_frame_time > 0 then
        self.frame = 8
        self.hurt_frame_time = self.hurt_frame_time - 1
    elseif not self.grounded and vely > 0 then
        self.frame = 6
    elseif not self.grounded and vely < 0 then
        self.frame = 7
    elseif self.intended_vel.x ~= 0 or self.intended_vel.z ~= 0 then

        if math.abs(velx) <= 8 * math.cos(self.dirangle) and math.abs(velz) <= 8 * math.sin(self.dirangle) then
            if self.frametime >= 0 then
                self.frametime = self.frametime - 1
            end

            if self.frametime < 0 then
                self.frametime = 7
                self.frame = self.frame + 1
            end

            if self.frame >= 4 then
                self.frame = 0
            end
        else
            if self.frametime >= 0 then
                self.frametime = self.frametime - 1
            end

            if self.frametime < 0 then
                self.frametime = 3
                self.frame = self.frame + 1
            end

            if self.frame >= 6 then
                self.frame = 4
            end

            if self.frame < 4 then
                self.frame = 4
            end
        end
    else
        self.frame = 0
    end

    self.prevhealth = self.health

    if MainLevel.exit_pos then
        local vec3exit = lovr.math.vec3(MainLevel.exit_pos.x,MainLevel.exit_pos.y,MainLevel.exit_pos.z)
        local x,y,z = self.body:getPosition()
        local distance = vec3exit:distance(x,y,z)
        if distance < MainLevel.exit_distance then
            BrainEvilLevelLoader:HandleExitTouch()
        end
    end
end

function KaizoPlayer:draw(pass)
    if KaizoSaveHandler.config.first_person then
        if not KaizoPauseHandler.active then
            Set2DPass(pass,true)

            local width, height = lovr.system.getWindowDimensions()
            local proportion = (width/512)

            local arm_y_offset = 0
            local arm_x_offset = 0

            if self.frame == 1 or self.frame == 4 then
                arm_y_offset = -2
            elseif self.frame == 3 or self.frame == 5 then
                arm_y_offset = 2
            elseif self.frame == 9 then
                arm_y_offset = 20
                arm_x_offset = 20
            end

            if self.current_weapon == "stick" then
                if self.attack_charge > 0 then
                    arm_y_offset = 30
                    arm_x_offset = arm_x_offset-40
                end

                pass:setMaterial(self.textures.stick.texture)
                if self.frame == 9 then
                    pass:plane(width - (220 + arm_x_offset) * proportion, height - (160 + arm_y_offset) * proportion, 0, 160 * proportion, 160 * proportion)
                else
                    pass:plane(width - (110 + arm_x_offset) * proportion, height - (160 + arm_y_offset) * proportion, 0, 160 * proportion, -160 * proportion)
                end
            end

            pass:setMaterial(self.textures.arm.texture)
            pass:plane(width - (120 + arm_x_offset) * proportion, height - (60 + arm_y_offset) * proportion, 0, 160 * proportion, -160 * proportion)
            pass:setMaterial()

            Set2DPass(pass,false)
        end
    else
        self:draw_body(pass)
        --local angle, ax, ay, az = self.body:getOrientation()
        --pass:box(x,y,z, 1, 1.45, 1, angle, ax, ay, az)
    end

    self:draw_hud(pass)
end

function KaizoPlayer:draw_body(pass)
    local x, y, z = self.body:getPosition()
    if self.current_weapon == "hand" then
        if self.frame == 0 or self.frame == 2 then
            self.textures.stay:draw_billboard(pass, x, y, z, nil, self.frameflip)
        elseif self.frame == 1 then
            self.textures.walk1:draw_billboard(pass, x, y, z, nil, self.frameflip)
        elseif self.frame == 3 then
            self.textures.walk2:draw_billboard(pass, x, y, z, nil, self.frameflip)
        elseif self.frame == 4 then
            self.textures.run:draw_billboard(pass, x, y, z, 1.2, self.frameflip)
        elseif self.frame == 5 then
            self.textures.run2:draw_billboard(pass, x, y, z, 1.2, self.frameflip)
        elseif self.frame == 6 then
            self.textures.jump:draw_billboard(pass, x, y, z, nil, self.frameflip)
        elseif self.frame == 7 then
            self.textures.fall:draw_billboard(pass, x, y, z, 1.2, self.frameflip)
        elseif self.frame == 8 then
            self.textures.hurt:draw_billboard(pass, x, y, z, 1.2, self.frameflip)
        elseif self.frame == 9 then
            self.textures.attack:draw_billboard(pass, x, y, z, 1.2, self.frameflip)
        end
    elseif self.current_weapon == "stick" then
        if self.attack_charge > 0 then
            self.textures.charge_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 0 or self.frame == 2 then
            self.textures.stay_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 1 or self.frame == 3 then
            self.textures.walk_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 4 then
            self.textures.run_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 5 then
            self.textures.run2_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 6 then
            self.textures.jump_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 7 then
            self.textures.fall_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 8 then
            self.textures.hurt_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        elseif self.frame == 9 then
            self.textures.attack_stick:draw_billboard(pass, x, y, z, 2.727, self.frameflip)
        end
    end
end

function KaizoPlayer:draw_hud(pass)
    if KaizoPauseHandler.active then
        return
    end

    local width, height = lovr.system.getWindowDimensions()
    local proportion = (width/512)
    Set2DPass(pass,true)
    pass:setColor(.15, .15, .17)
    pass:plane(width/2, height-25 * proportion, 0, width, 50 * proportion)
    pass:setColor(1, 1, 1)
    SetTextShader(pass)
    pass:text("Health",width/12, height-30 * proportion, 0,25 * proportion)
    if MainLevel.targets then
        pass:text("Targets",width/4, height-30 * proportion, 0,25 * proportion)
        pass:text(tostring(#MainLevel.targets),width/4, height-12 * proportion, 0,25 * proportion)
    end
    pass:text("Chydia",width/2, height-20 * proportion, 0,50 * proportion)
    pass:text("Weapon",width - width/12, height-30 * proportion, 0,25 * proportion)
    pass:text(self.current_weapon,width - width/12, height-12 * proportion, 0,25 * proportion)
    SetGameShader(pass)
    pass:setColor(1, 0, 0)
    pass:plane(width/12, height-18 * proportion, 0, 70 * proportion, 10 * proportion)
    pass:setColor(0, 1, 0)
    pass:plane(width/12 - ((70-(70*(math.max(self.health,0)/100)))/2) * proportion, height-18 * proportion, 0, 70*(self.health/100) * proportion, 10 * proportion)
    pass:setColor(1, 1, 1)
    Set2DPass(pass,false)
end
